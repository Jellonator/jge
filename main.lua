lib = require("lib");

inputmanager = lib.Input.Manager();
inputmanager:add_event("up",    lib.Input.IMatch(EVENTTYPE.keyboard, "w"))
inputmanager:add_event("down",  lib.Input.IMatch(EVENTTYPE.keyboard, "s"))
inputmanager:add_event("left",  lib.Input.IMatch(EVENTTYPE.keyboard, "a"))
inputmanager:add_event("right", lib.Input.IMatch(EVENTTYPE.keyboard, "d"))
inputmanager:add_event("rotl",  lib.Input.IMatch(EVENTTYPE.keyboard, "q"))
inputmanager:add_event("rotr",  lib.Input.IMatch(EVENTTYPE.keyboard, "e"))
-- inputmanager:add_callback("foo", printer, "foo", "There");
-- inputmanager:add_callback("bar", printer, "foo", "World");
inputmanager:override_love();

local prefab = lib.ncs.Prefab({
	children = {
		{ -- One child named `foo`
			name="foo",
			x = 40, -- offset by (20, 0)
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
			x = -40, -- offset by (20, 0)
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
});

root = lib.ncs.Node();
tree = root:add_child("tree")
tree:add_component("camera", 400*2, 224*2)

function love.load(arg)
	for ix = -800, 800, 40 do
		for iy = -448, 448, 56 do
			tree:add_child(("%i_%i"):format(ix, iy), prefab:instance(ix, iy));

		end
	end
	-- tree:add_child("a", prefab:instance(-200, -100));
	-- tree:add_child("b", prefab:instance( 200, -100));
	-- tree:add_child("c", prefab:instance(   0,  200));
	-- node = lib.ncs.Node(100, 100);
	-- -- node:add_component("drawable_rect", "fill");
	-- node.transform:scale(2, 1);
	--
	-- child = node:add_child("foo");
	-- child:add_component("drawable_rect")
	--
	-- inputmanager:add_callback("up",    child.transform, "translate",   0, -10)
	-- inputmanager:add_callback("down",  child.transform, "translate",   0,  10)
	-- inputmanager:add_callback("left",  child.transform, "translate", -10,   0)
	-- inputmanager:add_callback("right", child.transform, "translate",  10,   0)
	-- inputmanager:add_callback("rotl",  child.transform, "rotate", math.pi*-0.25/2)
	-- inputmanager:add_callback("rotr",  child.transform, "rotate", math.pi* 0.25/2)
end

function love.update(dt)
	root:update(dt);
end

function love.draw()
	root:draw(dt);
end

function love.quit()

end
