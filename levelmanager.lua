local LevelManager = {}

function LevelManager:on_init()
	self.levels = {}
end

function LevelManager:load_level(levelname, x, y)
	-- if self.node:has_child(levelname) then return end
	local node = self.node:add_child();
	node.transform:set_translation(x or 0, y or 0)
	local level = node:add_component("tiledmaploader", levelname)
	table.insert(self.levels, node)
	return node, level;
end

function LevelManager:clear_levels()
	for _, node in pairs(self.levels) do
		self.node:remove_child(node)
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
		level_node.transform:set_translation(x, y)
		table.insert(translate_nodes, level_node)
		for _, node in pairs(rm_levels) do
			table.insert(translate_nodes, node)
		end
		local _, camera = self.node:get_parent_with_component("camera");
		mx, my = jge.vlt.mul(-2, camera:world_coords_diff(mx, my))
		local len = jge.vlt.len(mx, my)
		local normx, normy = jge.vlt.normalize(mx, my);
		-- level_node:_update_children();
		level_node:get_root():_finalize_reset_draws();
		level_node:get_root():_finalize_reset_updates();
		level_node:get_root():_transformed();

		local is_first_iteration = true
		local do_sleep = false;
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

			if do_sleep then
				love.timer.sleep(0.4)
				do_sleep = false;
				love.timer.step()
			end
			if is_first_iteration then
				do_sleep = true;
				is_first_iteration = false;
			end
			self.node:get_root():draw(0)

			for _,node in pairs(translate_nodes) do
				node.transform:translate(dx, dy)
			end
		end)
		if do_sleep then
			love.timer.sleep(0.4)
		end
		level_node.transform:set_translation(0, 0);
	end
	for _, node in pairs(rm_levels) do
		print("Removing level:", name)
		self.node:remove_child(node)
	end

	return level_node, level;
end

jge.ncs.Component.register_component("levelmanager", LevelManager)
