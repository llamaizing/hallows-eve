local map = ...
local game = map:get_game()

map:register_event("on_started", function()

  map.light_fx:set_darkness_level({170,150,210})

end)

function map:on_opening_transition_finished()
  
end