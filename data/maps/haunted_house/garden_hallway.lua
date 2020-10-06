local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/map_settings/haunted_house_fx"):set_fx(map)
  map.light_fx:set_darkness_level(4)

  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/fog_2.png", mode = "blend", opacity = 90},
  	opacity_range = {30,90},
    drift = {15, 0, -1, 1}
  }
  sol.menu.start(map, fog2)

  local fog4 = require("scripts/fx/fog").new()
  fog4:set_props{
  	fog_texture = {png = "fogs/fog_1.png", mode = "blend", opacity = 40},
  	opacity_range = {50,100},
    drift = {10, 0, -1, 1}
  }
  sol.menu.start(map, fog4)

end)

