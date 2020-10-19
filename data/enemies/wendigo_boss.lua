local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local ghost_sprite
local movement


local DETECTION_DISTANCE = 120
local MELEE_RANGE = 600
local CHASE_SPEED = 70
local WANDER_SPEED = 40
local WIND_UP_TIME = 500
local COOLDOWN = 1500

local SPEED = 65

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed(), "main")
  ghost_sprite = enemy:create_sprite("enemies/"..enemy:get_breed(), "ghost_aura")
  enemy:bring_sprite_to_back(ghost_sprite)
  ghost_sprite:set_color_modulation{255,255,255}
  ghost_sprite:set_blend_mode"add"
  function sprite:on_frame_changed(animation, frame)
    frame = frame - 1
    if frame < 0 then frame = sprite:get_num_frames() - 1 end
    ghost_sprite:set_frame(frame)
  end
  
  enemy:set_life(20)
  enemy:set_push_hero_on_sword(true)
  enemy:set_damage(2)
  enemy:set_size(32,32)
  enemy:set_origin(16,29)
  enemy:set_attacking_collision_mode"overlapping"

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


function enemy:on_restarted()
	enemy.attacking = false
	enemy:choose_state()
end


function enemy:choose_state()
	if enemy:is_close_to_hero() then
		if enemy:get_distance(hero) <= MELEE_RANGE and not enemy.attacking then
			enemy:choose_attack()
		elseif not enemy.attacking then
			enemy:go_hero()
		end
	else
		enemy:go_random()
	end

	sol.timer.start(enemy, 200, function() enemy:choose_state() end)
end

function enemy:is_close_to_hero()
  local dist = enemy:get_distance(hero)

  return enemy:is_in_same_region(hero)
  and enemy:get_layer() == hero:get_layer()
  and dist <= DETECTION_DISTANCE
end


function enemy:go_hero()
	enemy.going_hero = true
	local m = sol.movement.create"target"
	m:set_speed(CHASE_SPEED)
	m:start(enemy)
end

function enemy:go_random()
	enemy.going_hero = false
	local rand = math.random(1, 100)
	if rand > 50 then
	elseif rand > 10 then
		local m = sol.movement.create"random"
		m:set_speed(WANDER_SPEED)
		m:start(enemy)
	else
		enemy:stop_movement()
	end
end


function enemy:choose_attack()
  local rand = math.random(1,3)
  if rand == 1 then enemy:shoot()
  elseif rand == 2 then enemy:roar()
  elseif rand == 3 then enemy:attack()
  end
end


function enemy:attack()
	enemy.attacking = true
	enemy:stop_movement()
  local attack_angle = enemy:get_angle(hero)
	sprite:set_animation("wind_up")
	sol.timer.start(enemy, WIND_UP_TIME, function()
    --animation
		sprite:set_animation("attack", function()
			sprite:set_animation"walking"
			enemy:go_hero()
		end)
    --attack sprite
		local attack_sprite = enemy:create_sprite("enemies/misc/slash")
		sol.audio.play_sound"swipe_1"
		enemy:set_invincible_sprite(attack_sprite)
		attack_sprite:set_direction(sprite:get_direction())
		sol.timer.start(enemy, 1000, function()
			enemy:remove_sprite(attack_sprite)
			enemy.attacking = false
		end)
    --movement
    local m = sol.movement.create"straight"
    m:set_max_distance(24)
    m:set_speed(100)
    m:set_angle(attack_angle)
    m:start(enemy)
	end)
end


function enemy:shoot()
  enemy.attacking = true
  enemy:stop_movement()
  sprite:set_animation"shoot"
	sol.audio.play_sound"cane3"
	sol.timer.start(enemy, WIND_UP_TIME, function()
		sol.audio.play_sound"frost2"
		local x,y,z = enemy:get_position()
		local projectile = map:create_enemy{
			x=x, y=y-16, layer=z, direction = 0,
			breed = "ghost_projectile",
		}
		projectile:go(projectile:get_angle(hero))
		sol.timer.start(enemy, COOLDOWN, function()
      enemy:restart()
      enemy.attacking = false
    end)
  	sprite:set_animation"walking"
  	enemy:go_hero()
	end)
end


function enemy:roar()
  local num_projectiles = 8
  enemy.attacking = true
  enemy:stop_movement()
  sprite:set_animation"roar"
  sol.audio.play_sound"monster_scream_short"
  sol.timer.start(enemy, WIND_UP_TIME, function()

		local x,y,z = enemy:get_position()
    for i=1, num_projectiles do
  		local projectile = map:create_enemy{
  			x=x, y=y-16, layer=z, direction = 0,
  			breed = "ghost_projectile",
  		}
  		projectile:go(math.pi*2 / num_projectiles * i)
    end

		sol.timer.start(enemy, COOLDOWN, function()
      enemy:restart()
      enemy.attacking = false
    end)
  	sprite:set_animation"walking"
  	enemy:go_hero()
  end)
end