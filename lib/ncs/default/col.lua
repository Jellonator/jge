local Shape = {
	shape = nil
}
function Shape:on_init(node, shape)
	self.shape = shape
end
function Shape:on_draw(node)
	love.graphics.setColor(50, 255, 50)
	self.shape:draw()
end
function Shape:contains_point(node, x, y)
	return self.shape:contains_point(node:transform_point_inv(x, y))
end
register_component("shape", Shape)
