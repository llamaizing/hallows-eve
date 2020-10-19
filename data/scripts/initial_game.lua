-- This script initializes game values for a new savegame file.
-- You should modify the initialize_new_savegame() function below
-- to set values like the initial life and equipment
-- as well as the starting location.
--
-- Usage:
-- local initial_game = require("scripts/initial_game")
-- initial_game:initialize_new_savegame(game)

local initial_game = {}

-- Sets initial values to a new savegame file.
function initial_game:initialize_new_savegame(game)

  -- You can modify this function to set the initial life and equipment
  -- and the starting location.
  game:set_starting_location("debug", "destination")  -- Starting location.

  game:set_max_life(6)
  game:set_life(game:get_max_life())
  game:set_max_magic(40)
  game:set_magic(game:get_max_magic())
  game:set_max_money(100)
  game:set_ability("lift", 1)
  game:set_ability("sword", 1)
  --game:set_ability("swim", 1)

  --game:get_item("seed_shoot"):set_variant(1)
  --game:get_item("soccer_kick"):set_variant(1)
  game:get_item("spin_kick"):set_variant(1)
  game:get_item("heal"):set_variant(1)
  --game:get_item("pumpkin_jordans"):set_variant(1)

  game:set_item_assigned(1, game:get_item("spin_kick"))
  game:set_item_assigned(2, game:get_item("heal"))

  game:set_value("darkness_level", "evening")
  game:set_value("respawn_map", "spirit_world/apartment")


end

return initial_game
