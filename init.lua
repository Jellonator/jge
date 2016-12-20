local lpath = ... .. '.';
module('jge', package.seeall)

local lg = love.graphics
local lg_push = love.graphics.push
local lg_pop = love.graphics.pop
local lg_origin = love.graphics.origin
local lg_scale = love.graphics.scale
local lg_rotate = love.graphics.rotate
local lg_shear = love.graphics.shear
local lg_translate = love.graphics.translate

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

function string.split(s)
	return s:gmatch("[^%s]")
end

function string.begins_with(self, other)
	return self:sub(1,#other) == other, self:sub(#other+1)
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

--[[ Probability Functions ]]
function random_normal_range(min, max, tries, rng)
	-- useful for returning a random number without
	-- the headache of standard deviation
	local stddev = math.abs(max-min)/4
	local mean = (max+min)/2
	return random_normal_limit(stddev, mean, 2, tries, rng)
end

function random_normal_limit(stddev, mean, limit, tries, rng)
	-- maximum standard deviations.
	-- default limit is 2, meaning 95% chance to fall in range
	limit = limit or 2
	-- three tries, 5% failing each. (total of 0.0125% chance of failing)
	tries = tries or 3
	-- when using a smaller limit, the person calling the function should use
	-- a higher number of tries. For example, with only 3 tries and a limit of 1
	-- std. dev, there is a 3.27% chance of this function failing.
	-- Or don't, the fallback should be fine anyways
	local min = -limit * stddev + mean
	local max = limit * stddev + mean
	for i = 1, math.max(1, tries) do
		local val;
		if rng then
			val = rng:randomNormal(stddev, mean)
		else
			val = love.math.randomNormal(stddev, mean)
		end
		if val >= min and val <= max then
			return val
		end
	end
	print("ugg, lets try something else")
	-- if all else fails, return a random number (not normal)
	if rng then
		return rng:random(min, max)
	else
		return love.math.random(min, max)
	end
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
vlt   = reqlocal("hump.vector-light")
vec   = reqlocal("hump.vector")
hcam  = reqlocal("hump.camera")
Transform = reqlocal("transform")
Matrix3 = reqlocal("matrix3")
-- Tween  = reqlocal("tween")
anim = reqlocal("anim")
Input = reqlocal("input")
json  = reqlocal("dkjson")
tiled = reqlocal("tiled")
ncs   = reqlocal("ncs")
HC    = reqlocal("HC")
distribute = reqlocal("distribute")
