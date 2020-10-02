local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/map_settings/haunted_house_fx"):set_fx(map)


for enemy in map:get_entities("group_a_enemy") do
  function enemy:on_dead()
print"check group a"
    if not map:has_entities("group_a_enemy") then
print"group a clear, open door"
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
print"check group b"
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
      map:focus_on(door_c, function()
        for door in map:get_entities("door_c") do
            door:set_enabled(false)
        end
      end)
    end
  end
end

end)
