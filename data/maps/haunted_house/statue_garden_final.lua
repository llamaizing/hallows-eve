local map = ...
local game = map:get_game()
local hero = map:get_hero()

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

  if game:get_value("haunted_house_lizardnapper_scene") then
    toby:remove()
    zach:remove()
    maggie:remove()
  end

end)


function map:on_opening_transition_finished()
  if not game:get_value("haunted_house_lizardnapper_scene") then
    map:cutscene()
  end
end


function map:cutscene()
  local camera = map:get_camera()
  map:start_coroutine(function()
    hero:freeze()
    local m = sol.movement.create"straight"
    m:set_max_distance(256)
    m:set_angle(math.pi / 2)
    m:set_speed(95)
    movement(m, camera)
    dialog"haunted_house.cutscenes.lizardnapper.1"
    dialog"haunted_house.cutscenes.lizardnapper.2"
    dialog"haunted_house.cutscenes.lizardnapper.3"
    dialog"haunted_house.cutscenes.lizardnapper.4"
    dialog"haunted_house.cutscenes.lizardnapper.5"
    dialog"haunted_house.cutscenes.lizardnapper.6"
    dialog"haunted_house.cutscenes.lizardnapper.7"
    dialog"haunted_house.cutscenes.lizardnapper.8"

    maggie:get_sprite():set_animation("jumping")
    sol.audio.play_sound"jump"
    m = sol.movement.create"straight"
    m:set_angle(math.rad(45))
    m:set_speed(90)
    m:set_ignore_obstacles()
    m:set_max_distance(24)
    movement(m, maggie)
    maggie:set_layer(0)
    m = sol.movement.create"straight"
    m:set_angle(math.rad(280))
    m:set_speed(150)
    m:set_ignore_obstacles()
    m:set_max_distance(48)
    movement(m, maggie)
    wait(1000)
    m = sol.movement.create"path"
    m:set_path{6,6,6,6,6,6}
    movement(m, camera)
    camera:start_tracking(zach)
    toby:get_sprite():set_direction(2)
    wait(1000)
    dialog"haunted_house.cutscenes.lizardnapper.9"
    dialog"haunted_house.cutscenes.lizardnapper.10"
    dialog"haunted_house.cutscenes.lizardnapper.11"
    dialog"haunted_house.cutscenes.lizardnapper.12"
    dialog"haunted_house.cutscenes.lizardnapper.13"
    local m2 = sol.movement.create"path"
    m2:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6}
    m2:set_speed(65)
    m2:set_ignore_suspend(false)
    m2:start(toby)
    m = sol.movement.create"path"
    m:set_path{6,6,6,6,6,6,6,6,6,6,6,6,5,6,6,6,6,6,6,6,7,7,7,7,6,6,6,6}
    m:set_speed(85)
    movement(m, zach)
    wait(1500)
    dialog"haunted_house.cutscenes.lizardnapper.14"
    dialog"haunted_house.cutscenes.lizardnapper.15"
    dialog"haunted_house.cutscenes.lizardnapper.16"
    dialog"haunted_house.cutscenes.lizardnapper.17"
    dialog"haunted_house.cutscenes.lizardnapper.18"
    dialog"haunted_house.cutscenes.lizardnapper.19"
    dialog"haunted_house.cutscenes.lizardnapper.20"
    dialog"haunted_house.cutscenes.lizardnapper.21"
    m = sol.movement.create"path"
    m:set_speed(90)
    m:set_path{6}
    m:set_ignore_obstacles(true)
    movement(m, zach)
    wait(100)
    zach:get_sprite():set_animation("kick", function() zach:get_sprite():set_animation"stopped" end)
    sol.audio.play_sound"sword1"
    wait(600)
    dialog"haunted_house.cutscenes.lizardnapper.22"
    m = sol.movement.create("target")
    m:set_target(teleporter_library)
    m:set_speed(100)
    m:set_ignore_obstacles()
    m:start(zach, function() zach:remove() end)
    m2 = sol.movement.create("target")
    m2:set_target(teleporter_library)
    m2:set_speed(100)
    m2:set_ignore_obstacles()
    movement(m2, toby)
    toby:remove()
    wait(200)
    hero:set_direction(3)
    wait(300)
    dialog"haunted_house.cutscenes.lizardnapper.23"
    game:set_value("haunted_house_lizardnapper_scene", true)
    hero:unfreeze()
  end)
end
