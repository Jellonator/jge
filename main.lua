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


local player_script = {}
function player_script:on_init(x, y)
	print(x, y)
	local x = x or 0
	local y = y or 0
	self.speed = 64*3
	self.node.transform:translate(x, y)
	self.node.transform:scale(2)
	self.node:add_component("spritemap", love.graphics.newImage("res/Girl.png"),{
		{ 0,  0, 16, 16}, {16,  0, 16, 16}, {32,  0, 16, 16},
		{ 0, 16, 16, 16}, {16, 16, 16, 16}, {32, 16, 16, 16},
		{ 0, 32, 16, 16}, {16, 32, 16, 16}, {32, 32, 16, 16},
		{ 0, 48, 16, 16}, {16, 48, 16, 16}, {32, 48, 16, 16},
	}, nil, 0, 0, 0, 1, 1, 8, 8);
	self.node:add_component("animation", {
		down  = {{1,{sprite= 1}}, {1,{sprite= 2}}, {1,{sprite= 3}}, {1,{sprite= 2}}},
		left  = {{1,{sprite= 4}}, {1,{sprite= 5}}, {1,{sprite= 6}}, {1,{sprite= 5}}},
		right = {{1,{sprite= 7}}, {1,{sprite= 8}}, {1,{sprite= 9}}, {1,{sprite= 8}}},
		up    = {{1,{sprite=10}}, {1,{sprite=11}}, {1,{sprite=12}}, {1,{sprite=11}}},
	}, {
		sprite={component="spritemap", func="set_frame"},
	}, 6);
	self.node:add_component("drawable_circle", "fill", 0, 0, 2, {0, 100, 200})
	local body = self.node:add_component("collisionbody", "rectangle", -4, 0, 8, 8)
	body.shape:set_mask("player")
	body.shape:add_layer("solid")
end
function player_script:on_update(dt)
	-- get inputs
	local up    = inputmanager:get_event("up");
	local left  = inputmanager:get_event("left");
	local right = inputmanager:get_event("right");
	local down  = inputmanager:get_event("down");

	-- calculate direction (dx, dy)
	local dx = (left and -1 or 0) + (right and 1 or 0)
	local dy = (up and -1 or 0) + (down and 1 or 0)
	dx,dy = lib.vlt.mul(self.speed*dt, lib.vlt.trim(1, dx,dy));

	-- play animations
	if up and not down then
		self.node:get_component("animation"):play("up")
	elseif left and not right then
		self.node:get_component("animation"):play("left")
	elseif right and not left then
		self.node:get_component("animation"):play("right")
	elseif down and not up then
		self.node:get_component("animation"):play("down")
	end
	if dx == 0 and dy == 0 then
		self.node:get_component("animation"):pause()
	else
		self.node:get_component("animation"):play()
	end

	-- movement
	local body = self.node:get_component("collisionbody")
	body:move(dx, dy)--, 10, true)

	-- mouse dot detection
	local x, y = camera.camera:mousePosition();
	local pt = self.node:get_component("drawable_circle")
	pt.color[1] = body:contains_point(x, y) and 255 or 0
	pt.x, pt.y = self.node:transform_point_inv(x, y)
end

function player_script:on_update_real(dt)
	local cx, cy = self.node:getpos()
	camera.camera:lockPosition(cx, cy, lib.hcam.smooth.damped(5))
end

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

function love.load(arg)
	generate_script(player_script, -50, 0)
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
