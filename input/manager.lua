local Manager = {}
Manager.__index = Manager;

function Manager.new()
	local self = setmetatable({}, Manager);
	self.events = {}
	self.callbacks = setmetatable({}, {__mode = "v"})
	return self
end

function Manager:get_event(name)
	local ev = self.events[name]
	if not ev then return false end
	return ev.is_down
end

function Manager:add_event(name, imatch)
	self.events[name] = imatch
end

function Manager:add_callback(ename, t, fname, ...)
	local key = {ename=ename, fname=fname, args={...}}
	self.callbacks[key] = t
	return key
end

function Manager:remove_callback(key)
	self.callbacks[key] = nil
end

function Manager:poll(event)
	for imatchname, imatch in pairs(self.events) do
		if imatch:match(event) then
			for calldata, t in pairs(self.callbacks) do
				if calldata.ename == imatchname
				and t[calldata.fname](t,unpack(calldata.args)) then
					return true
				end
			end
		end
	end
	return false
end

function Manager:override_love()
	function love.keypressed(keycode, _, isrepeat)
		self:poll(jge.Input.Event(EVENTTYPE.keyboard, keycode, false, isrepeat))
	end

	function love.keyreleased(keycode)
		self:poll(jge.Input.Event(EVENTTYPE.keyboard, keycode, true, false))
	end

	function love.mousepressed(x, y, button, isTouch)
		self:poll(jge.Input.Event(EVENTTYPE.mousebutton, x, y, button, false))
	end

	function love.mousereleased(x, y, button, isTouch)
		self:poll(jge.Input.Event(EVENTTYPE.mousebutton, x, y, button, true))
	end

	function love.mousemoved(x, y, dx, dy)
		self:poll(jge.Input.Event(EVENTTYPE.mousemove, x, y, dx, dy))
	end

	function love.wheelmoved(x, y)
		self:poll(jge.Input.Event(EVENTTYPE.mousewheel, x, y))
	end
end

return setmetatable(Manager, {
	__call = function(t, ...)
		return Manager.new(...)
	end
})
