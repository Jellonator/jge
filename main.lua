require("lib");
require("levelmanager");
do
	local major, minor, patch, codename = love.getVersion()
	jge.printf("Love2d version %d.%d.%d %s, running on %s",
		major, minor, patch, codename, _VERSION)
end
love.graphics.setDefaultFilter("nearest", "nearest")
inputmanager = jge.Input.Manager();
inputmanager:add_event("up",    jge.Input.IMatch(EVENTTYPE.keyboard, "w"))
inputmanager:add_event("down",  jge.Input.IMatch(EVENTTYPE.keyboard, "s"))
inputmanager:add_event("left",  jge.Input.IMatch(EVENTTYPE.keyboard, "a"))
inputmanager:add_event("right", jge.Input.IMatch(EVENTTYPE.keyboard, "d"))
inputmanager:add_event("jump",  jge.Input.IMatch(EVENTTYPE.keyboard, "space"))
inputmanager:add_event("rotl",  jge.Input.IMatch(EVENTTYPE.keyboard, "q"))
inputmanager:add_event("rotr",  jge.Input.IMatch(EVENTTYPE.keyboard, "e"))
inputmanager:add_event("slow",  jge.Input.IMatch(EVENTTYPE.keyboard, "r"))
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

love.timer.getRealDelta = function()
	return old_get_delta()
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

function get_camera_size()
	return 400, 240
end

function set_tree(newtree)
	tree = newtree
	if not tree:has_component("camera") then
		tree:add_component("camera", get_camera_size)
	end
	camera = tree:get_component("camera")
end

function get_tree()
	return tree
end

function love.load(arg)
	print("ARGS")
	for k,v in pairs(arg) do
		print(k, v)
	end
	print()
	tree = jge.ncs.Node();
	camera = tree:add_component("camera", get_camera_size())
	tree:add_component("collisionworld");

	local the_manager_is_here = tree:add_component("levelmanager");
	local f = arg[2]
	if f then
		local pos = f:find("/res/")
		if pos then
			f = f:sub(pos+1)
		end
		f = f:gsub("Source/([^%.]*)%.tmx", "%1.lua")
	end

	the_manager_is_here:load_level(f or "res/Worlds/Underground/enterance.lua")
end

-- make sure that calls to love.timer.getDelta are update_delta inside of
-- update function. This is important for camera locking functionality!
function love.update(dt)
	if inputmanager:get_event("slow") then dt = dt / 10 end
	update_timer = update_timer + dt;
	local i = 0;
	is_in_update = true;
	while update_timer >= update_delta and i < MAX_UPDATE_FRAMES do
		-- tree:set_debug_depth(525600)
		update_timer = update_timer - update_delta;
		tree:update(update_delta);
		i = i + 1
	end
	is_in_update = false;
	update_timer = update_timer % update_delta;
	tree:update_real(dt);
	collectgarbage("step")
end

local do_discard_frame = false;
function main_discard_frame()
	do_discard_frame = true
end

function love.draw()
	if do_discard_frame then
		print("DISCARDED FRAME")
		love.update(update_delta)
		do_discard_frame = false;
		tree:draw(0)
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.origin()
	end
	if update_timer > update_delta then print("timer is greater than delta!") end
	tree:draw(0)--update_timer/update_delta);
	love.graphics.setColor(255, 0, 0);
	love.graphics.print(("FPS: %.2f"):format(love.timer.getFPS()))
	-- tree:debug_draw("root")--, 8, 16);
	-- love.graphics.polygon("fill", 100,100, 400,200, 300,300)
end

function override_main_loop(f)
	love.graphics.push()
	local old_is_in_update = is_in_update
	is_in_update = false
	love.timer.step()
	local dt = 0

	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				-- if name == "quit" then
				-- 	if not love.quit or not love.quit() then
				-- 		return a
				-- 	end
				-- end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end

		-- Call update and draw
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
		end
		local ret = f(dt)
		if love.graphics and love.graphics.isActive() then
			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
		if ret then return ret end
	end
	is_in_update = old_is_in_update
	love.graphics.pop()
	love.timer.step()
end

function love.quit()

end
