local Node = {}
Node.__index = Node;

function Node.new(x, y)
	local self = setmetatable({
		transform = jge.Transform(x, y),
		components = {},
		components_named = {},
		components_draw = {},
		components_update = {},
		children = {},
		groups = {},
		layer = 0,
		-- child caches so that we know what needs drawn/updated and what doesn't
		children_draw = {},
		children_update = {},
		need_reset_updates = false,
		need_reset_draws = false,
		_i_am_a_node = true,
		_parent = nil,
		_paused = false,
		_visible = true,
		_timescale = 1,
		-- A system of caches so that positions can
		-- be lazily evaluated for efficiency
		_cache_x = x or 0,
		_cache_y = y or 0,
		_cache_rotation = 0,
		-- incremental IDs that correspond to '_id' in 'transform'
		-- If IDs are different, then caches need to be recalculated
		_self_id = -1,
		-- Draw data for previous frame
		-- _prev_x = 0,
		-- _prev_y = 0,
		-- _prev_rot = 0,
		-- _prev_scalex = 1,
		-- _prev_scaley = 1,
		--
		-- _lerp_x = x or 0,
		-- _lerp_y = y or 0,
		-- debug information
		_debug = false,
	}, Node);
	self.transform:set_hook(jge.bind(self._transform_hook, self))
	return self;
end


--[[ Debugging functions ]]
local time_count = 1;
function _node_debug_update_real(node, dt)
	local ptime = love.timer.getTime()
	Node.update_real(node, dt)
	local diff = love.timer.getTime() - ptime
	dt = love.timer.getRealDelta();

	node._debug._u = node._debug._u + diff
	node._debug.timer = node._debug.timer + dt
	if node._debug.timer >= time_count then
		-- local total = node._debug.utime + node._dtime
		node._debug.utime = node._debug._u / node._debug.timer
		node._debug.dtime = node._debug._d / node._debug.timer
		node._debug._d = 0
		node._debug._u = 0
		node._debug.timer = 0
		-- print("UPDATE")
	end
end

function _node_debug_update(node, dt)
	local ptime = love.timer.getTime()
	Node.update(node, dt)
	local diff = love.timer.getTime() - ptime
	node._debug._u = node._debug._u + diff
end

function _node_debug_draw(node, lerp)
	local ptime = love.timer.getTime()
	Node.draw(node, lerp)
	node._debug._d = node._debug._d + love.timer.getTime() - ptime
end

function Node:set_debug(val)
	self._debug = val and (self._debug or {utime = 0, dtime = 0, timer = 0, _u = 0, _d = 0}) or false
	if val then
		self.update = _node_debug_update
		self.draw = _node_debug_draw
		self.update_real = _node_debug_update_real
	else
		self.update = Node.update
		self.draw = Node.draw
		self.update_real = Node.update_real
	end
end

function Node:set_debug_depth(d, val)
	if val == nil then val = true end
	if d > 0 then
		self:set_debug(val);
		for _, node in pairs(self.children) do
			node:set_debug_depth(d - 1, val)
		end
	end
end

local function draw_rect_aabb(x1, y1, x2, y2, mode)
	love.graphics.rectangle(mode or "fill", x1, y1, x2-x1, y2-y1)
	-- love.graphics.setColor(255, 255, 255)
	-- love.graphics.rectangle("line", x1, y1, x2-x1, y2-y1)
end

function Node:debug_draw(label, x1, y1, x2, y2)
	if not self._debug then return end
	x1 = x1 or 8
	if not x2 or not y1 or not y2 then
		local ww, wh = love.graphics.getDimensions();
		y1 = y1 or wh - 20
		x2 = x2 or ww - 8
		y2 = y2 or y1 + 12
	end

	local uratio = self._debug.utime
	local dratio = self._debug.dtime

	love.graphics.setColor(240, 240, 240)
	draw_rect_aabb(x1, y1, x2, y2)

	-- love.graphics.setColor(0, 0, 0)
	-- draw_rect_aabb(x1, y1, x2, y2)
	local x_mid = jge.lerp(uratio, x1, x2)
	local x_final = jge.lerp(uratio + dratio, x1, x2)
	love.graphics.setColor(120, 140, 240)
	draw_rect_aabb(x1, y1, x_mid, y2)
	love.graphics.setColor(240, 120, 140)
	draw_rect_aabb(x_mid, y1, x_final, y2)

	love.graphics.setColor(0, 0, 0)
	draw_rect_aabb(x_mid, y1, x_mid, y2)
	love.graphics.print(label, x1 + 4, y1)

	local width = x2 - x1
	local height = y2 - y1
	-- x1 = x1 + width + 8
	-- x2 = x2 + width + 8
	-- local height = y2 - y1

	for name, node in pairs(self.children) do
		if node._debug then
			y2 = y2 - height - 8
			y1 = y1 - height - 8
			-- x1 = x1 + 16
			-- local node_time = node._debug.utime + node._debug.dtime
			-- local node_ratio = node_time-- / total_time
			-- local x2 = x1 + node_ratio * width
			node:debug_draw(label .. "/" .. name, x1 + 16, y1, x2, y2)
		end
	end
