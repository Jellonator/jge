local physical = {}
function Physical:on_init()
	self.gravity = self.gravity or 3200
	self.terminal_velocity = self.terminal_velocity or 500
	self.friction = self.friction or 400
	self.velocy = 0
	self.velocx = 0
	self.ground_timer = 0
	self.prev_ground = true
end

function Physical:on_update(dt)

end

jge.ncs.Component.register_component("physical", Physical)
