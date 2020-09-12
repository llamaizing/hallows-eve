local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  --map.light_fx:set_darkness_level("night")
  sol.menu.start(map, require"scripts/fx/fog")
end)
