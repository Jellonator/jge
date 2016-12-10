-- A few default components
local NAME = ...

require(NAME .. ".camera")
require(NAME .. ".anim")
require(NAME .. ".draw")
require(NAME .. ".col")

local _file_cache = {}
local function require_file(file)
	_file_cache[file] = _file_cache[file] or love.filesystem.load(jge.fix_path(file))()
	return _file_cache[file];
end

-- Script, intended to override basic functions such as on_update and on_draw
local Script = {}
function Script:on_init(t, ...)
	-- if not t then return end
	if type(t) == "string" then
		t = require_file(t);
	end
	for k,v in pairs(t) do
		self[k] = v
	end
	if t.on_init then
		t.on_init(self, ...)
	end
end
function Script:from_json(json)
	for k,v in pairs(json) do
		self[k] = v
	end
	self:on_init(json.script);
end
register_component("script", Script);
