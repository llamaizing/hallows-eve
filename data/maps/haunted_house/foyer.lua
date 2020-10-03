local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/map_settings/haunted_house_fx"):set_fx(map)

  if game:get_value"haunted_house_west_windigo_escaped" then
    west_wing_teleporter:set_destination_map("haunted_house/west_wing_final")
  end
end)
