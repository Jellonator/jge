local GROUND_TIME_MAX = 9/60

local ROTATE_MODE_CONTINUOUS = 1
local ROTATE_MODE_TAP = 2

local player_script = {}
function player_script:on_init()
	self.speed = self.speed or 240
	self.velocy = self.velocy or 0
	self.velocx = self.velocx or 0
	self.gravity = self.gravity or 1800
	self.speed_jump = self.speed_jump or 600;
	self.terminal_velocity = self.terminal_velocity or 600
	self.friction = self.friction or 400
	self.ground_timer = 0
	self.prev_ground = true
	self.pause = 0;

	self.rotate_mode = ROTATE_MODE_CONTINUOUS

	self.dirstr = "down"
	self.node:add_component("drawable_circle", "fill", 0, 0, 2, {0, 100, 200})
	inputmanager:add_callback("rotl", self, "rotate", -math.pi/2)
	inputmanager:add_callback("rotr", self, "rotate", math.pi/2)
end
function player_script:rotate(r)
	if self.rotate_mode ~= ROTATE_MODE_TAP then return end
	self.node.transform:rotate(r)
	self.pause = 0.25
end
function player_script:on_update(dt)
	if self.pause > 0 then
		self.pause = self.pause - dt
	else
		local anim = self.node:get_component("animation")
		local body = self.node:get_component("collisionbody")

		-- get inputs
		local up    = inputmanager:get_event("up");
		local left  = inputmanager:get_event("left");
		local right = inputmanager:get_event("right");
		local down  = inputmanager:get_event("down");
		local jump  = inputmanager:get_event("jump");
		self.ground_timer = self.ground_timer + dt

		-- calculate direction
		local dx = (left and -1 or 0) + (right and 1 or 0)
		dx = dx * self.speed

		-- play animations
		if left and not right then
			self.dirstr = "left"
		elseif right and not left then
			self.dirstr = "right"
		end
		if dx == 0 then
			anim:play("idle-"..self.dirstr)
		else
			anim:play("walk-"..self.dirstr)
		end

		-- movement
		if self.prev_ground then
			body:move_count(dx*dt, self.velocy*dt, 8);
		else
			body:move_count(self.velocx*dt, self.velocy*dt, 8);
		end
		nx, ny = body:get_collision_normal();
		local col_bottom = false
		if nx ~= 0 or ny ~= 0 then
			col_bottom = jge.vlt.dot(nx, ny, 0, -1) >= 0.49;
			local vx,vy = self.velocx,self.velocy;
			vx, vy = jge.vlt.project(vx, vy, jge.vlt.perpendicular(nx, ny));
			self.velocy = vy
			self.velocx = vx
		end
		if self.prev_ground and not col_bottom and self.velocy >= 0 then
			local px, py = self.node.transform:get_translation();
			if not body:move_step_binary_minlength(0, self.speed*dt*4.1, 5e-2) then
				local newx, newy = self.node.transform:get_translation()
				local mx,my = px-newx, py-newy
				body.shape:move(mx, my)
				body:_move_node(mx, my)
			else
				if jge.vlt.dot(0, -1, body:get_collision_normal()) >= 0.49 then
					col_bottom = true
				end
			end
		end
		if self.prev_ground and not col_bottom then
			self.velocx = dx
		end
		self.prev_ground = col_bottom;

		self.velocy = self.velocy + self.gravity * dt;
		self.velocx = jge.to(self.velocx, dx, self.speed*dt*6)
		-- self.velocx = jge.to(self.velocx, 0, dt*self.friction)
		if math.abs(self.velocy) > self.terminal_velocity then
			self.velocy = self.velocy * self.terminal_velocity / math.abs(self.velocy)
		end
		if col_bottom and self.velocy > 0 then
			-- always stop on the ground
			self.velocy = 0
		end
		if col_bottom then
			self.ground_timer = 0;
		end
		if jump and self.ground_timer < GROUND_TIME_MAX then
			self.velocy = -self.speed_jump
			self.ground_timer = GROUND_TIME_MAX+1
		end
	end
	if self.rotate_mode == ROTATE_MODE_CONTINUOUS then
		if inputmanager:get_event("rotl") then
			self.node.transform:rotate(-dt*math.pi)
		end
		if inputmanager:get_event("rotr") then
			self.node.transform:rotate(dt*math.pi)
		end
	end
	local camera = self.node:get_root():get_component("camera")
	local cx, cy = self.node:getpos();
	camera.camera:lockPosition(cx, cy)--, jge.hcam.smooth.damped(10))
	local r = camera.camera.rot;
	r = jge.angle_to(r, -self.node:getrot(), dt * math.pi*2)
	camera.camera:rotateTo(r)
	-- camera.camera:rotateTo(-self.node:getrot())
end

function player_script:on_update_real(dt)
	local camera = self.node:get_root():get_component("camera")

	-- mouse dot detection
	local body = self.node:get_component("collisionbody")
	local x, y = camera:mouse_position();
	local pt = self.node:get_component("drawable_circle")
	pt.color[1] = body:contains_point(x, y) and 255 or 0
	pt.x, pt.y = self.node:transform_point_inv(x, y)
end

function player_script:on_add()
	local camera = self.node:get_root():get_component("camera")
	local cx, cy = self.node:getpos();
	camera.camera:lockPosition(cx, cy)
	camera.camera:rotateTo(-self.node:getrot())
end

return player_script
