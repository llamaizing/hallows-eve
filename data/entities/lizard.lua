local entity = ...
local game = entity:get_game()
local map = entity:get_map()

function entity:on_created()
  entity:set_traversable_by("hero", false)
  entity:set_can_traverse("hero", false)

  entity:add_collision_test("sprite", function(entity, other_entity, sprite, other_sprite)
    if other_entity:get_type() == "hero" and other_entity:get_state() == "sword swinging" then
      entity:on_attacked_by_sword()
    end
  end)
end


function entity:on_attacked_by_sword()
  entity:set_layer(map:get_max_layer())
  local m = sol.movement.create"straight"
  m:set_angle(map:get_hero():get_angle(entity))
  m:set_speed(300)
  m:set_ignore_obstacles(true)
  m:set_max_distance(500)
  m:start(entity, function() entity:remove() end)
end