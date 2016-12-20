local AnimationPlayer = {}
AnimationPlayer.__index = AnimationPlayer

function AnimationPlayer.new(animations, current)
	local self = setmetatable({
		current = nil,
		animations = {},
		endings = {},
		playing = true,
		_i_am_an_animation_player = true,
	}, AnimationPlayer)
	if animations then
		for name, anim in pairs(animations) do
			self:add_animation(name, anim)
		end
	end
	if current then
		self:play(current)
	end
	return self
end

function AnimationPlayer:clone()
	local other = setmetatable({
		animations = {},
		endings = {},
		current = self.current,
		playing = self.playing,
	}, AnimationPlayer);
	for key, ending in pairs(self.endings) do
		other.endings[key] = ending
	end
	for key, anim in pairs(self.animations) do
		other.animations[key] = anim:clone()
	end
	return other
end

function AnimationPlayer:add_animation(name, anim, ...)
	print(name, anim, ...)
	if anim and anim._i_am_an_animation then
		self.animations[name] = anim:clone()
	else
		self.animations[name] = jge.anim.Animation(anim, ...)
	end
	return self.animations[name]
end

function AnimationPlayer:get_current()
	return self.current
end

function AnimationPlayer:get_current_animation()
	return self.animations[self.current]
end

function AnimationPlayer:get_animation(name)
	return self.animations[name]
end

function AnimationPlayer:set_ending(name, anim)
	if anim == nil then
		self.default_ending = name
		return
	end
	jge.printf("Set ending %s to %s", name, anim)
	-- self:get_animation(name):set_loop(false)
	self.endings[name] = anim
end

function AnimationPlayer:has_ending(anim)
	local e = self:get_ending(anim)
	return e and true or false
end

function AnimationPlayer:get_ending(anim)
	local e = self.endings[anim]
	if e then
		return e
	end
	if self.default_ending ~= anim then
		return self.default_ending
	end
end

function AnimationPlayer:pause()
	self.playing = false
end

function AnimationPlayer:resume()
	self.playing = true
end

function AnimationPlayer:has_animation(name)
	return self:get_animation(name) and true or false
end

function AnimationPlayer:play(name, reset)
	local reset = jge.try_or(reset, false)
	if name == self.current then
		if reset then
			self:reset()
		end
	else
		if self:has_animation(name) then
			self.current = name
			self:reset()
		end
	end
	self.playing = true
end

function AnimationPlayer:reset()
	local a = self:get_current_animation()
	if a then
		a:reset()
	end
end

function AnimationPlayer:step_random()
	local a = self:get_current_animation()
	if a then
		a:step_random()
	end
end

function AnimationPlayer:step(dt)
	if not self.playing then return false end
	local a = self:get_current_animation()
	if a then
		-- Do not allow animation to loop when there is a default ending
		local p_loop = a.loop
		local does_end = self:has_ending(self.current)
		if does_end and p_loop then
			a:set_loop(false)
		end
		local r = a:step(dt)
		if does_end and p_loop then
			a:set_loop(p_loop)
		end

		if r and does_end then
			self:play(self:get_ending(self.current), true)
		end
		return r
	end
	return true
end

function AnimationPlayer:track_set_func(track, ...)
	for _, anim in pairs(self.animations) do
		local t = anim:get_track(track)
		if t then
			t:set_func(...)
		end
	end
end

function AnimationPlayer:get_track(anim, track)
	return self:get_animation(anim):get_track(track)
end

return setmetatable(AnimationPlayer, {
	__call = function(t, ...)
		return AnimationPlayer.new(...)
	end,
})
