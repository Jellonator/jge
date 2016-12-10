local NAME = ...

local ncs = {
	Node      = require(NAME .. ".node"),
	Component = require(NAME .. ".component"),
	Prefab    = require(NAME .. ".prefab")
}

register_component = ncs.Component.register_component;
require(NAME .. ".default");
register_component = nil

return ncs;
