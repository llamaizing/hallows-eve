--[[
By Max Mraz
How to use:
This entity on its own has no movement or behavior when triggered, these need to be defined elsewhere,
so that this entity script can be used for any sort of guard-type entity. Methods to define are:
entity:on_suspicious()
entity:on_suspicion_lost()
entity:on_alerted()
entity:on_attacked_by_sword()

Required animations for the sentry are "stopped" and "walking"
sprites/entities/suspicion_indicator is also required, and needs animations "suspicious" and "alert"
This is used like the typical ? or ! over the entities' heads as they see the player.

Note: on_alerted is only called once, until entity.alerted is manually set to false or nil.
on_suspicious, however, is called whenever the entity sees the player. It will be called every 50ms if the player remains in line of sight.
entity.suspicious is set to true whenever this happens,
so you may define you on_suspicious behavior to, for example, only play a "suspicious" sound if entity.suspicious isn't true.
entity.alerted and entity.suspicious can be toggled manually as you need.
A sentry will eventually set entity.suspicious to false once enough time has lapsed without seeing the player.
This amount of time is 6x the alert threshold. This is currently hardcoded.

You can set the alert threshold- time between becoming suspicious and becoming alerted- with entity:set_alert_threshold(new_threshold)
Alert threshold is in units of 50ms, so if you want 1 second between when the entity sees the player and when it triggers an alert, then
set the alert threshold to  20. You'll want to set this depending on how easy it is to hide once you're already seen.

Sentry entities automatically save their starting position as entity.starting_position_x, entity.starting_position_y, entity.starting_position_z,
in case you want them to return to their starting position after handling their on_alerted() behavior.

As an example, you may want to define entity:alerted() like so

function sentry_entity:on_alerted()
  local x, y, z = sentry_entity:get_position()
  local direction = sentry_entity:get_sprite():get_direction()
  map:create_enemy{ x = x, y = y, layer = z, direction = direction, breed = "guard" }
  sentry_entity:remove()
end

You can also configure behavior for on_suspicious(), so for example you may want to register the coordinates of the player,
and have the entity go toward those, or perhaps simply have the entity face the direction of the player.

So that when a sentry entity is alerted, a guard enemy is placed on the map at this point, and the player can engage the guard enemy.

This script by default works with "foliage" entities that I've created. It's a bit hardcoded, but
foliage entities 32px tall or higher will hide the player, sentries cannot see through them.
--]]

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local alert_threshold = 12
local too_close_distance = 32 --distance to sentry at which angle doesn't matter, you're too close

function entity:on_created()
  entity:set_drawn_in_y_order(true)
  entity:set_can_traverse("custom_entity", false)

  entity.vision_angle = entity:get_property("vision_angle") or 80
  entity.vision_distance = entity:get_property("vision_distance") or 112

  entity.alert_level = 0
  entity.starting_position_x, entity.starting_position_y, entity.starting_position_z = entity:get_position()

  entity:start_watch()

  --Call a method if the sentry is attacked by the player
  entity:add_collision_test("sprite", function(entity, other_entity, sprite, other_sprite)
    if other_entity:get_type() == "hero" and other_entity:get_state() == "sword swinging" then
      entity:on_attacked_by_sword()
    end
  end)
end



function entity:set_alert_threshold(threshold)
  alert_threshold = threshold
end


--Normalize angle
function normalize(angle)
  return ((angle + math.pi) % (2 * math.pi)) - math.pi
end


--Set sprite direction and animations for stopped and walking based on movement
function entity:on_movement_changed(movement)
  local sprite = entity:get_sprite()
  sprite:set_direction(movement:get_direction4())
  if movement:get_speed() > 0 and sprite:get_animation() ~= "walking" then
    sprite:set_animation"walking"
  elseif movement:get_speed() <= 0 and sprite:get_animation() ~= "stopped" then
    sprite:set_animation"stopped"
  end
end



function entity:start_watch()
  sol.timer.start(entity, 50, function()
    --Check hero angle and distance:
    local sentry_angle = entity:get_sprite():get_direction() * math.pi / 2

    -- if delta between enemy facing angle and angle to hero is greater than vision threshold, or if hero is too far away
    if ( math.abs(normalize(sentry_angle) - normalize(entity:get_angle(hero)) ) > math.rad(entity.vision_angle)
    and entity:get_distance(hero) > too_close_distance )
    or not map:is_on_screen(entity) then
      return true
    end

    entity:shoot_ray()

    return true
  end)

  --Bring alert level down gradually
  sol.timer.start(entity, 300, function()
    entity.alert_level = math.max(entity.alert_level - 1, 0)
    entity:process_alert_level()
    return true
  end)
end



function entity:shoot_ray()
  --Create entity to check for line of sight
  local x, y, z = entity:get_position()
  local ray = map:create_custom_entity{
    x = x, y = y, layer = z, direction = 0,
    width = 8, height = 8, sprite = "shadows/shadow_small"
  }
  ray:set_can_traverse("hero", true)
  ray:set_can_traverse("custom_entity", true)
  ray:set_can_traverse("jumper", true)
  ray:set_can_traverse("stairs", true)
  ray:set_can_traverse("stream", true)
  ray:set_can_traverse("switch", true)
  ray:set_can_traverse("teletransporter", true)
  ray:set_can_traverse_ground("deep_water", true)
  ray:set_can_traverse_ground("shallow_water", true)
  ray:set_can_traverse_ground("hole", true)
  ray:set_can_traverse_ground("lava", true)
  ray:set_can_traverse_ground("prickles", true)
  --Send ray toward hero
  local m = sol.movement.create"straight"
  m:set_smooth(false)
  m:set_speed(800)
  m:set_angle(entity:get_angle(hero))
  m:set_max_distance(entity.vision_distance)
  m:start(ray, function() ray:remove() end)
  function m:on_obstacle_reached() ray:remove() end

  --If hero is seen
  ray:add_collision_test("overlapping", function(ray, other_entity)
    if other_entity:get_type() == "hero" then
      ray:remove()
      entity.alert_level = math.min(entity.alert_level + 1, alert_threshold)
      entity:process_alert_level()
    --Allow to hide in foliage 32px tall or higher
    elseif other_entity:get_type() == "custom_entity" and other_entity:get_model() == "foliage" then
      local _, height = other_entity:get_sprite():get_size()
      if height >= 32 then ray:remove() end
    end
  end)
end



function entity:process_alert_level()
  --Suspicious, hasn't been:
  if entity.alert_level > 0 and not entity.alert_sprite then
    entity.alert_sprite = entity:create_sprite("entities/suspicion_indicator")
    sol.audio.play_sound"picked_money"

  elseif entity.alert_level == 0 and entity.alert_sprite then
    entity:remove_sprite(entity.alert_sprite)
    entity.alert_sprite = nil
    entity.suspicious = false
    entity:on_suspicion_lost()

  elseif entity.alert_level > 0 and entity.alert_level < alert_threshold then
    entity.suspicious = true
    entity:on_suspicious()
    entity.alert_sprite:set_animation"suspicious"

  elseif entity.alert_level >= alert_threshold and not entity.alerted then
    entity.alert_sprite:set_animation("alert")
    if not entity.alerted then entity:on_alerted() end
    entity.alerted = true

  end
end


function entity:on_suspicious()
  print("Sentry entity suspicious! No suspicion behavior has been defined.")
end


function entity:on_alerted()
  sol.audio.play_sound("picked_small_key")
  print("sentry entity alerted! No alert behavior has been defined.")
end

function entity:on_attacked_by_sword()
end

function entity:on_suspicion_lost()
end