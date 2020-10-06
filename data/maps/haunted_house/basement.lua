local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/map_settings/haunted_house_fx"):set_fx(map)
  map.light_fx:set_darkness_level(4)

  if game:has_item("library_statue_gear") then
    exit_block_1:set_enabled()
    exit_block_2:set_enabled()
  end

end)

