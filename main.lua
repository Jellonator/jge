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
local camera = tree:add_component("camera", 400, 224)

local player_script = {}
function player_script:on_init(node)end
function player_script:on_update(node, dt)
	local up    = inputmanager:get_event("up");
	local left  = inputmanager:get_event("left");
	local right = inputmanager:get_event("right");
	local down  = inputmanager:get_event("down");
	local dx,dy = 0,0
	if up    then dy = dy - 1 end
	if down  then dy = dy + 1 end
	if left  then dx = dx - 1 end
	if right then dx = dx + 1 end
	local len = math.sqrt(dx*dy)
	if len > 1 then
		dx = dx / len
		dy = dy / len
	end
	dx = dx * 64 * dt
	dy = dy * 64 * dt
	if up and not down then
		node:get_component("animation"):play("up")
	elseif left and not right then
		node:get_component("animation"):play("left")
	elseif right and not left then
		node:get_component("animation"):play("right")
	elseif down and not up then
		node:get_component("animation"):play("down")
	end
	if dx == 0 and dy == 0 then
		node:get_component("animation"):pause()
	else
		node:get_component("animation"):play()
	end
	node.transform:translate(dx, dy)

	-- local x,y = love.mouse.getPosition()
	local x, y = camera.camera:mousePosition();
	x, y = node:transform_point_inv(x,y)
	local pt = node:get_component("drawable_circle")
	pt.x = x
	pt.y = y
end

function love.load(arg)
	local n = tree:add_child()
	n:add_component("spritemap", love.graphics.newImage("res/Girl.png"),{
		{ 0,  0, 16, 16}, {16,  0, 16, 16}, {32,  0, 16, 16},
		{ 0, 16, 16, 16}, {16, 16, 16, 16}, {32, 16, 16, 16},
		{ 0, 32, 16, 16}, {16, 32, 16, 16}, {32, 32, 16, 16},
		{ 0, 48, 16, 16}, {16, 48, 16, 16}, {32, 48, 16, 16},
	}, nil, 0, 0, 0, 1, 1, 8, 8);
	n:add_component("animation", {
		down  = {{1,{sprite= 1}}, {1,{sprite= 2}}, {1,{sprite= 3}}, {1,{sprite= 2}}},
		left  = {{1,{sprite= 4}}, {1,{sprite= 5}}, {1,{sprite= 6}}, {1,{sprite= 5}}},
		right = {{1,{sprite= 7}}, {1,{sprite= 8}}, {1,{sprite= 9}}, {1,{sprite= 8}}},
		up    = {{1,{sprite=10}}, {1,{sprite=11}}, {1,{sprite=12}}, {1,{sprite=11}}},
	}, {
		sprite={component="spritemap", func="set_frame"},
	}, 6);
	n:add_component("script", player_script)
	n:add_component("drawable_circle", "fill", 0, 0, 2, {0, 100, 200})
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
