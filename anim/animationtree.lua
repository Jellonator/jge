local AnimationTree = {}
-- TODO

return setmetatable(AnimationTree, {
	__call = function(t, ...)
		return AnimationTree.new(...)
	end
})
