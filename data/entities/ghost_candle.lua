local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()

function entity:on_created()
  entity.shadow_sprite = entity:create_sprite"shadows/shadow_small"
  entity.main_sprite = entity:create_sprite"entities/ghost_candle"
  entity.main_sprite:set_animation"solid"
  entity.main_sprite:set_blend_mode"blend"
  entity.main_sprite:set_opacity(140)
  entity.add_sprite = entity:create_sprite"entities/ghost_candle"
  entity.add_sprite:set_animation"wavy"
  entity.add_sprite:set_blend_mode"blend"
  entity.add_sprite:set_opacity(80)


  entity:set_modified_ground("wall")
  entity:set_drawn_in_y_order(true)

  local x, y, z = entity:get_position()

  sol.timer.start(entity, 400, function()
    entity:set_visible(false)
    sol.timer.start(entity, 60, function() entity:set_visible(true) end)
    return math.random(100, 1000)
  end)

end

function entity:on_interaction()
  sol.audio.play_sound"warp"
  hero:freeze()
  hero:set_animation"glowing"
  sol.timer.start(entity, 1000, function()
    hero:unfreeze()
  end)
  game:set_life(game:get_max_life())
  game:set_magic(game:get_max_magic())
  game:set_starting_location(map:get_id(), "ghost_candle_destination")
  game:set_value("respawn_map", map:get_id())
  game:save()
end
