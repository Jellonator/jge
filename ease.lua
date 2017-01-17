local Ease = {}

local ebase = {}

function ebase.linear(t)
	return t
end

function ebase.quad(t)
	return t * t
end

function ebase.cubic(t)
	return t * t * t
end
ebase.cube = ebase.cubic

function ebase.quart(t)
	return t * t * t * t
end

function ebase.power(t, n)
	return t ^ n
end

function ebase.trig(t)
	return 1-math.cos(t * math.pi * 2)
end

function ebase.circ(t)
	return 1-math.sqrt(1 - t*t)
end

for name, func in pairs(ebase) do
	local in_function = func
	local out_function = function(t, ...)
		return 1 - func(1 - t, ...)
	end
	local inout_function = function(t, ...)
		if t < 0.5 then
			return in_function(t * 2) / 2
		else
			return out_function(t * 2 - 1) / 2 + 0.5
		end
	end
	Ease[name] = func
	Ease[name .. "_in"] = in_function
	Ease[name .. "_out"] = out_function
	Ease[name .. "_inout"] = inout_function
end

return Ease
