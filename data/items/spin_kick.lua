local item = ...
local game = item:get_game()
local MAGIC_COST = 8

function item:on_started()
  item:set_savegame_variable("possession_spin_kick")
  item:set_assignable(true)
end

function item:on_using()
  local enough_magic = game:get_magic() - MAGIC_COST >= 0
  if not enough_magic then
    sol.audio.play_sound"wrong"
    item:set_finished()
    return
  end
  game:remove_magic(MAGIC_COST)

  local map = item:get_map()
  local hero = map:get_hero()
  local slot_assigned = (game:get_item_assigned(1) == item and 1) or 2
  local state = item:get_spin_state()

  hero:start_state(state)
  sol.audio.play_sound"spin_kick"
  hero:set_animation("spin_attack", function() hero:set_animation"stopped" end)
  local x,y,z = hero:get_position()
  local dir = hero:get_direction()
  local attack = map:create_custom_entity{
    x=x, y=y, layer=z,direction=dir,width=16,height=16,sprite="hero/sword1"
  }
  attack:get_sprite():set_animation("spin_attack", function()
    attack:remove()
    hero:unfreeze()
    item:set_finished()
  end)

  attack:add_collision_test("sprite", function(attack, other)
    if other:get_type() == "enemy" then
      other:hurt(1)
    end
  end)

end


function item:get_spin_state()
  local state = sol.state.create()
  state:set_visible(true)
  state:set_can_control_direction(false)
  state:set_can_control_movement(false)
  state:set_gravity_enabled(false)
  state:set_can_come_from_bad_ground(true)
  state:set_can_be_hurt(false)
  state:set_can_use_sword(false)
  state:set_can_use_shield(false)
  state:set_can_use_item(false)
  state:set_can_interact(false)
  state:set_can_grab(false)
  state:set_can_push(false)
  state:set_can_pick_treasure(true)
  state:set_can_use_teletransporter(false)
  state:set_can_use_switch(true)
  state:set_can_use_stream(true)
  state:set_can_use_stairs(false)
  state:set_can_use_jumper(false)
  state:set_carried_object_action("throw")

  return state
end