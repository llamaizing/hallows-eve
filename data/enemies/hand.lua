local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local ghost_sprite
local movement

local SLAM_DISTANCE = 32
local SPEED = 130

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed(), "main")
  ghost_sprite = enemy:create_sprite("enemies/"..enemy:get_breed(), "ghost_aura")
  enemy:bring_sprite_to_back(ghost_sprite)
  ghost_sprite:set_color_modulation{255,255,255}
  ghost_sprite:set_blend_mode"add"
--[[
  function sprite:on_frame_changed(animation, frame)
    frame = frame - 1
    if frame <= 0 then frame = sprite:get_num_frames() - 1 end
    ghost_sprite:set_frame(frame)
  end
--]]
  
  enemy:set_life(1000)
  enemy:set_invincible(true)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_damage(2)
  enemy:set_size(32,16)
  enemy:set_origin(16,13)
  enemy:set_attacking_collision_mode"overlapping"

  enemy:set_obstacle_behavior"flying"
end

function enemy:on_restarted()
  movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(SPEED)
  movement:set_ignore_obstacles(true)
  movement:start(enemy)

  sol.timer.start(enemy, 6000, function()
    sol.timer.stop_all(enemy)
    enemy:stop_movement()
    sprite:set_animation("slam", function() enemy:remove() end)
  end)
end


function enemy:on_attacking_hero()
  if enemy.slamming then return end
  enemy.slamming = true
  enemy:stop_movement()
  sol.audio.play_sound"hero_seen"
  local x,y,z = hero:get_position()
  enemy:set_position(x,y+2,z)
  hero:freeze()
  hero:set_direction(0)
  sprite:set_animation("slam", function() enemy:remove() end)
  hero:set_animation("dying", function()
    hero:set_visible(false)
  end)
  sol.timer.start(hero, 1900, function()
    sol.audio.play_sound"world_warp"
    hero:teleport("respawn_map")
    sol.timer.start(hero, 200, function()
      hero:teleport("suburbs/neighborhood", "from_hand_grab")
      hero:set_visible(true)
      hero:set_animation("stopped")
    end)
    hero:unfreeze()
  end)
end


function enemy:on_movement_changed(movement)
  local angle = movement:get_angle()
  if angle > (math.pi / 2) and angle < (3 * math.pi / 2) then
    sprite:set_direction(2)
    ghost_sprite:set_direction(2)
  else
    sprite:set_direction(0)
    ghost_sprite:set_direction(0)
  end
end