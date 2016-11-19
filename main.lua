lib = require("lib");
require("battle");
do
	local major, minor, patch, codename = love.getVersion()
	printf("Love2d version %d.%d.%d %s, running on %s",
		major, minor, patch, codename, _VERSION)
end
love.graphics.setDefaultFilter("nearest", "nearest")
inputmanager = lib.Input.Manager();
inputmanager:add_event("up",    lib.Input.IMatch(EVENTTYPE.keyboard, "w"))
inputmanager:add_event("down",  lib.Input.IMatch(EVENTTYPE.keyboard, "s"))
inputmanager:add_event("left",  lib.Input.IMatch(EVENTTYPE.keyboard, "a"))
inputmanager:add_event("right", lib.Input.IMatch(EVENTTYPE.keyboard, "d"))
inputmanager:add_event("jump",  lib.Input.IMatch(EVENTTYPE.keyboard, "space"))
inputmanager:add_event("rotl",  lib.Input.IMatch(EVENTTYPE.keyboard, "q"))
inputmanager:add_event("rotr",  lib.Input.IMatch(EVENTTYPE.keyboard, "e"))
inputmanager:override_love();

-- tree.transform:scale(6)
local tree, camera
local update_delta = 1/60;
local update_timer = 0;
local MAX_UPDATE_FRAMES = 2;
local is_in_update = false;
local old_get_delta = love.timer.getDelta;
love.timer.getDelta = function()
	if is_in_update then return update_delta
	else return old_get_delta() end
end

function generate_solid(...)
	local n = tree:add_child();
	local body = n:add_component("collisionbody", "polygon", ...);
	n:add_component("drawable_polygon", 'line', {0,0,255}, ...)
	body.shape:set_mask("solid")
end

function generate_script(script, ...)
	local n = tree:add_child();
	n:add_component("script", script, ...)
end

function generate_json(jfile, x, y)
	local n = tree:add_child();
	n:from_json(jfile);
	n.transform:translate(x or 0, y or 0)
end

function set_tree(newtree)
	tree = newtree
	if not tree:has_component("camera") then
		tree:add_component("camera", 400*2, 224*2)
	end
	camera = tree:get_component("camera")
end

function get_tree()
	return tree
end

function love.load(arg)
	tree = lib.ncs.Node();
	camera = tree:add_component("camera", 400*2, 224*2)
	tree:add_component("collisionworld");
	-- tree.transform:translate(400, 224)
	-- camera:set_position(4*400, 4*224)

	-- tree = root:add_child("tree");
	tree:add_component("tiledmaploader", "res/testlevel.lua")
end

-- make sure that calls to love.timer.getDelta are update_delta inside of
-- update function. This is important for camera locking functionality!
function love.update(dt)
	update_timer = update_timer + dt;
	local i = 0;
	is_in_update = true;
	while update_timer >= update_delta and i < MAX_UPDATE_FRAMES do
		update_timer = update_timer - update_delta;
		tree:update(update_delta);
		i = i + 1
	end
	is_in_update = false;
	update_timer = update_timer % update_delta;

	tree:update_real(dt);
end

function love.draw()
	if update_timer > update_delta then print("timer is greater than delta!") end
	tree:draw(1)--update_timer/update_delta);
	love.graphics.setColor(255, 0, 0);
	love.graphics.print(("FPS: %.2f"):format(love.timer.getFPS()))
	-- love.graphics.polygon("fill", 100,100, 400,200, 300,300)
end

function love.quit()

end
