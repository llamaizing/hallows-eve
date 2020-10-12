local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level(game:get_value("darkness_level"))
  
  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/pollen_1.png", mode = "blend", opacity = 0},
  	opacity_range = {0,40},
    drift = {15, 0, -1, 1}
  }
  --sol.menu.start(map, fog2)

  if game:get_value"seen_downtown_monster_attack" then
    dude_1:set_enabled(false)
    dude_2:set_enabled(false)
  else
    for e in map:get_entities_by_type"enemy" do
      e:set_enabled(false)
    end
  end

end)



function map:on_opening_transition_finished()
  if not game:get_value"seen_downtown_monster_attack" then
    map:dudes_run_scene()
  end
end


for sensor in map:get_entities"turn_back_sensor" do
  function sensor:on_activated()
    if not game:get_value("haunted_house_lizardnapper_scene") then
      game:start_dialog("downtown.too_early", function()
        hero:walk("66")
      end)
    end
  end
end


function map:dudes_run_scene()
  map:start_coroutine(function()
    local hero = map:get_hero()
    hero:freeze()
    for e in map:get_entities_by_type"enemy" do
      map:create_poof(e:get_position())
      e:set_enabled(true)
    end
    wait(500)
    dude_1:get_sprite():set_direction(3)
    dude_2:get_sprite():set_direction(3)
    wait(500)
    dialog("downtown.scared_guys")
    hero:unfreeze()
    game:set_value("seen_downtown_monster_attack", true)

    local m = sol.movement.create"target"
    m:set_target(scared_guys_run_target)
    m:set_speed(110)
    m:start(dude_1, function() dude_1:remove() end)
    local m2 = sol.movement.create"target"
    m2:set_target(scared_guys_run_target)
    m2:set_speed(110)
    m2:start(dude_2, function() dude_2:remove() end)

  end)
end