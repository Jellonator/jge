local String = {}

function String.split(val, sep)
	return val:gmatch('([^'..sep..']+)')
end

return String;
