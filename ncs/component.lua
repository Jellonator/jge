local Component = {
	components = {}
}

local function function_empty() end

local required_components = {"from_json", --[["to_json"]]}
function Component.register_component(name, t)
	local self = Component;
	if self.components[name] then
		error(("A component named %s already exists!"):format(name))
	end
	self.components[name] = t
	-- warn for components not implementing serialization
	local has_all_components = true;
	local warnstr = ""
	for i,v in pairs(required_components) do
		if not t[v] then
			if not has_all_components then
				warnstr = warnstr .. ", "
			end
			warnstr = warnstr .. "'"..v.."'"
			has_all_components = false
		end
	end
	if not has_all_components then
			print(("WARNING! component %s does not define the function(s): %s!")
				:format(name, warnstr))
	end
	-- t._can_update = (t.on_update_real or t.on_update) and true or false
	-- t._can_draw = (t.pre_draw or t.post_draw or t.on_draw) and true or false

	-- give default functions
	-- t.on_update = t.on_update or function_empty;
	-- t.on_draw   = t.on_draw   or function_empty;
	-- t.post_draw = t.post_draw or function_empty;
	-- t.pre_draw = t.pre_draw or function_empty;
	-- t.on_update_real = t.on_update_real or function_empty;
	-- t.on_input  = t.on_input  or function_empty;
	-- t.on_init   = t.on_init   or function_empty;
	-- t.on_transform  = t.on_transform  or function_empty;
	-- t.pre_transform  = t.pre_transform  or function_empty;
	-- no default provided for 'from_json!' if you try,
	-- you deserve the crash for not implementing it
	-- modify some metadata
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
