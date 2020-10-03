local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/map_settings/haunted_house_fx"):set_fx(map)

  if game:get_value"haunted_house_library_scene_viewed" then
    zach:remove()
    toby:remove()
  end

end)


function map:on_opening_transition_finished()
  map:kid_scene()
end


function statue_mechanism:on_interaction()
  if not game:has_item("library_statue_gear") then
    game:start_dialog("haunted_house.observations.3_library_statue_mechanism")
  else

  end
end



function map:kid_scene()
  if not game:get_value("haunted_house_library_scene_viewed") then
    game:set_value("haunted_house_library_scene_viewed", true)

    hero:freeze()

      map:start_coroutine(function()
        local camera = map:get_camera()
        local m = sol.movement.create("path")
        m:set_speed(80)
        m:set_path{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
        movement(m, camera)
        dialog("haunted_house.cutscenes.library_1")
        dialog("haunted_house.cutscenes.library_2")
        dialog("haunted_house.cutscenes.library_3")
        local m = sol.movement.create("path")
        m:set_speed(80)
        m:set_path{0,0,2,2,2,2}
        movement(m, zach)
        zach:set_enabled(false)
        m:set_path{4,4,2,2,2,2}
        movement(m, toby)
        toby:set_enabled(false)
        m:set_path{6,6,6}
        movement(m, camera)
        wait(800)
        statue_left_1:set_enabled(false) statue_left_2:set_enabled(false)
        statue_right_1:set_enabled(true) statue_right_2:set_enabled(true)
        sol.audio.play_sound"switch"
        sparkle:set_enabled(true)
        wait(1000)
        m:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6}
        movement(m, camera)
        wait(400)
        dialog("haunted_house.cutscenes.library_4")
        hero:unfreeze()
        camera:start_tracking(hero)
        return
      end)
  end
end