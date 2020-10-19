local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level(game:get_value("darkness_level"))
  map.light_fx:set_darkness_level"dusk"

  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/pollen_1.png", mode = "blend", opacity = 0},
  	opacity_range = {0,40},
    drift = {15, 0, -1, 1}
  }
  --sol.menu.start(map, fog2)


end)


function cutscene_sensor:on_activated()
  if not game:get_value("lizard_eaten") then
    map:start_coroutine(function()
      local camera = map:get_camera()
      hero:freeze()
      local x,y,z = hero:get_position()
      local tracking_ent = map:create_custom_entity{x=x, y=y, layer=z, width=16, height=16, direction=0}
      camera:start_tracking(tracking_ent)
      local m = sol.movement.create"straight"
      m:set_angle(hero:get_angle(zach))
      m:set_max_distance(hero:get_distance(zach))
      m:set_speed(80)
      movement(m, tracking_ent)
      wait(800)
      dialog"dennys.1"
      dialog"dennys.2"
      dialog"dennys.3"
      dialog"dennys.4"
      zach:get_sprite():set_animation"ring_bell"
      local ring_sound = true
      local bell_timer = sol.timer.start(map, 0, function()
        sol.audio.play_sound"bell"
        if ring_sound then return 200 end
      end)
      wait(1000)
      ring_sound = false
      zach:get_sprite():set_animation"stopped"
      wait(2000)
      dialog"dennys.5"
      dialog"dennys.6"
      dialog"dennys.7"
      sol.audio.play_sound"monster_scream"
      ghost_dragon:set_enabled(true)
      m = sol.movement.create"straight"
      m:set_angle(math.pi)
      m:set_speed(160)
      m:set_max_distance(480)
      m:set_ignore_obstacles(true)
      sol.timer.start(map, 1170, function()
        lizard:set_enabled(false)
        maggie:set_enabled(false)
      end)
      movement(m, ghost_dragon)
      ghost_dragon:set_enabled(false)
      zach:get_sprite():set_direction(2)
      dialog"dennys.8"
      dialog"dennys.9"
      dialog"dennys.10"
      m = sol.movement.create"target"
      m:set_target(ich_target)
      m:set_speed(80)
      hero:set_animation"walking"
      movement(m, hero)
      hero:set_animation"stopped"
      wait(200)
      dialog"dennys.11"
      toby:get_sprite():set_direction(3)
      zach:get_sprite():set_direction(3)
      dialog"dennys.12"
      dialog"dennys.13"
      dialog"dennys.14"
      dialog"dennys.15"
      dialog"dennys.16"
      dialog"dennys.17"
      dialog"dennys.18"
      dialog"dennys.19"
      dialog"dennys.20"
      dialog"dennys.21"
      m = sol.movement.create"target"
      m:set_target(kid_leave_target)
      m:set_speed(90)
      m:start(zach)
      local m2 = sol.movement.create"target"
      m2:set_target(kid_leave_target)
      m2:set_speed(80)
      movement(m2, toby)
      toby:set_enabled(false)
      zach:set_enabled(false)
      camera:start_tracking(hero)
      map:focus_on(from_creepytown, function() game:start_dialog"dennys.22" end)
      game:set_value("current_objective", nil)
      game:set_value("lizard_eaten", true)
      hero:unfreeze()
    end)
  end
end