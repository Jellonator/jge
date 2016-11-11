-- A few default components
local NAME = ...

require(NAME .. ".camera")
require(NAME .. ".anim")
require(NAME .. ".draw")
require(NAME .. ".col")

-- Script, intended to override basic functions such as on_update and on_draw
local Script = {}
function Script:on_init(t, ...)
	if not t then return end
	for k,v in pairs(t) do
		self[k] = v
	end
	if t.on_init then
		t.on_init(self, ...)
	end
end
register_component("script", Script);
