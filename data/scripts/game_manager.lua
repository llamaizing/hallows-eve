-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()

local initial_game = require("scripts/initial_game")

local game_manager = {}

-- Creates a game ready to be played.
function game_manager:create(file, overwrite)
  --Delete previous save if overwrite is true
  if overwrite then sol.game.delete(file) end

  -- Create the game (but do not start it).
  local exists = sol.game.exists(file)
  local game = sol.game.load(file)
  if not exists then
    -- This is a new savegame file.
    initial_game:initialize_new_savegame(game)
  end

  require("scripts/fx/lighting_effects"):initialize()
  require("scripts/button_inputs"):initialize(game)
  require("scripts/menus/inventory/inventory"):init(game, "standard")
  require("scripts/game_over"):init(game)

  --need 10ms delay or else game:get_hero() returns nil
  sol.timer.start(game, 10, function()
  	require("scripts/menus/quick_items"):init(game)
  end)

  return game
end

return game_manager
