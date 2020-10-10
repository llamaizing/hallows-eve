local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level(game:get_value("darkness_level"))

  local fog1 = require("scripts/fx/fog").new()
  fog1:set_props{
  	fog_texture = {png = "fogs/pollen_1.png", mode = "blend", opacity = 10},
  	opacity_range = {20,80},
    drift = {10, 0, -1, 1},
    parallax_speed = 1.2,
  }
  sol.menu.start(map, fog1)

  local fog3 = require("scripts/fx/fog").new()
  fog3:set_props{
  	fog_texture = {png = "fogs/pollen_2.png", mode = "blend", opacity = 10},
  	opacity_range = {30,70},
    drift = {20, 0, -1, 1},
    parallax_speed = 1.5,
  }
  sol.menu.start(map, fog3)
  
  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/fog_2.png", mode = "blend", opacity = 60},
  	opacity_range = {0,40},
    drift = {15, 0, -1, 1}
  }
  sol.menu.start(map, fog2)

  if game:get_value"lizard_flood_finished" then
    zach:set_enabled(false)
    toby:set_enabled(false)
  end
end)


function flood_end_sensor:on_activated()
  if not game:get_value"lizard_flood_finished" then
    game:set_value("lizard_flood_finished", true)
    map:start_coroutine(function()
      hero:freeze()
      dialog"haunted_house.cutscenes.outside_1"
      dialog"haunted_house.cutscenes.outside_2"
      dialog"haunted_house.cutscenes.outside_3"
      local m = sol.movement.create"target"
      m:set_target(kid_disappear_sensor)
      m:set_speed(90)
      m:start(toby)
      local m2 = sol.movement.create"target"
      m2:set_target(kid_disappear_sensor)
      m2:set_speed(90)
      movement(m2, zach)
      zach:set_enabled(false)
      toby:set_enabled(false)
      hero:unfreeze()

    end)
  end
end