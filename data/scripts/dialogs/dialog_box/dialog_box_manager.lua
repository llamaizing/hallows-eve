-- Script that creates a dialog box for a game.

-- Usage:
-- local dialog_box = require("scripts/dialog_box/dialog_box_manager"):create(game)

local dialog_box_manager = {}
local  dialog_box
local transitions = require("scripts/dialogs/libs/transitions.lua")

-- dialog_box_manager handles all of the objects which makes up a dialog box. The box image, the text, animations, etc.
-- display_position - An instace of the display_position class
function dialog_box_manager:create(game, display_position)
  dialog_box = {}

  -- Updates the dialog box. Uses the passed in config to set things like the box image, text font, transition, etc.
  --
  -- dialog - A table containg the current speaker and the dialog lines.
  -- config - A table containing the information to update to
  --
  -- Example
  --   dialog_box:update(
  --     {
  --        name = 'Todd',
  --        dialog_id = 'todd.greeting',
  --        lines = ['my', 'spoken', 'lines']
  --     },
  --     {
  --        image = {...},
  --        sprite = {...},
  --     }
  --   )
  --
  -- Returns nothing
  function dialog_box:update(dialog, config)
    dialog_box.close_delay = 0 -- the amount of time to wait before closing the dialog box (1000 = 1 second)
    dialog_box.box_graphic = require("scripts/dialogs/dialog_box/box_graphic"):create()
    dialog_box.dialog_text = require("scripts/dialogs/dialog_box/box_text/box_text_manager"):create(game)
    dialog_box.name_box = require("scripts/dialogs/dialog_box/name_box/name_box_manager"):create(game)
    dialog_box.transitions = {} -- table holding transition information for dialog box
    dialog_box.hidden = false

    dialog_box.box_graphic:update(config["image"])
    dialog_box.dialog_text:update(dialog, config["text"])

    if dialog.name ~= "NO SPEAKER" then
      dialog_box.name_box:update(dialog, config['name_box'], dialog_box.box_graphic.box_img)
    end

    for k,v in pairs(config) do
      if dialog_box[k] ~= v and dialog_box[k] ~= nil and type(dialog_box[k]) ~= "table" then
        dialog_box[k] = v
      end
    end

    dialog_box.transitions = config['transitions']
    dialog_box.box_graphic:set_xy(config['image']['position'])
  end

  -- tells the dialog_box_manager that it's closing and so it needs to start performing any
  -- final actions it needs to do
  --
  -- game - A Solarus Game Object
  --
  -- Examples
  --   stop(sol.game.new())
  --
  -- returns nothing
  function dialog_box:stop(sol_game)
    dialog_box.dialog_text:stop()

    sol.timer.start(sol_game, dialog_box.close_delay, function()
      sol_game:stop_dialog(dialog_box:get_answer())
    end)
  end

  -- checks to see if all text in the dialog box has been displayed
  --
  -- returns boolean
  function dialog_box:text_finished()
    return dialog_box.dialog_text:text_finished()
  end

  -- Advances the text inside the dialog box
  --
  -- Returns nothing
  function dialog_box:advance_text()
    dialog_box.dialog_text:advance_text()
  end

  -- Hides/Unhindes the dialog box image and sets the hidden flag accordingly
  -- If a boolean is passed in, then it will hide/unhide as dictated by it.
  -- Otherwise it will toggle the hidden flag back and forth
  --
  -- should_hide - OPTIONAL Boolean value
  --
  -- Examples:
  --   hide(false)
  --     #=> returns nothing (hidden = false)
  --
  --   hide(true)
  --     #=> returns nothing (hidden = true)
  --
  --   hide()
  --     #=> returns nothing (if hidden = true now hidden = false or vice versa)
  --
  -- Returns nothing
  function dialog_box:hide(should_hide)
    local hidden = nil

    if type(should_hide) == "boolean" then hidden = should_hide else hidden = not hidden end

    local opacity = (function() if hidden then return 0 else return 255 end end)()

    dialog_box.box_graphic.box_img:set_opacity(opacity)
    dialog_box.dialog_text.dialog_surface:set_opacity(opacity)

    dialog_box.name_box.box_img:set_opacity(opacity)
    dialog_box.name_box.name_line:set_opacity(opacity)
  end

  -- When the dialog box is displaying a question this allows the players to move the selection
  -- cursor up or down
  --
  -- Examples
  --   move_cursor("up")
  --   move_cursor("down")
  --
  -- Returns nothing
  function dialog_box:move_cursor(command)
    dialog_box.dialog_text:move_cursor(command)
  end

  -- Gets the answer line
  --
  -- Examples:
  --  get_answer()
  --    #=> 3
  --
  -- get_answer()
  --   #=> nil
  --
  -- Returns the index of the currently selected line or nil if it's not a question
  function dialog_box:get_answer()
    return dialog_box.dialog_text:get_answer()
  end

  -- This is called by Solarus as part of the sol.menu.start() function. You shouldn't call it directly
  -- Defines what to do when the sol.menu.start is first called with this object.
  --
  -- Example
  -- N/A
  --
  -- Returns nothing
  function dialog_box:on_started()
    sol.menu.start(dialog_box, dialog_box.box_graphic)
    sol.menu.start(dialog_box, dialog_box.dialog_text)
    sol.menu.start(dialog_box, self.name_box)
  end

  -- Draws the dialog box and text on to the passed in surface.
  -- This is called by Solarus as part of the sol.menu.start() function. You shouldn't call it directly
  --
  -- dst_surface - A sol.surface object
  --
  -- Example
  --   N/A
  --
  -- Returns nothing
  function dialog_box:on_draw(dst_surface)
    local box_surface = dialog_box.box_graphic:get_box_surface()
    local x, y = display_position:get_xy(box_surface)
    local origin_x, origin_y = display_position:get_origin(box_surface)
    local dialog_surface = dialog_box.dialog_text:get_text_surface(x - origin_x, y - origin_y)

    box_surface:draw(dst_surface)
    dialog_surface:draw(dst_surface)
  end

  -- Public: transitions dialog_box
  --
  -- state A string containing either 'enter' or 'exit'
  --
  -- Example:
  --
  --   transition('enter')
  --
  --   transition('exit')
  --
  -- Returns nothing
  function dialog_box:transition(state)
    if type(dialog_box['transitions']) == 'table' and next(dialog_box['transitions']) ~= nil then
      transitions:transition(state, dialog_box.box_graphic:get_box_surface(), dialog_box['transitions'])
    end
  end

  return dialog_box
end

return dialog_box_manager
