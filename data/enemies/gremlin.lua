local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local ghost_sprite
local movement

local DETECTION_DISTANCE = 120
local MELEE_RANGE = 64
local CHASE_SPEED = 70
local WANDER_SPEED = 40
local WIND_UP_TIME = 400


function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(4)
  enemy:set_damage(1)

  ghost_sprite = enemy:create_sprite("enemies/"..enemy:get_breed())
  enemy:bring_sprite_to_back(ghost_sprite)
  ghost_sprite:set_color_modulation{255,255,255}
  ghost_sprite:set_blend_mode"add"
  function sprite:on_frame_changed(animation, frame)
    frame = frame + 1
    if frame >= sprite:get_num_frames() then frame = 0 end
    ghost_sprite:set_frame(frame)
  end
end

function enemy:on_restarted()
  enemy:choose_state()
end

function enemy:on_movement_changed()
	sprite:set_direction(enemy:get_movement():get_direction4())
	ghost_sprite:set_direction(enemy:get_movement():get_direction4())
end

function enemy:choose_state()
	if enemy:is_close_to_hero() then
		if enemy:get_distance(hero) <= MELEE_RANGE and not enemy.attacking then
			enemy:attack()
		elseif not enemy.going_hero then
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
	elseif rand > 15 then
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
	sol.timer.start(map, 1500, function() enemy.attacking = false end)
	enemy:stop_movement()
	sprite:set_animation("wind_up")
	sol.timer.start(enemy, WIND_UP_TIME, function()
		sprite:set_animation("attack", function()
			sprite:set_animation"stopped"
			enemy:go_hero()
		end)
		local attack_sprite = enemy:create_sprite("enemies/misc/slash")
		enemy:set_invincible_sprite(attack_sprite)
		attack_sprite:set_direction(sprite:get_direction())
		sol.timer.start(enemy, 1000, function() enemy:remove_sprite(attack_sprite) end)
	end)
end