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

	local level_node, level = self:load_level(levelname)
	local _, camera = self.node:get_parent_with_component("camera");
	local start_x, start_y = camera:get_bounded_position()
	if mfunc then
		local x, y, player = mfunc(level_node, level);
		level:bind_camera();
		player:get_root():add_child(player)
		local end_x, end_y = camera:get_bounded_position()
		start_x, start_y = start_x - x, start_y - y

		camera.camera:setBounds();

		camera.camera.x = start_x
		camera.camera.y = start_y

		for _, node in pairs(rm_levels) do
			table.insert(translate_nodes, node)
		end
		for _,node in pairs(translate_nodes) do
			node.transform:translate(-x, -y)
		end

		level_node:get_root():_finalize_reset_draws();
		level_node:get_root():_finalize_reset_updates();
		-- level_node:get_root():_transformed();

		local len = jge.vlt.dist(start_x, start_y, end_x, end_y)
		local total_len = len;

		local is_first_iteration = true
		local do_sleep = false;
		override_main_loop(function(dt)
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

			local dx, dy = 0, 0
			if len > 0 then
				local lerp = len / total_len
				camera.camera.x = jge.lerp(1-lerp, start_x, end_x)
				camera.camera.y = jge.lerp(1-lerp, start_y, end_y)
				len = jge.to(len, 0, dt*speed)
			else
				return true;
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
