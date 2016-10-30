local Tween = {}
Tween.__index = Tween;

--[[
values = {
	{time, {var=val,var2=val, ...}},
	{time, {var=val, ...}},
	...
}
Possible metadata:
wraparound - whether interpolation should occur when looping back around
interpolation
--]]
local _defaultmeta = {
	rot = {wraparound = false},
	r = {wraparound = false},
	angle = {wraparound = false},
	rotation = {wraparound = false},
	_default = {
		wraparound = true,
		interpolation = "linear"
	}
}

function Tween.new(object, values, meta)
	return setmetatable({
		object = object,
		values = values,
		meta = meta or {},
		i = 1,
		t = 0,
		_i_am_a_tween = true
	}, Tween)
end

function Tween:get_current()
	return self.values[self.i]
end

function Tween:get_next(c)
	local c = c or 1
	return self.values[((self.i + c - 1) % #self.values) + 1]
end

-- function Tween:get_next_k(key, c, i)
-- 	local c = c or 1
-- 	local i = i or self.i
-- 	if c == 0 then
-- 		return self.values[i]
-- 	elseif c > 0 then
-- 		i = i + 1
-- 		if self.values[i][c] then
-- 			c = c - 1
-- 		end
-- 		return self:get_next_k(key, c, i)
-- 	else
-- 		i = i - 1
-- 		if self.values[i][c] then
-- 			c = c + 1
-- 		end
-- 		return self:get_next_k(key, c, i)
-- 	end
-- end

local function _getmeta(meta, valname, key)
	if meta[valname] and meta[valname][key] ~= nil then
		return meta[valname][key]

	elseif meta._default and meta._default[key] ~= nil then
		return meta._default[key]

	elseif meta ~= _defaultmeta then
		return _getmeta(_defaultmeta, valname, key)
	end
end

function Tween:get_meta(valname, key)
	return _getmeta(self.meta, valname, key)
end

function Tween:_apply()
	local next = self:get_next()
	local current = self:get_current();
	local prev = self:get_next(-1)
	local next_next = self:get_next(2);

	local nextvals = next[2]
	local currentvals = current[2]
	local nextnextvals = next_next[2];
	local prevvals = prev[2];

	local currentlength = current[1]
	local lerp = self.t / currentlength;
	local nlerp = 1-lerp
	local at_end = self.i >= #self.values;

	for k,v in pairs(currentvals) do
		local object = self:get_meta(k, "object") or self.object;
		local func = self:get_meta(k, "func");
		local interpolation = self:get_meta(k, "interpolation")
		local is_linear = interpolation == "linear"
		local is_cubic = interpolation == "cubic"
		local is_interpolated = is_linear or is_cubic

		local value;
		if is_interpolated and nextvals[k] and type(v) == "number"
		and type(nextvals[k]) == "number"
		and (not at_end or self:get_meta(k, "wraparound")) then
			if is_cubic then
				local p0 = v
				local p1 = nextvals[k]

				-- Simple finite difference spline
				local mpre = (p0 - prevvals[k]) / prev[1]
				local mcur = (p1 - p0) / currentlength
				local mpost= (nextnextvals[k] - p1) / next[1]
				local m0 = (mpre+mcur)/2
				local m1 = (mcur+mpost)/2

				-- Cubic hermite interpolation
				local lerp2 = lerp*lerp
				local lerp3 = lerp2*lerp
				value =
				  p0 * ( 2*lerp3 - 3*lerp2 +    1)
				+ m0 * (   lerp3 - 2*lerp2 + lerp)
				+ p1 * (-2*lerp3 + 3*lerp2       )
				+ m1 * (   lerp3 -   lerp2       )
			else
				-- linear
				value = lerp*nextvals[k] + nlerp*v
			end
		else -- none
			value = v
		end

		if func then
			func(object, value)
		else
			object[self:get_meta(k, "key") or k] = value
		end
	end
end

function Tween:step(dt)
	self.t = self.t + dt;
	while self.t >= self.values[self.i][1] do
		self.t = self.t - self.values[self.i][1];
		self.i = self.i + 1;
		if self.i > #self.values then
			self.i = 1
		end
	end
	self:_apply();
end
Tween.update = Tween.step;

return setmetatable(Tween, {
	__call = function(t, ...)
		return Tween.new(...)
	end
})
