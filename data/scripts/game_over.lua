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
      cam_surface:set_color_modulation({rgb[1]-darkDelta,rgb[2]-darkDelta,rgb[3]-darkDelta})
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
    sol.timer.start(sol.main, 2000, function()
      game:start()
    end)
  end


end

return game_over