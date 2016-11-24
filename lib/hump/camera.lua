--[[
Copyright (c) 2010-2015 Matthias Richter

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

local _PATH = (...):match('^(.*[%./])[^%.%/]+$') or ''
local cos, sin = math.cos, math.sin

local camera = {}
camera.__index = camera

-- Movement interpolators (for camera locking/windowing)
camera.smooth = {}

function camera.smooth.none()
	return function(dx,dy) return dx,dy end
end

function camera.smooth.linear(speed)
	assert(type(speed) == "number", "Invalid parameter: speed = "..tostring(speed))
	return function(dx,dy, s)
		-- normalize direction
		local d = math.sqrt(dx*dx+dy*dy)
		local dts = math.min((s or speed) * love.timer.getDelta(), d) -- prevent overshooting the goal
		if d > 0 then
			dx,dy = dx/d, dy/d
		end

		return dx*dts, dy*dts
	end
end

function camera.smooth.damped(stiffness)
	assert(type(stiffness) == "number", "Invalid parameter: stiffness = "..tostring(stiffness))
	return function(dx,dy, s)
		local dts = love.timer.getDelta() * (s or stiffness)
		return dx*dts, dy*dts
	end
end


local function new(x,y, zoom, rot, smoother)
	x,y  = x or love.graphics.getWidth()/2, y or love.graphics.getHeight()/2
	zoom = zoom or 1
	rot  = rot or 0
	smoother = smoother or camera.smooth.none() -- for locking, see below
	return setmetatable({
		x = x,
		y = y,
		scale = zoom,
		rot = rot,
		smoother = smoother,
		bounds = {
			x1 = -math.huge,
			y1 = -math.huge,
			x2 =  math.huge,
			y2 =  math.huge,
			correct = false,
		}
	}, camera)
end

function camera:lookAt(x,y)
	self.x, self.y = x, y
	return self
end

function camera:move(dx,dy)
	self.x, self.y = self.x + dx, self.y + dy
	return self
end

function camera:position()
	return self.x, self.y
end

function camera:rotate(phi)
	self.rot = self.rot + phi
	return self
end

function camera:rotateTo(phi)
	self.rot = phi
	return self
end

function camera:zoom(mul)
	self.scale = self.scale * mul
	return self
end

function camera:zoomTo(zoom)
	self.scale = zoom
	return self
end

function camera:attach(x,y,w,h, noclip)
	x,y = x or 0, y or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	self._sx,self._sy,self._sw,self._sh = love.graphics.getScissor()
	if not noclip then
		love.graphics.setScissor(x,y,w,h)
	end

	local selfx, selfy = self:_getBoundedPosition(x, y, w, h)

	local cx,cy = x+w/2, y+h/2
	love.graphics.push()
	-- love.graphics.origin()
	love.graphics.translate(cx, cy)
	love.graphics.scale(self.scale)
	love.graphics.rotate(self.rot)
	love.graphics.translate(-selfx, -selfy)
end

function camera:detach()
	love.graphics.pop()
	love.graphics.setScissor(self._sx,self._sy,self._sw,self._sh)
end

function camera:draw(...)
	local x,y,w,h,noclip,func
	local nargs = select("#", ...)
	if nargs == 1 then
		func = ...
	elseif nargs == 5 then
		x,y,w,h,func = ...
	elseif nargs == 6 then
		x,y,w,h,noclip,func = ...
	else
		error("Invalid arguments to camera:draw()")
	end

	self:attach(x,y,w,h,noclip)
	func()
	self:detach()
end

-- world coordinates to camera coordinates
function camera:cameraCoords(x,y, ox,oy,w,h)
	ox, oy = ox or 0, oy or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	-- x,y = ((x,y) - (self.x, self.y)):rotated(self.rot) * self.scale + center
	local c,s = cos(self.rot), sin(self.rot)
	x,y = x - self.x, y - self.y
	x,y = c*x - s*y, s*x + c*y
	return x*self.scale + w/2 + ox, y*self.scale + h/2 + oy
end

function camera:_getBoundedPosition(ox, oy, w, h)
	if self.bounds.correct then
		local selfx, selfy = self.x, self.y
		local x1,y1, x2,y2 = selfx - w/2, selfy - h/2, selfx + w/2, selfy + h/2
		local ax, ay = self:_worldCoordsRaw(x1, y1, ox, oy, w, h)
		local bx, by = self:_worldCoordsRaw(x2, y2, ox, oy, w, h)
		local cx, cy = self:_worldCoordsRaw(x1, y2, ox, oy, w, h)
		local dx, dy = self:_worldCoordsRaw(x2, y1, ox, oy, w, h)
		x1, x2 = jge.minmax(ax, bx, cx, dx)
		y1, y2 = jge.minmax(ay, by, cy, dy)
		local bw, bh = x2 - x1, y2 - y1
		local bx1 = self.bounds.x1+bw/2
		local bx2 = self.bounds.x2-bw/2
		local by1 = self.bounds.y1+bh/2
		local by2 = self.bounds.y2-bh/2
		if selfx < bx1 then
			selfx = bx1
		end
		if selfx > bx2 then
			selfx = bx2
		end
		if selfy < by1 then
			selfy = by1
		end
		if selfy > by2 then
			selfy = by2
		end
		if bx2-bx1 < 0 then selfx = (bx2 + bx1)/2 end
		if by2-by1 < 0 then selfy = (by2 + by1)/2 end
		return selfx, selfy
	else
		self.bounds.correct = true
		local prot = self.rot
		local c = math.cos(prot)
		local s = math.sin(prot)
		self.rot = 0
		local selfx1, selfy1 = self:_getBoundedPosition(ox, oy, w, h)
		self.rot = math.pi/2
		local selfx2, selfy2 = self:_getBoundedPosition(ox, oy, w, h)
		local selfx, selfy = selfx1*c+selfx2*(1-c), selfy1*c+selfy2*(1-c)
		self.rot = prot
		self.bounds.correct = false;
		return selfx, selfy
	end
end

-- camera coordinates to world coordinates
function camera:_worldCoordsRaw(x,y, ox,oy,w,h)
	ox, oy = ox or 0, oy or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	-- x,y = (((x,y) - center) / self.scale):rotated(-self.rot) + (self.x,self.y)
	local c,s = cos(-self.rot), sin(-self.rot)
	x,y = (x - w/2 - ox) / self.scale, (y - h/2 - oy) / self.scale
	x,y = c*x - s*y, s*x + c*y
	x, y = x+self.x, y+self.y

	return x, y
end

function camera:worldCoordDiff(x, y, ox,oy,w,h)
	local x1, y1 = self:worldCoords(x, y, ox, oy, w, h)
	local x2, y2 = self:_worldCoordsRaw(x, y, ox, oy, w, h)
	return x1-x2, y1-y2
end

function camera:worldCoords(x,y, ox,oy,w,h)
	ox, oy = ox or 0, oy or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	local selfx, selfy = self:_getBoundedPosition(ox,oy,w,h)
	-- x,y = (((x,y) - center) / self.scale):rotated(-self.rot) + (self.x,self.y)
	local c,s = cos(-self.rot), sin(-self.rot)
	x,y = (x - w/2 - ox) / self.scale, (y - h/2 - oy) / self.scale
	x,y = c*x - s*y, s*x + c*y
	x, y = x+selfx, y+selfy

	return x, y
end

function camera:mousePosition(ox,oy,w,h)
	local mx,my = love.mouse.getPosition()
	return self:worldCoords(mx,my, ox,oy,w,h)
end

-- camera scrolling utilities
function camera:lockX(x, smoother, ...)
	local dx, dy = (smoother or self.smoother)(x - self.x, self.y, ...)
	self.x = self.x + dx
	return self
end

function camera:lockY(y, smoother, ...)
	local dx, dy = (smoother or self.smoother)(self.x, y - self.y, ...)
	self.y = self.y + dy
	return self
end

function camera:lockPosition(x,y, smoother, ...)
	return self:move((smoother or self.smoother)(x - self.x, y - self.y, ...))
end

function camera:setBounds(x1, y1, x2, y2, correct)
	self.bounds.x1 = x1
	self.bounds.y1 = y1
	self.bounds.x2 = x2
	self.bounds.y2 = y2
	self.bounds.correct = correct ~= nil and correct or false
end

-- the module
return setmetatable({new = new, smooth = camera.smooth},
	{__call = function(_, ...) return new(...) end})
