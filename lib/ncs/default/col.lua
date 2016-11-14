local Body = {}
function Body:on_init(shape, ...)
	if type(shape) == "string" then
		self.world = self.node
			:get_parent_with_component("collisionworld")
			:get_component("collisionworld").world
		shape = self.world:create(shape, ...)
	end
	self.shape = shape
	self.shape.body = self
	self.pmat = lib.Matrix3();
end

function Body:_move_node(x, y)
	self.node.transform:translate(x, y);
	self.pmat:translate(-x, -y)
end

local function _get_correction(x, y, collisions)
	local sx,sy,count = 0,0,0
	for _, sep in pairs(collisions) do
		sx = sx + sep.x
		sy = sy + sep.y
		count = count + 1
	end
	sx = sx / count
	sy = sy / count
	if sx ~= 0 or sy ~= 0 then
		local cx, cy = lib.vlt.project(x,y, lib.vlt.perpendicular(sx,sy))
		return lib.vlt.mul(lib.vlt.len(x,y),lib.vlt.normalize(cx,cy))
	end
	return x, y;
end

--[[ MOVEMENT FUNCTIONS ]]
-- Test if body can move in a given direction
function Body:can_move(x, y)
	self.shape:move(x, y);
	local col, ret = self.world:collisions(self.shape);
	self.shape:move(-x, -y);
	return not ret, col
end

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
		if can_resolve then
			-- move, then resolve
			self:_move_node(x, y)
			self:resolve(col)
		else
			-- return back
			self.shape:move(-x, -y)
		end
	else
		-- move body if no collision
		self:_move_node(x, y)
	end
	return ret, col, cx, cy
end

function Body:_move_stepped(dx, dy, count, corrective)
	local corrective = try_or(corrective, false)
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
function Body:move_step_count(x, y, steps, corrective)
	return self:_move_stepped(x/steps, y/steps, steps, corrective);
end

-- Move by (x, y) with each step going over a set distance
function Body:move_step_size(x, y, stepsize, corrective)
	local dis = math.sqrt(x^2 + y^2)
	x,y = x/dis, y/dis
	local ratio = dis / stepsize
	local count = math.floor(ratio)
	local leftover = dis - stepsize*count
	if (not self:_move_stepped(x*stepsize, y*stepsize, count, corrective)) and leftover > 0 then
		self:move_try(x * leftover, y * leftover)
	end
end

-- Use a binary search algorithm to move by (x, y)
function Body:move_step_binary(x, y, maxdiv, corrective)
	if (x == 0 and y == 0) or maxdiv == 0 then return false end
	if not self:move_try(x, y, false) then return false end
	local corrective = try_or(corrective, false);
	local pos = 0.5;
	local step = 0.25;
	local final = 0;
	local lastcol = nil
	local didcollide = false
	while maxdiv > 0 do
		maxdiv = maxdiv - 1
		local canmove, col = self:can_move(pos*x, pos*y)
		if not canmove then
			lastcol = col
			didcollide = true
		end
		if canmove then
			final = pos
			pos = pos + step
		elseif corrective then
			-- change direction!
			local cx, cy = _get_correction(x*(1-pos),y*(1-pos), col)
			x = x * pos
			y = y * pos
			self.shape:move(x, y)
			self:_move_node(x, y);
			self:resolve()
			return self:move_step_binary(cx, cy, maxdiv, corrective)
		else
			pos = pos - step
		end
		step = step / 2
	end
	x = x * final
	y = y * final
	self.shape:move(x, y)
	self:_move_node(x, y);
	return didcollide, lastcol
end

-- Autodetect number of steps
function Body:move_step_binary_auto(x, y, len, maxsteps, corrective)
	if x == 0 and y == 0 then return false end
	local maxsteps = maxsteps or 8
	local len = len or 1
	local steps = math.min(maxsteps, math.max(math.ceil(math.sqrt(x^2+y^2) / len), 1))
	return self:move_step_binary(x, y, steps, corrective)
end

-- Default movement functionality, probably most useful
function Body:move(x, y)
	-- use a corrective two-step method
	return self:move_step_binary(x, y, 2, true)
end

-- Resolve a colliding body so that it no longer collides with anything
function Body:resolve(collisions)
	if not collisions then
		collisions = self.world:collisions(self.shape)
	end
	for obj, sep in pairs(collisions) do
		local does, sx, sy = self.shape:collidesWith(obj);
		if does and sx and sy then
			sx = sx * 1.001
			sy = sy * 1.001
			self.shape:move(sx, sy)
			self:_move_node(sx, sy)
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
	-- love.graphics.setColor(0, 255, 0, 140)
	-- for s in pairs(self.world.hash:shapes()) do
	-- 	s:draw('line')
	-- end
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

local Map = {}

function Map:on_init(fname)
	self.map = lib.tiled(fname, {"hc"})
	local parent, world = self.node:get_parent_with_component("collisionworld", true);
	if parent and world then
		print("INIT")
		self.map:hc_init(world.world)
	end
end

function Map:on_update(dt)
	self.map:update(dt)
end

function Map:on_draw()
	self.map:draw();

	-- Draw Collision Map (useful for debugging)
    -- love.graphics.setColor(255, 0, 0, 255)
    -- self.map:hc_draw()
end

register_component("tiledmaploader", Map)
