local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level(game:get_value("darkness_level"))
  
  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/fog_2.png", mode = "blend", opacity = 60},
  	opacity_range = {40,100},
    drift = {15, 0, -1, 1}
  }
  sol.menu.start(map, fog2)
end)

function warped_sensor:on_activated()
  game:set_life(game:get_max_life())
  game:set_magic(game:get_max_magic())
  game:save()
  game:set_value("respawn_map", map:get_id())
end