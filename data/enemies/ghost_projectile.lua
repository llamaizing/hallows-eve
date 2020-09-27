local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local SPEED = 130

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_invincible()
  enemy:set_damage(2)
end

function enemy:go(angle)
  local m = sol.movement.create"straight"
  m:set_angle(angle)
  m:set_speed(SPEED)
  m:set_smooth(false)
  m:start(enemy)
  function m:on_obstacle_reached()
    enemy:stop_movement()
    sprite:set_animation("pop", function() enemy:remove() end)
  end
end