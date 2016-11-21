local pathfollow = {}

local function parse_stops(stops)
	if type(stops) == "string" then
		local ret = {}
		for v in stops:gmatch("[^,]") do
			local n = tonumber(v:trim())
			table.insert(ret, n)
		end
		return ret
	end
	return stops
end

local function rev_sort(a, b)
	return a > b
end

function pathfollow:on_init()
	local body = self.node:get_component("collisionbody")

	self.path = self.path or {}
	local polygon = self.path.polygon or self.path.rectangle or self.path.ellipse
	if self.loop == nil then
		self.loop = polygon and true or false
	end
	self.path = polygon or self.path.polyline or self.path

	self.speed = self.speed or 80;
	self.wait = self.wait or 1;
	self.interpolation = self.interpolation or "linear"
	self.stops = self.stops and parse_stops(self.stops) or {#self.path, 1}
	table.sort(self.stops, rev_sort)
	if #self.path >= 1 then
		local p = self.path[1]
		body.shape:move(jge.vlt.add(-p.x, -p.y, self.node.transform:get_translation()))
	end
	if #self.path >= 2 then
		local points = {}
		for i, v in ipairs(self.path) do
			local nexti = i + 1
			if nexti > #self.path then nexti = self.loop and 1 or i - 1 end
			local next = self.path[nexti]
			local dis = jge.vlt.dist(v.x, v.y, next.x, next.y)
			table.insert(points, {dis, v})
			prev = v
		end
		if not self.loop then
			for i = #points-1, 2, -1 do
				local nexti = i - 1
				local next = self.path[nexti]
				local v = points[i][2]
				local dis = jge.vlt.dist(v.x, v.y, next.x, next.y)
				table.insert(points, {dis, v})
			end
		end
		if self.length then
			local total = 0;
			for k,v in pairs(points) do
				total = total + v[1]
			end
			self.speed = total / self.length
		end
		self.wait = self.wait * self.speed
		if self.length then
			-- make sure the length of all waits all add up to the same
			self.wait = self.wait * 2 / #self.stops
		end
		if self.wait > 0 then
			for _, i in ipairs(self.stops) do
				local v = points[i]
				local wait = self.wait
				table.insert(points, i, {wait, v[2]})
			end
		end
		self.node:add_component("tween", points, {
			x = {component="script", func="path_setx", interpolation=self.interpolation},
			y = {component="script", func="path_sety", interpolation=self.interpolation},
		}, self.speed)
	end
	body:generate_bodydraw();
end

function pathfollow:path_setx(x)
	self.x = x
end

function pathfollow:path_sety(y)
	self.y = y
end

function pathfollow:on_update(dt)
	if not self.x or not self.y then return end
	self.node.transform:set_translation(self.x, self.y)
	self.node:_recalculate()
	local newx, newy = self.node:getpos()
	if self.px and self.py then
		local mx, my = newx - self.px, newy - self.py
		local body = self.node:get_component("collisionbody")
		for shape, sep in pairs(body:get_collisions()) do
			if shape.body and shape.body.pushable then
				shape:move(mx, my)
				shape.body:_move_node(mx, my)
			end
		end
		body:resolve_neighbors()
	end
	self.px, self.py = newx, newy
end

return pathfollow;
