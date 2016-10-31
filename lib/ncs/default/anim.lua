-- Tweens
--[[
Adds a few extra meta options:
node - path to the node to modify
component - modify a component under the given node
transform - modifies a node's transformations
--]]
local Tween = {
	tween = nil
}
function Tween:on_init(node, values, meta, speed)
	if values.i_am_a_tween then
		self.tween = values
		return
	end
	for k,v in pairs(meta) do
		v.object = v.node and node:get_node(v.node) or v.object or node
		if v.component then
			v.object = v.object:get_component(v.component)
		end
		if v.transform then
			v.object = v.object.transform
		end
	end
	self.tween = lib.anim.Tween(node, values, meta, speed)
end
function Tween:on_update(node, dt)
	self.tween:update(dt);
end
register_component("tween", Tween)

-- Animation manager
local Animation = {
	tweens = nil,
	current = "$NONE",
	playing = true
}
function Animation:on_init(node, tweens, meta, speed)
	self.tweens = {}
	for k,v in pairs(meta) do
		v.object = v.node and node:get_node(v.node) or v.object or node
		if v.component then
			v.object = v.object:get_component(v.component)
		end
		if v.transform then
			v.object = v.object.transform
		end
	end
	for k,v in pairs(tweens) do
		if v.i_am_a_tween then
			self.tweens[k] = v
		else
			local tween = lib.anim.Tween(node, v, meta, speed);
			self.tweens[k] = tween
		end
	end
end
function Animation:play(name, doreset)
	self.playing = true
	local doreset = try_or(doreset, false)
	if name == self.current and doreset == false then
		return
	end
	if name then
		self.current = name
		local tween = self.tweens[self.current]
		if tween then
			tween:reset()
		end
	end
end
function Animation:pause()
	self.playing = false
end
function Animation:on_update(node, dt)
	local tween = self.tweens[self.current]
	if tween and self.playing then
		tween:update(dt);
	end
end
register_component("animation", Animation)
