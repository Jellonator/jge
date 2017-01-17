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
function Camera:set_bounds(...)
	self.camera:setBounds(...)
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
function Camera:move_by(x, y)
	self:moveTo(self.x+x, self.y+y)
end
function Camera:rotate_by(phi)
	self:set_rotation(self.rot + phi)
end
function Camera:zoomBy(val)
	self:set_zoom(self.zoom*val)
end
function Camera:on_init(width, height)
	self.width = width or self.width
	self.height = height or self.height
	self.camera = jge.hcam(0, 0)
end
function Camera:from_json(json)
	self.width = json.width or self.width
	self.height = json.height or self.height
	self.camera = jge.hcam(0, 0)
	self:set_position(json.x or 0, json.y or 0);
	self:set_rotation(json.rotation or json.angle or json.r or json.rot or 0)
	self:set_zoom(json.zoom or 1)
	if json.bounds then
		self.camera:setBounds(
			json.bounds.x1, json.bounds.y1, 
			json.bounds.x2, json.bounds.y2,
			json.bounds.correct, json.bounds.range)
	end
end
function Camera:_push()
	local window_width, window_height = love.graphics.getDimensions()
	local window_scale = math.min(
		window_width/self.width, window_height/self.height)
	-- self.camera:lookAt(self.x, self.y);
	assert(not self._px and not self._py and not self._prot,
		"We pushed twice! We've gone too far!")

	self._px, self._py, self._prot = self.camera.x, self.camera.y, self.camera.rot
	self.camera:move(self.x, self.y)
	self.camera:rotate(self.rot);
	self.camera:zoomTo(self.zoom*window_scale);

	return
		(window_scale*self.width  - window_width ) * -0.5,
		(window_scale*self.height - window_height) * -0.5,
		self.width*window_scale,
		self.height*window_scale;
end
function Camera:_pop()
	assert(self._px and self._py and self._prot,
		"We popped without a dang ol' push!")
	self.camera:lookAt(self._px, self._py);
	self.camera.rot = self._prot
	self._px, self._py, self._prot = nil, nil, nil
end
function Camera:pre_draw()
	self.camera:attach(self:_push());
	self:_pop()
end
function Camera:world_coords(x, y)
	x, y = self.camera:worldCoords(x, y, self:_push())
	self:_pop()

	return x, y
end
function Camera:mouse_position()
	local x, y = self.camera:mousePosition(self:_push())
	self:_pop()

	return x, y
end
function Camera:world_coords_diff(mx, my)
	local x, y = self.camera:worldCoordDiff(mx, my, self:_push())
	self:_pop()

	return x, y
end
function Camera:get_bounded_position()
	local x, y = self.camera:_getBoundedPosition(self:_push())
	self:_pop()

	return x, y
end
function Camera:bbox()
	local x1,y1,x2,y2 = self.camera:bbox(self:_push())
	self:_pop()
	return x1,y1,x2,y2
end
function Camera:post_draw()
	self.camera:detach();
	love.graphics.setScissor();
end
register_component("camera", Camera);
