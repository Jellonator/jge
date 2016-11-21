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

function angle_diff(a, b)
	local ret = a - b;
	ret = _mod(ret + math.pi, math.pi*2) - math.pi
	return ret;
end

function angle_lerp(lerp, a, b)
	local diff = angle_diff(a, b);
	a = a + diff * lerp;
	return _mod(a, math.pi*2)
end

function angle_to(a, b, dis)
	local diff = angle_diff(a, b);
	if math.abs(diff) < dis then return b end
	diff = diff * dis / math.abs(diff);
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

function love.graphics.push(...)
	lg_push(...)
	table.insert(matrices, Matrix3())
	table.insert(stop, stop[mindex])
	mindex = mindex + 1
end
function love.graphics.pop()
	lg_pop()
	table.remove(stop)
	table.remove(matrices)
	mindex = mindex - 1
end
function love.graphics.origin()
	lg_origin()
	stop[mindex] = mindex
end
function love.graphics.scale(sx, sy)
	lg_scale(sx, sy)
	sy = sy or sx
	matrices[mindex]:scale(sx, sy)
end
function love.graphics.rotate(angle)
	lg_rotate(angle)
	matrices[mindex]:rotate(angle)
end
function love.graphics.shear(kx, ky)
	lg_shear(kx, ky)
	matrices[mindex]:skew(kx, ky)
end
function love.graphics.translate(x, y)
	lg_translate(x, y)
	matrices[mindex]:translate(x, y)
end
