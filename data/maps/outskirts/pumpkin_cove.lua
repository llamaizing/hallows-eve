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

end)

function map:on_opening_transition_finished()
  if game:has_item"pumpkin_jordans" and not game:get_value"farm_seen_lizard_cross_holes" then
    game:set_value("farm_seen_lizard_cross_holes", true)
    lizard:set_enabled(true)
    local m = sol.movement.create"straight"
    m:set_ignore_obstacles(true)
    m:set_speed(120)
    m:set_angle(0)
    m:set_max_distance(400)
    m:set_ignore_suspend(true)
    m:start(lizard, function()
      lizard:remove()
    end)
    --map:focus_on(lizard, function() end)
  end
end