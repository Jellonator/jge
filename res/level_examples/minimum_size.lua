return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.17.1",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 30,
  height = 30,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 11,
  properties = {},
  tilesets = {
    {
      name = "Foreground",
      firstgid = 1,
      filename = "../WorldA/Foreground.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../Foreground.png",
      imagewidth = 192,
      imageheight = 192,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {
        {
          name = "solid",
          tile = -1,
          properties = {}
        }
      },
      tilecount = 36,
      tiles = {
        {
          id = 0,
          terrain = { -1, -1, -1, 0 }
        },
        {
          id = 1,
          terrain = { -1, -1, 0, 0 }
        },
        {
          id = 3,
          terrain = { -1, -1, 0, 0 }
        },
        {
          id = 4,
          terrain = { -1, -1, 0, -1 }
        },
        {
          id = 5,
          terrain = { 0, -1, 0, 0 }
        },
        {
          id = 6,
          terrain = { -1, 0, -1, 0 }
        },
        {
          id = 7,
          terrain = { 0, 0, 0, 0 },
          probability = 0
        },
        {
          id = 8,
          terrain = { 0, 0, 0, 0 },
          probability = 0
        },
        {
          id = 9,
          terrain = { 0, 0, 0, 0 },
          probability = 0
        },
        {
          id = 10,
          terrain = { 0, -1, 0, -1 }
        },
        {
          id = 11,
          terrain = { 0, 0, 0, -1 }
        },
        {
          id = 13,
          terrain = { 0, 0, 0, 0 },
          probability = 0
        },
        {
          id = 14,
          terrain = { 0, 0, 0, 0 }
        },
        {
          id = 15,
          terrain = { 0, 0, 0, 0 },
          probability = 0
        },
        {
          id = 17,
          terrain = { -1, 0, 0, 0 }
        },
        {
          id = 18,
          terrain = { -1, 0, -1, 0 }
        },
        {
          id = 19,
          terrain = { 0, 0, 0, 0 },
          probability = 0
        },
        {
          id = 20,
          terrain = { 0, 0, 0, 0 },
          probability = 0
        },
        {
          id = 21,
          terrain = { 0, 0, 0, 0 },
          probability = 0
        },
        {
          id = 22,
          terrain = { 0, -1, 0, -1 }
        },
        {
          id = 23,
          terrain = { 0, 0, -1, 0 }
        },
        {
          id = 24,
          terrain = { -1, 0, -1, -1 }
        },
        {
          id = 25,
          terrain = { 0, 0, -1, -1 }
        },
        {
          id = 27,
          terrain = { 0, 0, -1, -1 }
        },
        {
          id = 28,
          terrain = { 0, -1, -1, -1 }
        },
        {
          id = 29,
          objectGroup = {
            type = "objectgroup",
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            draworder = "index",
            properties = {},
            objects = {
              {
                id = 3,
                name = "",
                type = "",
                shape = "polygon",
                x = 0,
                y = 0,
                width = 0,
                height = 0,
                rotation = 0,
                visible = true,
                polygon = {
                  { x = 0, y = 0 },
                  { x = 24, y = 0 },
                  { x = 0, y = 24 }
                },
                properties = {}
              }
            }
          }
        },
        {
          id = 30,
          terrain = { 0, 0, 0, 0 },
          probability = 0.3
        },
        {
          id = 35,
          objectGroup = {
            type = "objectgroup",
            name = "",
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            draworder = "index",
            properties = {},
            objects = {
              {
                id = 1,
                name = "",
                type = "",
                shape = "polygon",
                x = 8,
                y = 0,
                width = 0,
                height = 0,
                rotation = 0,
                visible = true,
                polygon = {
                  { x = 0, y = 0 },
                  { x = 24, y = 0 },
                  { x = 24, y = 24 }
                },
                properties = {}
              }
            }
          }
        }
      }
    },
    {
      name = "Objects",
      firstgid = 37,
      filename = "../WorldA/Objects.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 1,
      tiles = {
        {
          id = 1,
          properties = {
            ["json"] = "../Player/player.json"
          },
          image = "../Player/playericon.png",
          width = 32,
          height = 32
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "Tile Layer 1",
      x = 0,
      y = 0,
      width = 30,
      height = 30,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["collidable"] = true
      },
      encoding = "lua",
      data = {
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 3, 3, 3, 3, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 3, 3, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3,
        15, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 15,
        3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 15, 3,
        3, 3, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 3, 3,
        3, 3, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 3, 3,
        3, 15, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 15, 3,
        15, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 15,
        3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 0, 0, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 3, 3, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 15, 3, 3, 3, 3, 15, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
      }
    },
    {
      type = "objectgroup",
      name = "Object Layer 1",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 6,
          name = "",
          type = "",
          shape = "polygon",
          x = 5.68434e-14,
          y = 0,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 576, y = 0 },
            { x = 0, y = 576 }
          },
          properties = {}
        },
        {
          id = 7,
          name = "",
          type = "",
          shape = "polygon",
          x = 0,
          y = 960,
          width = 0,
          height = 0,
          rotation = -810,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 576, y = 0 },
            { x = 0, y = 576 }
          },
          properties = {}
        },
        {
          id = 8,
          name = "",
          type = "",
          shape = "polygon",
          x = 960,
          y = 960,
          width = 0,
          height = 0,
          rotation = -540,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 576, y = 0 },
            { x = 0, y = 576 }
          },
          properties = {}
        },
        {
          id = 9,
          name = "",
          type = "",
          shape = "polygon",
          x = 960,
          y = 0,
          width = 0,
          height = 0,
          rotation = -270,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 576, y = 0 },
            { x = 0, y = 576 }
          },
          properties = {}
        },
        {
          id = 10,
          name = "",
          type = "",
          shape = "rectangle",
          x = 480,
          y = 704,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 38,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
