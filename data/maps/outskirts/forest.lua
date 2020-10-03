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


  --Roll Log
  roll_log:set_traversable_by("hero", true)
  roll_log:set_modified_ground"traversable"
  roll_log:add_collision_test("sprite", function(roll_log, other_entity)
print("collide. Other type: ", other_entity:get_type())
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


