local loadzone = {}

local default_player_json = "res/Player/player.json"
function loadzone:on_init()
	local body = self.node:get_component("collisionbody");
	body:disable();
end

return loadzone;
