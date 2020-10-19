-- Main Lua script of the quest.
-- See the Lua API! http://www.solarus-games.org/doc/latest

require("scripts/features")
require("scripts/multi_events")

-- Edit scripts/menus/initial_menus_config.lua to add or change menus before starting a game.
local initial_menus_config = require("scripts/menus/initial_menus_config")
local initial_menus = {}

-- This function is called when Solarus starts.
function sol.main:on_started()

  local is_new_install = not sol.file.exists("settings.dat")
  if is_new_install then
    sol.video.set_fullscreen(true)
  end
  if sol.video.is_fullscreen() then
    sol.video.set_cursor_visible(false)
  end

  --preload the sounds for faster access
  sol.audio.preload_sounds()

  --Set the window title.
  sol.video.set_window_title("Ocean's Heart")

  sol.main.load_settings()
  math.randomseed(os.time())

  --Set window title
  sol.video.set_window_title("Hallow's Eve")

  -- Show the initial menus.
  if #initial_menus_config == 0 then
    return
  end

  for _, menu_script in ipairs(initial_menus_config) do
    initial_menus[#initial_menus + 1] = require(menu_script)
  end

  local on_top = false  -- To keep the debug menu on top.
  sol.menu.start(sol.main, initial_menus[1], on_top)
  for i, menu in ipairs(initial_menus) do
    function menu:on_finished()
      if sol.main.get_game() ~= nil then
        -- A game is already running (probably quick start with a debug key).
        return
      end
      local next_menu = initial_menus[i + 1]
      if next_menu ~= nil then
        sol.menu.start(sol.main, next_menu)
      end
    end
  end

  local game_meta = sol.main.get_metatable("game")
  game_meta:register_event("on_started", function(game)
    -- Skip initial menus when a game starts.
    for _, menu in ipairs(initial_menus) do
      sol.menu.stop(menu)
    end
  end)
end

-- Event called when the program stops.
function sol.main:on_finished()

  sol.main.save_settings()
end

-- Event called when the player pressed a keyboard key.
function sol.main:on_key_pressed(key, modifiers)

  local handled = false
  if key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    sol.video.set_fullscreen(not sol.video.is_fullscreen())
    sol.video.set_cursor_visible(not sol.video.is_fullscreen())
    handled = true
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "escape" and sol.main.get_game() == nil then
    -- Escape in pre-game menus: stop the program.
    sol.main.exit()
    handled = true
  end

  return handled
end


--Starts a game.
function sol.main:start_savegame(game)
  sol.main.game = game
  game:start()
end

--Called when app stops
function sol.main:on_finished()
  sol.main.save_settings()
end
