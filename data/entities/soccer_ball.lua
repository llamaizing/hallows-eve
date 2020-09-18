local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  sprite = entity:create_sprite("entities/soccer_ball")
  entity:set_can_traverse("hero", true)
  entity:set_can_traverse("crystal", true)
  entity:set_can_traverse("crystal_block", true)
  entity:set_can_traverse("destructible", true)
  entity:set_can_traverse("jumper", true)
  entity:set_can_traverse("stairs", false)
  entity:set_can_traverse("stream", true)
  entity:set_can_traverse("switch", true)
  entity:set_can_traverse("teletransporter", true)
  entity:set_can_traverse_ground("deep_water", true)
  entity:set_can_traverse_ground("shallow_water", true)
  entity:set_can_traverse_ground("hole", true)
  entity:set_can_traverse_ground("lava", true)
  entity:set_can_traverse_ground("prickles", true)

  entity:set_drawn_in_y_order(true)

  entity.damage = 1

  sprite:set_animation"bouncing"
end

function entity:on_movement_changed(m)
  sprite:set_direction(m:get_direction4())
end


function entity:apply_type(type)
  entity.type = type
end


function entity:fire(angle)
  sprite:set_animation"rolling"
  local m = sol.movement.create"straight"
  m:set_speed(190)
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(entity)

  function m:on_obstacle_reached()
    m:stop()
    sol.audio.play_sound("arrow_hit")
    if entity.type then entity:create_effect() end
    entity:pop()
  end

end


function entity:pop()
  entity:stop_movement()
  entity:clear_collision_tests()
  sol.audio.play_sound"pop"
  sprite:set_animation("pop", function() entity:remove() end)
end


function entity:create_effect()
  if entity.type == "fire" then
    local dir = entity:get_direction()
    local x, y, z = entity:get_position()
    map:create_fire{x=x+game:dx(8)[dir], y=y+game:dy(8)[dir], layer=z}
    entity:get_sprite():set_color_modulation{50,50,50}
    entity:pop()

  elseif entity.type == "ice" then
    map:create_ice_sparkle(entity:get_position())

  elseif entity.type == "electric" then
    local x, y, z = entity:get_position()
    local dir = entity:get_direction()
    map:create_lightning{x=x+game:dx(8)[dir], y=y+game:dy(8)[dir], layer=z}

  elseif entity.type == "bomb" then
    local x, y, z = entity:get_position()
    map:create_explosion{x=x, y=y, layer=z}
    sol.audio.play_sound"explosion"
    entity:pop()

  end
end


entity:add_collision_test("sprite", function(entity, other_entity, sprite, other_sprite)
  local type = other_entity:get_type()

  if type == "enemy" then
    other_entity:hurt(entity.damage)
    entity:pop()
  end

  if type == "destructible" and other_entity:get_sprite():get_animation_set() == "destructibles/pot" then
    print"BREAK POT"
    entity:break_pot(other_entity)
  end

end)


entity:add_collision_test("overlapping", function(entity, other_entity)
  local type = other_entity:get_type()

  if type == "crystal" then
    entity:get_movement():on_obstacle_reached()
    sol.audio.play_sound("switch")
    map:change_crystal_state()
    entity:clear_collision_tests()

  elseif type == "switch" and not other_entity:is_walkable() then
    entity:get_movement():on_obstacle_reached()
    local switch = other_entity
    if not switch:is_activated() then
      sol.audio.play_sound("switch")
      switch:set_activated(true)
      switch:on_activated()
    else
      sol.audio.play_sound("switch")
      switch:set_activated(false)
      if switch.on_inactivated then switch:on_inactivated() end
    end
    entity:clear_collision_tests()

  end
end)


--Break pots
function entity:break_pot(other_entity)
    print"yow pow pow breaking a pot"
--    if other_entity:get_destruction_sound() then sol.audio.play_sound(other_entity:get_destruction_sound()) end
    other_entity:get_sprite():set_animation("destroy", function() entity:pop() other_entity:remove() end)
    local treasure = other_entity:get_treasure()
    if treasure then
      local x,y,z = other_entity:get_position()
      map:create_pickable{
        x=x, y=y, layer=z, treasure_name = treasure,
      }
    end
    entity:clear_collision_tests()
end

