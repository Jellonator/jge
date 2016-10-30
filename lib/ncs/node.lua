local Node = {}
Node.__index = Node;

function Node.new(x, y)
	return setmetatable({
		transform = lib.Transform(x, y),
		components = {},
		components_named = {},
		children = {},
		_parent = nil,
		-- A system of caches so that positions can
		-- be lazily evaluated for efficiency
		_cache_x = x or 0,
		_cache_y = y or 0,
		_cache_rotation = 0,
		-- incremental IDs that correspond to '_id' in 'transform'
		-- If IDs are different, then caches need to be recalculated
		_parent_id = -1, -- Parent's transform's '_id'
		_self_id = -1 -- Own transform's '_id'
	}, Node);
end

-- Transform functions
function Node:transform_point(x, y)
	if self._parent then
		return self._parent:transform_point(self.transform:transform(x, y))
	else
		return self.transform:transform(x, y);
	end
end

function Node:_recalculate()
	if (self._self_id ~= self.transform._id) or
	(self._parent and (self._parent_id ~= self._parent.transform._id)) then
		self._self_id = self.transform._id;
		if self._parent then
			self._parent_id = self._parent.transform._id;

			local prot = self._parent:getrot()
			self._cache_rotation = prot + self.transform.rotation;
		else
			self._cache_rotation = self.transform.rotation;
		end
		self._cache_x, self._cache_y = self:transform_point(0, 0);
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
function Node:update(dt)
	for i, c in pairs(self.components) do
		c:on_update(self, dt);
	end
	for i, node in pairs(self.children) do
		node:update(dt)
	end
end

function Node:draw()
	self.transform:draw_push();
	for i, c in pairs(self.components) do
		c:on_draw(self);
	end
	for i, node in pairs(self.children) do
		node:draw();
	end
	for i, c in pairs(self.components) do
		c:post_draw(self);
	end
	self.transform:draw_pop();
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
	c:on_init(self, ...);
end

return setmetatable(Node, {
	__call = function(t, ...)
		return Node.new(...)
	end
})
