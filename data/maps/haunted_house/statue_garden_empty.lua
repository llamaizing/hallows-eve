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
end)


function sensor:on_activated()
  if not game:get_value("haunted_house_statue_garden_empty") then
    game:set_value("haunted_house_statue_garden_empty", true)
    map:start_coroutine(function()
      hero:freeze()
      dialog("haunted_house.observations.4_statue_garden_1")
      local camera = map:get_camera()
      local m = sol.movement.create"straight"
      m:set_speed(70)
      m:set_max_distance(192)
      m:set_angle(math.pi / 2)
      movement(m, camera)
      dialog("haunted_house.observations.4_statue_garden_2")
      m = sol.movement.create"straight"
      m:set_speed(100)
      m:set_max_distance(192)
      m:set_angle(math.pi / 2 * 3)
      movement(m, camera)
      camera:start_tracking(hero)
      hero:unfreeze()
    end)
  end
end