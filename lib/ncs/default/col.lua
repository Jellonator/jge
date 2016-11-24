local Body = {}
function Body:on_init(shape, ...)
	self.world = self.node
		:get_parent_with_component("collisionworld")
		:get_component("collisionworld").world
	if type(shape) == "string" then
		shape = self.world:create(shape, ...)
	end
	self.world:register(shape)
	self.pushable = false
	self.shape = shape
	self.shape.body = self
	self.enabled = true;
	self.pmat = jge.Matrix3();
end

function Body:on_remove()
	self.world:remove(self.shape)
end

function Body:on_add()
	if self.enabled then self.world:register(self.shape) end
end

function Body:disable()
	self.enabled = false;
	self.world:remove(self.shape)
end

function Body:enable()
	self.enabled = true;
	self.world:register(self.shape)
end

function Body:from_json(json)
	local shape = json.shape;
	if shape == nil then
		error("No shape given!")
	end
	if type(shape) ~= "string" then
		self:on_init(shape);
	elseif shape == "rectangle" then
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
-- function Body:post_draw()
-- 	if not self.draw then return end
-- 	love.graphics.setColor(0,255,255)
-- 	self.shape:transform_mat(self.pmat);
-- 	-- love.graphics.push()
-- 	-- love.graphics.origin()
-- 	self.shape:draw('line')
-- 	-- love.graphics.pop()
-- 	self.shape:transform_mat(self.pmat:clone():inverse());
-- end

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

function Body:get_collision_normal(s)
	s = s or 1.01
	local rx, ry = 0, 0
	self.shape:scale(s)
	local col = self.world:collisions(self.shape);
	self.shape:scale(1/s)

	local count = 0;
	for _,sep in pairs(col) do
		rx, ry = rx+sep.x, ry+sep.y
		count = count + 1
	end

	if count > 0 then
		rx, ry = rx/count, ry/count
		return jge.vlt.normalize(self:motion_world_to_local(rx, ry))
	end

	return 0, 0
end

function Body:is_colliding(s)
	s = s or 1.01
	self.shape:scale(s)
	local _,ret = self.world:collisions(self.shape);
	self.shape:scale(1/s)
	return ret;
end

function Body:get_collisions(s)
	s = s or 1.01
	self.shape:scale(s)
	local ret = self.world:collisions(self.shape);
	self.shape:scale(1/s)
	return ret;
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
		local cx, cy = jge.vlt.project(x,y, jge.vlt.perpendicular(sx,sy))
		return jge.vlt.mul(jge.vlt.len(x,y),jge.vlt.normalize(cx,cy))
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
	local can_resolve = jge.try_or(can_resolve, false)
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
			cx, cy = jge.vlt.project(mx,my, jge.vlt.perpendicular(sx,sy))
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
	local corrective = jge.try_or(corrective, false)
	for i = 1, count do
		local ret, col, cx, cy = self:move_try(dx, dy)
		if ret then
			if corrective and (cx ~= 0 or cy ~= 0) then
				dx, dy = jge.vlt.mul(jge.vlt.len(dx,dy),jge.vlt.normalize(cx,cy))
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
	local corrective = jge.try_or(corrective, false);
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

local _log2 = math.log(2)
function Body:move_step_binary_minlength(x, y, min_length, corrective)
	local len = jge.vlt.len(x, y)
	local div = math.log(len/min_length)/_log2
	return self:move_step_binary(x, y, math.ceil(div), corrective)
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
		return jge.vlt.dist(selfx, selfy, aobj:center())
		     < jge.vlt.dist(selfx, selfy, bobj:center())
	end)

	for _, obj in ipairs(collisions) do
		local does, sx, sy = self.shape:collidesWith(obj);
		if does and sx and sy then
			local seplist = obj._allsep
			if seplist and #seplist > 1 then
				for _, sep in pairs(seplist) do
					local does, sx, sy, seplist = self.shape:collidesWith(sep.obj);
					if does then
						sx,sy = jge.vlt.mul(1.01, sx,sy)
						self.shape:move(sx, sy)
						self:_move_node(sx, sy)
					end
				end
			else
				sx,sy = jge.vlt.mul(1.01, sx,sy)
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

function Body:generate_bodydraw()
	self.node:add_component("collisionbodydraw", self.shape)
end

register_component("collisionbody", Body)

local BodyDraw = {}
function BodyDraw:on_init(shape, color)
	self.shape = shape
	self.color = color and {unpack(color)} or {0,255,255}
end

function BodyDraw:post_draw()
	love.graphics.setColor(self.color)
	if self.shape.body then
		self.shape:transform_mat(self.shape.body.pmat);
	end

	self.shape:draw('line')

	if self.shape.body then
		self.shape:transform_mat(self.shape.body.pmat:clone():inverse());
	end
end

register_component("collisionbodydraw", BodyDraw)

local World = {}

function World:on_init(cellsize)
	self.world = jge.HC.new(cellsize)
