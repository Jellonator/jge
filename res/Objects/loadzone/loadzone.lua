local loadzone = {}

local loadzone_bboxes = {}

function loadzone:on_init()
	print("ADDING LOAD ZONE: ", tostring(self.target) .. " to " .. tostring(self.name))
	local body = self.node:get_component("collisionbody");
	body:disable();
	local shape = body.shape;
	local _, tilemap = self.node:get_parent_with_component("tiledmaploader");
	self.node:_recalculate()
	local x1,y1, x2,y2 = shape:bbox();
	loadzone_bboxes[self.name] = self
	if not self.edge then
		local tx1, ty1, tx2, ty2 = tilemap:bbox();
		local c = 0;
		if x2 >= tx2 then
			c = c + 1
			self.edge = "right"
		end
		if y2 >= ty2 then
			c = c + 1
			self.edge = "bottom"
		end
		if x1 <= tx1 then
			c = c + 1
			self.edge = "left"
		end
		if y1 <= ty1 then
			c = c + 1
			self.edge = "top"
		end
		assert(c == 1, "Could not guess edge for loadzone! Either specify the edge directly, or place it in a better spot. " .. tostring(c));
	end
	assert(self.level, "This loadzone does not have an associated level!")
	self.level = tilemap.map._path .. self.level
end

function loadzone:load_zone(shape)
	local body = self.node:get_component("collisionbody");
	local player = shape.body.node
	local old_level_node, old_level = self.node:get_parent_with_component("tiledmaploader");
	local _, levelmanager = self.node:get_parent_with_component("levelmanager");
	assert(levelmanager, "There is no level manager mang!")

	local   self_x1,   self_y1,   self_x2,   self_y2 = body.shape:bbox();
	local player_x1, player_y1, player_x2, player_y2 = shape:bbox();
	local player_width, player_height = player_x2-player_x1, player_y2-player_y1
	local player_x, player_y = shape:center()

	local _,camera = self.node:get_root():get_component("camera");

	local to_x, to_y = 0, 0;
	local _, tilemap = levelmanager:set_level(self.level, function(new_level_node, new_level)
		local target_x1, target_y1, target_x2, target_y2 =
			loadzone_bboxes[self.target].node
			:get_component("collisionbody").shape:bbox()

		local offx, offy = 0, 0;
		if self.edge == "left" then
			to_x = target_x1 - player_width - 1
			to_y = player_y - self_y2 + target_y2
			offx = self_x2 - target_x1
			offy = self_y2 - target_y2
		elseif self.edge == "right" then
			to_x = target_x2 + player_width + 1
			to_y = player_y - self_y2 + target_y2
			offx = self_x1 - target_x2
			offy = self_y2 - target_y2
		elseif self.edge == "top" then
			to_y = target_y1 - player_height - 1
			to_x = player_x - (self_x2 + self_x1)/2 + (target_x2 + target_x1)/2
			offy = self_y2 - target_y1
			offx = (self_x2 + self_x1)/2 - (target_x2 + target_x1)/2
		elseif self.edge == "bottom" then
			to_y = target_y2 + player_height + 1
			to_x = player_x - (self_x2 + self_x1)/2 + (target_x2 + target_x1)/2
			offy = self_y1 - target_y2
			offx = (self_x2 + self_x1)/2 - (target_x2 + target_x1)/2
		end

		local mx, my = to_x - player_x, to_y - player_y
		shape:move(mx, my);
		shape.body:_move_node(mx, my);
		player:get_root():_recalculate();
		return offx, offy, player
	end, 640, {})

	player:get_root():_recalculate();
	player:get_root():add_child(player)
	if tilemap then
		tilemap:bind_camera()
	end
end

function loadzone:on_update(dt)
	local body = self.node:get_component("collisionbody");
	local col = body:get_collisions();
	for shape in pairs(col) do
		local player = shape.body and shape.body.node
		if player and player:is_in_group("player") then
			self:load_zone(shape);
		end
	end
end

return loadzone;
