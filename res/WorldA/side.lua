return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.17.1",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 30,
  height = 48,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 3,
  properties = {},
  tilesets = {
    {
      name = "Background",
      firstgid = 1,
      filename = "Background.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../Background.png",
      imagewidth = 192,
      imageheight = 192,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 36,
      tiles = {}
    },
    {
      name = "Foreground",
      firstgid = 37,
      filename = "Foreground.tsx",
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
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "Background",
      x = 0,
      y = 0,
      width = 30,
      height = 48,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 2, 2, 1, 2, 1, 1, 2, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1, 1, 1, 2, 1, 2, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 1, 2, 1, 1, 1, 2, 24, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 2, 1, 2, 2, 1, 2, 2, 2, 2, 24, 1, 1, 2, 2, 1, 1, 1, 2, 1, 2, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 24, 1, 1, 1, 1, 2, 1, 2, 2, 2, 2, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 24, 1, 1, 2, 1, 2, 1, 1, 2, 2, 1, 20, 2, 1,
        0, 0, 0, 0, 0, 0, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 24, 2, 2, 2, 2, 1, 1, 1, 1, 2, 2, 26, 1, 2,
        0, 0, 0, 0, 0, 0, 2, 2, 1, 1, 2, 2, 1, 2, 1, 2, 9, 4, 4, 4, 4, 4, 8, 1, 1, 2, 1, 20, 2, 1,
        0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 1, 1, 2, 1, 2, 24, 1, 2, 1, 2, 1, 24, 2, 2, 2, 2, 20, 2, 1,
        0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 1, 2, 2, 2, 2, 2, 24, 1, 2, 1, 1, 2, 24, 2, 2, 2, 2, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 2, 19, 25, 19, 19, 19, 2, 1, 2, 1, 24, 1, 2, 2, 2, 2, 24, 2, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 2, 1, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 2, 1, 24, 2, 2, 2, 1, 20, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 1, 1, 2, 2, 0, 0, 0, 0, 2, 2, 2, 1, 24, 1, 1, 2, 2, 26, 2, 2,
        0, 0, 0, 0, 0, 0, 1, 4, 4, 4, 4, 4, 4, 4, 2, 0, 2, 2, 1, 1, 2, 2, 24, 1, 1, 1, 2, 26, 2, 1,
        0, 0, 0, 0, 0, 0, 2, 1, 2, 1, 1, 1, 2, 2, 1, 0, 2, 2, 1, 1, 1, 2, 13, 4, 4, 4, 4, 20, 4, 4,
        0, 0, 0, 0, 0, 0, 0, 2, 1, 2, 1, 1, 2, 2, 2, 1, 2, 2, 2, 1, 2, 1, 1, 1, 1, 2, 1, 26, 1, 1,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 1, 2, 2, 1, 2, 2, 2, 1, 1, 1, 1, 2, 2, 2, 1, 20, 1, 1,
        0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 25, 19, 19, 19, 25, 1, 2, 2, 1, 2, 1, 2, 1, 1, 1, 2, 2, 26, 2, 2,
        0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1, 2, 1, 1, 2, 2, 1, 1, 1, 2, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 1, 1, 2, 1, 2, 1, 1, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 1, 1, 2, 2, 2, 1, 2, 2, 1, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 1, 2, 2, 2, 2, 1, 1, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 1, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 1, 2, 2, 2, 2, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "Tile Layer 1",
      x = 0,
      y = 0,
      width = 30,
      height = 48,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["collidable"] = true
      },
      encoding = "lua",
      data = {
        51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 67, 67, 67, 67, 51, 51, 67, 67, 51, 67, 51, 51, 51, 51, 51,
        67, 51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 67, 51, 51, 51, 67, 51, 67, 67, 51, 51, 51, 67, 67, 51, 51, 51, 51, 51, 51,
        51, 67, 51, 67, 51, 51, 67, 67, 51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 67, 67, 67, 51, 51,
        51, 51, 51, 67, 51, 51, 67, 51, 51, 67, 51, 51, 51, 51, 67, 51, 51, 67, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 67,
        51, 51, 51, 67, 67, 67, 51, 51, 51, 51, 67, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 67, 51, 51, 67, 51, 51, 51, 51, 51,
        51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 67, 67, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 67, 67, 51, 51,
        51, 51, 51, 51, 67, 67, 51, 51, 67, 51, 51, 67, 51, 51, 51, 51, 67, 51, 51, 51, 67, 67, 67, 67, 67, 51, 51, 51, 51, 51,
        51, 67, 51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 67, 51, 51, 51, 67, 51, 67, 51, 51, 51, 51, 67, 67, 51, 67, 67, 67,
        51, 67, 51, 51, 51, 67, 51, 51, 67, 51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 51, 51, 51,
        67, 67, 51, 51, 51, 51, 51, 67, 51, 67, 67, 51, 51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51,
        51, 51, 51, 51, 51, 51, 51, 51, 51, 67, 67, 51, 67, 67, 51, 67, 51, 51, 51, 51, 51, 51, 67, 51, 67, 67, 51, 51, 51, 51,
        51, 51, 67, 51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 67, 51, 51, 51, 67, 67, 67, 67, 51, 67, 51, 51, 51, 67, 51, 51,
        51, 51, 67, 51, 51, 67, 51, 51, 67, 51, 51, 51, 51, 51, 51, 51, 67, 67, 67, 51, 48, 64, 62, 64, 64, 60, 51, 51, 51, 51,
        51, 51, 67, 51, 67, 51, 51, 51, 51, 51, 51, 51, 48, 62, 64, 60, 67, 48, 62, 62, 65, 0, 0, 0, 0, 55, 51, 67, 51, 51,
        67, 51, 51, 51, 51, 51, 51, 67, 51, 51, 48, 62, 65, 0, 0, 61, 64, 65, 0, 0, 0, 0, 0, 0, 0, 43, 51, 51, 51, 51,
        51, 51, 51, 51, 51, 51, 51, 51, 51, 48, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 55, 67, 51, 51, 67,
        51, 67, 51, 67, 51, 51, 67, 48, 64, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 55, 51, 51, 51, 51,
        67, 67, 51, 67, 51, 51, 67, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 61, 62, 64, 64, 62,
        51, 51, 51, 67, 51, 51, 51, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        67, 51, 51, 67, 51, 51, 51, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        51, 51, 67, 51, 67, 67, 51, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 37, 40, 38, 38,
        51, 51, 51, 51, 51, 51, 51, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 37, 38, 40, 40, 38, 40, 38, 54, 51, 51, 51,
        51, 51, 51, 51, 51, 51, 51, 59, 0, 0, 0, 37, 38, 38, 38, 40, 38, 38, 38, 54, 51, 51, 51, 51, 51, 67, 51, 51, 67, 51,
        51, 51, 51, 67, 51, 51, 67, 59, 0, 0, 0, 55, 51, 51, 51, 51, 67, 51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 67, 51,
        67, 51, 51, 67, 51, 51, 51, 59, 0, 0, 0, 61, 60, 51, 67, 51, 51, 51, 67, 48, 64, 62, 64, 64, 62, 62, 62, 62, 64, 62,
        51, 51, 67, 67, 51, 51, 51, 42, 41, 0, 0, 0, 61, 60, 51, 51, 51, 51, 48, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        51, 51, 51, 51, 51, 51, 51, 67, 47, 0, 0, 0, 0, 61, 60, 51, 48, 64, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        51, 67, 51, 67, 51, 51, 51, 51, 59, 0, 0, 0, 0, 0, 43, 51, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        51, 51, 67, 51, 67, 67, 67, 51, 47, 0, 0, 0, 0, 0, 55, 48, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        51, 51, 67, 51, 67, 51, 51, 51, 42, 40, 41, 0, 0, 0, 55, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        51, 51, 51, 67, 67, 51, 51, 67, 51, 51, 59, 0, 0, 0, 61, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 37, 38, 40, 40, 40,
        67, 67, 67, 51, 51, 51, 51, 51, 51, 51, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 55, 51, 51, 67, 51,
        51, 51, 51, 51, 51, 51, 51, 67, 51, 51, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 55, 51, 51, 51, 67,
        51, 51, 67, 51, 51, 67, 51, 51, 51, 51, 42, 40, 40, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 37, 54, 51, 51, 51, 51,
        51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 51, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 37, 54, 51, 51, 51, 51, 51,
        67, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 67, 51, 42, 41, 0, 0, 0, 0, 0, 0, 37, 38, 54, 51, 51, 67, 51, 67, 51,
        51, 51, 51, 51, 51, 51, 51, 67, 51, 67, 67, 51, 67, 51, 42, 40, 38, 40, 40, 38, 40, 54, 51, 51, 51, 51, 51, 51, 51, 51,
        51, 51, 51, 51, 67, 51, 67, 51, 67, 51, 67, 51, 51, 67, 67, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 51, 51, 67, 51, 67,
        51, 67, 67, 51, 51, 51, 51, 51, 51, 67, 67, 67, 51, 51, 51, 67, 51, 51, 51, 51, 67, 67, 51, 51, 67, 51, 51, 51, 51, 51,
        51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 67, 67, 51, 67, 51, 51, 51, 67, 67, 51, 67, 67, 51, 51, 67, 51, 51, 51, 67, 51,
        51, 51, 51, 51, 67, 67, 67, 67, 67, 67, 51, 67, 51, 51, 51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 67, 67, 67, 51, 51,
        51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 67, 51, 67, 51, 67, 67, 51, 51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 67, 67,
        51, 51, 51, 51, 67, 51, 67, 51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 67, 67, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51,
        51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 67, 51, 67, 67, 51, 67, 51, 51, 67, 51, 51, 51, 67, 67,
        51, 67, 51, 67, 51, 67, 67, 51, 51, 51, 51, 51, 51, 51, 51, 51, 67, 51, 51, 67, 67, 51, 51, 51, 51, 67, 51, 51, 51, 51,
        51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 67, 51, 51, 51, 51, 67, 67, 51, 51, 67, 51, 51, 51, 51, 67, 67,
        51, 51, 51, 51, 67, 51, 67, 51, 67, 67, 51, 51, 67, 51, 51, 51, 67, 51, 51, 51, 51, 67, 51, 51, 51, 67, 51, 51, 51, 51,
        67, 51, 51, 67, 67, 51, 51, 51, 67, 51, 51, 51, 51, 67, 51, 51, 51, 51, 51, 51, 51, 51, 51, 67, 67, 51, 67, 51, 51, 51
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
          id = 2,
          name = "",
          type = "",
          shape = "rectangle",
          x = 960,
          y = 544,
          width = 64,
          height = 448,
          rotation = 0,
          visible = true,
          properties = {
            ["json"] = "../Objects/loadzone/loadzone.json",
            ["level"] = "enterance.lua",
            ["name"] = "enterance",
            ["target"] = "side"
          }
        }
      }
    }
  }
}
