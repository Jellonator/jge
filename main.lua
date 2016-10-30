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

root = lib.ncs.Node();
tree = root:add_child("tree")
tree:add_component("camera", 400*2, 224*2)

function love.load(arg)
	local n = tree:add_child("child")
	n:add_component("tween", {
		{.5,{x=   0, y= 100}},
		{.5,{x=   0, y=  50}},
		{.5,{x=   0, y=   0}},
		{.5,{x=   0, y= -50}},
		-- {1,{x=   0, y=  50}},
		{2,{x=   0, y=-100}},
	},
	{
		x={object=n.transform,func=n.transform.set_x,interpolation="cubic"},
		y={object=n.transform,func=n.transform.set_y,interpolation="cubic"}
	})
	n:add_component("drawable_rectangle", "fill", -40, -40, 40, 40);
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
