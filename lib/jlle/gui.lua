local Gui = {}
Gui.__index = Gui;

function Gui.new()
	local self = setmetatable({}, Gui);
	return self;
end

function Gui:create()

end

function Gui:draw()

end

function Gui:feed(input)

end

setmetatable(Gui, {
	__call = function(t, ...)
		return Gui.new(...);
	end
})

return Gui;
