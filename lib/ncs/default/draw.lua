-- A rectangle that gets drawn
local DrawableRect = {
	color = {255, 255, 255, 255},
	mode = "fill",
	x1 = -10,
	y1 = -10,
	x2 =  10,
	y2 =  10,
}
function DrawableRect:on_init(mode, x1, y1, x2, y2, color)
	self.x1 = x1 or self.x1;
	self.y1 = y1 or self.y1;
	self.x2 = x2 or self.x2;
	self.y2 = y2 or self.y2;
	self.mode = mode or mode;
	self.color = color or {unpack(self.color)};
end
function DrawableRect:on_draw()
	-- local x, y = node:getpos();
	love.graphics.setColor(self.color);
	love.graphics.rectangle(self.mode, self.x1, self.y1,
		self.x2 - self.x1, self.y2 - self.y1)
end
register_component("drawable_rectangle", DrawableRect);

local DrawableCircle = {
	mode = "fill",
	x = 0,
	y = 0,
	radius = 10,
	color = {255, 255, 255, 255}
}
function DrawableCircle:on_init(mode, x, y, radius, color)
	self.mode = mode or self.mode
	self.x = x or self.x
	self.y = y or self.y
	self.radius = radius or self.radius
	self.color = color or {unpack(self.color)}
end
function DrawableCircle:on_draw()
	love.graphics.setColor(self.color);
	love.graphics.circle(self.mode, self.x, self.y, self.radius)
end
register_component("drawable_circle", DrawableCircle);

local DrawablePolygon = {
	mode = "fill",
	color = {255, 255, 255, 255},
}

function DrawablePolygon:on_init(mode, color, ...)
	self.mode = mode or self.mode
	if type(color) == "table" then
		self.color = {unpack(color)}
		self:_add_point(...)
	else
		self:_add_point(color, ...)
	end
end

function DrawablePolygon:_add_point(x,y,...)
	if x and y then
		table.insert(self, x)
		table.insert(self, y)
		self:_add_point(...)
	end
end

function DrawablePolygon:on_draw()
	love.graphics.setColor(self.color);
	love.graphics.polygon(self.mode, self)
end

register_component("drawable_polygon", DrawablePolygon)

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
function Drawable:on_init(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
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
function Drawable:on_draw()
	love.graphics.draw(self.drawable, self.x, self.y, self.rot,
		self.sx, self.sy, self.ox, self.oy, self.kx, self.ky);
end
register_component("drawable", Drawable)

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
function Spritemap:on_init(texture, sprites, current,
x, y, r, sx, sy, ox, oy, kx, ky)
	self.quads = {}
	if not sprites._i_am_inited then
		for k,v in pairs(sprites) do
			v[1] = v[1] + 0.1
			v[2] = v[2] + 0.1
			v[3] = v[3] - 0.2
			v[4] = v[4] - 0.2
		end
		sprites._i_am_inited = true
	end
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
function Spritemap:from_json(json)
	self:on_init(love.graphics.newImage(json.image), json.frames, json.current,
		json.x, json.y, json.rot, json.sx, json.sy,
		json.ox, json.oy, json.kx, json.ky)
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
register_component("spritemap", Spritemap)
