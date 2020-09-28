local map = ...
local game = map:get_game()

map:register_event("on_started", function()

  map.light_fx:set_darkness_level("misty_forest")

  local fog1 = require("scripts/fx/fog").new()
  fog1:set_props{
  	fog_texture = {png = "fogs/fog.png", mode = "blend", opacity = 0},
  	opacity_range = {10,80},
    drift = {8, 0, -1, 1}
  }
  sol.menu.start(map, fog1)

  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/fog_2.png", mode = "blend", opacity = 60},
  	opacity_range = {40,140},
    drift = {15, 0, -1, 1}
  }
  sol.menu.start(map, fog2)
end)
