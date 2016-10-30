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
end
lib.ncs.Component.register_component("drawable_rectangle", DrawableRect);

-- An image or drawable
local Drawable = {
	drawable = nil,
	x = 0,
	y = 0,
	rot = 0,
	sx = 1,
	sy = 1,
	ox = 0,
	oy = 0,
	kx = 0,
	ky = 0
}
function Drawable:on_init(node, drawable, x, y, r, sx, sy, ox, oy, kx, ky)
	self.drawable = drawable
	self.x = x or self.x
	self.y = y or self.y
	self.rot = r or self.rot
	self.sx = sx or self.sx
	self.sy = sy or self.sy
	self.ox = ox or self.ox
	self.oy = oy or self.oy
	self.kx = kx or self.kx
	self.ky = ky or self.ky
end
function Drawable:on_draw(node)
	love.graphics.draw(self.drawable, self.x, self.y, self.rot,
		self.sx, self.sy, self.ox, self.oy, self.kx, self.ky);
end
lib.ncs.Component.register_component("drawable", Drawable)

-- Spritemap (Image or canvas with multiple sprites)
local Spritemap = {
	quads = nil,
	texture = nil,
	sprites = nil,
	current = 1,
	x = 0,
	y = 0,
	rot = 0,
	sx = 1,
	sy = 1,
	ox = 0,
	oy = 0,
	kx = 0,
	ky = 0
}
function Spritemap:on_init(node, texture, sprites, current,
x, y, r, sx, sy, ox, oy, kx, ky)
	self.quads = {}
	self.texture = texture
	self.sprites = sprites or self.sprites
	self.current = current or self.current
	self.x = x or self.x
	self.y = y or self.y
	self.rot = r or self.rot
	self.sx = sx or self.sx
	self.sy = sy or self.sy
	self.ox = ox or self.ox
	self.oy = oy or self.oy
	self.kx = kx or self.kx
	self.ky = ky or self.ky
end
function Spritemap:set_frame(id)
	self.current = id
end
function Spritemap:set_texture(texture)
	self.texture = texture
	self.quads = {}
end
function Spritemap:get_quad(id)
	local id = id or self.current;
	local q = self.quads[id]
	if q then
		return q
	else
		local sprite = self.sprites[id]
		if sprite then
			self.quads[id] = love.graphics.newQuad(
				sprite[1], sprite[2], sprite[3], sprite[4],
				self.texture:getDimensions())
			return self.quads[id]
		end
	end
end
function Spritemap:on_draw()
	local q = self:get_quad(self.current)
	if q then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.texture, q, self.x, self.y, self.rot,
			self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
	end
end
lib.ncs.Component.register_component("spritemap", Spritemap)

-- Tweens
--[[
Adds a few extra meta options:
node - path to the node to modify
component - modify a component under the given node
transform - modifies a node's transformations
--]]
local Tween = {
	tween = nil
}
function Tween:on_init(node, values, meta, speed)
	if values.i_am_a_tween then
		self.tween = values
		return
	end
	for k,v in pairs(meta) do
		v.object = v.node and node:get_node(v.node) or v.object or node
		if v.component then
			v.object = v.object:get_component(v.component)
		end
		if v.transform then
			v.object = v.object.transform
		end
	end
	self.tween = lib.anim.Tween(node, values, meta, speed)
end
function Tween:on_update(node, dt)
	self.tween:update(dt);
end
lib.ncs.Component.register_component("tween", Tween)

-- Animation manager
local Animation = {
	tweens = nil,
	current = "$NONE",
	playing = true
}
function Animation:on_init(node, tweens, meta, speed)
	self.tweens = {}
	for k,v in pairs(meta) do
		v.object = v.node and node:get_node(v.node) or v.object or node
		if v.component then
			v.object = v.object:get_component(v.component)
		end
		if v.transform then
			v.object = v.object.transform
		end
	end
	for k,v in pairs(tweens) do
		if v.i_am_a_tween then
			self.tweens[k] = v
		else
			local tween = lib.anim.Tween(node, v, meta, speed);
			self.tweens[k] = tween
		end
	end
end
function Animation:play(name, doreset)
	local doreset = try_or(doreset, false)
	if name == self.current and doreset == false then
		return
	end
	if name then
		self.current = name
		local tween = self.tweens[self.current]
		if tween then
			tween:reset()
		end
	end
	self.playing = true
end
function Animation:pause()
	self.playing = false
end
function Animation:on_update(node, dt)
	local tween = self.tweens[self.current]
	if tween and self.playing then
		tween:update(dt);
	end
end
lib.ncs.Component.register_component("animation", Animation)

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
