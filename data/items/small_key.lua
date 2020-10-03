local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_small_key")
  item:set_amount_savegame_variable("amount_small_key")
end)

item:register_event("on_obtained", function(self)
  self:add_amount(1)
end)
