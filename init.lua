local lpath = ... .. '.';
module('jge', package.seeall)

local function reqlocal(path)
	return require(lpath .. path)
end
local function _mod(a, n)
	return a - math.floor(a/n) * n
end

--[[ Extra String Functions ]]
function string.trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function _str_split(state, i)
	if state.i == nil then return nil end
	local f_start, f_end = state.str:find(state.sep, state.i, true)
	local ret, next_i
	if f_start == nil then
		ret = state.str:sub(state.i)
		next_i = nil
	else
		ret = state.str:sub(state.i, f_start-1)
		next_i = f_end + 1
	end
	state.i = next_i
	return ret
end

function string.split(s, val)
	if val then
		return _str_split, {
			sep = val,
			str = s,
			i = 1
		}
	else
		return s:gmatch("[^%s]")
	end
end

function string.begins_with(self, other)
	local ret = self:sub(1,#other) == other
	return ret, ret and self:sub(#other+1)
end

function string.ends_with(self, other)
	local pos = #self-#other
	local ret = self:sub(pos+1) == other
	return ret, ret and self:sub(1, pos)
end

--[[ Extra Math Functions ]]
function math.sign(x)
	if x > 0 then return 1
	elseif x < 0 then return -1 end
	return 0
end

--[[ Basic Utility Functions ]]
function try_or(a, b, ...)
	if a ~= nil then
		return a
	elseif b ~= nil then
		return try_or(b, ...)
	end
end

function printf(s, ...)
	print(s:format(...))
end

function bind(f, x, ...)
	if not x then return f end
	return jge.bind(function(...) return f(x, ...) end, ...)
end

function nullfunc()end

--[[ More Math Functions ]]
function lerp(val, a, b)
	return val*b + (1-val)*a
end

function limit_index(i, length)
	return ((i - 1) % length) + 1
end

function clamp(val, ...)
	local lowest = math.min(...)
	local highest = math.max(...)
	return math.max(math.min(val, highest), lowest)
end

function normalize(value, min, max, to_min, to_max, clamp)
	if to_min == to_max then return to_min end
	if clamp == nil then clamp = true end
	local a = (to_max - to_min) / (max - min);
	local b = to_max - a * max;
	value = a * value + b;
	if clamp then return jge.clamp(value, to_min, to_max) end
	return value;
end

function to(a, b, speed)
	local greater = a > b
	a = a + (greater and -speed or speed)
	if a > b ~= greater then
		return b
	end
	return a
end

function to_2d(from_x, from_y, to_x, to_y, speed)
	local dist = jge.vlt.dist(from_x, from_y, to_x, to_y);
	-- local angle = jge.vlt.angle_to(from_x - to_x, from_y - to_y);
	local nx, ny = jge.vlt.normalize(from_x-to_x, from_y-to_y)
	dist = math.max(0, dist - speed)
	return jge.vlt.add(to_x, to_y, jge.vlt.mul(dist, nx, ny))
end

function infnorm(x, n)
	-- 'n' is the point at which this function will yeild 1/2
	n = n or 1
	return x / (math.abs(x) + n)
end

function minmax(...)
	return math.min(...), math.max(...)
end

--[[ Angle Functions ]]
function angle_diff(a, b)
	local ret = b - a;
	ret = _mod(ret + math.pi, math.pi*2) - math.pi
	return ret;
end

function angle_lerp(lerp, a, b)
	local diff = angle_diff(a, b);
	a = a + diff * lerp;
	return _mod(a, math.pi*2)
end

function angle_to(a, b, speed)
	local diff = angle_diff(a, b);
	if math.abs(diff) < speed*2 then return b end
	diff = diff * speed / math.abs(diff);
	a = a + diff;
	return _mod(a, math.pi*2);
end

--[[ Extra Table Functions ]]
function table_clear(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

local function _union(ret, a, ...)
	if not a then return ret end
	for k, v in pairs(a) do
		ret[k] = v
	end
	return _union(ret, ...)
end

function table_union(...)
	return _union({}, ...)
end

--[[ Path Functions ]]
--[[
Because for some god-forsaken reason Love2d does not allow for '..' to show up
in filepaths, I have to use this function to fix up paths so that I can
actually use them.
--]]
function fix_path(p)
	local dot_s, dot_e = p:find("/../", 1, true);
	if not dot_s then return p end
	local begin = p:sub(1, dot_s - 1)
	local ending = p:sub(dot_e + 1)
	begin = begin:reverse();
	local slash = begin:find("/", 1, true);
	if slash then
		begin = begin:sub(slash):reverse();
	else
		begin = ""
	end
	return fix_path(begin .. ending)
end

--[[ Function Binding Functions ]]
function bind_method(object, method)
	return function(...)
		return object[method](object, ...)
	end
	-- return jge.bind(object[method], object, ...)
end

function bind_property(object, property, ...)
	if not property then return nullfunc end
	local f = bind_property(object, ...)
	return function(v, ...)
		object[property] = v
		return f(...)
	end
end

function bind_unpack(f)
	return function(t)
		return f(unpack(t))
	end
end

--[[ Modules ]]
-- types
Transform = reqlocal("transform")
Matrix3 = reqlocal("matrix3")
Input = reqlocal("input")
HC    = reqlocal("HC")

-- modules
vlt   = reqlocal("hump.vector-light")
vec   = reqlocal("hump.vector")
hcam  = reqlocal("hump.camera")
json  = reqlocal("dkjson")
tiled = reqlocal("tiled")
ncs   = reqlocal("ncs")
anim = reqlocal("anim")
distribute = reqlocal("distribute")
random = reqlocal("random")
ease = reqlocal("ease")
