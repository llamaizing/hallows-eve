local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1000)
  --enemy:set_invincible(true)
  enemy:set_damage(1)
  enemy:set_size(32,32)
  enemy:set_origin(16,29)
  enemy:set_attacking_collision_mode"overlapping"
end

function enemy:on_restarted()
  movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(48)
  movement:start(enemy)
end

function enemy:on_movement_changed(movement)
  local angle = movement:get_angle()
  if angle > (math.pi / 2) and angle < (3 * math.pi / 2) then
    sprite:set_direction(2)
  else
    sprite:set_direction(0)
  end
end