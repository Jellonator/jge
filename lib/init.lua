local lpath = ... .. '.';
local function reqlocal(path)
	return require(lpath .. path)
end
local function _mod(a, n)
	return a - math.floor(a/n) * n
end

function try_or(a, b, ...)
	if a ~= nil then
		return a
	elseif b ~= nil then
		return try_or(b, ...)
	end
end

function string.trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string.split(s)
	return s:gmatch("[^%s]")
end

function math.sign(x)
	if x == 0 then return 0
	elseif x > 0 then return 1
	else return -1 end
end

local Lib = {
	vlt   = reqlocal("hump.vector-light"),
	vec   = reqlocal("hump.vector"),
	hcam  = reqlocal("hump.camera"),
	Transform = reqlocal("transform"),
	Matrix3 = reqlocal("matrix3"),
	Input = reqlocal("input"),
	json  = reqlocal("dkjson"),
	tiled = reqlocal("tiled"),
	anim  = reqlocal("anim"),
	ncs   = reqlocal("ncs"),
	HC    = reqlocal("HC"),
}

function Lib.bind(f, x, ...)
	if not x then return f end
	return Lib.bind(function(...) return f(x, ...) end, ...)
end

function Lib.nullfunc()end

function Lib.lerp(val, a, b)
	return val*b + (1-val)*a
end

function Lib.angle_diff(a, b)
	local ret = a - b;
	ret = _mod(ret + math.pi, math.pi*2) - math.pi
	return ret;
end

function Lib.angle_lerp(lerp, a, b)
	local diff = Lib.angle_diff(a, b);
	a = a + diff * lerp;
	return _mod(a, math.pi*2)
end

function Lib.angle_to(a, b, dis)
	local diff = Lib.angle_diff(a, b);
	if math.abs(diff) < dis then return b end
	diff = diff * dis / math.abs(diff);
	a = a + diff;
	return _mod(a, math.pi*2);
end

function Lib.infnorm(x, n)
	-- 'n' is the point at which this function will yeild 1/2
	n = n or 1
	return x / (math.abs(x) + n)
end

return Lib
