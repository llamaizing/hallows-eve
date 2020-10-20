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


  --Lizard situation:
  if game.lizard_flood_started and not game:get_value("lizard_flood_finished") then
    map:start_spawning_lizards()
    game:set_value("darkness_level", "sunset")
  end


  --Roll Log
  roll_log:set_traversable_by("hero", true)
  roll_log:set_modified_ground"traversable"
  roll_log:add_collision_test("sprite", function(roll_log, other_entity)
    if other_entity:get_type() == "hero" and other_entity:get_state() == "sword swinging" and hero:get_direction() == 0 then
      roll_log:clear_collision_tests()
      roll_log:get_sprite():set_animation"rolling"
      sol.audio.play_sound"dash_big"
      local m2 = sol.movement.create("straight")
      m2:set_max_distance(64)
      m2:set_ignore_obstacles(true)
      m2:start(log_shadow)
      local m = sol.movement.create("straight")
      m:set_max_distance(64)
      m:set_ignore_obstacles(true)
      m:start(roll_log, function()
        sol.audio.play_sound"running_obstacle"
        roll_log:get_sprite():set_animation"stopped"
        game:set_value("haunted_forest_log_rolled", true)
      end)
    end
  end)

  if game:get_value"haunted_forest_log_rolled" then
    roll_log:clear_collision_tests()
    local x,y,z = roll_log:get_position()
    roll_log:set_position(x + 64, y, z)
    local x,y,z = log_shadow:get_position()
    log_shadow:set_position(x + 64, y, z)
  end

end)



function see_tree_sensor:on_activated()
  if not game:get_value"haunted_forest_seen_tree_explanation" then
    game:start_dialog"farm.forest_tree_kick"
    game:set_value("haunted_forest_seen_tree_explanation", true)
    see_tree_sensor:remove()
  end
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
      lm:set_speed(80)
      lm:start(liz, function() liz:remove() end)
      return true
    end)
  end
end
