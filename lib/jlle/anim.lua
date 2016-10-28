local Animation = {}
Animation.__index = Animation;

function Animation.new(filename, ...)
	local self = setmetatable({
		filename=filename,
		frames = {},
		animations = {}
	}, Animation);
	return self:addFrame(...);
end

function Animation:addFrame(anim_name, frame, ...)
	if frame == nil then return self end
	if self.animations[anim_name] == nil then
		self.animations[anim_name] = {}
	end
	local anim = self.animations[anim_name];

	if type(frame) == 'number' then
		table.insert(anim, frame);

	elseif type(frame) == 'string' then
		for val in JLLE.String.split(frame, ',') do
			local prev;
			for strnum in JLLE.String.split(val, '-') do
				local next = tonumber(strnum);
				if prev then
					for i = prev, next, (next > prev and 1 or -1) do
						if i ~= prev and i ~= next then
							self:addFrame(anim_name, i);
						end
					end
				end
				self:addFrame(anim_name, next);
				prev = next;
			end
		end

	elseif type(frame) == 'table' then
		for i,v in ipairs(frame) do
			self:addFrame(anim_name, v);
		end
	end

	return self:addFrame(anim_name, ...);
end

function Animation:spawn()
	return {filename=self.filename};
end

return setmetatable(Animation, {
	__call = function(t, ...)
		return Animation.new(...);
	end
});
