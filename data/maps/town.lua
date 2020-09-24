local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level({180, 160, 200})
  map.light_fx:set_darkness_level("dusk")
end)