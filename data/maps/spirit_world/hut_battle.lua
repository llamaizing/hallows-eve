local map = ...
local game = map:get_game()

local trans_surf = sol.surface.create()
trans_surf:set_opacity(0)
local boss_bar = require"scripts/hud/boss_bar"

map:register_event("on_started", function()

  map.light_fx:set_darkness_level({170,150,210})

  hero:set_visible(false)

  boss:set_detection_distance(600)

  trans_surf:fill_color{255,255,255}
  trans_surf:set_opacity(255)
end)

function map:on_opening_transition_finished()
  trans_surf:fade_out()
  map:create_poof(hero:get_position())
  hero:set_visible()
  if not game:get_value"witch_hut_scene_viewed" then
    sol.timer.start(map, 500, function()
      game:set_value("witch_hut_scene_viewed", true)
      game:start_dialog"spirit_world.witch_hut.7"
      hero:unfreeze()
    end)
  end

  sol.menu.start(game, boss_bar)
  boss_bar:set_enemy(boss)
end

function boss:on_dead()
  sol.menu.stop(boss_bar)
  map:start_coroutine(function()
    sol.audio.play_sound"monster_scream"
    sol.audio.play_sound"monster_scream_short"
    sol.audio.stop_music()
    hero:freeze()
    hero:set_direction(hero:get_direction4_to(ich_target))
    hero:set_animation"walking"
    local m = sol.movement.create"target"
    m:set_target(ich_target)
    m:set_speed(100)
    movement(m, hero)
    hero:set_animation"stopped"
    hero:set_direction(1)
    wait(600)
    acimonia:set_enabled(true)
    map:create_poof(acimonia:get_position())
    wait(1000)
    dialog"spirit_world.witch_hut.defeated_1"
    sol.audio.play_sound"enemy_killed_finale"
    acimonia:get_sprite():set_animation("blow_up", function() acimonia:set_enabled(false) end)
    wait(1200)
    maggie:set_enabled(true)
    map:create_poof(maggie:get_position())
    lizard:set_enabled(true)
    map:create_poof(lizard:get_position())
    wait(600)
    eye_rune:set_enabled(false)
    wait(600)
    dialog"spirit_world.witch_hut.defeated_2"
    dialog"spirit_world.witch_hut.defeated_3"
    dialog"spirit_world.witch_hut.defeated_4"
    dialog"spirit_world.witch_hut.defeated_5"

    zach:set_enabled(true)
    m = sol.movement.create"straight"
    m:set_max_distance(192)
    m:set_angle(math.pi / 2 * 3)
    m:set_speed(300)
    sol.audio.play_sound"jump"
    zach:get_sprite():set_animation"falling"
    movement(m, zach)
    zach:get_sprite():set_animation"crashed"
    sol.audio.play_sound"running_obstacle"
    wait(1500)
    hero:set_direction(3)
    wait(1000)
    zach:get_sprite():set_animation"stopped"
    zach:get_sprite():set_direction(2)
    wait(200)
    zach:get_sprite():set_direction(0)
    wait(200)
    zach:get_sprite():set_direction(2)
    wait(200)
    zach:get_sprite():set_direction(0)
    wait(200)
    zach:get_sprite():set_direction(1)
    wait(500)
    dialog"spirit_world.witch_hut.defeated_6"
    dialog"spirit_world.witch_hut.defeated_7"
    dialog"spirit_world.witch_hut.defeated_8"
    wait(400)
    dialog"spirit_world.witch_hut.defeated_9"
    wait(400)
    trans_surf:fill_color{0,0,0}
    trans_surf:set_opacity(255)
    sol.audio.play_music"funky-fresh-credits"
    wait(2000)
    hero:teleport"spirit_world/credits_apartment"
  end)
end

function map:on_draw(dst)
  trans_surf:draw(dst)
end