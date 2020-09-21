local enemy_meta = sol.main.get_metatable"enemy"

function enemy_meta:on_hurt(attack)
  local enemy = self
  local game = sol.main.get_game()
  local sprite = enemy:get_sprite("main")
  local map = self:get_map()
  local camera = map:get_camera()

  game:set_suspended(true)
  sol.timer.start(game, 120, function()
    game:set_suspended(false)
    camera:shake({count = 4, amplitude = 5, speed = 100, zoom_factor = 1.005})
  end) --end of timer

print(sprite:get_blend_mode())
	if not enemy.being_hit then
		enemy.being_hit = true
		sol.timer.start(map, 300, function() enemy.being_hit = false end)
		sprite:set_blend_mode"add"
		sol.timer.start(map, 50, function()
			sprite:set_blend_mode"blend"
		end)
  end
end