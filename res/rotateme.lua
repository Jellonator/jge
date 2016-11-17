local script = {}

function script:on_init()
	-- print("INIt")
	self.node:get_component("collisionbody").draw = true
end

function script:on_update(dt)
	self.node.transform:rotate(dt*math.pi*0.125)
	self.node:get_component("collisionbody"):resolve_neighbors()
end

return script
