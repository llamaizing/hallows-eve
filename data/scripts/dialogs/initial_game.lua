local initial_game = {}

-- Starting conditions for the game
--
-- game - sol.game
--
-- Example
--  initialize_new_savegame(sol.game)
--
-- Returns nothing
function initial_game:initialize_new_savegame(game)
  game:set_starting_location("demo/start",nil)

  game:set_max_life(12)
  game:set_life(game:get_max_life())

  game:set_ability("lift", 1)
  game:set_ability("swim",0)

  local bow = game:get_item("bow")
  bow:set_variant(1)
  game:set_item_assigned(1,bow)
end

return initial_game
