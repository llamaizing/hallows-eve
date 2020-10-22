local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/map_settings/haunted_house_fx"):set_fx(map)

  if game:get_value"haunted_house_key_room_defeated" then
    for door in map:get_entities"door" do
      door:set_enabled(false)
    end
  end


  for enemy in map:get_entities("group_a_enemy") do
    function enemy:on_dead()
      if not map:has_entities("group_a_enemy") then
        map:focus_on(door_a, function()
          for door in map:get_entities("door_a") do
              door:set_enabled(false)
          end
        end)
      end
    end
  end

  for enemy in map:get_entities("group_b_enemy") do
    function enemy:on_dead()
      if not map:has_entities("group_b_enemy") then
        map:focus_on(door_b, function()
          for door in map:get_entities("door_b") do
              door:set_enabled(false)
          end
        end)
      end
    end
  end

  for enemy in map:get_entities("group_c_enemy") do
    function enemy:on_dead()
      if not map:has_entities("group_c_enemy") then
        game:set_value("haunted_house_key_room_defeated", true)
        map:focus_on(door_c, function()
          for door in map:get_entities("door_c") do
              door:set_enabled(false)
          end
        end)
      end
    end
  end

end)

for sensor in map:get_entities("trap_you_sensor") do
  function sensor:on_activated()
    if not game:get_value("haunted_house_key_room_defeated") then
      for e in map:get_entities("door_c_trap") do
        e:set_enabled(true)
      end
    end
  end
end
