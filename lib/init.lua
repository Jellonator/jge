local lpath = ... .. '.';
local function reqlocal(path)
	return require(lpath .. path)
end

function try_or(a, b, ...)
	if a ~= nil then
		return a
	elseif b ~= nil then
		return try_or(b, ...)
	end
end

function string.trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string.split(s)
	return s:gmatch("[^%s]")
end

function math.sign(x)
	if x == 0 then return 0
	elseif x > 0 then return 1
	else return -1 end
end

return {
	vec   = reqlocal("hump.vector"),
	vlt   = reqlocal("hump.vector-light"),
	hcam  = reqlocal("hump.camera"),
	jlle  = reqlocal("jlle"),
	tiled = reqlocal("tiled"),
	ncs   = reqlocal("ncs"),
	anim  = reqlocal("anim"),
	Input = reqlocal("input"),
	Transform = reqlocal("transform"),
	Shape = reqlocal("shape")
}
