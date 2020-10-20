local item = ...
local game = item:get_game()

local MAGIC_COST = 8

function item:on_started()
  item:set_savegame_variable("possession_seed_shoot")
  item:set_assignable(true)
end

function item:on_using(props)
  local projectile_type = (props and props.ball_type) or nil
  local map = item:get_map()
  local hero = map:get_hero()
  local slot_assigned = (props and props.slot_assigned) or (game:get_item_assigned(1) == item and 1 or 2)

  local enough_magic = game:get_magic() - MAGIC_COST >= 0
  if not enough_magic then
    sol.audio.play_sound"wrong"
    item:set_finished()
    return
  end
  game:remove_magic(MAGIC_COST)

  hero:set_animation("shoot_seed", function()
    item:set_finished()
  end)

  sol.timer.start(item, 150, function()
    --create projectile
    local dir4 = hero:get_direction()
    local x, y, z = hero:get_position()
    local projectile = map:create_custom_entity{
      x = x + game:dx(8)[dir4],
      y = y + game:dy(8)[dir4] - 8,
      layer = z,
      width = 8, height = 8,
      direction = dir4,
      model = "shoot_seed",
    }
    projectile:fire(dir4 * math.pi / 2)
  end)

end
