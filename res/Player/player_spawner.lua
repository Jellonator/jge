local player_spawner = {}

local default_player_json = "res/Player/player.json"
function player_spawner:on_init()
	local x, y = self.node:getpos();
	local body = self.node:get_component("collisionbody");
	if body then body:disable() end
	if not self.node:get_root():find_node_group("player") then
		local player = self.node:get_root():add_child("player");
		player:from_json(default_player_json);
		player.transform:set_translation(x, y)
	end
end

return player_spawner;
