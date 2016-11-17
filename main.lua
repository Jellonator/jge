lib = require("lib");
love.graphics.setDefaultFilter("nearest", "nearest")
inputmanager = lib.Input.Manager();
inputmanager:add_event("up",    lib.Input.IMatch(EVENTTYPE.keyboard, "w"))
inputmanager:add_event("down",  lib.Input.IMatch(EVENTTYPE.keyboard, "s"))
inputmanager:add_event("left",  lib.Input.IMatch(EVENTTYPE.keyboard, "a"))
inputmanager:add_event("right", lib.Input.IMatch(EVENTTYPE.keyboard, "d"))
inputmanager:add_event("rotl",  lib.Input.IMatch(EVENTTYPE.keyboard, "q"))
inputmanager:add_event("rotr",  lib.Input.IMatch(EVENTTYPE.keyboard, "e"))
inputmanager:override_love();

root = lib.ncs.Node();
local camera = root:add_component("camera", 400*2, 224*2)
root:add_component("collisionworld");

tree = root:add_child("tree");
tree:add_component("tiledmaploader", "res/testlevel.lua")
-- tree.transform:scale(6)

function generate_solid(...)
	local n = tree:add_child();
	local body = n:add_component("collisionbody", "polygon", ...);
	n:add_component("drawable_polygon", 'line', {0,0,255}, ...)
	body.shape:set_mask("solid")
end
generate_solid(-150,-100, 100,-100, 25,-25, -125,-25, -100,-50)

function generate_script(script, ...)
	local n = tree:add_child();
	n:add_component("script", script, ...)
end

function generate_json(jfile, x, y)
	local n = tree:add_child();
	n:from_json(jfile);
	n.transform:translate(x or 0, y or 0)
end

function love.load(arg)
	generate_json("res/Player/player.json", -50, 0)
end

local update_delta = 1/60;
local update_timer = 0;
local MAX_UPDATE_FRAMES = 2;

-- make sure that calls to love.timer.getDelta are update_delta inside of
-- update function. This is important for camera locking functionality!
local is_in_update = false;
local old_get_delta = love.timer.getDelta;
love.timer.getDelta = function()
	if is_in_update then return update_delta
	else return old_get_delta() end
end

function love.update(dt)
	update_timer = update_timer + dt;
	local i = 0;
	is_in_update = true;
	while update_timer >= update_delta and i < MAX_UPDATE_FRAMES do
		update_timer = update_timer - update_delta;
		root:update(update_delta);
		i = i + 1
	end
	is_in_update = false;
	update_timer = update_timer % update_delta;

	root:update_real(dt);
end

function love.draw()
	if update_timer > update_delta then print("timer is greater than delta!") end
	root:draw(update_timer/update_delta);
	love.graphics.setColor(255, 0, 0);
	love.graphics.print(("FPS: %.2f"):format(love.timer.getFPS()))
	-- love.graphics.polygon("fill", 100,100, 400,200, 300,300)
end

function love.quit()

end
