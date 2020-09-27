local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local ghost_sprite
local movement

local LIFE = 1
local SPEED = 70
local DETECTION_DIST = 180

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed(), "main")
  
  enemy:set_life(LIFE)
  enemy:set_damage(1)
  enemy:set_attacking_collision_mode"overlapping"

  enemy.spawn_x, enemy.spawn_y, enemy.spawn_z = enemy:get_position()

  --Ghost undersprite
  ghost_sprite = enemy:create_sprite("enemies/"..enemy:get_breed(), "ghost_aura")
  enemy:bring_sprite_to_back(ghost_sprite)
  ghost_sprite:set_color_modulation{255,255,255}
  ghost_sprite:set_blend_mode"add"
  function sprite:on_frame_changed(animation, frame)
    frame = frame - 1
    if frame < 0 then frame = sprite:get_num_frames() - 1 end
    ghost_sprite:set_frame(frame)
  end

end

function enemy:on_restarted()
  enemy:check_to_move()
end

function enemy:check_to_move()
  if map:is_on_screen(enemy) and enemy:get_layer() == hero:get_layer()
  and enemy:get_distance(hero) <= DETECTION_DIST and enemy:is_in_same_region(hero) then
  --Chase hero
    enemy:chase_hero()
  else
    enemy:go_random()
  end

  sol.timer.start(enemy, 200, function()
    enemy:check_to_move()
  end)
end


function enemy:chase_hero()
  if enemy.chasing_hero then
    enemy:check_for_close_enemies()
  else
    enemy.chasing_hero = true
    local m = sol.movement.create"target"
    m:set_speed(SPEED)
    m:start(enemy)
  end

end

function enemy:go_random()
  if not enemy.chasing_hero then return end
  enemy.chasing_hero = false
  local m = sol.movement.create"random"
  m:start(enemy)
end


function enemy:check_for_close_enemies()
  local x, y, z = enemy:get_position()
  local are_close_enemies = false
  for e in map:get_entities_in_rectangle(x-4, y-4, 8, 8) do
    if e:get_type() == "enemy" and e:get_breed() == "spider_thing" and e ~= enemy then
      are_close_enemies = true
    end
  end
  if are_close_enemies then enemy:go_random() end
end






