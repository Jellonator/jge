--[[
Copyright (c) 2011 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local math_min, math_sqrt, math_huge = math.min, math.sqrt, math.huge

local _PACKAGE, common_local = (...):match("^(.+)%.[^%.]+"), common
if not (type(common) == 'table' and common.class and common.instance) then
	assert(common_class ~= false, 'No class commons specification available.')
	require(_PACKAGE .. '.class')
end
local vector  = require(_PACKAGE .. '.vector-light')
local Polygon = require(_PACKAGE .. '.polygon')
local GJK     = require(_PACKAGE .. '.gjk') -- actual collision detection

-- reset global table `common' (required by class commons)
if common_local ~= common then
	common_local, common = common, common_local
end

--
-- base class
--
local Shape = {}
function Shape:init(t)
	self._type = t
	self._rotation = 0
	self._layer = {[""]=true}
	self._mask = ""
end

function Shape:add_layer(name)
	self._layer[name] = true
end

function Shape:remove_layer(name)
	self._layer[name] = nil
end

function Shape:set_mask(name)
	self._mask = name;
end

function Shape:can_mask_collide(other)
	return self._layer[other._mask] or other._layer[self._mask]
end

function Shape:check_oneway(other, collides, sx, sy)
	if not sx or not sy then
		collides, sx, sy = self:collidesWith(other);
	end
	if not collides then
		return collides, sx, sy;
	end
	if other._prev_x and other._prev_y and self._prev_x and self._prev_y
	and (self._hollow or self._oneway) then
		local opx, opy = other:center();
		local spx, spy = self:center();
		other:moveTo(other._prev_x, other._prev_y);
		self:moveTo(self._prev_x, self._prev_y)
		local pcollide, nsx, nsy = self:collidesWith(other);
		other:moveTo(opx, opy);
		self:moveTo(spx, spy);
		if pcollide and sx and sy and jge.vlt.len(nsx, nsy) >= 1 then
			return false, sx, sy
		end
	end
	if not self._oneway then
		return collides, sx, sy
	end
	if sx == 0 and sy == 0 then
		return collides, sx, sy
	end
	sx, sy = jge.vlt.rotate(self._rotation, sx, sy)
	if self._oneway.rotate then
		sx, sy = jge.vlt.rotate(-other._rotation, sx, sy)
	end

	local dot = jge.vlt.dot(self._oneway.dx, self._oneway.dy, jge.vlt.normalize(sx, sy))
	return dot >= self._oneway.dot, sx, sy
end

function Shape:disable_oneway()
	self._oneway = nil
end

function Shape:set_hollow(value)
	local value = value or true;
	self._hollow = value;
end

function Shape:set_oneway(dx, dy, dot, rotate)
	if dx == nil and dy == nil then
		return self:disable_oneway();
	end
	local dot = dot or 0;
	if dot == 0 then dot = -1e-5 end
	if self._oneway == nil then
		self._oneway = {};
	end
	dx, dy = jge.vlt.normalize(dx, dy)
	self._oneway.dx = dx;
	self._oneway.dy = dy;
	self._oneway.rotate = rotate ~= nil and rotate or false
	-- self._oneway.dir = VL.angleTo(dx, dy);
	self._oneway.dot = dot
end

function Shape:moveTo(x,y)
	local cx,cy = self:center()
	self:move(x - cx, y - cy)
end

function Shape:rotation()
	return self._rotation
end

function Shape:rotate(angle)
	self._rotation = self._rotation + angle
end

function Shape:setRotation(angle, x,y)
	return self:rotate(angle - self._rotation, x,y)
end

--
-- class definitions
--
local ConvexPolygonShape = {}
function ConvexPolygonShape:init(polygon)
	Shape.init(self, 'polygon')
	assert(polygon:isConvex(), "Polygon is not convex.")
	self._polygon = polygon
end

local ConcavePolygonShape = {}
function ConcavePolygonShape:init(poly)
	Shape.init(self, 'compound')
	self._polygon = poly
	self._shapes = poly:splitConvex()
	for i,s in ipairs(self._shapes) do
		self._shapes[i] = common_local.instance(ConvexPolygonShape, s)
	end
end

local CircleShape = {}
function CircleShape:init(cx,cy, radius)
	Shape.init(self, 'circle')
	self._center = {x = cx, y = cy}
	self._radius = radius
end

local PointShape = {}
function PointShape:init(x,y)
	Shape.init(self, 'point')
	self._pos = {x = x, y = y}
end

--
-- collision functions
--
function ConvexPolygonShape:support(dx,dy)
	local v = self._polygon.vertices
	local max, vmax = -math_huge
	for i = 1,#v do
		local d = vector.dot(v[i].x,v[i].y, dx,dy)
		if d > max then
			max, vmax = d, v[i]
		end
	end
	return vmax.x, vmax.y
end

function CircleShape:support(dx,dy)
	return vector.add(self._center.x, self._center.y,
		vector.mul(self._radius, vector.normalize(dx,dy)))
end

-- collision dispatching:
-- let circle shape or compund shape handle the collision
function ConvexPolygonShape:collidesWith(other)
	if self == other then return false end
	if other._type ~= 'polygon' then
		local collide, sx,sy = other:collidesWith(self)
		return collide, sx and -sx, sy and -sy
	end

	-- else: type is POLYGON
	return GJK(self, other)
end

function ConcavePolygonShape:collidesWith(other)
	if self == other then return false end
	if other._type == 'point' then
		return other:collidesWith(self)
	end

	local otherx, othery = other:center();
	local collide = false
	local dx = 0
	local dy = 0
	local maxlen = 0
	local allsep = {}
	for _,s in ipairs(self._shapes) do
		local status, sx,sy = s:collidesWith(other)
		collide = collide or status
		if status then
			if math.abs(sx) > math.abs(dx) then
				dx = sx
			end
			if math.abs(sy) > math.abs(dy) then
				dy = sy
			end
			maxlen = math.max(maxlen, vector.len(sx, sy))
			table.insert(allsep, {x=sx,y=sy,obj=s})
		end
	end

	maxlen = math.max(maxlen, vector.len(dx, dy))
	dx,dy = vector.mul(maxlen, vector.normalize(dx,dy))

	self._allsep = allsep

	return collide, dx, dy
end

function CircleShape:collidesWith(other)
	if self == other then return false end
	if other._type == 'circle' then
		local px,py = self._center.x-other._center.x, self._center.y-other._center.y
		local d = vector.len2(px,py)
		local radii = self._radius + other._radius
		if d < radii*radii then
			-- if circles overlap, push it out upwards
			if d == 0 then return true, 0,radii end
			-- otherwise push out in best direction
			return true, vector.mul(radii - math_sqrt(d), vector.normalize(px,py))
		end
		return false
	elseif other._type == 'polygon' then
		return GJK(self, other)
	end

	-- else: let the other shape decide
	local collide, sx,sy = other:collidesWith(self)
	return collide, sx and -sx, sy and -sy
end

function PointShape:collidesWith(other)
	if self == other then return false end
	if other._type == 'point' then
		return (self._pos == other._pos), 0,0
	end
	return other:contains(self._pos.x, self._pos.y), 0,0
end

--
-- point location/ray intersection
--
function ConvexPolygonShape:contains(x,y)
	return self._polygon:contains(x,y)
end

function ConcavePolygonShape:contains(x,y)
	return self._polygon:contains(x,y)
end

function CircleShape:contains(x,y)
	return vector.len2(x-self._center.x, y-self._center.y) < self._radius * self._radius
end

function PointShape:contains(x,y)
	return x == self._pos.x and y == self._pos.y
end


function ConcavePolygonShape:intersectsRay(x,y, dx,dy)
	return self._polygon:intersectsRay(x,y, dx,dy)
end

function ConvexPolygonShape:intersectsRay(x,y, dx,dy)
	return self._polygon:intersectsRay(x,y, dx,dy)
end

function ConcavePolygonShape:intersectionsWithRay(x,y, dx,dy)
	return self._polygon:intersectionsWithRay(x,y, dx,dy)
end

function ConvexPolygonShape:intersectionsWithRay(x,y, dx,dy)
	return self._polygon:intersectionsWithRay(x,y, dx,dy)
end

-- circle intersection if distance of ray/center is smaller
-- than radius.
-- with r(s) = p + d*s = (x,y) + (dx,dy) * s defining the ray and
-- (x - cx)^2 + (y - cy)^2 = r^2, this problem is eqivalent to
-- solving [with c = (cx,cy)]:
--
--     d*d s^2 + 2 d*(p-c) s + (p-c)*(p-c)-r^2 = 0
function CircleShape:intersectionsWithRay(x,y, dx,dy)
	local pcx,pcy = x-self._center.x, y-self._center.y

	local a = vector.len2(dx,dy)
	local b = 2 * vector.dot(dx,dy, pcx,pcy)
	local c = vector.len2(pcx,pcy) - self._radius * self._radius
	local discr = b*b - 4*a*c

	if discr < 0 then return {} end

	discr = math_sqrt(discr)
	local ts, t1, t2 = {}, discr-b, -discr-b
	if t1 >= 0 then ts[#ts+1] = t1/(2*a) end
	if t2 >= 0 then ts[#ts+1] = t2/(2*a) end
	return ts
end

function CircleShape:intersectsRay(x,y, dx,dy)
	local tmin = math_huge
	for _, t in ipairs(self:intersectionsWithRay(x,y,dx,dy)) do
		tmin = math_min(t, tmin)
	end
	return tmin ~= math_huge, tmin
end

-- point shape intersects ray if it lies on the ray
function PointShape:intersectsRay(x,y, dx,dy)
	local px,py = self._pos.x-x, self._pos.y-y
	local t = vector.dot(px,py, dx,dy) / vector.len2(dx,dy)
	return t >= 0, t
end

function PointShape:intersectionsWithRay(x,y, dx,dy)
	local intersects, t = self:intersectsRay(x,y, dx,dy)
	return intersects and {t} or {}
end

--
-- auxiliary
--
function ConvexPolygonShape:center()
	return self._polygon.centroid.x, self._polygon.centroid.y
end

function ConcavePolygonShape:center()
	return self._polygon.centroid.x, self._polygon.centroid.y
end

function CircleShape:center()
	return self._center.x, self._center.y
end

function PointShape:center()
	return self._pos.x, self._pos.y
end

function ConvexPolygonShape:outcircle()
	local cx,cy = self:center()
	return cx,cy, self._polygon._radius
end

function ConcavePolygonShape:outcircle()
	local cx,cy = self:center()
	return cx,cy, self._polygon._radius
end

function CircleShape:outcircle()
	local cx,cy = self:center()
	return cx,cy, self._radius
end

function PointShape:outcircle()
	return self._pos.x, self._pos.y, 0
end

function ConvexPolygonShape:bbox()
	return self._polygon:bbox()
end

function ConcavePolygonShape:bbox()
	return self._polygon:bbox()
end

function CircleShape:bbox()
	local cx,cy = self:center()
	local r = self._radius
	return cx-r,cy-r, cx+r,cy+r
end

function PointShape:bbox()
	local x,y = self:center()
	return x,y,x,y
end


function ConvexPolygonShape:move(x,y)
	self._polygon:move(x,y)
end

function ConcavePolygonShape:move(x,y)
	self._polygon:move(x,y)
	for _,p in ipairs(self._shapes) do
		p:move(x,y)
	end
end

function CircleShape:move(x,y)
	self._center.x = self._center.x + x
	self._center.y = self._center.y + y
end

function PointShape:move(x,y)
	self._pos.x = self._pos.x + x
	self._pos.y = self._pos.y + y
end

function ConcavePolygonShape:transform_mat(mat)
	self._polygon:transform_mat(mat);
	for _,p in pairs(self._shapes) do
		p:transform_mat(mat)
	end
end

function ConvexPolygonShape:transform_mat(mat)
	self._polygon:transform_mat(mat);
end

function PointShape:transform_mat(mat)
	self._pos.x, self._pos.y = mat:transform_point(self._pos.x, self._pos.y)
end

-- local ROOT_2 = math.math.sqrt(2);
function CircleShape:transform_mat(mat)
	self._center.x, self._center.y = mat:transform_point(self._center.x, self._center.y);

	-- calculate new radius sorta(its kinda weird, but hey, it works)
	local radroot = math.sqrt(self._radius^2 / 2)
	local rx, ry = radroot, radroot;
	rx, ry = mat:transform_point(rx, ry, 0)
	self._radius = math.sqrt(rx^2 + ry^2)
end

function ConcavePolygonShape:rotate(angle,cx,cy)
	Shape.rotate(self, angle)
	if not (cx and cy) then
		cx,cy = self:center()
	end
	self._polygon:rotate(angle,cx,cy)
	for _,p in ipairs(self._shapes) do
		p:rotate(angle, cx,cy)
	end
end

function ConvexPolygonShape:rotate(angle, cx,cy)
	Shape.rotate(self, angle)
	self._polygon:rotate(angle, cx, cy)
end

function CircleShape:rotate(angle, cx,cy)
	Shape.rotate(self, angle)
	if not (cx and cy) then return end
	self._center.x,self._center.y = vector.add(cx,cy, vector.rotate(angle, self._center.x-cx, self._center.y-cy))
end

function PointShape:rotate(angle, cx,cy)
	Shape.rotate(self, angle)
	if not (cx and cy) then return end
	self._pos.x,self._pos.y = vector.add(cx,cy, vector.rotate(angle, self._pos.x-cx, self._pos.y-cy))
end

function ConcavePolygonShape:scale(s)
	assert(type(s) == "number" and s > 0, "Invalid argument. Scale must be greater than 0")
	local cx,cy = self:center()
	self._polygon:scale(s, cx,cy)
	for _, p in ipairs(self._shapes) do
		local dx,dy = vector.sub(cx,cy, p:center())
		p:scale(s, cx, cy)
		p:moveTo(cx-dx*s, cy-dy*s)
	end
end

function ConvexPolygonShape:scale(s)
	assert(type(s) == "number" and s > 0, "Invalid argument. Scale must be greater than 0")
	self._polygon:scale(s, self:center())
end

function CircleShape:scale(s)
	assert(type(s) == "number" and s > 0, "Invalid argument. Scale must be greater than 0")
	self._radius = self._radius * s
end

function PointShape:scale()
	-- nothing
end


function ConvexPolygonShape:draw(mode)
	mode = mode or 'line'
	if #self._polygon.vertices >= 3 then
		love.graphics.polygon(mode, self._polygon:unpack())
	elseif #self._polygon.vertices == 2 then
		love.graphics.line(self._polygon:unpack())
	elseif #self._polygon.vertices == 1 then
		love.graphics.points(self._polygon:unpack())
	end
	-- love.graphics.points(self._polygon.centroid.x, self._polygon.centroid.y)
	-- love.graphics.circle(mode, self._polygon.centroid.x, self._polygon.centroid.y, self._polygon._radius)
end

function ConcavePolygonShape:draw(mode, wireframe)
	local mode = mode or 'line'
	love.graphics.polygon(mode, self._polygon:unpack())
	-- love.graphics.points(self._polygon.centroid.x, self._polygon.centroid.y)
	-- love.graphics.circle(mode, self._polygon.centroid.x, self._polygon.centroid.y, self._polygon._radius)
	if mode == 'line' then
		love.graphics.polygon('line', self._polygon:unpack())
		if not wireframe then return end
	end
	for _,p in ipairs(self._shapes) do
		love.graphics.polygon(mode, p._polygon:unpack())
	end

end

function CircleShape:draw(mode, segments)
	love.graphics.circle(mode or 'line', self:outcircle())
end

function PointShape:draw()
	love.graphics.points(self:center())
end


Shape = common_local.class('Shape', Shape)
ConvexPolygonShape  = common_local.class('ConvexPolygonShape',  ConvexPolygonShape,  Shape)
ConcavePolygonShape = common_local.class('ConcavePolygonShape', ConcavePolygonShape, Shape)
CircleShape         = common_local.class('CircleShape',         CircleShape,         Shape)
PointShape          = common_local.class('PointShape',          PointShape,          Shape)

local function newPolygonShape(polygon, ...)
	-- create from coordinates if needed
	if type(polygon) == "number" then
		polygon = common_local.instance(Polygon, polygon, ...)
	else
		polygon = polygon:clone()
	end

	if polygon:isConvex() then
		return common_local.instance(ConvexPolygonShape, polygon)
	end

	return common_local.instance(ConcavePolygonShape, polygon)
end

local function newCircleShape(...)
	return common_local.instance(CircleShape, ...)
end

local function newPointShape(...)
	return common_local.instance(PointShape, ...)
end

return {
	ConcavePolygonShape = ConcavePolygonShape,
	ConvexPolygonShape  = ConvexPolygonShape,
	CircleShape         = CircleShape,
	PointShape          = PointShape,
	newPolygonShape     = newPolygonShape,
	newCircleShape      = newCircleShape,
	newPointShape       = newPointShape,
}