end

--[[ Node state functions ]]
function Node:pause()
	self._paused = true
end

function Node:unpause()
	self._paused = false
end

function Node:hide()
	self._visible = false
end

function Node:show()
	self._visible = true
end

function Node:set_timescale(scale)
	scale = scale or 1
	self._timescale = scale
end

function Node:on_remove()
	for _, c in pairs(self.components) do
		if c.on_remove then c:on_remove() end
	end
	for _, node in pairs(self.children) do
		node:on_remove()
	end
end

function Node:on_add()
	for _, c in pairs(self.components) do
		if c.on_add then c:on_add() end
	end
	for _, node in pairs(self.children) do
		node:on_add()
	end
end

-- Group functions
function Node:add_to_group(name)
	self.groups[name] = name
end

function Node:remove_from_group(name)
	self.groups[name] = nil
end

function Node:is_in_group(name)
	return self.groups[name]
end

-- Matrix functions
function Node:get_mat()
	if self._parent then
		return self._parent:get_mat() * self.transform:get_mat()
	else
		return self.transform:get_mat()
	end
end

function Node:get_mat_inv()
	if self._parent then
		return self.transform:get_mat_inv() * self._parent:get_mat_inv()
	else
		return self.transform:get_mat_inv()
	end
end

-- Transform functions
function Node:_transform_hook()
	self._cache_rotation = self.transform.rotation;
	if self:get_parent() then
		self._cache_rotation = self._cache_rotation + self:get_parent().transform.rotation
	end
	self._cache_x, self._cache_y = self:transform_point(0, 0);
	for _, c in pairs(self.components) do
		if c.on_transform then
			c:on_transform(self.transform)
		end
	end
	for _, c in pairs(self.children) do
		c:_transform_hook()
	end
end

function Node:transform_point(x, y, w) -- local -> global
	local mat = self:get_mat()
	return mat:transform_point(x, y, w)
end

function Node:transform_point_inv(x, y, w) -- global -> local
	local mat = self:get_mat_inv();
	return mat:transform_point(x, y, w)
end

function Node:getpos()
	return self._cache_x, self._cache_y
end

function Node:getrot()
	return self._cache_rotation;
end
--
-- function Node:getdrawpos()
-- 	return self._lerp_x, self._lerp_y;
-- end

-- Regular functions
-- local val = 100 / math.pi
function Node:update_real(dt)
	if self._paused then return end
	dt = dt * self._timescale;
	-- self:_recalculate();
	for i, c in pairs(self.components_update) do
		if c.on_update_real then c:on_update_real(dt); end
	end
	for i, node in pairs(self.children_update) do
		node:update_real(dt)
	end
end

function Node:_reset_draws()
	self.need_reset_draws = true;
	if self._parent then self._parent:_reset_draws() end
end

function Node:_reset_updates()
	self.need_reset_updates = true;
	if self._parent then self._parent:_reset_updates() end
end

function Node:_finalize_reset_updates()
	self.components_update = {}
	self.children_update = {}

	for _,v in pairs(self.components) do
		if v.on_update or v.on_update_real then
			table.insert(self.components_update, v)
		end
	end
	for _,v in pairs(self.children) do
		v:_finalize_reset_updates();
		if #v.components_update > 0 then
			table.insert(self.children_update, v)
		end
	end
	self.need_reset_updates = false
end

function Node:update(dt)
	if self._paused then return end

	dt = dt * self._timescale;
	-- self._prev_x = self.transform.x
	-- self._prev_y = self.transform.y
	-- self._prev_scalex = self.transform.scalex
	-- self._prev_scaley = self.transform.scaley
	-- self._prev_rot = self.transform.rotation

	if self.need_reset_updates then
		self:_finalize_reset_updates()
	end

	-- self:_recalculate();
	for i, c in pairs(self.components_update) do
		if c.on_update then c:on_update(dt); end
	end
	local children = self.need_reset_updates and self.children or self.children_update
	for i, node in pairs(children) do
		node:update(dt)
	end
