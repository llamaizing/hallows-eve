local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local ghost_sprite
local movement

local SPEED = 65

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed(), "main")
  ghost_sprite = enemy:create_sprite("enemies/"..enemy:get_breed(), "ghost_aura")
  enemy:bring_sprite_to_back(ghost_sprite)
  ghost_sprite:set_color_modulation{255,255,255}
  ghost_sprite:set_blend_mode"add"
  function sprite:on_frame_changed(animation, frame)
    frame = frame + 1
    if frame >= sprite:get_num_frames() then frame = 0 end
    ghost_sprite:set_frame(frame)
  end
  
  enemy:set_life(1000)
  enemy:set_invincible(true)
  enemy:set_damage(1)
  enemy:set_size(32,32)
  enemy:set_origin(16,29)
  enemy:set_attacking_collision_mode"overlapping"
end

function enemy:on_restarted()
  movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(SPEED)
  movement:start(enemy)
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