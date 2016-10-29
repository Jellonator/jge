-- A few default components

-- Script, intended to override basic functions such as on_update and on_draw
local Script = {}
function Script:on_init(node, t)
	if not t then return end
	for k,v in pairs(t) do
		self[k] = v
	end
	if t.on_init then
		t.on_init(self, node)
	end
end
lib.ncs.Component.register_component("script", Script);

-- A rectangle that gets drawn
local DrawableRect = {
	color = {255, 255, 255, 255},
	mode = "fill",
	x1 = -10,
	y1 = -10,
	x2 =  10,
	y2 =  10,
	_depends = {"position"}
}
function DrawableRect:on_init(node, mode, x1, y1, x2, y2, color)
	self.x1 = x1 or self.x1;
	self.y1 = y1 or self.y1;
	self.x2 = x2 or self.x2;
	self.y2 = y2 or self.y2;
	self.mode = mode or mode;
	self.color = color or {unpack(self.color)};
end
function DrawableRect:on_draw(node)
	-- local x, y = node:getpos();
	love.graphics.setColor(self.color);
	love.graphics.rectangle(self.mode, self.x1, self.y1,
		self.x2 - self.x1, self.y2 - self.y1)
	--
	-- love.graphics.push()
	-- love.graphics.origin();
	-- local x1, y1, x2, y2 = self.x1, self.y1, self.x2, self.y2
	-- local x3, y3 = node:transform_point(x1, y2);
	-- local x4, y4 = node:transform_point(x2, y1);
	-- x1, y1 = node:transform_point(x1, y1);
	-- x2, y2 = node:transform_point(x2, y2);
	-- love.graphics.setColor(100, 255, 0, 255);
	-- love.graphics.polygon("line", x1,y1, x4,y4, x2,y2, x3,y3);
	-- love.graphics.pop();
end
lib.ncs.Component.register_component("drawable_rect", DrawableRect);

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
function Camera:on_init(node, width, height)
	self.width = width or self.width
	self.height = height or self.height
	self.camera = lib.hcam(0, 0)
end
function Camera:on_draw(node)
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
function Camera:post_draw(node)
	self.camera:detach();
	love.graphics.setScissor();
end

lib.ncs.Component.register_component("camera", Camera);
