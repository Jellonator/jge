local player_script = {}
function player_script:on_init()
	self.speed = self.speed or 128
	self.dirstr = "down"
	self.node:add_component("drawable_circle", "fill", 0, 0, 2, {0, 100, 200})
end
function player_script:on_update(dt)
	-- get inputs
	local up    = inputmanager:get_event("up");
	local left  = inputmanager:get_event("left");
	local right = inputmanager:get_event("right");
	local down  = inputmanager:get_event("down");

	-- calculate direction (dx, dy)
	local dx = (left and -1 or 0) + (right and 1 or 0)
	local dy = (up and -1 or 0) + (down and 1 or 0)
	dx,dy = lib.vlt.mul(self.speed*dt, lib.vlt.trim(1, dx,dy));

	-- play animations
	if up and not down then
		self.dirstr = "up"
	elseif left and not right then
		self.dirstr = "left"
	elseif right and not left then
		self.dirstr = "right"
	elseif down and not up then
		self.dirstr = "down"
	end
	local anim = self.node:get_component("animation")
	if dx == 0 and dy == 0 then
		anim:play("idle-"..self.dirstr)
	else
		anim:play("walk-"..self.dirstr)
	end

	-- movement
	local body = self.node:get_component("collisionbody")
	body:move_count(dx, dy, 20)
	if inputmanager:get_event("rotl") then
		self.node.transform:rotate(-dt*math.pi)
	end
	if inputmanager:get_event("rotr") then
		self.node.transform:rotate(dt*math.pi)
	end
end

function player_script:on_update_real(dt)
	local camera = self.node:get_root():get_component("camera")
	local cx, cy = self.node:getpos()
	camera.camera:lockPosition(cx, cy, lib.hcam.smooth.none(5))
	camera.camera:rotateTo(-self.node:getrot())
end

function player_script:on_draw()
	local camera = self.node:get_root():get_component("camera")
	-- mouse dot detection
	local body = self.node:get_component("collisionbody")
	local x, y = camera.camera:mousePosition();
	local pt = self.node:get_component("drawable_circle")
	pt.color[1] = body:contains_point(x, y) and 255 or 0
	pt.x, pt.y = self.node:transform_point_inv(x, y)
end

return player_script
