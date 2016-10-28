local Table = {};

--[[
	valuemap is a map of values by the string uuid of the old table.
	this is done for several reasons.
	First, this prevents a stack overflow from recursively copying tables.
	Second, it makes sure that child-parent relationships stay consistent.
	Third, it allows for metatables to be used correctly.
]]
local function _deepcopy(t, valuemap)
	-- local valuemap = valuemap or {};
	local ret = {};
	local oldmeta = getmetatable(t);
	setmetatable(t, nil);
	valuemap[t] = {old = t, new = ret, meta = oldmeta};

	for previous_key, previous_value in pairs(t) do
		local new_key = previous_key;
		if type(previous_key) == "table" then
			if valuemap[previous_key] ~= nil then
				new_key = valuemap[previous_key].new;
			else
				new_key = _deepcopy(previous_key, valuemap);
			end
		end

		if type(previous_value) == "table" then
			if valuemap[previous_value] ~= nil then
				-- use new value if the value has already been copied
				ret[new_key] = valuemap[previous_value].new;
			else
				-- otherwise create a copy of the value
				ret[new_key] = _deepcopy(previous_value, valuemap);
			end
		else
			ret[new_key] = previous_value;
		end
	end
	setmetatable(t, oldmeta);

	return ret;
end

function Table.deepcopy(t, copy_nonlocal_metatables)
	local copy_nonlocal_metatables = copy_nonlocal_metatables ~= nil and copy_nonlocal_metatables or false;
	-- do copies
	local valuemap = {};
	local ret = _deepcopy(t, valuemap);

	-- do deep copy of all metatables ( NOT perfect, don't use yet! )
	if copy_nonlocal_metatables then
		local done = false;
		while not done do
			done = true;
			for key, value in pairs(valuemap) do
				if value.meta ~= nil and value.newmeta == nil then
					value.newmeta = _deepcopy(value.meta, valuemap);
					done = false;
				end
			end
		end
	end

	-- set metatables
	for key, value in pairs(valuemap) do
		if value.meta ~= nil then
			-- if the metatable exists in valuemap use that instead
			local oldmeta = value.meta;
			local newmeta = valuemap[oldmeta];
			if newmeta ~= nil then
				setmetatable(value.new, newmeta);
			elseif copy_nonlocal_metatables then
				setmetatable(value.new, value.newmeta);
			else
				setmetatable(value.new, oldmeta);
			end
		end
	end

	return ret;
end

local function unpackeach_default(n)
	return n;
end

function Table.unpackeach(t, func, i, ...)
	local i = i or #t;
	if i == 0 then
		return ...;
	end
	local func = func or unpackeach_default;
	return Table.unpackeach(t, func, i - 1, func(t[i], i), ...)
end

return Table;
