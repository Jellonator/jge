local AnimationPlayer = {}
AnimationPlayer.__index = AnimationPlayer

function AnimationPlayer.new(animations, current)
	local self = setmetatable({
		current = nil,
		animations = {},
		endings = {},
		playing = true
	}, AnimationPlayer)
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

function AnimationPlayer:addAnimation(name, anim)
	self.animations[name] = anim
end

function AnimationPlayer:get_current_animation()
	return self.animations[self.current]
end

function AnimationPlayer:get_animation(name)
	return self.animations[name]
end

function AnimationPlayer:set_ending(name, anim)
	self:get_animation(name):set_loop(false)
	self.endings[name] = anim
end

function AnimationPlayer:pause()
	self.playing = false
end

function AnimationPlayer:play(name, reset)
	local reset = jge.try_or(reset, false)
	if name == self.current then
		if reset then
			self:reset()
		end
	else
		self.current = name
		self:reset()
	end
	self.playing = true
end

function AnimationPlayer:reset()
	local a = self:get_current_animation()
	if a then
		a:reset()
	end
end

function Animation:step(dt)
	if not self.playing then return false end
	local a = self:get_current_animation()
	if a then
		local r = a:step(dt)
		if r and self.endings[self.current] then
			self:play(self.endings[self.current], true)
		end
		return r
	end
	return false
end

return setmetatable(AnimationPlayer, {
	__call = function(t, ...)
		return AnimationPlayer.new(...)
	end,
})
