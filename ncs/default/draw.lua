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
	self.mode = mode or self.mode;
	self.color = color or {unpack(self.color)};
end
function DrawableRect:from_json(json)
	self.x1 = json.x1 or self.x1;
	self.y1 = json.y1 or self.y1;
	self.x2 = json.x2 or self.x2;
	self.y2 = json.y2 or self.y2;
	self.mode = json.mode or self.mode;
	self.color = json.color or {unpack(self.color)};
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
function DrawableCircle:from_json(json)
	self.mode = json.mode or self.mode
	self.x = json.x or self.x
	self.y = json.y or self.y
	self.radius = json.radius or self.radius
	self.color = json.color or {unpack(self.color)}
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
function DrawablePolygon:from_json(json)
	self.mode = mode or self.mode
	self.color = json.color or {unpack(self.color)}
	local p = json.points or json.vertices
	if p then
		self:_add_point(unpack(p))
	end
end
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
function Drawable:from_json(json)
	self.x = json.x or self.x
	self.y = json.y or self.y
	self.rot = json.r or self.rot
	self.sx = json.sx or self.sx
	self.sy = json.sy or self.sy
	self.ox = json.ox or self.ox
	self.oy = json.oy or self.oy
	self.kx = json.kx or self.kx
	self.ky = json.ky or self.ky
	if json.text then
		self.drawable = love.graphics.newText(love.graphics.getFont(), json.text)
	elseif json.image then
		self.drawable = love.graphics.newImage(json.image, json.flags)
	elseif json.video then
		self.drawable = love.graphics.newVideo(json.video, json.load_audio)
	end
end
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
	if not self.drawable then return end
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
	-- if not sprites._i_am_inited then
	-- 	for k,v in pairs(sprites) do
	-- 		v[1] = v[1] + 0.1
	-- 		v[2] = v[2] + 0.1
	-- 		v[3] = v[3] - 0.2
	-- 		v[4] = v[4] - 0.2
	-- 	end
	-- 	sprites._i_am_inited = true
	-- end
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
			local x = sprite[1]
			local y = sprite[2]
			local w = sprite[3]
			local h = sprite[4]
			local iw, ih = self.texture:getDimensions()
			--(quadX+0.5) * (1 + 1/tileW), (quadY+0.5) * (1 + 1/tileH),
			--tileW, tileH, imageW+imageW/tileW, imageH+imageH/tileH
			self.quads[id] = love.graphics.newQuad(
				(x+0.5) * (1 + 1/w), (y+0.5) * (1 + 1/h),
				w, h, iw + iw/w, ih + ih/h
			)
				-- sprite[1], sprite[2], sprite[3], sprite[4],
				-- self.texture:getDimensions())
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
