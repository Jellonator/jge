local Prefab = {}
Prefab.__index = Prefab;

--[[ Prefab definition:
{
	x = 80, y = 80, -- at (80, 80)
	scalex = 2, scaley = 2, -- scaled by 2
	rotation = 0, -- no rotation
	children = {
		{ -- One child named `foo`
			name="foo",
			x = 20, -- offset by (20, 0)
			children = {},
			components = {
				{ -- and with a single component that draws a rectangle
					name = "drawable_rect",
					args = {"fill",-10,-10,10,10}
				},
			}
		},
		{ -- One child named `foo`
			name="bar",
			x = -20, -- offset by (20, 0)
			children = {},
			components = {
				{ -- and with a single component that draws a rectangle
					name = "drawable_rect",
					args = {"fill",-10,-10,10,10}
				},
			}
		}
	},
	components = {
		{ -- with a script component that rotates
			name="script",
			args={
				{
					on_update=function(self, node, dt)
						node.transform:rotate(dt)
					end
				}
			}
		}
	}
}
]]
function Prefab.new(def, x, y)
	return setmetatable({
		def = def,
		x = x or 0,
		y = y or 0
	}, Prefab);
end

local function _instance(def, x, y)
	x = x or 0
	y = y or 0
	if def.x then x = x + def.x end
	if def.y then y = y + def.y end
	local node = jge.ncs.Node(x, y);
	node.transform:scale(def.scalex or 1, def.scaley or 1);
	node.transform:rotate(def.rotation or 0);
	if def.components then
		for _, c in pairs(def.components) do
			node:add_component(c.name, unpack(c.args))
		end
	end

	if def.children then
		for _, c in pairs(def.children) do
			node:add_child(c.name, _instance(c))
		end
	end

	return node
end

function Prefab:instance(x, y)
	x = x or 0
	y = y or 0
	return _instance(self.def, self.x + x, self.y + y)
end

return setmetatable(Prefab, {
	__call = function(t, ...)
		return Prefab.new(...)
	end
})
