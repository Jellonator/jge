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
tree = root:add_child("tree")
tree:add_component("camera", 400, 224)

function love.load(arg)
	local n = tree:add_child()
	local spritemap = n:add_component("spritemap",
		love.graphics.newImage("res/Girl.png"),{
		{ 0,  0, 16, 16}, {16,  0, 16, 16}, {32,  0, 16, 16},
		{ 0, 16, 16, 16}, {16, 16, 16, 16}, {32, 16, 16, 16},
		{ 0, 32, 16, 16}, {16, 32, 16, 16}, {32, 32, 16, 16},
		{ 0, 48, 16, 16}, {16, 48, 16, 16}, {32, 48, 16, 16},
	}, nil, 0, 0, 0, 1, 1, 16, 16);
	local anim = n:add_component("animation", {
		down  = {{1,{sprite= 1}}, {1,{sprite= 2}}, {1,{sprite= 3}}, {1,{sprite= 2}}},
		left  = {{1,{sprite= 4}}, {1,{sprite= 5}}, {1,{sprite= 6}}, {1,{sprite= 5}}},
		right = {{1,{sprite= 7}}, {1,{sprite= 8}}, {1,{sprite= 9}}, {1,{sprite= 8}}},
		up    = {{1,{sprite=10}}, {1,{sprite=11}}, {1,{sprite=12}}, {1,{sprite=11}}},
	}, {
		sprite={component="spritemap", func="set_frame"},
	}, 6)
end

function love.update(dt)
	root:update(dt);
end

function love.draw()
	root:draw(dt);
	love.graphics.setColor(255, 0, 0);
	love.graphics.print(("FPS: %.2f"):format(love.timer.getFPS()))
end

function love.quit()

end
