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

	love.graphics.push()
	love.graphics.origin();
	local x1, y1, x2, y2 = self.x1, self.y1, self.x2, self.y2
	local x3, y3 = node:transform_point(x1, y2);
	local x4, y4 = node:transform_point(x2, y1);
	x1, y1 = node:transform_point(x1, y1);
	x2, y2 = node:transform_point(x2, y2);
	love.graphics.setColor(100, 255, 0, 255);
	love.graphics.polygon("line", x1,y1, x4,y4, x2,y2, x3,y3);
	love.graphics.pop();
end
lib.ncs.Component.register_component("drawable_rect", DrawableRect);
