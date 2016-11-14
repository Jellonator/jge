local function unpack_points(t, i)
	i = i or 1
	if t[i] then
		return t[i].x, t[i].y, unpack_points(t, i+1)
	end
end

local function get_property(dat, prop, default)
	local val = (dat and dat.properties and dat.properties[prop])
	if val ~= nil then
		return val
	else
		return default
	end
end

local function generate_shape(hc, dat)
	local shape
	local x = dat.x or dat.x1 or 0
	local y = dat.y or dat.y1 or 0
	if dat.shape == "rectangle" then
		local width  = dat.width  or dat.w or (dat.x2 and dat.x2-x) or 1
		local height = dat.height or dat.h or (dat.y2 and dat.y2-y) or 1
		shape = hc:rectangle(x, y, width, height)
	elseif dat.shape == "polygon" then
		local points = shape.polygon or shape.points or shape.polyline or shape
		shape = hc:polygon(unpack(points))
		shape:move(x, y)
	elseif dat.shape == "circle" then
		local radius = dat.radius or dat.r
		shape = hc:circle(x, y, radius)
	elseif dat.shape == "point" then
		shape = hc:point(x, y)
	end

	return shape
end

local function load_objectgroup(map, hc, layer, collidables)
	local layer_collidable = get_property(layer, "collidable", false)
	for _, object in ipairs(layer.objects) do
		local object_collidable = get_property(object, "collidable", false)
		if object_collidable or layer_collidable then
			local dat = {
				shape = object.shape
			}
			local x       = object.dx or object.x
			local y       = object.dy or object.y
			local w       = object.width
			local h       = object.height
			local polygon = object.polygon or object.polyline or object.ellipse or object.rectangle
			local rot     = math.rad(object.rotation or 0)
			if object.shape == "rectangle" then
				local shape = hc:rectangle(x, y, w, h)
				shape:rotate(rot, x, y)
				if object.gid then
					local tileset = map.tilesets[map.tiles[object.gid].tileset]
					local ox = math.sin(rot)*h
					local oy = -math.cos(rot)*h
					shape:move(ox, oy)
				end
				collidables[shape] = shape
			elseif object.shape == "polygon" or object.shape == "polyline"
			or (object.shape == "ellipse" and w ~= h) then
				local shape = hc:polygon(unpack_points(polygon));
				-- shape:rotate(rot, x, y)
				print("rot", rot)
				collidables[shape] = shape
			elseif object.shape == "ellipse" then
				local r = w/2
				local cy = math.sin(rot)*r + math.cos(rot)*r
				local cx = math.cos(rot)*r - math.sin(rot)*r
				local shape = hc:circle(x+cx, y+cy, w/2)
				collidables[shape] = shape
			end
		end
	end
end

local function load_tilelayer(map, hc, layer, collidables)
	for gid, tiles in pairs(map.tileInstances) do
		local tile = map.tiles[gid]
		local tileset = map.tilesets[tile.tileset]

		for _, instance in ipairs(tiles) do
			if instance.layer == layer then
				local object = {
					shape  = "rectangle",
					x      = instance.x,
					y      = instance.y,
					width  = tileset.tilewidth,
					height = tileset.tileheight,
				}
				local shape = generate_shape(hc, object)
				collidables[shape] = shape
			end
		end
	end
end

return {
	hc_init = function(map, hc)
		local collidables = {}

		for _, layer in ipairs(map.layers) do
			-- Entire layer
			local layer_collidable = get_property(layer, "collidable", false)
			if layer_collidable then
				if layer.type == "tilelayer" then
					load_tilelayer(map, hc, layer, collidables)
				elseif layer.type == "objectgroup" then
					load_objectgroup(map, hc, layer, collidables)
				end
			end
		end
		map.hc_collidables = collidables
		map.hc_world = hc
	end,

	hc_removeLayer = function(map, index)--, hc)
		local layer = map.layers[index];
		local collidables = map.hc_collidables;
		local hc = map.hc_world;
		for shape in pairs(collidables) do
			if shape._maplayer == layer then
				hc:remove(shape)
				collidables[shape] = nil
			end
		end
	end,

	hc_draw = function(map)
		if not map.hc_collidables then return end
		for shape in pairs(map.hc_collidables) do
			shape:draw('line')
		end
	end
}