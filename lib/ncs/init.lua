local NAME = ...

local ncs = {
	Node      = require(NAME .. ".node"),
	Component = require(NAME .. ".component"),
	Prefab    = require(NAME .. ".prefab")
}

return ncs;
