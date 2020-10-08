local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level(game:get_value("darkness_level"))
  
  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/fog_2.png", mode = "blend", opacity = 60},
  	opacity_range = {40,100},
    drift = {15, 0, -1, 1}
  }
  sol.menu.start(map, fog2)
end)


function map:on_opening_transition_finished()
  if not game:get_value("cemetery_cutscene_viewed") then
    map:curse_cutscene()
  end
end


function warped_sensor:on_activated()
--[[
  game:set_life(game:get_max_life())
  game:set_magic(game:get_max_magic())
  game:set_value("respawn_map", map:get_id())
  game:set_starting_location(map:get_id(), "ghost_candle_destination")
  game:save()
--]]
end


--Curse Cutscene
function map:curse_cutscene()
  --disable all enemies
  for e in map:get_entities_by_type"enemy" do
    e:set_enabled(false)
  end

  local camera = map:get_camera()
  map:start_coroutine(function()
    hero:freeze()
    local m = sol.movement.create"path"
    m:set_path{6,6,6,6,6,6}
    m:set_speed(70)
    hero:set_animation"walking"
    movement(m, hero)
    hero:set_animation"stopped"
    dialog("cemetery.curse_scene.1")
    hero:set_direction(2)
    --Focus on obelisk
    m = sol.movement.create"straight"
    m:set_max_distance(352)
    m:set_speed(90)
    m:set_angle(math.pi)
    movement(m, camera)
    m = sol.movement.create"path"
    m:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    m:set_speed(70)
    m:start(zach)
    m2 = sol.movement.create"path"
    m2:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    m2:set_speed(70)
    movement(m2, lizard)
    dialog("cemetery.curse_scene.2")
    zach:get_sprite():set_direction(1)
    wait(200)
    zach:get_sprite():set_direction(3)
    wait(200)
    zach:get_sprite():set_direction(2)
    wait(200)
    dialog("cemetery.curse_scene.3")
    m = sol.movement.create"path"
    m:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    m:set_speed(70)
    movement(m, toby)
    dialog"cemetery.curse_scene.4"
    dialog"cemetery.curse_scene.5"
    dialog"cemetery.curse_scene.6"
    dialog"cemetery.curse_scene.7"
    m = sol.movement.create"path"
    m:set_path{2,2,0,0}
    movement(m, zach)
    witch_obelisk:get_sprite():set_animation("falling")
    sol.audio.play_music("malice-and-crickets")
    sol.audio.play_sound("thunder4_short")
    wait(100)
    sol.audio.play_sound("running_obstacle")
    wait(1000)
    dialog("cemetery.curse_scene.8")
    local x,y,z = acimonia:get_position()
    map:create_poof(x,y+2,z)
    acimonia:set_enabled(true)
    sol.audio.play_sound"thunder1"
    map.light_fx:set_darkness_level("dusk")
    zach:get_sprite():set_direction(1)
    toby:get_sprite():set_direction(1)
    wait(1500)
    dialog"cemetery.curse_scene.9"
    m = sol.movement.create"straight"
    m:set_angle(math.pi)
    m:set_speed(110)
    m:set_ignore_obstacles(true)
    m:set_ignore_suspend(true)
    m:start(lizard, function() lizard:set_enabled(false) end)
    wait(1000)
    dialog"cemetery.curse_scene.10"
    zach:get_sprite():set_direction(2)
    toby:get_sprite():set_direction(2)
    wait(700)
    dialog("cemetery.curse_scene.11")
    dialog("cemetery.curse_scene.12")
    m = sol.movement.create("path")
    m:set_path{5,5,5,5,5,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
    m:set_speed(100)
    m:start(zach)
    m2 = sol.movement.create"path"
    m2:set_path{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
    m2:set_speed(70)
    movement(m2, toby)
    toby:set_enabled(false)
    zach:set_enabled(false)
    m = sol.movement.create("path")
    m:set_path{6,6}
    movement(m, acimonia)
    dialog("cemetery.curse_scene.13")
    for e in map:get_entities_by_type("enemy") do
      local x, y, z = e:get_position()
      map:create_poof(x, y+2, z)
      e:set_enabled(true)
    end
    wait(1100)
    map:create_poof(acimonia:get_position())
    sol.audio.play_sound("thunder2")
    acimonia:set_enabled(false)
    sol.audio.play_music("fields")
    map.light_fx:set_darkness_level(game:get_value("darkness_level"))
    wait(1000)
    camera:start_tracking(hero)
    wait(500)
    dialog("cemetery.curse_scene.14")
    dialog("controls.kick")
    hero:unfreeze()
    game:set_value("cemetery_cutscene_viewed", true)
    
  end)
  --352

end