local item = ...
local game = item:get_game()

local MAGIC_COST = 13
local HEAL_TIME = 1100

function item:on_started()
  item:set_savegame_variable("possession_heal")
  item:set_assignable(true)
end

function item:on_using()
  local hero = game:get_hero()
  local slot_assigned = (props and props.slot_assigned) or (game:get_item_assigned(1) == item and 1 or 2)
  local state = item:get_heal_state()

  local enough_magic = game:get_magic() - MAGIC_COST >= 0
  if not enough_magic or game:get_life() == game:get_max_life() then
    sol.audio.play_sound"wrong"
    hero:unfreeze()
    item:set_finished()
    return
  end

  hero:set_animation"healing"
  hero:start_state(state)
  item.heal_timer = sol.timer.start(state, HEAL_TIME, function()
    game:remove_magic(MAGIC_COST)
    game:add_life(2)
    hero:set_animation("flash", function() hero:set_animation"healing" end)
    sol.audio.play_sound"charge_leaf"
    if game:get_life() < game:get_max_life() and game:get_magic() >= MAGIC_COST then
      return true
    else
      sol.timer.start(hero, 30, function()
        hero:unfreeze()
        item:set_finished()
      end)
    end
  end)

  --End if button released
  sol.timer.start(hero,10,function()
    if game:is_command_pressed("item_" .. slot_assigned) then
      return true
    else
      hero:unfreeze()
      item:set_finished()
    end
  end)

  --Create leaf visual effect
  sol.timer.start(hero, 200, function()
    if hero:get_state_object() == state then
      sol.audio.play_sound"leaf_rattle"
      local leaf_sprite = hero:create_sprite("entities/leaf_blowing")
      local m = sol.movement.create("random")
      m:start(leaf_sprite)
      leaf_sprite:set_animation("fade_out", function()
        hero:remove_sprite(leaf_sprite)
      end)
      return true
    end
  end)

end



function item:get_heal_state()
  local state = sol.state.create()
  state:set_visible(true)
  state:set_can_control_direction(false)
  state:set_can_control_movement(false)
  state:set_gravity_enabled(true)
  state:set_can_come_from_bad_ground(true)
  state:set_can_be_hurt(true)
  state:set_can_use_sword(false)
  state:set_can_use_shield(false)
  state:set_can_use_item(false)
  state:set_can_interact(false)
  state:set_can_grab(false)
  state:set_can_push(false)
  state:set_can_pick_treasure(false)
  state:set_can_use_teletransporter(false)
  state:set_can_use_switch(true)
  state:set_can_use_stream(true)
  state:set_can_use_stairs(false)
  state:set_can_use_jumper(false)
  state:set_carried_object_action("throw")
  return state
end