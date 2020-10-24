local map = ...
local game = map:get_game()

map:register_event("on_started", function()

  require("maps/spirit_world/challenge_islands/spirit_challenge_map_effects"):set_fx(map)

end)

function door_switch:on_activated()
  map:focus_on(door_a, function()
    map:open_doors("door_a")
  end)
end