end

local function _sort_layers(a, b)
	if a.layer ~= b.layer then return a.layer < b.layer end
	return tostring(a) < tostring(b)
end
function Node:_finalize_reset_draws()
	self.components_draw = {}
	self.children_draw = {}
	for _,v in pairs(self.components) do
		if v.pre_draw or v.on_draw or v.post_draw then
			table.insert(self.components_draw, v)
		end
	end
	for _,v in pairs(self.children) do
		v:_finalize_reset_draws();
		if #v.components_draw > 0 then
			table.insert(self.children_draw, v)
		end
	end
	table.sort(self.children_draw, _sort_layers)
	self.need_reset_draws = false;
end

function Node:draw(lerp)
	if not self._visible then return end
	-- local x = self.transform.x
	-- local y = self.transform.y
	-- local scalex = self.transform.scalex
	-- local scaley = self.transform.scaley
	-- local rot = self.transform.rotation
	--
	-- assert(0 <= lerp and lerp <= 1, "Lerp is not between 0 and 1")
	--
	-- self.transform.x = jge.lerp(lerp, self._prev_x, x)
	-- self.transform.y = jge.lerp(lerp, self._prev_y, y)
	-- self.transform.scalex = jge.lerp(lerp, self._prev_scalex, scalex)
	-- self.transform.scaley = jge.lerp(lerp, self._prev_scaley, scaley)
	-- self.transform.rotation = jge.lerp(lerp, self._prev_rot, rot)
	--
	-- self._lerp_x, self._lerp_y = self.transform:get_translation();
	if self.need_reset_draws then
		self:_finalize_reset_draws();
	end

	for i, c in pairs(self.components_draw) do
		if c.pre_draw then c:pre_draw(lerp); end
	end
	self.transform:draw_push();
	for i, c in pairs(self.components_draw) do
		if c.on_draw then c:on_draw(lerp); end
	end
	local children = self.need_reset_draws and self.children or self.children_draw
	for i, node in pairs(children) do
		node:draw(lerp);
	end
	for i, c in pairs(self.components_draw) do
		if c.post_draw then c:post_draw(lerp); end
	end
	self.transform:draw_pop();

	-- self.transform.x = x
	-- self.transform.y = y
	-- self.transform.scalex = scalex
	-- self.transform.scaley = scaley
	-- self.transform.rotation = rot
end

-- Children/parent functions
function Node:get_root()
	if self._parent then
		return self._parent:get_root()
	else
		return self
	end
end

function Node:get_parent_with_component(cname, canretself)
	local c = self:get_component(cname);
	if canretself ~= false and c then
		return self, c
	elseif self._parent then
		return self._parent:get_parent_with_component(cname, true);
	end
end

