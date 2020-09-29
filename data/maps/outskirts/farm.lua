local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level(game:get_value("darkness_level"))
  
  local fog1 = require("scripts/fx/fog").new()
  fog1:set_props{
  	fog_texture = {png = "fogs/pollen_1.png", mode = "blend", opacity = 60},
  	opacity_range = {0,70},
    drift = {10, 0, -1, 1}
  }
  sol.menu.start(map, fog1)

  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/pollen_2.png", mode = "blend", opacity = 10},
  	opacity_range = {0,40},
    drift = {15, 0, -1, 1},
    parallax_speed = 1.3,
  }
  sol.menu.start(map, fog2)

  local fog3 = require("scripts/fx/fog").new()
  fog3:set_props{
  	fog_texture = {png = "fogs/pollen_3.png", mode = "blend", opacity = 60},
  	opacity_range = {10,110},
    drift = {25, 0, -1, 1},
    parallax_speed = 1.7,
  }
  sol.menu.start(map, fog3)
end)