end

function World:on_update(dt)
end

-- function World:on_draw()
-- 	-- love.graphics.setColor(0, 255, 0, 140)
-- 	-- for s in pairs(self.world.hash:shapes()) do
-- 	-- 	s:draw('line')
-- 	-- end
-- end

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

local function clear_shape_from_layer(shape)
	if shape.tiled_layer then
		shape.tiled_layer.rm_indexes = shape.tiled_layer.rm_indexes or {}
		table.insert(shape.tiled_layer.rm_indexes, shape.tiled_layer_index);
		-- table.remove(shape.tiled_layer.objects, shape.tiled_layer_index);
		shape.tiled_layer = nil;
		shape.tiled_layer_index = nil;
	end
	if shape.tiled_batch then
		shape.tiled_batch:set(shape.tiled_batchid, 0,0,0,0,1,1)
		shape.tiled_batch = nil;
		shape.tiled_batchid = nil
	end
end

local function finalize_removals(map)
	for _,layer in pairs(map.layers) do
		if layer.rm_indexes and layer.objects then
			table.sort(layer.rm_indexes);
			for i = #layer.rm_indexes, 1, -1 do
				table.remove(layer.objects, layer.rm_indexes[i])
			end
		end
	end
end

function Map:on_init(fname)
	self.map = jge.tiled(fname, {"hc"})
	local parent, world = self.node:get_parent_with_component("collisionworld", true);
	if parent and world then
		-- create solid bodies
		self.map:hc_init(world.world)
		for shape in pairs(self.map.hc_collidables) do
			local properties = jge.table_union(
				shape.tileset_properties or {},
				shape.tile_properties or {},
				shape.object_properties or {})
			properties.shape = shape or properties.shape
			for k,v in pairs(properties) do
				if type(v) == "string" then
					local begins, val = v:begins_with("@object:")
					if begins then
						local other_shape = self.map.hc_collidables_named[val]
						properties[k] = other_shape and other_shape.tiled_object
						clear_shape_from_layer(other_shape)
					end
				end
			end

			local tile = shape.tiled_gid and self.map.tiles[shape.tiled_gid];
			local json = properties.json
			local script = properties.script
			local child;
			if json or script then
				child = self.node:add_child();
				local centerx, centery = shape:center();
				local rot = shape.tiled_object and math.rad(shape.tiled_object.rotation) or 0
				child.transform:translate(centerx, centery)
				child.transform:rotate(rot)
				shape:rotate(rot, centerx, centery)
				shape:move(-centerx, -centery)
				clear_shape_from_layer(shape)
			end
			if json then
				json = self.map._path .. json
				child:from_json(json, properties)
			elseif script then
				local b = child:add_component("collisionbody", shape)
				local script = child:add_component("script", self.map._path .. script)
				for k,v in pairs(properties) do
					if k ~= "script" then
						script[k] = v
					end
				end
			elseif properties.collidable then
				self.node:add_component("collisionbody", shape)
			end
		end

		finalize_removals(self.map)
	end
end

function Map:bind_camera()
	local _, camera = self.node:get_parent_with_component("camera");
	if camera then
		local w, h = self.map.width*self.map.tilewidth,
			self.map.height*self.map.tileheight;
		local x1, y1 = self.node:transform_point(0,0)
		local x2, y2 = self.node:transform_point(w,h)
		local x3, y3 = self.node:transform_point(0,h)
		local x4, y4 = self.node:transform_point(w,0)
		local ax = math.min(x1, x2, x3, x4)
		local ay = math.min(y1, y2, y3, y4)
		local bx = math.max(x1, x2, x3, x4)
		local by = math.max(y1, y2, y3, y4)
		camera.camera:setBounds(ax, ay, bx-ax, by-ay, true)
	end
end

function Map:on_update(dt)
	self.map:update(dt)
	self:bind_camera();
end

function Map:on_remove()
	for shape in pairs(self.map.hc_collidables) do
		if shape._world then shape._world:remove(shape) end
	end
end

function Map:on_draw()
	local _,camera = self.node:get_parent_with_component("camera");
	local x1,y1,x2,y2 = camera:bbox();
	x1,y1 = self.node:transform_point_inv(x1,y1)
	x2,y2 = self.node:transform_point_inv(x2,y2)
	self.map:setDrawRange(x1,y1,x2-x1,y2-y1)
	self.map:draw();
	if not self.draw then return end
	-- Draw Collision Map (useful for debugging)
	love.graphics.setColor(255, 0, 0, 255)
	self.map:hc_draw()
end

function Map:bbox()
	local x1,y1, x2,y2 = 0, 0,
		self.map.width*self.map.tilewidth, self.map.height*self.map.tileheight;
	-- x1, y1 = self.node:transform_point(x1, y1)
	-- x2, y2 = self.node:transform_point(x2, y2)
	return x1, y1, x2, y2
end

register_component("tiledmaploader", Map)
