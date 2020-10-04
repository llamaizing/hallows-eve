local map = ...
local game = map:get_game()

map:register_event("on_started", function()

  map.light_fx:set_darkness_level({200,180,240})

  local fog1 = require("scripts/fx/fog").new()
  fog1:set_props{
  	fog_texture = {png = "fogs/fog.png", mode = "blend", opacity = 0},
  	opacity_range = {0,30},
    drift = {8, 0, -1, 1}
  }
  sol.menu.start(map, fog1)

  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/fog_2.png", mode = "blend", opacity = 60},
  	opacity_range = {10,60},
    drift = {15, 0, -1, 1}
  }
  sol.menu.start(map, fog2)
end)


function warped_sensor:on_activated()
  game:set_life(game:get_max_life())
  game:set_magic(game:get_max_magic())
  game:set_value("respawn_map", map:get_id())
  game:set_starting_location(map:get_id(), "ghost_candle_destination")
  game:save()
end