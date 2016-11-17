local Body = {}
function Body:on_init(shape, ...)
	self.world = self.node
		:get_parent_with_component("collisionworld")
		:get_component("collisionworld").world
	if type(shape) == "string" then
		shape = self.world:create(shape, ...)
	end
	self.pushable = false
	self.shape = shape
	self.shape.body = self
	self.pmat = lib.Matrix3();
end

function Body:from_json(json)
	local shape = json.shape;
	if shape == "rectangle" then
		self:on_init(shape, json.x, json.y, json.w or json.width, json.h or json.height)
	elseif shape == "point" then
		self:on_init(shape, json.x, json.y)
	elseif shape == "circle" then
		self:on_init(shape, json.x, json.y, json.r or json.radius)
	elseif shape == "polygon" then
		self:on_init(shape, unpack(json.points or json.vertices))
		self.shape:move(json.x or 0, json.y or 0)
	else
		error("No such shape of name '"..tostring(shape).."'")
	end

	if json.layers then
		for _,v in pairs(json.layers) do
			self.shape:add_layer(v);
		end
	end
	if json.mask then
		self.shape:set_mask(json.mask)
	end
	if json.pushable ~= nil then
		self:set_pushable(json.pushable)
	end
end

function Body:set_pushable(value)
	self.pushable = value
end

--
function Body:post_draw()
	if not self.draw then return end
	love.graphics.setColor(0,255,255)
	self.shape:transform_mat(self.pmat);
	-- love.graphics.push()
	-- love.graphics.origin()
	self.shape:draw('line')
	-- love.graphics.pop()
	self.shape:transform_mat(self.pmat:clone():inverse());
end

function Body:_move_node(x, y)
	-- shape needs to be transformed back by world coordinates
	self.pmat:translate(-x, -y)
	-- and node needs to be transformed in local coordinates
	x, y = self:motion_world_to_local(x, y)
	x, y = self.node.transform:get_mat():transform_point(x, y, 0)
	self.node.transform:translate(x, y);
end

function Body:motion_local_to_world(x, y)
	return self.node:get_mat():transform_point(x, y, 0)
end

function Body:motion_world_to_local(x, y)
	return self.node:get_mat_inv():transform_point(x, y, 0)
end

local function _get_correction(x, y, collisions)
	local sx,sy,count,avglen = 0,0,0
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
	local mx, my = self:motion_local_to_world(x, y);
	self.shape:move(mx, my);
	local col, ret = self.world:collisions(self.shape);
	self.shape:move(-mx, -my);
	return not ret, col
end

-- Move by (x,y) if that position is free; most basic form of movement
function Body:move_try(x, y, can_resolve)
	local mx, my = self:motion_local_to_world(x, y);
	local can_resolve = try_or(can_resolve, false)
	self.shape:move(mx, my);
	local col, ret = self.world:collisions(self.shape);
	local cx, cy = mx, my
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
			cx, cy = lib.vlt.project(mx,my, lib.vlt.perpendicular(sx,sy))
		end
		if can_resolve then
			-- move, then resolve
			self:_move_node(mx, my)
			self:resolve(col)
		else
			-- return back
			self.shape:move(-mx, -my)
		end
	else
		-- move body if no collision
		self:_move_node(mx, my)
	end
	return ret, col, self:motion_world_to_local(cx, cy)
end

function Body:_move_stepped(dx, dy, count, corrective)
	-- local mx, my = self:motion_local_to_world(x, y);
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
	local mx, my = self:motion_local_to_world(x, y);
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
			local cx, cy = _get_correction(x*(1-final),y*(1-final), col)
			mx = mx * final
			my = my * final
			self.shape:move(mx, my)
			self:_move_node(mx, my);
			self:resolve()
			return self:move_step_binary(cx, cy, maxdiv)
		else
			pos = pos - step
		end
		step = step / 2
	end
	mx = mx * final
	my = my * final
	self.shape:move(mx, my)
	self:_move_node(mx, my);
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
	local mx, my = self:motion_local_to_world(x, y);
	self.shape:move(mx, my);
	self:_move_node(mx, my);
	local col, ret = self.world:collisions(self.shape);
	if ret then
		self:resolve()
	end
end

function Body:move_count(x, y, count)
	for i = 1, count do
		self:move(x/count,y/count)
	end
end

-- Resolve a colliding body so that it no longer collides with anything
function Body:resolve(collisions)
	if not collisions then
		collisions = self.world:neighbors(self.shape)
	end

	local _col = {}
	for obj in pairs(collisions) do
		table.insert(_col, obj)
	end
	collisions = _col

	local selfx, selfy = self.shape:center()
	table.sort(collisions, function(aobj, bobj)
		return lib.vlt.dist(selfx, selfy, aobj:center())
		     < lib.vlt.dist(selfx, selfy, bobj:center())
	end)

	for _, obj in ipairs(collisions) do
		local does, sx, sy = self.shape:collidesWith(obj);
		if does and sx and sy then
			local seplist = obj._allsep
			if seplist and #seplist > 1 then
				for _, sep in pairs(seplist) do
					local does, sx, sy, seplist = self.shape:collidesWith(sep.obj);
					if does then
						sx,sy = lib.vlt.mul(1.01, sx,sy)
						self.shape:move(sx, sy)
						self:_move_node(sx, sy)
					end
				end
			else
				sx,sy = lib.vlt.mul(1.01, sx,sy)
				self.shape:move(sx, sy)
				self:_move_node(sx, sy)
			end
		end
	end
end

-- Resolves all nearby neighbors
function Body:resolve_neighbors(collisions)
	if not collisions then
		collisions = self.world:neighbors(self.shape)
	end
	for neighbor, _ in pairs(collisions) do
		if neighbor.body and neighbor:collidesWith(self.shape) and neighbor.body.pushable then
			neighbor.body:resolve();
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
		-- print("INIT")
		for _,layer in ipairs(self.map.layers) do
			if layer.type == "objectgroup" then
				local i = 1;
				while i <= #layer.objects do
					local object = layer.objects[i];
					local t = object.gid and self.map.tiles[object.gid];
					local json = t and t.properties and t.properties.json
						or object.properties and object.properties.json
					if json then
						object.batch:set(object.batchid, 0,0,0,0,1,1)
						json = self.map._path .. json
						local o = self.node:add_child();
						local r = math.rad(object.rotation)
						o:from_json(json)

						local x,y = object.x+object.width/2, object.y+object.height/2
						y = y - math.cos(r)*object.height
						o.transform:translate(x, y)
						o.transform:rotate(r)

						table.remove(layer.objects, i)
					else
						i = i + 1
					end
				end
			end
		end

		self.map:hc_init(world.world)
		for shape in pairs(self.map.hc_collidables) do
			local c = self.node:add_child();
			c:add_component("collisionbody", shape)
			local cx, cy = shape:center();
			c.transform:translate(cx, cy)
			shape:move(-cx, -cy)
			local script = shape.tiledproperties and shape.tiledproperties.script
			if script then
				c:add_component("script", self.map._path .. script)
			end
		end
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
