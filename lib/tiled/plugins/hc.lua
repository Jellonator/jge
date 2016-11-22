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

local function generate_object_shape(map, hc, object,
		collidables, ox, oy, object_collidable, layer, layer_index)
	ox = ox or 0
	oy = oy or 0
	local x       = object.dx or object.x
	local y       = object.dy or object.y
	local w       = object.width
	local h       = object.height
	local polygon = object.polygon or object.polyline or object.ellipse or object.rectangle
	local rot     = math.rad(object.rotation or 0)
	local shape;
	local is_polygon = false;
	if object.shape == "rectangle" then
		shape = hc:rectangle(0, 0, w, h)
		shape:rotate(rot, 0, 0)
		if object.gid then
			local tileset = map.tilesets[map.tiles[object.gid].tileset]
			local ox = math.sin(rot)*h
			local oy = -math.cos(rot)*h
			shape:move(ox, oy)
		end
	elseif object.shape == "polygon" or object.shape == "polyline"
	or (object.shape == "ellipse" and w ~= h) then
		is_polygon = true;
		shape = hc:polygon(unpack_points(polygon));
	elseif object.shape == "ellipse" then
		local r = w/2
		local cy = math.sin(rot)*r + math.cos(rot)*r
		local cx = math.cos(rot)*r - math.sin(rot)*r
		shape = hc:circle(cx, cy, w/2)
	end
	collidables[shape] = shape
	if is_polygon and ox == 0 and oy == 0 then
		x = 0
		y = 0
	end
	shape:move(ox+x, oy+y)
	shape.tiled_object = object
	shape.tiled_layer = layer
	shape.tiled_layer_index = layer_index
	shape.object_properties = object.properties
	if object.gid then
		local tile = map.tiles[object.gid]
		local tileset = map.tilesets[tile.tileset]
		shape.tileset_properties = tileset.properties;
		shape.tile_properties = tile.properties
		shape.tiled_gid = object.gid
		shape.tiled_batch = object.batch
		shape.tiled_batchid = object.batchid
	end
	if not object_collidable then
		hc:remove(shape)
	end
	map.hc_collidables_named[object.name] = shape
end

local function load_objectgroup(map, hc, layer, collidables, ox, oy, force_col)
	force_col = force_col ~= nil and force_col or false
	local layer_collidable = get_property(layer, "collidable", false)
	for i, object in ipairs(layer.objects) do
		local object_collidable = get_property(object, "collidable", false)
		object_collidable = object_collidable or layer_collidable or force_col
		--then
		generate_object_shape(map, hc, object, collidables,
			ox, oy, object_collidable, layer, i)
		--end
	end
end

local function tilemap_test_range(tilemap, x1, y1, x2, y2)
	for ix = x1, x2 do
		if ix < 1 or ix > #tilemap then return false end
		for iy = y1, y2 do
			if iy < 1 or iy > #tilemap[ix] then return false end
			if tilemap[ix][iy] == 0 then
				return false
			end
		end
	end
	return true
end

local function tilemap_take_range(tilemap, x1, y1, x2, y2)
	for ix = x1, x2 do
		for iy = y1, y2 do
			tilemap[ix][iy] = 0
		end
	end
end

local function tilemap_take_horizontal(tilemap, x1, y1, x2, y2)
	-- try to the left
	while tilemap_test_range(tilemap, x1-1, y1, x1-1, y2) do
		x1 = x1 - 1
	end
	-- try to the right
	while tilemap_test_range(tilemap, x2+1, y1, x2+1, y2) do
		x2 = x2 + 1
	end
	return x1, y1, x2, y2
end

local function tilemap_take_vertical(tilemap, x1, y1, x2, y2)
	-- try to the top
	while tilemap_test_range(tilemap, x1, y1-1, x2, y1-1) do
		y1 = y1 - 1
	end
	-- try to the bottom
	while tilemap_test_range(tilemap, x1, y2+1, x2, y2+1) do
		y2 = y2 + 1
	end
	return x1, y1, x2, y2
end

local function load_tilelayer(map, hc, layer, collidables)
	local tilemap = {}
	for ix = 1, layer.width do
		tilemap[ix] = {}
		for iy = 1, layer.height do
			tilemap[ix][iy] = 0
		end
	end

	local indexes_x = {}
	local indexes_y = {}
	for gid, tiles in pairs(map.tileInstances) do
		local tile = map.tiles[gid]
		local tileset = map.tilesets[tile.tileset]

		for _, instance in ipairs(tiles) do
			if instance.layer == layer then
				if tile.objectGroup then
					load_objectgroup(map, hc, tile.objectGroup, collidables,
						instance.x + layer.offsetx, instance.y + layer.offsety, true)
				else
					local ix, iy = map:convertPixelToTile(instance.x, instance.y)
					ix = ix + 1
					iy = iy + 1
					tilemap[ix][iy] = 1
					table.insert(indexes_x, ix)
					table.insert(indexes_y, iy)
				end
			end
		end
	end
	local count = 1
	for i = 1, #indexes_x do
		local ix = indexes_x[i]
		local iy = indexes_y[i]
		if tilemap[ix][iy] == 1 then
			local x1, y1, x2, y2 = ix, iy, ix, iy
			x1, y1, x2, y2 = tilemap_take_vertical(tilemap, x1, y1, x2, y2)
			x1, y1, x2, y2 = tilemap_take_horizontal(tilemap, x1, y1, x2, y2)
			tilemap_take_range(tilemap, x1, y1, x2, y2)
			x1, y1 = map:convertTileToPixel(x1-1, y1-1)
			x2, y2 = map:convertTileToPixel(x2, y2)
			local object = {
				shape  = "rectangle",
				x      = x1 + layer.offsetx,
				y      = y1 + layer.offsety,
				width  = x2-x1,
				height = y2-y1,
			}
			local shape = generate_shape(hc, object)
			collidables[shape] = shape
			count = count + 1
		end
	end
end

return {
	hc_init = function(map, hc)
		local collidables = {}
		map.hc_collidables_named = {}

		for _, layer in ipairs(map.layers) do
			-- Entire layer
			local layer_collidable = get_property(layer, "collidable", false)
			if layer.type == "tilelayer" then
				if layer_collidable then
					load_tilelayer(map, hc, layer, collidables)
				end
			elseif layer.type == "objectgroup" then
				load_objectgroup(map, hc, layer, collidables)
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
