local Shape = {}

-- Circles and polygons are the only necessary shapes

function Shape.new_rectangle(x1,y1, x2,y2)
	return Shape.new_polygon(x1,y1, x2,y1, x2,y2, x1,y2);
end

function Shape.new_point(x,y)
	-- return Shape.new_circle(x,y, 1e-5)
	return Shape.new_circle(x,y, 0)
end

local function side_of_line(x1,y1, x2,y2, qx,qy)
	return math.sign((x2-x1)*(qy-y1) - (y2-y1)*(qx-x1))
end

local function lines_cross(x1,y1, x2,y2, x3,y3, x4,y4)
	local a = side_of_line(x1,y1, x2,y2, x3,y3);
	local b = side_of_line(x1,y1, x2,y2, x4,y4);
	local c = side_of_line(x3,y3, x4,y4, x1,y1);
	local d = side_of_line(x3,y3, x4,y4, x2,y2);
	local ab = a ~= b
	local cd = c ~= d
	return (ab and cd) or ((a==0 or b==0) and cd) or ((c==0 or d==0) and ab)
end

local function polygon_dir(points)
	if points._dir == nil then
		points._dir = side_of_line(points[1].x, points[1].y,
			points[2].x, points[2].y, points[3].x, points[3].y)
	end
	return points._dir
end

local function split_convex(points)
	local triangles = love.math.triangulate(points);
	local shapes = {}
	local edges = {}
	local points = {}
	for i,tri in ipairs(triangles) do
		local shape = {}
		for i=1,#tri,2 do
			local x,y = tri[i],tri[i+1]
			table.insert(shape, {x,y,x=x,y=y})
		end
		shape.dir = side_of_line(unpack(tri));
		table.insert(shapes, shape)
	end
	local x1, y1, x2, y2 = math.huge, math.huge, -math.huge, -math.huge
	local px,py = points[#points-1], points[#points]
	for i = 1,#points, 2 do
		local x, y = points[i],points[i+1]
		x1 = math.min(x1, x)
		y1 = math.min(y1, y)
		x2 = math.max(x2, x)
		y2 = math.max(y2, y)
		table.insert(points, {x,y,x=x,y=y})
		table.insert(edges, {x1=px,y1=py,x2=x,y2=y})
		px,py = x,y
	end

	return shapes, edges, points, minx, miny, maxx, maxy
end

local function unpack_points(point, ...)
	if not point then return end
	return point.x, point.y, unpack_points(...)
end

local function circle_contains_point(x1, y1, radius, x2, y2)
	return (x2-x1)^2 + (y2-y1)^2 <= radius^2
end

local function circle_contains_line(x, y, radius, x1, y1, x2, y2)
	return circle_contains_point(x,y,radius,x1,y1)
	or circle_contains_point(x,y,radius,x2,y2)
	or circle_contains_point(lib.vlt.project(x2-x1,y2-y1, x-x1,y-y1))
end

local function circle_contains_polygon(x, y, radius, points)
	if polygon_contains_point(points, x, y) then
		return true
	end
	local prev_point = points[#points]
	for i,point in ipairs(points) do
		if circle_contains_line(prev_point.x, prev_point.y, point.x, point.y) then
			return true
		end
		prev_point = point
	end
	return false
end

local function polygon_contains_point(points, x, y)
	local prev_point = points[#points];
	for i,point in ipairs(points) do
		if side_of_line(prev_point.x,prev_point.y,
		point.x,point.y, x,y) == -polygon_dir(points) then
			return false
		end
		prev_point = point
	end
	return true;
end

-- Polygon shape
local Polygon = {}
Polygon.__index = Polygon;
function Polygon:contains_point(x, y)
	for _, shape in pairs(self.shapes) do
		local is_in_shape = true;

		if polygon_contains_point(shape, x, y) then
			return true
		end
	end
	return false
end
function Polygon:contains_line(x1,y1, x2,y2)
	if self:contains_point(x1,y1) or self:contains_point(x2,y2) then
		return true
	end
	for i,line in ipairs(self.lines) do
		if lines_cross(line.x1,line.y1, line.x2,line.y2, x1,y1, x2,y2) then
			return true
		end
	end
	return false
end
function Polygon:contains_polygon(points)
	if #points == 0 then return false end
	local prev_point = points[#points]
	for i,point in ipairs(points) do
		if self:contains_line(prev_point.x,prev_point.y, point.x,point.y) then
			return true
		end
		prev_point = point
	end
	for i,point in ipairs(self.points) do
		if polygon_contains_point(points, point.x, point.y) then
			return true
		end
	end
	return false
end
function Polygon:contains_circle(x, y, radius)
	for _,shape in pairs(self.shapes) do
		if circle_contains_polygon(x,y,radius, shape) then
			return true
		end
	end
	return false
end
function Polygon:contains_shape(shape)
	if not self:check_bbox(shape) then return false end
	for _,shape in pairs(self.shapes) do
		if shape:contains_polygon(shape) then
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
function Polygon:bbox()
	return self.x1, self.y1, self.x2, self.y2
end
function Shape.new_polygon(...)
	local shapes, edges, points, x1, y1, x2, y2 = split_convex({...})
	return setmetatable({
		shapes = shapes,
		lines = edges,-- kek
		edges = edges,
		points = points,
		x1 = x1,
		y1 = y1,
		x2 = x2,
		y2 = y2
	}, Polygon)
end

-- Circle shape
local Circle = {}
Circle.__index = Circle;
function Circle:contains_point(x, y)
	return circle_contains_point(self.x, self.y, self.radius, x, y)
end
function Circle:contains_line(x1,y1, x2,y2)
	return circle_contains_line(self.x, self.y, self.radius, x1,y1, x2,y2)
end
function Circle:contains_polygon(points)
	return circle_contains_polygon(self.x, self.y, self.radius, points)
end
function Circle:contains_circle(x, y, radius)
	return circle_contains_point(self.x, self.y, self.radius + radius, x, y)
end
function Circle:contains_shape(shape)
	if not self:check_bbox(shape) then return false end
	return shape:contains_circle(self.x, self.y, self.radius)
end
function Circle:draw()
	love.graphics.circle("line", self.x, self.y, self.radius)
end
function Circle:bbox()
	return self.x - self.radius, self.y - self.radius,
	self.x + self.radius, self.y + self.radius
end
function Circle:check_bbox(shape)
	local x1,y1,x2,y2 = self:bbox()
	local x3,y3,x4,y4 = shape:bbox()
	return x1 <= x4 and y1 <= y4 and x2 >= x3 and y2 >= y3
end
function Shape.new_circle(x, y, r)
	return setmetatable({x=x,y=y,radius=r}, Circle);
end

return Shape;
