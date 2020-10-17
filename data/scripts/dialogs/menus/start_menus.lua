-- Displays the menus in the list one after another,
-- and execute callback when done.

-- Usage:
-- start_menus:show({
--    "scripts/menus/solarus_logo"
--  },
--  function()
--    -- Do whatever you want next (e.g. start a game)
--  end)

local start_menus = {}

-- Show the start menus.
function start_menus:show(menu_script_list, on_finished)
  -- Execute callback immediately if not menus in list.
  if #menu_script_list == 0 then
    if on_finished ~= nil then
      on_finished()
    end
  end

  -- Load menus.
  for i, menu_script in ipairs(menu_script_list) do
    local menu = require(menu_script)

    function menu:on_finished()
      if sol.main.game ~= nil then
        -- A game is already running (probably quick start with a debug key).
        return
      end

      -- Show next menu.
      local next_menu = menu_script_list[i + 1]
      if next_menu ~= nil then
        sol.menu.start(sol.main, next_menu)
      else
        -- All menus have been displayed.
        if on_finished ~= nil then
          on_finished()
        end
      end
    end

    menu_script_list[i] = menu
  end

  -- Start first menu.
  local on_top = false  -- To keep the debug menu on top.
  sol.menu.start(sol.main, menu_script_list[1], on_top)
end

return start_menus
