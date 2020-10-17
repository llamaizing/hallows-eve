-- Script that creates the name box for a game.

-- Usage:
-- local name_box = require("scripts/name_box/name_box/name_box_manager"):create(game)

local image_helper = require("scripts/dialogs/libs/image_helper")
local display_position = require("scripts/dialogs/libs/display_position")

local name_box_manager = {}

local name_box
-- name_box_manager handles all of the objects which makes up a name box. The box image, the text, animations, etc.
function name_box_manager:create(game)
  name_box = {
    image = {}, -- table of image information
    box_img = sol.surface.create(67,17), -- need a default size in case one isn't passed
    name_line = require("scripts/dialogs/dialog_box/box_text/lines/line/line_wrapper"):create(game),
    dialog_box_img = sol.surface.create(),
  }

  -- Updates the dialog box. Uses the passed in config to set things like the box image, text font, transition, etc.
  --
  -- dialog - A table containg the current speaker and the dialog lines.
  -- config - A table containing the information to update to
  --
  -- Example
  --   name_box:update(
  --     {
  --       name = 'Todd',
  --       dialog_id = 'todd.greeting',
  --       lines = ['my', 'spoken', 'lines']
  --     },
  --     {
  --       image = {...},
  --       sprite = {...},
  --     },
  --     sol.surface
  --   )
  --
  -- Returns nothing
  function name_box:update(dialog, config, dialog_box_img)
    for k,v in pairs(config) do
      if name_box[k] ~= v and name_box[k] ~= nil and type(name_box[k]) ~= "table" then
        name_box[k] = v
      end
    end

    name_box.image = config.image
    name_box.line = config.line

    name_box.box_graphic = name_box:create_name_box_image(config["image"])
    name_box.dialog_box_img = dialog_box_img

    name_box.name_line:update(config['line'], 1) -- set to 1 cause name box is only ever one line

    -- set name box to new name
    name_box.name_line:clear()
    name_box.name_line.text = dialog['name']
    for _ = 1, #name_box.name_line.text do name_box.name_line:add_next_character() end
  end

  -- Creates the name box image
  --
  -- config - A table of configuration options
  --
  -- Examples
  --   create_name_box({image = {...}, sprite = {...},...})
  --     #=> sol.sprite
  --
  --   create_name_box({image = {...},...})
  --     #=> sol.surface
  --
  -- Returns sol.sprite or sol.surface
  function name_box:create_name_box_image(config)
    local path = config['path']
    if type(path) ~= 'string' or path == '' then return end
    name_box.box_img = image_helper:get_image(config)
  end

  -- tells the name_box_manager that it's closing and so it needs to start performing any
  -- final actions it needs to do
  --
  -- game - A Solarus Game Object
  --
  -- Examples
  --   stop(sol.game.new())
  --
  -- returns nothing
  function name_box:stop(_)
    name_box.dialog_text:stop()
  end

  -- This is called by Solarus as part of the sol.menu.start() function. You shouldn't call it directly
  -- Defines what to do when the sol.menu.start is first called with this object.
  --
  -- Example
  -- N/A
  --
  -- Returns nothing
  function name_box:on_started()
    sol.menu.start(name_box, self.name_line)
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
  function name_box:on_draw(dst_surface)
    if name_box.box_img == nil or name_box.box_img['draw'] == nil or name_box.box_img['set_xy'] == nil then return end
    if type(name_box['image']) ~= 'table' then return end

    local position = (function() if name_box['image']['position'] ~= nil then return name_box['image']['position'] else return 'outsidetopleft' end end)()

    local box_x,box_y = display_position:compute_position(name_box.box_img, position, name_box.dialog_box_img)
    if name_box['image']['x_offset'] ~= nil then box_x = box_x + name_box['image']['x_offset'] end
    if name_box['image']['y_offset'] ~= nil then box_y = box_y + name_box['image']['y_offset'] end
    name_box.box_img:set_xy(box_x,box_y)
    name_box.box_img:draw(dst_surface)

    if type(name_box['line']) == 'table' then
      local x, y
      if name_box['line']['x_offset'] ~= nil then x = box_x + name_box['line']['x_offset'] end
      if name_box['line']['y_offset'] ~= nil then y = box_y + name_box['line']['y_offset'] end
      name_box.name_line:set_xy(x,y)
    else
      name_box.name_line:set_xy(box_x, box_y)
    end

    name_box.name_line:draw(dst_surface)
  end

  function name_box:fade_in(delay)
    name_box.box_img:fade_in(delay)
  end

  function name_box:fade_out(delay)
    name_box.box_img:fade_out(delay)
  end

  return name_box
end

return name_box_manager
