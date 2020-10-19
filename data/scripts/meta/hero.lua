-- Initialize hero behavior specific to this quest.

local hero_meta = sol.main.get_metatable("hero")

hero_meta:register_event("on_created", function(self)
  local hero = self
  hero:set_walking_speed(100)
end)


function hero_meta:on_taking_damage(damage)
  local hero = self
  local game = self:get_game()
  local defense = game:get_value("defense") or 4
  damage = math.floor(damage*4 / defense)
  if game.take_half_damage then
    damage = damage / 2
  end
  if damage < 1 then
    damage = 1
  end

  --if this attack would kill you in 1 hit at above 40% max life
  if damage >= game:get_life()
  and game:get_life() >= game:get_max_life() * .4
  and damage >= game:get_max_life() * .6
  and not game.guts_save_used then
    --leave you with half a heart
    damage = game:get_life() - 1
    game:get_map():get_camera():shake()
    sol.audio.play_sound"ohko"
    --set this mechanic on a cooldown
    game.guts_save_used = true
    sol.timer.start(game, 40 * 1000, function() game.guts_save_used = false end)
  elseif damage >= game:get_max_life() * .5 then
    sol.audio.play_sound"oh_lotsa_damage"
  end

  game:remove_life(damage)

    game:set_suspended(true)
    sol.timer.start(game, 120, function()
      game:set_suspended(false)
      self:get_map():get_camera():shake({count = 4, amplitude = 5, speed = 100})
     end) --end of timer

  local iframe_length = 1000
  hero:set_invincible(true, iframe_length)
  hero:set_blinking(true, iframe_length)


    --If this is the first time you've been hurt, explain healing
    if not game:get_value("healing_explained") then
      game:set_value("healing_explained", true)
      game:start_dialog("controls.healing", function()
        hero:set_invincible(true, 1000)
        hero:set_blinking(true, 1000)
      end)
    end

end





hero_meta:register_event("on_state_changed", function(self, state)
  local hero = self
  local game = sol.main.get_game()
  local map = hero:get_map()

  if state == "sword swinging" then
    -- Makes sure that the sword is drawn behind the hero when the hero is facing north
    local main_sprite = self:get_sprite("tunic")
    local sword_sprite = self:get_sprite("sword")
    local direction4 = self:get_direction4_to(self:get_facing_position())
    if (direction4 == 0 or direction4 == 1 or direction4 == 2) then
      self:bring_sprite_to_back(sword_sprite)
      self:bring_sprite_to_front(main_sprite)
    else
      self:bring_sprite_to_front(sword_sprite)
      self:bring_sprite_to_back(main_sprite)
    end
    --Damage entities that overlap with the hero
    local x,y,z = hero:get_position()
    for entity in map:get_entities_in_rectangle(x-8, y-13, 16, 16) do
      if entity:get_type() == "enemy" then
        --entity:hurt(1)
      end
    end
  end

  --1500s of invincibility after falling into a hole in case you're returned to a space with an enemey
  if state == "back to solid ground" then
    hero:set_invincible(true,1500)
  end


  if state == "sword loading" then
    game:simulate_command_released("attack")
    hero:start_attack_loading(0)
  end



  --weird bad fire sword
  if state == "sword swinging" and game.sword_on_fire then
    local dx = {[0]=16,[1]=0,[2]=-16,[3]=0}
    local dy = {[0]=0,[1]=-16,[2]=0,[3]=16}
    local map = game:get_map()
    local x, y, z = hero:get_position()
    local direction = hero:get_direction()
    local spread = {math.rad(-50), math.rad(-25), math.rad(25), math.rad(50)}
    for i=1, 4 do
      sol.timer.start(map, 50 * i-1, function()
        local flame = map:create_fire{ x = x+dx[direction], y= y+dy[direction], layer=z}
        local m = sol.movement.create"straight" m:set_speed(100) m:set_max_distance(16)
        m:set_ignore_obstacles()
        m:set_angle( direction*math.pi/2  + spread[i])
        m:start(flame, function() flame:remove() end)
        sol.timer.start(map, 1000, function() flame:remove() end)
      end)
    end

  --Sword Beam
  elseif state == "sword swinging" and game:get_life() == game:get_max_life() and 2==4 --turned off
  and game:get_value"hard_mode" and not hero.sword_beam_cooldown then
    hero.sword_beam_cooldown = true
    sol.timer.start(game,500,function() hero.sword_beam_cooldown = false end)
    local dx = {[0]=16,[1]=0,[2]=-16,[3]=0}
    local dy = {[0]=0,[1]=-16,[2]=0,[3]=16}
    local map = game:get_map()
    local x, y, z = hero:get_position()
    local direction = hero:get_direction()

    sol.audio.play_sound"sword_beam"
    local beam = map:create_custom_entity{
      x=x+dx[direction], y=y+dy[direction], layer=z, direction=direction, width=8, height=8,
      sprite="entities/sword_beam", model="damaging_sparkle"
    }
    beam:get_sprite():set_animation"head"
    sol.timer.start(beam, 60, function()
      local bx,by,bz=beam:get_position()
      local tail = map:create_custom_entity{x=bx,y=by,layer=bz,direction=direction,width=16,height=16,
      sprite="entities/sword_beam", model="ephereral_effect"}
      tail:get_sprite():set_animation"tail"
      if beam:exists() then return true end
    end)
    local m = sol.movement.create"straight"
    m:set_speed(250) m:set_angle(direction * math.pi/2) m:set_smooth(false)
    m:start(beam, function() beam:explode() end)
    function m:on_obstacle_reached() beam:explode() end
    function beam:explode()
      local bx,by,bz = beam:get_position()
      local pop = map:create_custom_entity{x=bx,y=by,layer=bz,direction=direction,width=16,height=16,
      sprite="enemies/enemy_killed_small", model="ephereral_effect"} 
      beam:remove()     
    end

  elseif game.spirit_counter_sword and state == "sword swinging" and hero:is_blinking() then
    local map = game:get_map()
    local x, y, z = hero:get_position()
    sol.audio.play_sound"sword_beam"
    map:create_custom_entity{x=x,y=y,layer=z,width=16,height=16,direction=0,
      model="damaging_sparkle",sprite="entities/spirit_counter"
    }

  end
end)

function hero_meta:become_all_powerful()
  local game = self:get_game()
  game:set_value("sword_damage", 25)
  game:set_value("bow_damage", 25)
  game:set_value("defense", 25)
  game:set_max_life(52)
  game:set_life(52)
end

local MAX_BUFFER_SIZE = 48
function hero_meta:on_position_changed(x,y,z)
  local hero = self
  if not hero.position_buffer then hero.position_buffer = {} end
  local hero = self
  local dir = hero:get_sprite():get_direction()
  table.insert(hero.position_buffer, 1, {x=x,y=y,layer=l,direction=dir})

  if #hero.position_buffer > MAX_BUFFER_SIZE then
    table.remove(hero.position_buffer)
  end
end

return true