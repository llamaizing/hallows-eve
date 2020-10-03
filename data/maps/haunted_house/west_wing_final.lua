local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/map_settings/haunted_house_fx"):set_fx(map)

end)

function map:on_opening_transition_finished()
  if not game:get_value("haunted_house_west_wing_loop_acknowledge") then
    game:set_value("haunted_house_west_wing_loop_acknowledge", true)
    game:start_dialog("haunted_house.observations.2_west_wing_again", function()
      map:focus_on(from_key_room, function() end)
    end)
  end
end