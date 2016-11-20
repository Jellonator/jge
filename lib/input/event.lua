local Event = {}
Event.__index = Event;

function Event:set_keyboard(keycode, release, is_repeat)
	self.keycode = keycode
	self.release = jge.try_or(release, false)
	self.is_repeat = jge.try_or(is_repeat, false)
end

function Event:set_directory(dir)
	self.directory = dir;
end

function Event:set_mousemove(x, y, relx, rely, touch)
	self[1] = x
	self[2] = y
	self.x = x
	self.y = y
	self.rx = relx
	self.ry = rely
	self.is_touch = touch
end

function Event:set_mousebutton(x, y, button, release)
	self.button = button
	self.release = release
	self[1] = x
	self[2] = y
	self.x = x
	self.y = y
end

function Event:set_mousewheel(x, y)
	self[1] = x
	self[2] = y
	self.x = x
	self.y = y
end

function Event:set_windowresize(x, y)
	self[1] = x
	self[2] = y
	self.x = x
	self.y = y
end

function Event.new(event_type, ...)
	local self = setmetatable({
		taken = false,
		event_type = event_type or EVENTTYPE.null
	}, Event);

	if event_type == EVENTTYPE.keyboard then
		self:set_keyboard(...);
	elseif event_type == EVENTTYPE.directory then
		self:set_directory(...);
	elseif event_type == EVENTTYPE.mousemove then
		self:set_mousemove(...);
	elseif event_type == EVENTTYPE.mousebutton then
		self:set_mousebutton(...);
	elseif event_type == EVENTTYPE.mousewheel then
		self:set_mousewheel(...);
	elseif event_type == EVENTTYPE.windowresize then
		self:set_windowresize(...);
	end

	return self
end

function Event:take()
	self.taken = true;
end

return setmetatable(Event, {
	__call = function(t, ...)
		return Event.new(...);
	end
})