function Node:add_child(name, child)
	if name == nil or type(name) == "table" then
		return self:add_child(#self.children+1, name)
	end
	if not child then
		child = Node()
	end
	if child._parent then
		child._parent:remove_child(child);
	end
	self.children[name] = child
	child._parent = self
	child:on_add();
	self:_reset_updates();
	self:_reset_draws();
	return child
end

function Node:has_child(name)
	return self.children[name]
end

function Node:remove_child(child)
	for k,v in pairs(self.children) do
		if v == child or k == child then
			self.children[k]:on_remove();
			self.children[k] = nil
		end
	end
	self:_reset_updates();
	self:_reset_draws();
end

function Node:get_node(name)
	if name == ".." then return self._parent end
	if name == "." then return self end
	local pos_s, pos_e = name:find('/');
	if pos_s then
		local pre, post = name:sub(1,pos_s-1), name:sub(pos_e+1);
		local c = pre == "" and self:get_root() or self:get_node(pre);
		return c:get_node(post)
	else
		return self.children[name]
	end
end
function Node:get_child(name)
	return self.children[name]
end

function Node:get_children_recursive(t)
	t = t or {}
	for _, child in pairs(self.children) do
		table.insert(t, child)
		child:get_children_recursive(t)
	end
	return t
end

function Node:find_node(name, plain)
	plain = jge.try_or(plain, true)
	for child_name, child_node in pairs(self.children) do
		if child_name:find(name, 1, plain) then return child_node end
		local ret = child_node:find_node(name, plain)
		if ret then return ret end
	end
	return nil;
end

function Node:find_nodes(name, plain, t)
	t = t or {}
	plain = jge.try_or(plain, true)
	for child_name, child_node in pairs(self.children) do
		if child_name:find(name, 1, plain) then
			table.insert(t, child_node)
		end
		child_node:find_nodes(name, plain, t)
	end
	return t
end

function Node:find_node_group(group)
	for _, child in pairs(self.children) do
		if child:is_in_group(group) then return child end
		local ret = child:find_node_group(group)
		if ret then return ret end
	end
	return nil;
end

function Node:destroy()
	if self._parent then self._parent:remove(self) end
end

function Node:get_parent()
	return self._parent
end

-- Component functions
function Node:call_signal(cname, fname, recursive, ...)
	local recursive = jge.try_or(recursive, false)
	for _,c in pairs(self.components) do
		if (cname == nil or c._name == cname) and c[fname] then
			c[fname](c, ...)
		end
	end

	if recursive == true or (type(recursive) == "number" and recursive > 1) then
		local next_recursive = recursive == true and true or recursive - 1
		for _, node in pairs(self.children) do
			node:call_signal(cname, fname, next_recursive, ...)
		end
	end
end

function Node:get_component(name)
	return self.components_named[name];
end
Node.has_component = Node.get_component;

function Node:get_components_all(name)
	local ret = {};
	for i, c in pairs(self.components) do
		if c._name == name then
			table.insert(ret, c)
		end
	end
	return ret
end

function Node:add_component(name, ...)
	local c = jge.ncs.Component.instance(name);
	table.insert(self.components, c);
	self.components_named[name] = c;
	c.node = self;
	c:on_init(...);
	if c.on_add then c:on_add() end
	self:_reset_updates();
	self:_reset_draws();
	return c
end

function Node:_add_component_json(name, jsondata)
	local c = jge.ncs.Component.instance(name);
	table.insert(self.components, c);
	self.components_named[name] = c;
	c.node = self;
	if c.on_add then c:on_add() end
	self:_reset_updates();
	self:_reset_draws();
	return c
end

function Node:add_component_json(name, jsondata)
	local c = self:_add_component_json(name, jsondata)
	c:from_json(jsondata)
end

local _contains = function(t, val)
	for _,v in pairs(t) do
		if v == val then return true end
	end
	return false
end
function Node:from_json(json, override)
	-- load json
	if type(json) == "string" then
		-- print(json)
		-- print("LOADING NODE FROM JSON: " .. tostring(json))
		-- json = json:gsub("/[^/%.]+/%.%.", "")
		json = jge.fix_path(json)
		print("LOADING NODE FROM JSON: " .. tostring(json))
		local contents = love.filesystem.read(json)
		json,pos,err = jge.json.decode(contents)
		if err then error(err) end
	end
	local override_t = {}
	if override then
		for ok, ov in pairs(override) do
			local target_key = json.override and json.override[ok] or ok
			local a, b = target_key:match("([^,]+)%.(.*)")
			if a and b then
				override_t[a] = override_t[a] or {}
				override_t[a][b] = ov
			end
		end
	end
	-- load groups
	if json.layer then
		self.layer = json.layer
	end
	if json.groups then
		for _, name in pairs(json.groups) do
			self:add_to_group(name)
		end
	end
	-- load transforms
	self.transform:scale(
		json.scale or json.sx or json.scalex or 1,
		json.scale or json.sy or json.scaley or 1)
	self.transform:translate(json.x or 0, json.y or 0)
	self.transform:rotate(
		json.r or json.rot or json.rotation or json.angle or 0)
	-- load components
	if json.components then
		local t = {}
		for k,v in pairs(json.components) do
			local cname = v.component or k
			local override_component = override_t[cname]
			if override_component then
				for ok, ov in pairs(override_component) do
					v[ok] = ov
				end
			end
			local obj = self:_add_component_json(cname, v)
			table.insert(t, obj)
			obj._depends = v.depends or obj._depends
			obj._jsondata = v
		end
		table.sort(t, function(a, b)
			local a_dependson_b = a._depends and _contains(a._depends, b._name) or false
			local b_dependson_a = b._depends and _contains(b._depends, a._name) or false
			if a_dependson_b and b_dependson_a then
				error("Circular dependencies!")
			end
			if a_dependson_b then
				return false
			end
			if b_dependson_a then
				return true
			end
			return tostring(a) < tostring(b)
		end)
		for i,v in ipairs(t) do
			v:from_json(v._jsondata)
		end
	end
	-- load children
	if json.children then
		for k,v in pairs(json.children) do
			local c = self:add_child(k);
			c:from_json(v)
			if c.on_add then c:on_add() end
		end
	end
	-- self:_transformed();
end

return setmetatable(Node, {
	__call = function(t, ...)
		return Node.new(...)
	end
})
