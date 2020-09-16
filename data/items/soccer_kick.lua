local item = ...
local game = item:get_game()

local SPEED_DELTA = 40

function item:on_started()
  item:set_savegame_variable("possession_soccer_kick")
  item:set_assignable(true)
end

function item:on_using(props)
  local arrow_type = (props and props.ball_type) or nil
  local map = item:get_map()
  local hero = map:get_hero()
  local slot_assigned = (props and props.slot_assigned) or (game:get_item_assigned(1) == item and 1 or 2)

  hero:set_animation"dribbling"
  local state = item:get_dribbling_state()
  hero:start_state(state)

  --Bounce sound effect
  sol.timer.start(hero, 0, function()
    if hero:get_state_object() == state then
      sol.audio.play_sound"ball_kick"
      return 360
    end
  end)

  --create ball
  local dir4 = hero:get_direction()
  local x, y, z = hero:get_position()
  local ball = map:create_custom_entity{
    x = x + game:dx(8)[dir4],
    y = y + game:dy(8)[dir4] - 2,
    layer = z,
    width = 16, height = 16,
    direction = dir4,
    model = "soccer_ball",
  }

  function state:on_position_changed(x,y,z)
    ball:set_position(x + game:dx(8)[dir4], y + game:dy(8)[dir4] - 2, z)
  end

  sol.timer.start(hero,10,function()
    if game:is_command_pressed("item_" .. slot_assigned) then
      return true
    else
      if ball_type then ball:apply_type(ball_type) end
      ball:fire(dir4)
      sol.audio.play_sound"ball_kick_harder"
      hero:set_animation("kick", function()
        hero:unfreeze()
        item:set_finished()
      end)
      hero:get_sprite():set_frame(3)
    end
  end)
end


function item:get_dribbling_state()
  local state = sol.state.create()
  state:set_visible(true)
  state:set_can_control_direction(false)
  state:set_can_control_movement(true)
  state:set_gravity_enabled(true)
  state:set_can_come_from_bad_ground(true)
  state:set_can_be_hurt(true)
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

--[[
  function state:on_command_pressed(cmd)
    local handled = false
    if cmd == "right" then
      hero:set_direction(0)
      handled = true
    elseif cmd == "up" then
      hero:set_direction(1)
      handled = true
    elseif cmd == "left" then
      hero:set_direction(2)
      handled = true
    elseif cmd == "down" then
      hero:set_direction(3)
      handled = true


    return handled
  end
--]]
  return state
end



