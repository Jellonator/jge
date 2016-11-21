local script = {}

function script:on_init()
	-- print("INIt")
	self.speed = self.speed or 0.125
	self.node:get_component("collisionbody"):generate_bodydraw();
end

function script:on_update(dt)
	self.node.transform:rotate(dt*math.pi*self.speed)
	self.node:get_component("collisionbody"):resolve_neighbors()
end

return script
