local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local flying = false
local THRESHOLD = 50

-- Event called when the enemy is initialized.
function enemy:on_created()
  if enemy:get_property("type") then
    sprite = enemy:create_sprite("enemies/misc/" .. enemy:get_property("type"))
  else
    sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  end
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_invincible()
end

function enemy:on_restarted()
  sprite:set_animation"standing"
  sprite:set_direction(math.random(0,3))
  enemy:check_hero()
  if not flying then
    sol.timer.start(enemy, math.random(200, 2000), function() enemy:choose_animation() end)
  end
  sol.timer.start(enemy, math.random(2000, 4000), function()
    if not flying then
      sprite:set_direction(math.random(0, 3))
      return true
    end
  end)
end

function enemy:check_hero()
  if enemy:is_in_same_region(hero) and enemy:get_distance(hero) <= THRESHOLD then
    enemy:fly_away()
  else
    sol.timer.start(enemy, 100, function()
      if not flying then return enemy:check_hero() end
    end)
  end
end

function enemy:fly_away()
  flying = true
  sprite:set_animation"flying"
  sol.audio.play_sound"bird_flying_away"
  local angle = hero:get_angle(enemy)
  if angle > math.pi /2 and angle < 3 * math.pi / 2 then --hero is right of bird
    angle = 2.5
  else --hero is left of bird
    angle = .5
  end
  local m = sol.movement.create("straight")
  m:set_angle(angle)
  m:set_speed(160)
  m:set_ignore_obstacles()
  m:set_max_distance(400)
  enemy:set_layer(map:get_max_layer())
  m:start(enemy, function() enemy:remove() end)
  sprite:set_direction(m:get_direction4())
end

function enemy:choose_animation()
  --animations: standing (default), bobbing, hopping, pecking
  local animations = {"bobbing", "hopping", "pecking"}  
  local rand = math.random(1, #animations)
  sprite:set_animation(animations[rand], function()
    sprite:set_animation"standing"
    sol.timer.start(enemy, math.random(700, 2400), function()
      if not flying then enemy:choose_animation() end
    end)
  end)
end
