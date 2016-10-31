local Shape = {}

function Shape.new_rectangle(x1,y1, x2,y2)
	return Shape.new_polygon(x1,y1, x2,y1, x2,y2, x1,y2);
end

local function side_of_line(x1,y1, x2,y2, qx,qy)
	return math.sign((x2-x1)*(qy-y1) - (y2-y1)*(qx-x1))
end

local function split_convex(points)
	local triangles = love.math.triangulate(points);
	local shapes = {}
	for i,tri in ipairs(triangles) do
		local shape = {}
		for i=1,#tri,2 do
			local x,y = tri[i],tri[i+1]
			table.insert(shape, {x,y,x=x,y=y})
		end
		shape.dir = side_of_line(unpack(tri));
		table.insert(shapes, shape)
	end

	return shapes
end

local function unpack_points(point, ...)
	if not point then return end
	return point.x, point.y, unpack_points(...)
end

local Polygon = {}
Polygon.__index = Polygon;
function Polygon:contains_point(x, y)
	for _, shape in pairs(self.shapes) do
		local prev_point = shape[#shape];
		local is_in_shape = true;
		for i,point in ipairs(shape) do
			if side_of_line(prev_point.x,prev_point.y,
			point.x,point.y, x,y) ~= shape.dir then
				is_in_shape = false;
				break;
			end
			prev_point = point
		end
		if is_in_shape then
			return true
		end
	end
	return false
end
function Polygon:draw()
	for _,shape in pairs(self.shapes) do
		if not shape.color then
			shape.color = {math.random(0, 255),math.random(0, 255),math.random(0, 255), 150}
			shape.color[math.random(1,3)] = 255
		end
		if #shape >= 3 then
			love.graphics.polygon("line", unpack_points(unpack(shape)))
			love.graphics.setColor(shape.color)
			love.graphics.polygon("fill", unpack_points(unpack(shape)))
		end
	end
end
function Shape.new_polygon(...)
	return setmetatable({
		shapes = split_convex({...})
	}, Polygon)
end

local Circle = {}
Circle.__index = Circle;
function Circle:contains_point(x, y)
	return (x-self.x)^2 + (y-self.y)^2 < self.radius^2
end
function Circle:draw()
	love.graphics.circle("line", self.x, self.y, self.radius)
end
function Shape.new_circle(x, y, r)
	return setmetatable({x=x,y=y,radius=r}, Circle);
end

return Shape;
