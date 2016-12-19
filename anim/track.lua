local Track = {}
Track.__index = Track
local nullfunc = function()end

local interpolation_functions = {
	none = function(a, b, lerp)
		return a
	end,
	linear = function(a, b, lerp)
		return a*(1-lerp) + b*lerp
	end,
}

--[[
Data format:
{{4,1}, {3,1}, {2}}
--]]
function Track.new(data, func, interpolation, loop)
	interpolation = interpolation or "none"
	func = func or nullfunc
	loop = jge.try_or(loop, true)
	local self = setmetatable({
		func = func,
		interpolation = interpolation,
		data = {},
		length = 0,
		offset = 0,
		time = 0,
		current_i = 1,
		pos = 0,
		loop = loop,
		pvalue
	}, Track);
	if data then
		for _, datum in ipairs(data) do
			local value = datum[1] or datum.value
			local length = datum[2] or datum.length
			local other = datum[3]  or datum.other
			if other and length then
				local d = self:append_raw(value, other, length);
				d.can_replace = false
			elseif length then
				self:append(value, length)
			else
				self:append_stop(value)
			end
		end
	end
	return self
end

function Track:clone(func)
	local other = setmetatable({
		func = func or self.func,
		data = {},
		interpolation = self.interpolation,
		length = self.length,
		offset = self.offset,
		time = self.time,
		current_i = self.current_i,
		pos = self.pos,
		loop = self.loop,
		pvalue = self.pvalue
	}, Track)
	for i, d in ipairs(self.data) do
		other.data[i] = d
	end
	return other
end

function Track:get_length()
	return self.length
end

function Track:get_position()
	return self.pos + self.time
end

function Track:_call_func()
	self.func(self:get_current_value())
end

function Track:get_current_value()
	local d = self:get_current()
	local lerp = self.time/d.length
	return interpolation_functions[self.interpolation](d.a, d.b, lerp)
end

function Track:get_current()
	return self.data[self.current_i]
end

function Track:reset()
	self.pos = 0
	self.current_i = 1
	self.time = 0
	if self.func then
		local val = self:get_current_value()
		if val ~= self.pvalue then
			self.pvalue = val
			self.func(val)
		end
	end
end

function Track:set_loop(value)
	self.loop = value
end

function Track:set_position(p)
	self:reset()
	self:step(p)
end

function Track:step(dt)
	local ret = false;
	if self:get_position() < self:get_length() or self.loop then
		self.time = self.time + dt
	else
		ret = true
	end

	while self.time >= self:get_current().length do
		self.time = self.time - self:get_current().length
		self.pos = self.pos + self:get_current().length
		self.current_i = self.current_i + 1
		if self.current_i > #self.data then
			if self.loop then
				self.current_i = 1
				self.pos = 0
			else
				self.current_i = #self.data
				self.pos = self.length - self:get_current().length
				self.time = self:get_current().length
				ret = true
				break
			end
		end
	end
	if self.func then
		local val = self:get_current_value()
		if val ~= self.pvalue then
			self.pvalue = val
			self.func(val)
		end
	end
	return ret
end

function Track:get_first()
	return self.data[1]
end

function Track:get_last()
	return self.data[#self.data]
end

function Track:get_at(t)
	if self.length == 0 then
		return self:get_first()
	end
	t = (t+self.offset) % self.length
	local i = 1
	while t > 0 do
		local d = self.data[i]
		t = t - d.length
		i = i + 1
		if i > #self.data then
			return self:get_last().b
		end
	end
	return self.data[i]
end

function Track:append_raw(a, b, length)
	self.length = self.length + length
	local d = {a=a, b=b, length=length}
	table.insert(self.data, d)
	return self
end

function Track:append_stop(value)
	local last = self:get_last()
	if last then
		last.b = value or last.b
		last.can_replace = false
	else
		local v = self:append(value, 0)
		v.can_replace = false
	end
	return self
end

function Track:append(value, length)
	local last = self:get_last()
	local first = self:get_first()
	if last and last.can_replace ~= false then
		last.b = value
	end
	self:append_raw(value, first and first.a or value, length)
	return self
end

function Track:set_offset(offset)
	self.offset = offset
	return self
end

return setmetatable(Track, {
	__call = function(t, ...)
		return Track.new(...)
	end
})
