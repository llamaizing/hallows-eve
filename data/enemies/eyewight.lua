 local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local ghost_sprite
local movement

local DETECTION_DISTANCE = 120
local SHOOTING_RANGE = 100
local CHASE_SPEED = 70
local WANDER_SPEED = 40
local WIND_UP_TIME = 700
local COOLDOWN = 2000


function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed(), "main")
  --set proper windup time
  WIND_UP_TIME = sprite:get_num_frames("charging", 0) * sprite:get_frame_delay("charging")
  enemy:set_life(2)
  enemy:set_damage(3)

  ghost_sprite = enemy:create_sprite("enemies/"..enemy:get_breed(), "ghost_aura")
  enemy:bring_sprite_to_back(ghost_sprite)
  ghost_sprite:set_color_modulation{255,255,255}
  ghost_sprite:set_blend_mode"add"
  shadow_sprite = enemy:create_sprite("shadows/shadow_medium", "shadow")
  -- function sprite:on_frame_changed(animation, frame)
  --   frame = frame - 1
  --   if frame < 0 then frame = sprite:get_num_frames() - 1 end
  --   ghost_sprite:set_frame(frame)
  -- end
end

function enemy:on_restarted()
	enemy.attacking = false
	enemy:choose_state()
end

function enemy:on_movement_changed()
	sprite:set_direction(enemy:get_movement():get_direction4())
	ghost_sprite:set_direction(enemy:get_movement():get_direction4())
end

function enemy:choose_state()
	if enemy:is_close_to_hero() then
		if enemy:get_distance(hero) <= SHOOTING_RANGE and not enemy.attacking then
			enemy:attack()
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

function enemy:attack()
	--stuff
	enemy.attacking = true
	enemy:stop_movement()
	sprite:set_animation("charging", "walking")
	sol.audio.play_sound"cane3"
	sol.timer.start(enemy, WIND_UP_TIME, function()
		sprite:set_animation("shooting", function()
			sprite:set_animation"walking"
			enemy:go_hero()
		end)
		sol.audio.play_sound"frost2"
		local x,y,z = enemy:get_position()
		local projectile = map:create_enemy{
			x=x, y=y-8, layer=z, direction = 0,
			breed = "ghost_projectile",
		}
		projectile:go(projectile:get_angle(hero))
		sol.timer.start(enemy, COOLDOWN, function() enemy:restart() end)
	end)
end