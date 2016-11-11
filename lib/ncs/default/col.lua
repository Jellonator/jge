local Body = {}
function Body:on_init(shape, ...)
	if type(shape) == "string" then
		self.world = self.node
			:get_parent_with_component("collisionworld")
			:get_component("collisionworld").world
		shape = self.world:create(shape, ...)
	end
	self.shape = shape
	self.pmat = lib.Matrix3();
end

function Body:_move_node(x, y)
	self.node.transform:translate(x, y);
end

--[[ MOVEMENT FUNCTIONS ]]
-- Move by (x,y) if that position is free; most basic form of movement
function Body:move_try(x, y, can_resolve)
	local can_resolve = try_or(can_resolve, true)
	self.shape:move(x, y);
	local col, ret = self.world:collisions(self.shape);
	local cx, cy = x, y
	if ret then
		-- correct direction if collision
		local sx,sy,count = 0,0,0
		for _, sep in pairs(col) do
			sx = sx + sep.x
			sy = sy + sep.y
			count = count + 1
		end
		sx = sx / count
		sy = sy / count
		if sx ~= 0 or sy ~= 0 then
			cx, cy = lib.vlt.project(x,y, lib.vlt.perpendicular(sx,sy))
		end
		-- self.shape:move(-x, -y);
		if can_resolve then
			-- self.shape:move(-x, -y)
			self:_move_node(x, y)
			self.pmat:translate(-x, -y)
			self:resolve(col)
		else
			self.shape:move(-x, -y)
		end
	else
		-- move body if no collision
		self:_move_node(x, y)
		self.pmat:translate(-x, -y)
	end
	return ret, col, cx, cy
end

function Body:_move_stepped(dx, dy, count, corrective)
	local corrective = try_or(corrective, true)
	for i = 1, count do
		local ret, col, cx, cy = self:move_try(dx, dy)
		if ret then
			if corrective and (cx ~= 0 or cy ~= 0) then
				dx, dy = lib.vlt.mul(lib.vlt.len(dx,dy),lib.vlt.normalize(cx,cy))
			else
				return true, col
			end
		end
	end
	return false
end
-- Move by (x,y) distributed over a set number of steps
function Body:move_step_count(x, y, steps)
	return self:_move_stepped(x/steps, y/steps, steps);
end

-- Move by (x, y) with each step going over a set distance
function Body:move_step_size(x, y, stepsize)
	local dis = math.sqrt(x^2 + y^2)
	x,y = x/dis, y/dis
	local ratio = dis / stepsize
	local count = math.floor(ratio)
	local leftover = dis - stepsize*count
	if (not self:_move_stepped(x*stepsize, y*stepsize, count)) and leftover > 0 then
		self:move_try(x * leftover, y * leftover)
	end
end

-- Use a binary search algorithm to move by (x, y)
function Body:move_step_binary(x, y, maxdiv)

end

-- Resolve a colliding body so that it no longer collides with anything
function Body:resolve(collisions)
	if not collisions then
		collisions = self.world:collisions(self.shape)
	end
	for obj, sep in pairs(collisions) do
		local does, sx, sy = self.shape:collidesWith(obj);
		if does and sx and sy then
			self.shape:move(sx, sy)
			self:_move_node(sx, sy)
			self.pmat:translate(-sx, -sy)
			--self:move_try(sx*1.01, sy*1.01, false)
		end
	end
end

--[[ TESTING FUNCTIONS ]]
function Body:contains_point(x, y)
	return self.shape:contains(x, y)
end

function Body:contains_ray(x,y, dx,dy)
	return self.shape:intersectsRay(x,y,dx,dy)
end

function Body:contains_shape(other)
	return self.shape:collidesWith(other)
end

function Body:ray_intersections(x,y, dx,dy)
	return self.shape:intersectionsWithRay(x,y, dx,dy)
end

function Body:center()
	return self.shape:center()
end

function Body:on_transform()
	self.shape:transform_mat(self.pmat);
	local mat = self.node:get_mat()
	self.shape:transform_mat(mat)
	self.pmat:copy(mat)
	self.pmat:inverse();
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
