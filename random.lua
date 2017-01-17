local Random = {}

local function _random(rng, ...)
	if rng then
		return rng:random(...)
	else
		return love.math.random(...)
	end
end

local function _random_normal(rng, ...)
	if rng then
		return rng:randomNormal(...)
	else
		return love.math.randomNormal(...)
	end
end

function Random.uniform(min, max, rng)
	return _random(rng)*(max-min)+min
end

function Random.normal(...)
	return _random_normal(...)
end

function Random.normal_range(min, max, tries, rng)
	-- useful for returning a random number without
	-- the headache of standard deviation
	local stddev = math.abs(max-min)/4
	local mean = (max+min)/2
	return Random.normal_limit(stddev, mean, 2, tries, rng)
end

function Random.normal_limit(stddev, mean, limit, tries, rng)
	limit = limit or 3
	tries = tries or 3
	local val = Random.limited_no_fallback(_random_normal, tries,
	 	mean-stddev*limit, mean+stddev*limit, rng, stddev, mean)
	if val then return val end
	-- if all else fails, return a random number (not normal, but close enough)
	return _random(rng)*stddev*limit + mean
end

function Random.triangular(min, max, center, rng)
	center = center or (max+min)/2
	local r = _random(rng, -1, 1)
	if r < 0 then
		r = -r
		return jge.lerp(r, min, center)
	elseif r > 0 then
		return jge.lerp(r, center, max)
	end
	return center
end

function Random.normal_skewed(stddev, mean, skew, rng)
	-- skew alters shape of the distribution.
	-- Deviation on same side of skew is similar to regular normal distribution
	-- Deviation on other side of skew is divided by 1+skew
	local skew = skew or 0
	local df = math.abs(skew) + 1
	local value = _random_normal(rng, 1, 0)

	local inorm = jge.infnorm(value*skew, df)
	local lerp = (inorm+1)/2
	local ret = value * jge.lerp(lerp*lerp, stddev/df, stddev)
	ret = ret + mean

	return ret
end

function Random.normal_skewed_limit(stddev, mean, skew, limit, tries, rng)
	limit = limit or 3
	tries = tries or 3
	local val = Random.limited_no_fallback(Random.normal_skewed, tries,
	 	mean-stddev*limit, mean+stddev*limit, rng, stddev, mean, skew)
	if val then return val end
	-- if all else fails, return a random number (not normal, but close enough)
	return _random(rng)*stddev*limit + mean
end

function Random.sampled(func, samples, ...)
	local ret = 0
	for i = 1, samples do
		ret = ret + func(...)
	end
	return ret / samples
end

function Random.limited(func, tries, min, max, ...)
	local ret = Random.limited_no_fallback(func, tries, min, max, ...)
	return ret or love.math.random()*(max-min)+min
end

function Random.limited_no_fallback(func, tries, min, max, ...)
	for i = 1, math.max(1, tries or 3) do
		local result = func(...)
		if result >= min and result <= max then
			return result
		end
	end
end

return Random
