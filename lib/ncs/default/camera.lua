-- A camera
local Camera = {
	bounds = {-math.huge, -math.huge, math.huge, math.huge},
	width = 100,
	height = 100,
	x = 0,
	y = 0,
	rot = 0,
	zoom = 1
}
function Camera:set_bounds(x1, y1, x2, y2)
	self.bounds[1] = math.min(x1, x2);
	self.bounds[2] = math.min(y1, y2);
	self.bounds[3] = math.max(x1, x2);
	self.bounds[4] = math.max(y1, y2);
end
function Camera:set_position(x, y)
	self.x = x
	self.y = y
end
function Camera:set_rotation(phi)
	self.rot = phi
end
function Camera:set_zoom(val)
	self.zoom = val
end
function Camera:moveBy(x, y)
	self:moveTo(self.x+x, self.y+y)
end
function Camera:rotateBy(phi)
	self:set_rotation(self.rot + phi)
end
function Camera:zoomBy(val)
	self:set_zoom(self.zoom*val)
end
function Camera:on_init(width, height)
	self.width = width or self.width
	self.height = height or self.height
	self.camera = lib.hcam(0, 0)
end
function Camera:on_draw()
	local window_width, window_height = love.graphics.getDimensions()
	local window_scale = math.min(
		window_width/self.width, window_height/self.height)
	self.camera:lookAt(self.x, self.y);
	self.camera:rotateTo(self.rot);
	self.camera:zoomTo(self.zoom*window_scale);
	self.camera:attach(
		(window_scale*self.width  - window_width ) * -0.5,
		(window_scale*self.height - window_height) * -0.5,
		self.width*window_scale, self.height*window_scale);
end
function Camera:post_draw()
	self.camera:detach();
	love.graphics.setScissor();
end
register_component("camera", Camera);
