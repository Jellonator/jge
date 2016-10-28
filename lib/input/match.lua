local IMatch = {}
IMatch.__index = IMatch;

local WHEELDIR = {
	left = 1,
	right = 2,
	up = 3,
	down = 4
}

function IMatch:set_keyboard(keycode, release, allow_repeat)
	self.event_type = EVENTTYPE.keyboard;
	self.keycode = keycode;
	self.release = try_or(release, false);
	self.allow_repeat = try_or(allow_repeat, false);
	return self
end

function IMatch:set_mousebutton(button, release, x1, y1, x2, y2)
	if y2 then
		self:set_mousearea_aabb(x1, y1, x2, y2);
	else
		self:set_mousearea_radial(x1, y1, x2);
	end
	self.event_type = EVENTTYPE.mousebutton;
	self.button = button
	self.release = try_or(release, false);
	return self
end

function IMatch:set_mousewheel(dir)
	self.event_type = EVENTTYPE.mousewheel;
	self.wheel = WHEELDIR[dir] or 0
	return self
end

function IMatch:set_mousearea_radial(x, y, radius)
	self.event_type = EVENTTYPE.mousemove;
	self[1] = x
	self[2] = y
	self.x = x
	self.y = y
	self.radius = radius
	return self
end

function IMatch:set_mousearea_aabb(x1, y1, x2, y2)
	self.event_type = EVENTTYPE.mousemove;
	self.x1 = math.min(x1, x2);
	self.x2 = math.max(x1, x2);
	self.y1 = math.min(y1, y2);
	self.y2 = math.max(y1, y2);
	self.radius = nil
	return self
end

--[[function IMatch.from_string(s)

end]]

function IMatch.new(event_type, ...)
	local self = setmetatable({
		event_type = event_type or EVENTTYPE.null
	}, IMatch);

	if event_type == EVENTTYPE.keyboard then
		self:set_keyboard(...)
	elseif event_type == EVENTTYPE.mousebutton then
		self:set_mousebutton(...)
	elseif event_type == EVENTTYPE.mousewheel then
		self:set_mousewheel(...)
	elseif event_type == EVENTTYPE.mousemove then
		local args = {...}
		if #args == 4 then
			self:set_mousearea_aabb(...)
		else
			self:set_mousearea_radial(...)
		end
	end

	return self
end

function IMatch:match(event)
	if self.event_type ~= event.event_type then
		return false
	end
	if self.event_type == EVENTTYPE.mousemove
	or self.event_type == EVENTTYPE.mousebutton and (self.radius or self.y2) then
		if self.radius then
			local diffx = self.x - event.x
			local diffy = self.y - event.y
			local radius = self.radius
			if not (diffx*diffx + diffy*diffy < radius*radius) then
				return false
			end
		else
			if not (event.x >= self.x1 and event.x <= self.x2
			and event.y >= self.y1 and event.y <= self.y2) then
				return false
			end
		end
	end
	if self.event_type == EVENTTYPE.keyboard then
		return self.keycode == event.keycode and self.release == event.release
		and (self.allow_repeat or not event.is_repeat)

	elseif self.event_type == EVENTTYPE.mousebutton then
		return self.button == event.button and self.release == event.release

	elseif self.event_type == EVENTTYPE.mousewheel then
		return self.wheel == WHEELDIR.left  and event.x < 0
		or     self.wheel == WHEELDIR.right and event.x > 0
		or     self.wheel == WHEELDIR.up    and event.y > 0
		or     self.wheel == WHEELDIR.down  and event.y < 0

	elseif self.event_type == EVENTTYPE.mousemove then
		return true
	end

	return false
end

return setmetatable(IMatch, {
	__call = function(t, ...)
		return IMatch.new(...);
	end
})
