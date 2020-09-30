local item = ...
local game = item:get_game()


local SPEED_DELTA = 40
local MAGIC_COST = 13

function item:on_started()
  item:set_savegame_variable("possession_soccer_kick")
  item:set_assignable(true)
end

function item:on_using(props)
  local ball_type = (props and props.ball_type) or nil
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

  hero:set_animation"dribbling"
  local state = item:get_dribbling_state()
  hero:start_state(state)

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
    item:update_ball_dribble_position(ball)
  end

  --Direction changes
  function state:on_command_pressed(cmd)
    local hero = game:get_hero()
    local handled = false
    if cmd == "right" then
      hero:set_direction(0)
      item:update_ball_dribble_position(ball)
      handled = true
    elseif cmd == "up" then
      hero:set_direction(1)
      item:update_ball_dribble_position(ball)
      handled = true
    elseif cmd == "left" then
      hero:set_direction(2)
      item:update_ball_dribble_position(ball)
      handled = true
    elseif cmd == "down" then
      hero:set_direction(3)
      item:update_ball_dribble_position(ball)
      handled = true
    end
    return handled
  end

    --Avoid analog stick wildly jumping
    local joy_avoid_repeat = {-2, -2}
    function state:on_joypad_axis_moved(axis, state)
      local handled = joy_avoid_repeat[0] == sol.input.get_joypad_axis_state(0)   
        and joy_avoid_repeat[0] == sol.input.get_joypad_axis_state(1)
      joy_avoid_repeat[0] = sol.input.get_joypad_axis_state(0)   
      joy_avoid_repeat[0] = sol.input.get_joypad_axis_state(1)
      return handled
    end

  --Bounce sound effect and bounces counter
  local dribbles = 0
  sol.timer.start(hero, 0, function()
    if hero:get_state_object() == state then
      dribbles = dribbles + 1
      sol.audio.play_sound"ball_kick"

      --
      if dribbles == 3 then
        local flame_sprite = ball:create_sprite"entities/soccer_ball_flame"
        ball:bring_sprite_to_back(flame_sprite)
        sol.audio.play_sound"fuse"
        ball_type = "bomb"
      end --]]

      return 360
    end
  end)



  --Kick!
  sol.timer.start(hero,10,function()
    if game:is_command_pressed("item_" .. slot_assigned) then
      return true
    else
      if ball_type then ball:apply_type(ball_type) end

      local angle = sol.input.get_left_stick_direction8()
      if not angle then angle = hero:get_direction() * math.pi/2
      else angle = angle * math.pi / 4 end

      ball:fire(angle)
      sol.audio.play_sound"ball_kick_harder"
      hero:set_animation("kick", function()
        hero:unfreeze()
        item:set_finished()
      end)
      hero:get_sprite():set_frame(3)
    end
  end)
end


function item:update_ball_dribble_position(ball)
  local hero = game:get_hero()
  local dir4 = hero:get_direction()
  local x,y,z = hero:get_position()
  ball:set_position(x + game:dx(8)[dir4], y + game:dy(8)[dir4] - 2, z)
end


function item:get_dribbling_state()
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
  state:set_can_pick_treasure(true)
  state:set_can_use_teletransporter(false)
  state:set_can_use_switch(true)
  state:set_can_use_stream(true)
  state:set_can_use_stairs(false)
  state:set_can_use_jumper(false)
  state:set_carried_object_action("keep")

  return state
end



