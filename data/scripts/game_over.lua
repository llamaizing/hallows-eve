local game_over = {}

function game_over:init(game)

  function game:on_game_over_started()
    local map = game:get_map()
    local hero = map:get_hero()
    local x, y, z = hero:get_position()

    --Clear defeated enemies table so all will respawn
    require("scripts/misc/enemy_respawn_manager"):clear_killed_enemies()

    hero:set_visible(false)

    local cam_surface = map:get_camera():get_surface()
    local dark_steps = 1
    local darkDelta = 5
    sol.timer.start(sol.main, 40, function()
      local rgb = cam_surface:get_color_modulation()
      cam_surface:set_color_modulation({math.max(rgb[1]-darkDelta, 0), math.max(rgb[2]-darkDelta, 0), math.max(rgb[3]-darkDelta, 0)})
      dark_steps = dark_steps + 1
      if dark_steps <= 20 then
        return true
      end
    end)

    local dummy = map:create_custom_entity({
      x=x, y=y, layer=z, direction=0, width=16,height=16,
      sprite = "hero/tunic1"
    })
    local sprite = dummy:get_sprite()
    sprite:set_ignore_suspend()
    sprite:set_animation("dying", function()
      sprite:set_animation"dead"
      game_over:step2()
    end)
  end


  function game_over:step2()
    local hero = game:get_hero()
    game:set_value("times_died", (game:get_value"times_died" or 0) + 1)
    game:save()
    sol.timer.start(sol.main, 1500, function()
      --send the player to a different map to ensure the one they died on resets
      hero:teleport("respawn_map", "destination")
      sol.timer.start(sol.main, 1000, function()
        game:set_life(game:get_max_life())
        game:set_magic(game:get_max_magic())
        hero:teleport(game:get_value"respawn_map", "ghost_candle_destination", "immediate")
        hero:set_visible()
        game:stop_game_over()
        hero:set_blinking(true, 500)
      end)
    end)
  end


end

return game_over