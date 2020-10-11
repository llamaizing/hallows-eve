local item = ...
local game = item:get_game()


item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_pumpkin_seed")
  item:set_amount_savegame_variable("amount_pumpkin_seed")
end)

function item:on_obtaining()
  item:add_amount(1)
  if item:get_amount() == 5 then
    item:set_amount(0)
    game:set_max_life(game:get_max_life() + 2)
    game:set_life(game:get_max_life())
  end
end