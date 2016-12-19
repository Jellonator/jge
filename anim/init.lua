local NAME = ...

local Anim = {
	Track = require(NAME .. ".track"),
	Animation = require(NAME .. ".animation"),
	AnimationPlayer = require(NAME .. ".animationplayer"),
	AnimationTree = require(NAME .. ".animationtree")
}

return Anim
