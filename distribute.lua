local Distribute = {}

-- local utilities
local PI2 = math.pi*2

local function _calculate_shells(count, num, cutoff, initial)
	initial = initial or num
	cutoff = cutoff or 0.5
	local shells = {}
	local iter = initial
	local mul = 1
	local shell_vals = {}
	while count >= iter do
		count = count - iter
		table.insert(shells, iter)
		for i = 1, iter/num do
			table.insert(shell_vals, #shells)
		end
		iter = iter + num
	end
	if count <= cutoff * iter and #shell_vals >= 1 then
		--add remaining count to existing shells
		local i = #shell_vals
		while count > 0 do
			local pos = shell_vals[i]
			shells[pos] = shells[pos] + 1
			i = i - 1
			count = count - 1
			if i < 1 then
				i = #shell_vals
			end
		end
	else
		mul = count / iter
		-- make new shell with remainder if takes up at least 75% of a shell
		table.insert(shells, count)
		count = 0
	end
	-- always have a shell with null length at end
	table.insert(shells, 0)
	return shells, mul
end

--[[ DISTRIBUTION FUNCTIONS ]]
-- these distribution functions place a series of points into the bounds (-1, -1) to (1, 1)
-- distribute in a circle
function Distribute.circle(t, offset)
	local rot = offset or 0
	local rot_delta = PI2/#t
	for i, pos in ipairs(t) do
		local c = math.cos(rot)
		local s = math.sin(rot)
		rot = rot + rot_delta
		pos.x = c
		pos.y = s
	end
	return 1
end

-- distribute in concentric circles
function Distribute.circles_concentric(t, per_circle, initial)
	per_circle = per_circle or 6
	initial = initial or per_circle
	local d = ((initial or per_circle) - 1)/(per_circle-1)
	local a = math.random()*PI2
	local dis = 1

	local shells, dir_mul = _calculate_shells(#t, per_circle, 0.5, initial);
	local next_s = 1;
	local num = shells[next_s]
	local left = num
	local dir_mul = 1
	local actual_d = d
	print("DIST")
	for i, pos in ipairs(t) do
		actual_d = d
		local angle = a + PI2*(left/num)

		pos.x = math.cos(angle)*d
		pos.y = math.sin(angle)*d
		left = left - 1
		if left <= 0 then
			a = -math.random()*PI2
			next_s = next_s + 1
			num = shells[next_s]
			if next_s == #shells then
				dis = dis*dir_mul
			end
			left = num
			d = d + dis
		end
	end

	for _, pos in ipairs(t) do
		pos.x = pos.x / actual_d
		pos.y = pos.y / actual_d
	end

	return actual_d
end

--[[ DISTRIBUTION TRANFORMATION FUNCTIONS ]]
-- these functions take a distribution and transform them
function Distribute.mul(t, val)
	for _, pos in ipairs(t) do
		pos.x = pos.x * val
		pos.y = pos.y * val
	end
end

function Distribute.mul_xy(t, x, y)
	for _, pos in ipairs(t) do
		pos.x = pos.x * x
		pos.y = pos.y * y
	end
end

function Distribute.translate(t, x, y)
	for _, pos in ipairs(t) do
		pos.x = pos.x + x
		pos.y = pos.y + y
	end
end

function Distribute.rotate(t, angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	for _, pos in ipairs(t) do
		local x, y = pos.x, pos.y
		pos.x = c*x - s*y
		pos.y = s*x + c*y
	end
end

return Distribute
