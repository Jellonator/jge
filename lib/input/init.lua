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

local ret = {
    Event = require("lib.input.event"),
    IMatch = require("lib.input.match"),
    Manager = require("lib.input.manager"),
}

return ret
