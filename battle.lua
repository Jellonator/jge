--
local TurnController = {}
function TurnController:on_init() end
function TurnController:from_json() end
function TurnController:get_order()
	local script = self.node:get_component("script")
	if script and script.get_turn_order then return script:get_turn_order() end
	return 0;
end
function TurnController:turn_end()
	local _, parent = self.node:get_parent_with_component("turnsystem");
	if parent and parent:get_active() == self then
		self.node:call_signal("script", "on_turn_end", true)
		parent:next_turn();
	end
end
function TurnController:on_turn_update(dt)
	self.node:call_signal("script", "on_turn_update", true, dt)
end
function TurnController:on_turn_draw(lerp)
	self.node:call_signal("script", "on_turn_draw", true, lerp)
end
jge.ncs.Component.register_component("turncontroller", TurnController);

-- Controls turn-based system of children
local TurnSystem = {}
function TurnSystem:on_init()
	self.turnorder = {}
	self.index = 1
end
function TurnSystem:from_json()end
function TurnSystem:on_update(dt)
	local active = self:get_active();
	if active then
		active:on_turn_update(dt)
	else
		self:next_turn();
	end
end
function TurnSystem:on_draw(lerp)
	local active = self:get_active();
	if active then
		active:on_turn_draw(lerp)
	end
end
function TurnSystem:get_active()
	return self.turnorder[self.index]
end
function TurnSystem:next_turn()
	self.index = self.index + 1
	if self.index > #self.turnorder then
		self:_recollect();
	end
end
local function _sortturns(a, b)
	local aval = a:get_order();
	local bval = b:get_order();
	if aval < bval then return true end
	if bval < aval then return false end
	return tostring(a) > tostring(b)
end
function TurnSystem:_recollect()
	jge.table_clear(self.turnorder);

	local children = self.node:get_children_recursive();
	for _, child in pairs(children) do
		local script = child:get_component("turncontroller");
		if script then
			table.insert(self.turnorder, script)
		end
	end

	table.sort(self.turnorder, _sortturns)
	self.index = 1
end
jge.ncs.Component.register_component("turnsystem", TurnSystem);
