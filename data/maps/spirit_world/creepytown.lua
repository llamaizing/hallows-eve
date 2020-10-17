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


function map:on_opening_transition_finished()
    if not game:get_value("creepytown_seen_warp") then
      game:start_dialog("spirit_world.directions_to_warp")
    end
end


function see_ghost_candle_sensor:on_activated()
  if not game:get_value("ghost_candle_explanation") then
    game:set_value("ghost_candle_explanation", true)
    map:focus_on(ghost_candle, function()
      game:start_dialog("spirit_world.see_ghost_candle")
    end)
  end
end


function see_portal_sensor:on_activated()
  if not game:get_value("creepytown_seen_warp") then
    map:focus_on(warp_portal, function()
      game:start_dialog("spirit_world.see_warp")
      game:set_value("creepytown_seen_warp", true)
    end)
  end
end


function warped_sensor:on_activated()
--[[
  game:set_life(game:get_max_life())
  game:set_magic(game:get_max_magic())
  game:set_value("respawn_map", map:get_id())
  game:set_starting_location(map:get_id(), "ghost_candle_destination")
  game:save()
--]]
end



function witch_area_switch:on_activated()
  map:open_doors"witch_area_gate"
end
