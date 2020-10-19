local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level({230,200,230})
  
  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/dust_1.png", mode = "blend", opacity = 60},
  	opacity_range = {40,100},
    drift = {10, 0, -1, 1}
  }
  --sol.menu.start(map, fog2)

  if not game:get_value("intro_cutscene_viewed") then
    game:get_hud():set_enabled(false)
    door:set_enabled(true)
  else
    map:ralph_looks_at_ich()
  end
end)


function map:on_opening_transition_finished()
  if not game:get_value("intro_cutscene_viewed") then
    map:intro_cutscene()
  end
end

function map:ralph_looks_at_ich()
  sol.timer.start(map, 100, function()
    local x,y,z = hero:get_position()
    if y < 120 then
      ralph:get_sprite():set_animation("looking_up")
    else
      ralph:get_sprite():set_animation("stopped")
    end
    return true
  end)
end


for e in map:get_entities("ralph") do
function e:on_interaction()
  game:start_dialog("spirit_world.apartment.ralph_beginning")
end
end




function map:intro_cutscene()
  local ralph_sprite = ralph:get_sprite()
  map:start_coroutine(function()
    hero:freeze()
    wait(2000)
    hero:set_animation("kick", function() hero:set_animation"stopped" end)
    wait(100)
    sol.audio.play_sound"ball_kick_harder"
    door:set_enabled(false)
    wait(1000)
    local m = sol.movement.create"path"
    m:set_path{6,6,6,6}
    hero:set_animation"walking"
    movement(m, hero)
    hero:set_animation"stopped"
    dialog"spirit_world.intro_scene.1"
    wait(400)
    ralph_sprite:set_animation"looking_up"
    wait(600)
    dialog"spirit_world.intro_scene.2"
    dialog"spirit_world.intro_scene.3"
    dialog"spirit_world.intro_scene.4"
    dialog"spirit_world.intro_scene.5"
    ralph_sprite:set_animation"stopped"
    hero:unfreeze()
    game:get_hud():set_enabled(true)
    game:set_value("intro_cutscene_viewed", true)
  end)
end
