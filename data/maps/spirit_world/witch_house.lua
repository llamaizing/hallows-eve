local map = ...
local game = map:get_game()

map:register_event("on_started", function()

  require("maps/spirit_world/challenge_islands/spirit_challenge_map_effects"):set_fx(map)

  if game:get_value"witch_house_gates_unlocked_forever" then
    map:set_doors_open("door")
  end

end)

function unlock_gates_forever_sensor:on_activated()
  game:set_value("witch_house_gates_unlocked_forever", true)
end