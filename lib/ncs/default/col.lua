local Body = {}
function Body:on_init(shape, ...)
	if type(shape) == "string" then
		shape = self.node
			:get_parent_with_component("collisionworld")
			:get_component("collisionworld").world
			:create(shape, ...)
	end
	self.shape = shape
	self.pmat = lib.Matrix3();
end

function Body:on_transform()
	self.shape:transform_mat(self.pmat);
	local mat = self.node:get_mat();
	self.shape:transform_mat(mat)
	self.pmat:copy(mat)
	self.pmat:inverse();
	-- print("WOW")
	-- self.ptransform:transform_shape_inv(self.shape);
	-- self.node:transform_shape(self.shape)
	-- self.ptransform:copy(transform);
end

register_component("collisionbody", Body)

local World = {}

function World:on_init(cellsize)
	self.world = lib.HC.new(cellsize)
end

function World:on_update(dt)

end

function World:on_draw()
	love.graphics.setColor(0, 255, 0, 140)
	for s in pairs(self.world.hash:shapes()) do
		s:draw('line')
	end
end

function World:get_neighbors(shape)
	if type(shape) == "string" then
		return self:get_neighbors(self.node:get_path(shape))
	elseif shape._i_am_a_node then
		return self:get_neighbors(shape:get_component("collisionbody"))
	elseif shape._i_am_a_body then
		return self:get_neighbors(shape.shape)
	end
	return self.world:neighbors(shape)
end

function World:get_collisions(shape)
	if type(shape) == "string" then
		return self:get_collisions(self.node:get_path(shape))
	elseif shape._i_am_a_node then
		return self:get_collisions(shape:get_component("collisionbody"))
	elseif shape._i_am_a_body then
		return self:get_collisions(shape.shape)
	end
	return self.world:collisions(shape)
end
register_component("collisionworld", World)
