local enemy_meta = sol.main.get_metatable"enemy"

function enemy_meta:on_hurt(attack)
  local enemy = self
  local game = sol.main.get_game()
  local sprite = enemy:get_sprite("main")
  local map = self:get_map()
  local camera = map:get_camera()

  --Shake screen
  game:set_suspended(true)
  sol.timer.start(game, 60, function()
    game:set_suspended(false)
    camera:shake({count = 4, amplitude = 5, speed = 200, zoom_factor = 1.005})
  end) --end of timer

  --Flash enemy
	if not enemy.being_hit then
		enemy.being_hit = true
		sol.timer.start(map, 300, function() enemy.being_hit = false end)
		sprite:set_blend_mode"add"
		sol.timer.start(map, 50, function()
			sprite:set_blend_mode"blend"
		end)
  end

  --If you have magic shoelaces
  if game:get_item("pumpkin_jordans"):get_variant() >= 2 then
    enemy:remove_life(1)
  end

  --Remove extra life if attack was an explosion
  if attack == "explosion" then
    enemy:remove_life(5)
  end

  --Recharge ammo if it was a kick attac
  if attack == "sword" then
    game:add_magic(8)
  end
end