local dash_manager = {}

local MAX_MOTHS = 10
local MAGIC_COST = 0
local enough_magic
local movement_id = 1
local current_movement

function dash_manager:dash(game)
    --create movement
    local hero = game:get_hero()
    local dir = hero:get_direction()
    local dd = {[0]=0,[1]=math.pi/2,[2]=math.pi,[3]=3*math.pi/2} --to convert 0-4 direction to radians
    dir = dd[dir]
    if hero:get_movement() then dir = hero:get_movement():get_angle() end
    dash_manager.m = sol.movement.create("straight")
    dash_manager.m:set_angle(dir)
    dash_manager.m:set_speed(180)
    dash_manager.m:set_max_distance(88)
    dash_manager.m:set_smooth(true)

    hero:get_sprite():set_animation("dash", function()
      hero:get_sprite():set_animation("walking")
    end)
    game:set_value("hero_dashing", true)
    self:generate_moths(game)
    sol.audio.play_sound("dash")
    can_dash = false

    --create little dust clouds
    local x, y, z = hero:get_position()
    local map = hero:get_map()
    map:create_custom_entity({
      direction = 0, x = x, y = y, layer = z, width = 16, height = 16,
      sprite = "entities/dust_cloud_roll", model = "ephemeral_effect"
    })
    --this version does a couple little dust clouds
    local num_clouds = 3
    local cloud_delay = 100
    sol.timer.start(map, cloud_delay, function()
      for i = 1, num_clouds do
        local hx, hy, hz = hero:get_position()
        map:create_custom_entity({
          direction = 0, x = hx, y = hy, layer = hz, width = 16, height = 16,
          sprite = "entities/dust_cloud_roll", model = "ephemeral_effect"
        })
      end
    end)

    --start movement
    map:create_poof(hero:get_position())

    --Apply jump state
    hero:start_state(game:get_item("inventory/feather"):get_jumping_state())
    hero:set_animation("dash")

    dash_manager.m:start(hero, function()
      local x, y, layer = hero:get_position()
      map:create_poof(x,y,layer)
      hero:unfreeze()
      game:set_value("hero_dashing", false)
      game:set_value("hero_rolling", false)
    end)

    --Invincible while dashing?
    hero:set_invincible(true, 200)

    function dash_manager.m:on_obstacle_reached()
      hero:unfreeze()
      game:set_value("hero_dashing", false)
      game:set_value("hero_rolling", false)
    end


end


local hero_meta = sol.main.get_metatable"hero"

--[[
--Add check to dash movement to prevent dashing over holes and stuff
hero_meta:register_event("on_position_changed", function(self)
  local game = sol.main.get_game()
  if game:get_value("hero_dashing") or game:get_value("hero_rolling") then
    local ground = self:get_ground_below()
    if ground == "deep_water" or ground == "hole" or ground == "lava" then
        dash_manager.m:stop()
    end
  end
end)
--]]

dash_manager.seeds = {}
hero_meta:register_event("on_pre_draw", function(self, dst)
    for sprite, seed in pairs(dash_manager.seeds) do
      if sprite:is_animation_started() then
        self:get_map():draw_visual(sprite, seed.x, seed.y)
      end
    end
end)


function dash_manager:generate_moths(game)
  local map = game:get_map()
  local hero = game:get_hero()
  dash_manager.seeds = {}
  local n = 0
  for n = 0, MAX_MOTHS do
    local x, y, layer = game:get_hero():get_position()
    local sprite = sol.sprite.create"entities/moth"
    local moth = {
        x = x,
        y = y,
    }
    --[[
    moth.m = sol.movement.create"straight"
    moth.m:set_speed(160)
    moth.m:set_angle(2 * math.pi / MAX_MOTHS * n)
    --]]
    moth.m = sol.movement.create"random"
    moth.m:set_speed(80)
    moth.m:start(moth)
    sprite:set_animation("fade_out", function() moth = nil end)
    dash_manager.seeds[sprite] = moth
  end

  --[[
  --Moths return to Hero as they stop dashing
  sol.timer.start(map, 120, function()
      for _, seed in pairs(dash_manager.seeds) do
        seed.m:stop()
        local m = sol.movement.create"target"
        m:set_target(hero)
        m:set_speed(240)
        m:start(seed)
      end
  end)
  --]]

end



return dash_manager