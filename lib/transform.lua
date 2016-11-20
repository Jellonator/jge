local Transform = {}
Transform.__index = Transform;

-- A more-sane way to transform points
function Transform.new(x, y)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		scalex = 1,
		scaley = 1,
		rotation = 0,
		_id = 0,
		_matid = -1,
		_matcache = jge.Matrix3():const(),
		_invid = -1,
		_invcache = jge.Matrix3():const(),
	}, Transform)
end

function Transform:get_translation()
	return self.x, self.y
end

function Transform:get_rotation()
	return self.rotation
end

function Transform:get_scale()
	return self.scalex, self.scaley
end

function Transform:translate(x, y)
	self.x = self.x + x;
	self.y = self.y + y;
	self._id = self._id + 1;
end

function Transform:scale(sx, sy)
	self.scalex = self.scalex * sx;
	self.scaley = self.scaley * (sy or sx);
	self._id = self._id + 1;
end

function Transform:rotate(phi)
	self.rotation = self.rotation + phi
	self._id = self._id + 1;
end

function Transform:set_rotation(phi)
	self.rotation = phi
	self._id = self._id + 1;
end

function Transform:set_scale(sx, sy)
	self.scalex = sx;
	self.scaley = sy;
	self._id = self._id + 1
end

function Transform:set_translation(x, y)
	self.x = x
	self.y = y
	self._id = self._id + 1
end

function Transform:set_x(x)
	self:set_translation(x, self.y)
end

function Transform:set_y(y)
	self:set_translation(self.x, y)
end

function Transform:transform(x, y)
	x = x * self.scalex;
	y = y * self.scaley;

	if self.rotation ~= 0 then
		local len = math.sqrt(x*x + y*y)
		local rot = math.atan2(y, x) + self.rotation;
		x = math.cos(rot)*len
		y = math.sin(rot)*len
	end

	x = x + self.x
	y = y + self.y

	return x, y
end

function Transform:transform_inv(x, y)
	x = x - self.x
	y = y - self.y

	if self.rotation ~= 0 then
		local len = math.sqrt(x*x + y*y)
		local rot = math.atan2(y, x) + self.rotation;
		x = math.cos(-rot)*len
		y = math.sin(-rot)*len
	end

	x = x / self.scalex;
	y = y / self.scaley;

	return x, y
end

function Transform:transform_shape(shape)
	shape:scale(self.scalex, self.scaley)
	shape:rotate(self.rotation)
	shape:move(self.x, self.y)
end

function Transform:transform_shape_inv(shape)
	shape:move(-self.x, -self.y)
	shape:rotate(-self.rotation)
	shape:scale(1/self.scalex, 1/self.scaley)
end

function Transform:draw_push()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.rotate(self.rotation)
	love.graphics.scale(self.scalex, self.scaley)
end

function Transform:draw_pop()
	love.graphics.pop()
end

function Transform:copy(other)
	self.x = other.x;
	self.y = other.y;
	self.scalex = other.scalex;
	self.scaley = other.scaley;
	self.rotation = other.rotation;
	self._id = self._id + 1;
end

function Transform:get_mat()
	if self._matid ~= self._id then
		jge.Matrix3.identity(self._matcache)
		jge.Matrix3.translate(self._matcache, self.x, self.y)
		jge.Matrix3.rotate(self._matcache, self.rotation)
		jge.Matrix3.scale(self._matcache, self.scalex, self.scaley)
	end
	return self._matcache
end

function Transform:get_mat_inv()
	if self._invid ~= self._id then
		jge.Matrix3.identity(self._invcache)
		jge.Matrix3.scale(self._invcache, 1/self.scalex, 1/self.scaley)
		jge.Matrix3.rotate(self._invcache, -self.rotation)
		jge.Matrix3.translate(self._invcache, -self.x, -self.y)
	end
	return self._invcache
end

return setmetatable(Transform, {
	__call = function(t, ...)
		return Transform.new(...)
	end
})
