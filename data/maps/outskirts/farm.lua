local map = ...
local game = map:get_game()
local hero = map:get_hero()

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

  if game:get_value"lizard_flood_finished" then
    zach:set_enabled(false)
    toby:set_enabled(false)
    lizard_scene_sensor:set_enabled(false)
    for e in map:get_entities("barrier_pumpkin") do
      e:set_enabled(false)
    end
  end
end)



function lizard_scene_sensor:on_activated()
  if game:get_value("lizard_flood_finished") then return end
  map:start_coroutine(function()
    hero:freeze()
    local camera = map:get_camera()
    local m = sol.movement.create"path"
    m:set_path{4,4,4,4,4,4,4,4,4,4,4,4}
    m:set_speed(80)
    movement(m, camera)
    wait(500)
    dialog"farm.lizard_scene.1"
    dialog"farm.lizard_scene.2"
    dialog"farm.lizard_scene.3"
    dialog"farm.lizard_scene.4"
    dialog"farm.lizard_scene.5"
    wait(300)
    zach:get_sprite():set_animation"ring_bell"
    local ring_sound = true
    local bell_timer = sol.timer.start(map, 0, function()
      sol.audio.play_sound"bell"
      if ring_sound then return 200 end
    end)
    bell_timer:set_suspended_with_map(false)
    wait(3000)
    dialog"farm.lizard_scene.6"
    zach:get_sprite():set_animation("stopped")
    ring_sound = false
    dialog"farm.lizard_scene.7"
    wait(500)
    toby:get_sprite():set_direction(0)
    for e in map:get_entities("lizard_spawner") do
      local x,y,z = e:get_position()
      local liz = map:create_custom_entity{
        x=x, y=y, layer=z, width=16, height=16, direction=3,
        model="lizard", sprite="npcs/lizard"
      }
      liz:get_sprite():set_animation"walking"
      local lm = sol.movement.create"target"
      lm:set_target(lizard_target)
      lm:set_ignore_obstacles(true)
      lm:set_speed(80)
      lm:start(liz)
    end
    wait(2600)
    dialog"farm.lizard_scene.8"
    for e in map:get_entities("lizard_spawner") do
      local x,y,z = e:get_position()
      local liz = map:create_custom_entity{
        x=x, y=y, layer=z, width=16, height=16, direction=3,
        model="lizard", sprite="npcs/lizard"
      }
      liz:get_sprite():set_animation"walking"
      local lm = sol.movement.create"target"
      lm:set_target(lizard_target)
      lm:set_ignore_obstacles(true)
      lm:set_speed(80)
      lm:start(liz)
    end
    wait(300)
    m = sol.movement.create"path"
    m:set_path{0,0,0,0,0,0,0,0,0,0,0,0}
    m:set_speed(100)
    movement(m, camera)
    big_lizard:set_enabled(true)
    sol.audio.play_sound"monster_scream"
    sol.audio.play_music"haunted_house_monster_chase"
    for e in map:get_entities_by_type("destructible") do
      if e:get_name() == nil then
        e:get_sprite():set_animation("destroy", function() e:remove() end)
      end
    end
    wait(400)
    dialog"farm.lizard_scene.9"
    dialog"farm.lizard_scene.10"
    m = sol.movement.create"straight"
    m:set_angle(math.pi)
    m:set_speed(120)
    m:start(zach, function() zach:remove() end)
    function m:on_obstacle_reached() zach:remove() end
    local m2 = sol.movement.create"straight"
    m2:set_angle(math.pi)
    m2:set_speed(120)
    m2:start(toby, function() toby:remove() end)
    function m2:on_obstacle_reached() toby:remove() end
    wait(200)
    camera:start_tracking(hero)
    hero:unfreeze()
    game.lizard_flood_started = true
    map:start_spawning_lizards()
  end)
end

function map:start_spawning_lizards()
  for emitter in map:get_entities("lizard_emitter") do
    local x,y,z = emitter:get_position()
    sol.timer.start(map, 400, function()
      local x,y,z = emitter:get_position()
      local liz = map:create_custom_entity{
        x=x, y=y + math.random(-64,32), layer=z,
        width=16, height=16, direction=3,
        model="lizard", sprite="npcs/lizard"
      }
      liz:get_sprite():set_animation"walking"
      liz:get_sprite():set_direction(liz:get_direction4_to(lizard_target))
      local lm = sol.movement.create"target"
      lm:set_ignore_obstacles(true)
      lm:set_target(lizard_target)
      lm:set_speed(90)
      lm:start(liz, function() liz:remove() end)
      return true
    end)
  end
end
