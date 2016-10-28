lib = require("lib");

inputmanager = lib.Input.Manager();
inputmanager:add_event("up",    lib.Input.IMatch(EVENTTYPE.keyboard, "w"))
inputmanager:add_event("down",  lib.Input.IMatch(EVENTTYPE.keyboard, "s"))
inputmanager:add_event("left",  lib.Input.IMatch(EVENTTYPE.keyboard, "a"))
inputmanager:add_event("right", lib.Input.IMatch(EVENTTYPE.keyboard, "d"))
inputmanager:add_event("rotl",  lib.Input.IMatch(EVENTTYPE.keyboard, "q"))
inputmanager:add_event("rotr",  lib.Input.IMatch(EVENTTYPE.keyboard, "e"))
-- inputmanager:add_callback("foo", printer, "foo", "There");
-- inputmanager:add_callback("bar", printer, "foo", "World");
inputmanager:override_love();

function love.load(arg)
	node = lib.ncs.Node(100, 100);
	-- node:add_component("drawable_rect", "fill");
	node.transform:scale(2, 1);

	child = node:add_child("foo");
	child:add_component("drawable_rect")

	inputmanager:add_callback("up",    child.transform, "translate",   0, -10)
	inputmanager:add_callback("down",  child.transform, "translate",   0,  10)
	inputmanager:add_callback("left",  child.transform, "translate", -10,   0)
	inputmanager:add_callback("right", child.transform, "translate",  10,   0)
	inputmanager:add_callback("rotl",  child.transform, "rotate", math.pi*-0.25/2)
	inputmanager:add_callback("rotr",  child.transform, "rotate", math.pi* 0.25/2)
end

function love.update(dt)
	node:update(dt);
end

function love.draw()
	node:draw(dt);
end

function love.quit()

end
