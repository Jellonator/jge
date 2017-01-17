-- Animations
local function calc_bindings(node, bindings, anim)
	for track, bind in pairs(bindings) do
		local colon_pos = bind:find(':', 1, true)
		local path, func_def
		if colon_pos then
			path = bind:sub(1, colon_pos-1)
			func_def = bind:sub(colon_pos+1)
			if path == "" then path = "." end
		else
			func_def = bind
			path = "."
		end
		local target = node:get_node(path)
		local dot_pos = func_def:find(".", 1, true)
		local component_name = func_def:sub(1, dot_pos-1)
		local function_name = func_def:sub(dot_pos+1)
		if component_name == "transform" then
			local tr = target.transform
			anim:track_set_func(track, jge.bind_method(tr, function_name))
		else
			local func = jge.bind(target.call_signal, target, function_name, false)
			anim:track_set_func(track, func)
		end
	end
end

local Animation = {
	animation = nil
}
function Animation:on_init(tracks, length, loop)
	if tracks and tracks._i_am_an_animation then
		self.animation = tracks:clone()
	else
		self.animation = jge.anim.Animation(tracks, length, loop)
	end
end
function Animation:from_json(json)
	local tracks = {}
	local length = json.length
	local loop = json.loop
	if anim_def.tracks then
		for track_name, track_def in pairs(json.tracks) do
			tracks[track_name] = jge.anim.Track(track_def.data,
			track_def.func, track_def.interpolation, track_def.loop,
			track_def.ease)
		end
	end
	self.animation = jge.anim.Animation(tracks, length, loop)
	if json.bindings then
		calc_bindings(self.node, json.bindings, self.animationplayer)
	end
end
function Animation:on_update(dt)
	self.animation:step(dt)
end
function Animation:reset()
	self.animation:reset()
end
function Animation:get_track(name)
	return self.animation:get_track(name)
end
function Animation:add_track(name, track)
	self.animation:add_track(name, track)
end
function Animation:set_loop(loop)
	self.animation:set_loop(loop)
end
function Animation:set_length(length)
	self.animation:set_length(length)
end
function Animation:get_animation()
	return self.animation
end
function Animation:get_track(track)
	return self:get_animation():get_track(track)
end
function Animation:track_set_func(name, ...)
	self:get_track(name):set_func(...)
end
function Animation:track_set_component(track, nodepath, component, fname)
	if fname == nil then
		-- assume nodepath is self
		return self:track_set_component(track, self.node, nodepath, component)
	end
	if type(nodepath) == "string" then
		nodepath = self.node:get_node(nodepath)
	end
	local c = nodepath:get_component(component);
	local f_bind = jge.bind_method(c, fname)
	self:track_set_func(track, f_bind)
end
function Animation:track_set_property(track, object, property, ...)
	self:track_set_func(track, jge.bind_property(object, property, ...))
end
register_component("animation", Animation)

-- AnimationPlayer manager
local AnimationPlayer = {
	animationplayer = nil
}
function AnimationPlayer:on_init(animations, current)
	if animations and animations._i_am_an_animation_player then
		self.animationplayer = animations:clone()
	else
		self.animationplayer = jge.anim.AnimationPlayer(animations, current)
	end
end
function AnimationPlayer:from_json(json)
	self.animationplayer = jge.anim.AnimationPlayer();
	local animations = json.animations
	local current = json.current
	if animations then
		for anim_name, anim_def in pairs(animations) do
			local tracks = {}
			local length = anim_def.length
			local loop = anim_def.loop
			if anim_def.tracks then
				for track_name, track_def in pairs(anim_def.tracks) do
					tracks[track_name] = jge.anim.Track(track_def.data,
					track_def.func, track_def.interpolation, track_def.loop,
					track_def.ease)
				end
			end
			local anim = jge.anim.Animation(tracks, length, loop)
			self.animationplayer:add_animation(anim_name, anim)
			if anim_def.ending then
				self.animationplayer:set_ending(anim_name, anim_def.ending)
			end
		end
	end
	if json.endings then
		for anim, target in pairs(json.endings) do
			self.animationplayer:set_ending(anim, target)
		end
	end
	if json.ending_default then
		self.animationplayer:set_ending(json.ending_default)
	end
	if json.bindings then
		calc_bindings(self.node, json.bindings, self.animationplayer)
	end
	if current then
		self:play(current)
	end
end
function AnimationPlayer:add_animation(name, ...)
	return self.animationplayer:add_animation(name, ...)
end
function AnimationPlayer:get_animationplayer()
	return self.animationplayer
end
function AnimationPlayer:get_animation(anim)
	return self.animationplayer:get_animation(anim)
end
function AnimationPlayer:get_track(anim, track)
	return self.animationplayer:get_track(anim, track)
end
function AnimationPlayer:reset()
	self.animationplayer:reset()
end
function AnimationPlayer:play(name, doreset)
	self.animationplayer:play(name, doreset)
end
function AnimationPlayer:pause()
	self.animationplayer:pause()
end
function AnimationPlayer:resume()
	self.animationplayer:resume()
end
function AnimationPlayer:get_current()
	return self.animationplayer:get_current()
end
function AnimationPlayer:on_update(dt)
	self.animationplayer:step(dt)
end
function AnimationPlayer:set_ending(anim, name)
	self.animationplayer:set_ending(anim, name)
end
function AnimationPlayer:track_set_func(name, ...)
	self.animationplayer:track_set_func(name, ...)
end
function AnimationPlayer:track_set_component(track, nodepath, component, fname)
	if fname == nil then
		-- assume nodepath is self
		return self:track_set_component(track, self.node, nodepath, component)
	end
	if type(nodepath) == "string" then
		nodepath = self.node:get_node(nodepath)
	end
	local c = nodepath:get_component(component);
	local f_bind = jge.bind_method(c, fname)
	self:track_set_func(track, f_bind)
end
function AnimationPlayer:track_set_property(track, object, property, ...)
	self:track_set_func(track, jge.bind_property(object, property, ...))
end
register_component("animationplayer", AnimationPlayer)
