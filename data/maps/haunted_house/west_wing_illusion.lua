local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/map_settings/haunted_house_fx"):set_fx(map)
  map.light_fx:set_darkness_level{100,100,80}

end)

function map:on_opening_transition_finished()
game:start_dialog("haunted_house.observations.1-wendigo")
end
