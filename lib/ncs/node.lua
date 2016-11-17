local Node = {}
Node.__index = Node;

function Node.new(x, y)
	return setmetatable({
		transform = lib.Transform(x, y),
		components = {},
		components_named = {},
		children = {},
		_i_am_a_node = true,
		_parent = nil,
		_paused = false,
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
		_prev_x = 0,
		_prev_y = 0,
		_prev_rot = 0,
		_prev_scalex = 1,
		_prev_scaley = 1,
	}, Node);
end

function Node:pause()
	self._paused = true
end

function Node:unpause()
	self._paused = false
end

function Node:set_timescale(scale)
	scale = scale or 1
	self._timescale = scale
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
function Node:transform_point(x, y) -- local -> global
	local mat = self:get_mat()
	return mat:transform_point(x, y)
end

function Node:transform_point_inv(x, y) -- global -> local
	local mat = self:get_mat_inv();
	return mat:transform_point(x, y)
end

function Node:_recalculate()
	if self._self_id ~= self.transform._id  then
		self._self_id = self.transform._id;
		if self._parent then
			local prot = self._parent:getrot()
			self._cache_rotation = prot + self.transform.rotation;
		else
			self._cache_rotation = self.transform.rotation;
		end
		self._cache_x, self._cache_y = self:transform_point(0, 0);

		-- callback for components and nodes
		for i, c in pairs(self.components) do
			c:on_transform(self.transform);
		end
		for i, node in pairs(self.children) do
			node:_recalculate()
		end
	end
end

function Node:getpos()
	self:_recalculate();
	return self._cache_x, self._cache_y;
end

function Node:getrot()
	self:_recalculate();
	return self._cache_rotation;
end

-- Regular functions
-- local val = 100 / math.pi
function Node:update_real(dt)
	if self._paused then return end
	dt = dt * self._timescale;
	self:_recalculate();
	for i, c in pairs(self.components) do
		c:on_update_real(dt);
	end
	for i, node in pairs(self.children) do
		node:update_real(dt)
	end
end

function Node:update(dt)
	if self._paused then return end
	dt = dt * self._timescale;
	-- val = val * math.pi * 0.01
	-- print(("%.70f"):format(val))
	-- val = val / math.pi * 100
	self._prev_x = self.transform.x
	self._prev_y = self.transform.y
	self._prev_scalex = self.transform.scalex
	self._prev_scaley = self.transform.scaley
	self._prev_rot = self.transform.rotation

	self:_recalculate();
	for i, c in pairs(self.components) do
		c:on_update(dt);
	end
	for i, node in pairs(self.children) do
		node:update(dt)
	end
end

function Node:draw(lerp)
	local x = self.transform.x
	local y = self.transform.y
	local scalex = self.transform.scalex
	local scaley = self.transform.scaley
	local rot = self.transform.rotation

	self.transform.x = lib.lerp(lerp, self._prev_x, x)
	self.transform.y = lib.lerp(lerp, self._prev_y, y)
	self.transform.scalex = lib.lerp(lerp, self._prev_scalex, scalex)
	self.transform.scaley = lib.lerp(lerp, self._prev_scaley, scaley)
	self.transform.rotation = lib.lerp(lerp, self._prev_rot, rot)

	self.transform:draw_push();
	for i, c in pairs(self.components) do
		c:on_draw(lerp);
	end
	for i, node in pairs(self.children) do
		node:draw(lerp);
	end
	for i, c in pairs(self.components) do
		c:post_draw(lerp);
	end
	self.transform:draw_pop();

	self.transform.x = x
	self.transform.y = y
	self.transform.scalex = scalex
	self.transform.scaley = scaley
	self.transform.rotation = rot
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
	if canretself == true and c then
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
	return child
end

function Node:remove_child(child)
	for k,v in pairs(self.children) do
		if v == child then
			self.children[k] = nil
		end
	end
end

function Node:get_node(name)
	if name == ".." then return self._parent end
	if name == "." then return self end
	local pos_s, pos_e = name:find('/');
	if pos_s then
		local pre, post = name:sub(1,pos_s-1), name:sub(pos_e+1);
		local c = pre == "" and self:get_root() or self:get_child(pre);
		return c:get_child(post)
	else
		return self.children[name]
	end
end

-- Component functions
function Node:get_component(name)
	return self.components_named[name];
end

function Node:get_components_all(name)
	if self.components_named[name]._allow_multiple then
		local ret = {};
		for i, c in pairs(self.components) do
			if c._name == name then
				table.insert(ret, c)
			end
		end
		return ret
	else
		return {self.components_named[name]}
	end
end

function Node:add_component(name, ...)
	local c = lib.ncs.Component.instance(name);
	if c._allow_multiple then
		table.insert(self.components, c);
	end
	self.components_named[name] = c;
	c.node = self;
	c:on_init(...);
	return c
end

function Node:_add_component_json(name, jsondata)
	local c = lib.ncs.Component.instance(name);
	if c._allow_multiple then
		table.insert(self.components, c);
	end
	self.components_named[name] = c;
	c.node = self;
	-- c:from_json(jsondata);
	return c
end

local _contains = function(t, val)
	for _,v in pairs(t) do
		if v == val then return true end
	end
	return false
end
function Node:from_json(json)
	-- load json
	if type(json) == "string" then
		local contents = love.filesystem.read(json)
		json,pos,err = lib.json.decode(contents)
		if err then error(err) end
	end
	-- load components
	if json.components then
		local t = {}
		for k,v in pairs(json.components) do
			local cname = v.component or k
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
	-- load transforms
	self.transform:scale(
		json.scale or json.sx or json.scalex or 1,
		json.scale or json.sy or json.scaley or 1)
	self.transform:translate(json.x or 0, json.y or 0)
	self.transform:rotate(
		json.r or json.rot or json.rotation or json.angle or 0)
	-- load children
	if json.children then
		for k,v in pairs(json.children) do
			local c = self:add_child(k);
			c:from_json(v)
		end
	end
end

return setmetatable(Node, {
	__call = function(t, ...)
		return Node.new(...)
	end
})
