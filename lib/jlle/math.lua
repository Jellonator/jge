local Math = {}

local function _mod(a, n)
	return a - math.floor(a/n) * n
end

function Math.floor(val)
	return val > 0 and math.floor(val) or math.ceil(val);
end

function Math.angle_diff(a, b)
	local ret = a - b;
	ret = _mod(ret + math.pi, math.pi*2) - math.pi
	return ret;
end

function Math.tween_linear(prev, to, delta)
	local is_less = prev < to;
	if is_less then
		prev = prev + delta;
	else
		prev = prev - delta;
	end
	local new_less = prev < to;
	if new_less ~= is_less then
		return to;
	else
		return prev;
	end
end

function Math.clamp(val, min, max)
	if min > max then return Math.clamp(val, max, min) end
	return math.max(math.min(val, max), min)
end

function Math.clampabs(val, c)
	return Math.clamp(val, -math.abs(c), math.abs(c));
end

function Math.infnormal(val, num)
	return math.abs(val) / (math.abs(val) + num);
end

return Math;
