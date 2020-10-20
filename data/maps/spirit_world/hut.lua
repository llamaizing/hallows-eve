local map = ...
local game = map:get_game()

map:register_event("on_started", function()

  map.light_fx:set_darkness_level({170,150,210})

end)

function maggie:on_interaction()
  if game:get_value"witch_hut_scene_viewed" then
    map:it_a_trap()
  else
    map:start_coroutine(function()
      hero:freeze()
      dialog"spirit_world.witch_hut.1"
      dialog"spirit_world.witch_hut.2"
      dialog"spirit_world.witch_hut.3"
      dialog"spirit_world.witch_hut.4"
      wait(200)
      sol.audio.play_sound"sword1"
      hero:set_animation("kick", function()
        hero:set_animation"stopped"
      end)
      wait(1000)
      dialog"spirit_world.witch_hut.5"
      wait(200)
      map:it_a_trap()
    end)
  end
end

function map:it_a_trap()
  map:start_coroutine(function()
    hero:freeze()
    map:create_poof(acimonia:get_position())
    acimonia:set_enabled(true)
    wait(800)
    dialog"spirit_world.witch_hut.6"
    wait(300)
    hero:teleport("spirit_world/hut_battle", "destination", "immediate")
  end)
end