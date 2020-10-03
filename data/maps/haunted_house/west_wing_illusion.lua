local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/map_settings/haunted_house_fx"):set_fx(map)
  map.light_fx:set_darkness_level{100,100,80}

end)

function map:on_opening_transition_finished()
  map:focus_on(wendigo, function()
    game:start_dialog("haunted_house.observations.1-wendigo")
  end)
end

function escape_teleporter:on_activated()
  game:set_value("haunted_house_west_windigo_escaped", true)
end