local Animation = {}
Animation.__index = Animation;

function Animation.new(tracks, length, loop)
	local self = setmetatable({
		tracks = {},
		length = length or 0,
		pos = 0,
		loop = jge.try_or(loop, true),
	}, Animation);
	for name, track in pairs(tracks) do
		self:add_track(name, track)
	end
end

function Animation:clone()
	local other = setmetatable({
		tracks = {},
		length = self.length,
		pos = self.pos,
		loop = self.loop
	}, Animation)
	for name, track in pairs(self.tracks) do
		other.tracks[name] = track:clone()
	end
	return other
end

function Animation:set_loop(loop)
	self.loop = loop
	for name, track in pairs(self.tracks) do
		track:set_loop(self:do_tracks_loop())
	end
end

function Animation:set_length(length)
	self.length = length or 0
	for name, track in pairs(self.tracks) do
		track:set_loop(self:do_tracks_loop())
	end
end

function Animation:add_track(name, track)
	self.tracks[name] = track
	track:set_loop(self:do_tracks_loop())
end

function Animation:get_track(name)
	return self.tracks[name]
end

function Animation:reset()
	for name, track in pairs(self.tracks) do
		track:reset();
	end
	self.pos = 0
end

function Animation:is_independent()
	return self.length <= 0
end

function Animation:do_tracks_loop()
	return self.loop and self:is_independent()
end

function Animation:step(dt)
	local ret = false
	if self:is_independent() then
		for name, track in pairs(self.tracks) do
			track:step(dt)
		end
	else
		self.pos = self.pos + dt
		if self.pos >= self.length and self.loop then
			self.pos = self.pos % self.length
			for name, track in pairs(self.tracks) do
				track:reset()
				track:step(self.pos)
			end
		else
			if not self.loop and self.pos >= self.length then
				ret = true
			end
			for name, track in pairs(self.tracks) do
				track:step(dt)
			end
		end
	end
	return ret
end

return setmetatable(Animation, {
	__call = function(t, ...)
		return Animation.new(...)
	end
})
