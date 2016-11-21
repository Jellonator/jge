local script = {}

function script:on_init()
	-- print("INIt")
	self.speed = self.speed or 0.125
	self.node:get_component("collisionbody"):generate_bodydraw();
end

function script:on_update(dt)
	local body = self.node:get_component("collisionbody")
	local col = body:get_collisions();
	local old_mat = self.node:get_mat():inverse();
	self.node.transform:rotate(dt*math.pi*self.speed)
	local new_mat = self.node:get_mat();
	for shape in pairs(col) do
		if shape.body and shape.body.pushable then
			local other = shape.body;
			local px, py = other.node:getpos()
			local nx, ny = old_mat:transform_point(px, py)
			nx, ny = new_mat:transform_point(nx, ny)
			local mx, my = nx-px, ny-py
			shape:move(mx, my)
			other:_move_node(mx, my)
			other.node.transform:rotate(dt*math.pi*self.speed)
		end
	end

end

return script
