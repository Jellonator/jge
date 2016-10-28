local Transform = {}
Transform.__index = Transform;

function Transform.new(x, y)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		scalex = 1,
		scaley = 1,
		rotation = 0,
		_id = 0,
	}, Transform)
end

function Transform:translate(x, y)
	self.x = self.x + x;
	self.y = self.y + y;
	self._id = self._id + 1;
end

function Transform:scale(sx, sy)
	self.scalex = self.scalex * sx;
	self.scaley = self.scaley * sy;
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
	self._id = self_id + 1
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

function Transform:draw_push()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.rotate(self.rotation)
	love.graphics.scale(self.scalex, self.scaley)
end

function Transform:draw_pop()
	love.graphics.pop()
end

return setmetatable(Transform, {
	__call = function(t, ...)
		return Transform.new(...)
	end
})
