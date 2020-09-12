local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  area_darkness_level = "night"
  light_fx = require"scripts/fx/lighting_effects"
  light_fx:set_darkness_level(area_darkness_level)
  sol.menu.start(map, light_fx)

end)