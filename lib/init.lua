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

function string.trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string.split(s)
	return s:gmatch("[^%s]")
end

function string.begins_with(self, other)
	return self:sub(1,#other) == other, self:sub(#other+1)
end

function math.sign(x)
	if x == 0 then return 0
	elseif x > 0 then return 1
	else return -1 end
end

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
	return bind(function(...) return f(x, ...) end, ...)
end

function nullfunc()end

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

function to(a, b, speed)
	local greater = a > b
	a = a + (greater and -speed or speed)
	if a > b ~= greater then
		return b
	end
	return a
end

function infnorm(x, n)
	-- 'n' is the point at which this function will yeild 1/2
	n = n or 1
	return x / (math.abs(x) + n)
end

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

function minmax(...)
	return math.min(...), math.max(...)
end

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

vlt   = reqlocal("hump.vector-light")
vec   = reqlocal("hump.vector")
hcam  = reqlocal("hump.camera")
Transform = reqlocal("transform")
Matrix3 = reqlocal("matrix3")
Tween  = reqlocal("tween")
Input = reqlocal("input")
json  = reqlocal("dkjson")
tiled = reqlocal("tiled")
ncs   = reqlocal("ncs")
HC    = reqlocal("HC")

local matrices = {Matrix3()}
local mindex = 1;
local stop = {1}
local cache_mat;
local cache_mat_inv;

-- function love.graphics.push(...)
-- 	lg_push(...)
-- 	table.insert(matrices, Matrix3())
-- 	table.insert(stop, stop[mindex])
-- 	mindex = mindex + 1
-- 	cache_mat = nil
-- 	cache_mat_inv = nil
-- end
-- function love.graphics.pop()
-- 	lg_pop()
-- 	table.remove(stop)
-- 	table.remove(matrices)
-- 	mindex = mindex - 1
-- 	cache_mat = nil
-- 	cache_mat_inv = nil
-- end
-- function love.graphics.origin()
-- 	lg_origin()
-- 	stop[mindex] = mindex
-- 	matrices[mindex]:identity();
-- end
-- function love.graphics.scale(sx, sy)
-- 	lg_scale(sx, sy)
-- 	sy = sy or sx
-- 	matrices[mindex]:scale(sx, sy)
-- end
-- function love.graphics.rotate(angle)
-- 	lg_rotate(angle)
-- 	matrices[mindex]:rotate(angle)
-- end
-- function love.graphics.shear(kx, ky)
-- 	lg_shear(kx, ky)
-- 	matrices[mindex]:skew(kx, ky)
-- end
-- function love.graphics.translate(x, y)
-- 	lg_translate(x, y)
-- 	matrices[mindex]:translate(x, y)
-- end
--
-- function love.graphics.getScreenPos(x, y)
-- 	if not cache_mat then
-- 		cache_mat = Matrix3();
-- 		for i = mindex, stop[mindex], -1 do
-- 			cache_mat = cache_mat * matrices[i]
-- 		end
-- 	end
-- 	x, y = cache_mat:transform_point(x, y)
-- 	return x, y
-- end
--
-- function love.graphics.getWorldPos(x, y)
-- 	if not cache_mat_inv then
-- 		cache_mat_inv = Matrix3();
-- 		for i = stop[mindex], mindex do
-- 			cache_mat_inv = cache_mat_inv * matrices[i]:clone():inverse()
-- 		end
-- 	end
-- 	x, y = cache_mat_inv:transform_point(x, y)
-- 	return x, y
-- end
