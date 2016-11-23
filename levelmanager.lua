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

function LevelManager:set_level(levelname, mfunc, speed, translate_nodes)
	speed = speed or 200;
	local rm_levels = self.levels;
	self.levels = {}

	local mx, my, x, y = 0,0,0,0;
	local level_node, level = self:load_level(levelname)
	if mfunc then
		mx, my, x, y = mfunc(level_node, level);
	end
	level_node.transform:set_translation(x, y)
	table.insert(translate_nodes, level_node)
	for name in pairs(rm_levels) do
		table.insert(translate_nodes, self.node:get_child(name))
	end
	if mfunc then
		-- level_node:_update_children();
		love.timer.sleep(0.25)
		level_node:get_root():_finalize_reset_draws();
		level_node:get_root():_finalize_reset_updates();
		level_node:get_root():_transformed();
		override_main_loop(function(dt)
			local dx, dy = 0, 0
			if math.abs(mx) > 0 then
				local new_mx = jge.to(mx, 0, dt*speed)
				dx = new_mx - mx
				mx = new_mx
			elseif math.abs(my) > 0 then
				local new_my = jge.to(my, 0, dt*speed)
				dy = new_my - my
				my = new_my
			else
				return true
			end

			self.node:get_root():draw(0)

			for _,node in pairs(translate_nodes) do
				node.transform:translate(dx, dy)
			end
		end)
	end
	for name in pairs(rm_levels) do
		print("Removing level:", name)
		self.node:remove_child(name)
	end
	level_node.transform:set_translation(0, 0);

	return level_node, level;
end

jge.ncs.Component.register_component("levelmanager", LevelManager)
