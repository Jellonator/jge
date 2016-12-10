EVENTTYPE = {
	null         = 0,
	directory    = 1,
	keyboard     = 2,
	mousemove    = 3,
	mousebutton  = 4,
	mousewheel   = 5,
	windowresize = 6,
	--[[
	joyaxis      = 7,
	joydirection = 8,
	joybutton    = 9
	]]
}

local NAME = ...

local ret = {
	Event = require(NAME .. ".event"),
	IMatch = require(NAME .. ".match"),
	Manager = require(NAME .. ".manager"),
}

return ret
