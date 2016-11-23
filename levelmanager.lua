local LevelManager = {}

function LevelManager:on_init()
	self.levels = {}
end

function LevelManager:load_level(levelname, x, y)
	if self.node:has_child(levelname) then return end
	local node = self.node:add_child(levelname);
	node.transform:set_translation(x or 0, y or 0)
	local level = node:add_component("tiledmaploader", levelname)
	self.levels[levelname] = levelname;
	return node, level;
end

function LevelManager:remove_level(levelname, next, ...)
	print("Removing level:", levelname)
	self.levels[levelname] = nil;
	self.node:remove_child(levelname)
	if next then return self:remove_level(next, ...) end
end

function LevelManager:clear_levels()
	for name in pairs(self.levels) do
		print("Removing level:", name)
		self.node:remove_child(name)
	end
	self.levels = {}
end

function LevelManager:set_level(levelname, x, y)
	self:clear_levels();
	return self:load_level(levelname, x, y)
end

jge.ncs.Component.register_component("levelmanager", LevelManager)
