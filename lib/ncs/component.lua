local Component = {
	components = {}
}

local function function_empty() end

function Component.register_component(name, t)
	local self = Component;
	if self.components[name] then
		error(("A component named %s already exists!"):format(name))
	end
	self.components[name] = t
	-- warn for components not implementing serialization
	if not t.on_serialize or not t.on_loadstring then
		local s = "";
		if not t.on_serialize then
			s = "'serialize'";
		end
		if not t.on_serialize and not t.on_loadstring then
			s = "s " .. s .. " or ";
		else
			s = " " .. s;
		end
		if not t.on_loadstring then
			s = s .. "'loadstring'";
		end
		print(("WARNING! component %s does not define the function%s!")
			:format(name, s))
	end

	-- give default functions
	t.on_update = t.on_update or function_empty;
	t.on_draw   = t.on_draw   or function_empty;
	t.post_draw = t.post_draw or function_empty;
	t.on_input  = t.on_input  or function_empty;
	t.on_init   = t.on_init   or function_empty;
	t.on_serialize  = t.on_serialize  or function_empty;
	t.on_loadstring = t.on_loadstring or function_empty;

	-- modify some metadata
	t._allow_multiple = try_or(t._allow_multiple, true);
	t._name = name;
	t._depends = t._depends or {}

	t.__index = t;
end

function Component.instance(name)
	local self = Component;
	if not self.components[name] then
		error(("No such component of name %s!"):format(name))
	end
	return setmetatable({}, self.components[name])
end

return Component;
