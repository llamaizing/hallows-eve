-- Script which creates and handles the dialog box image

-- Usage:
-- require("scripts/dialogs/dialog_box/libs/dialog_box_graphics"):create()

local dialog_box_graphics = {}

local image_helper = require("scripts/dialogs/libs/image_helper")

-- handles the dialog box graphic. e.g. the "box" graphic of the dialog box.
function dialog_box_graphics:create()
  local screen_width, screen_height = sol.video.get_quest_size()

  box_graphics = {}
  
  -- Updates the box graphics using the passed table
  --
  -- Example
  -- update(
  --   {
  --     box_img = "hud/dialog_box/dialog_box.png",
  --     transitions = {...},
  --     ...
  --  }
  -- )
  --
  -- Returns nothing
  function box_graphics:update(config)
    config = config or {}
    box_graphics.box_img = sol.surface.create(screen_width - 16, screen_height/3) -- Dialog box surface
    box_graphics.sprite = {
      animation = '',
      direction = 0,
    }
    box_graphics.x_offset = 0
    box_graphics.y_offset = 0

    for k,v in pairs(config) do
      if box_graphics[k] ~= nil and box_graphics[k] ~= 'path' then
        box_graphics[k] = v
      end
    end

    path = config['path']
    if type(path) == 'string' and path ~= '' then
      box_graphics.box_img = image_helper:get_image(config)
    end
  end

  -- Returns a surface containing a surface with a dialog box drawn on it
  --
  -- Example
  --   get_box_surface
  --     #=> box_graphics.box_img
  --
  -- Returns get_box_surface or nil
  function box_graphics:get_box_surface()
    return box_graphics.box_img
  end

  -- Sets xy of box image
  --
  -- position - A String of the position to set the box to
  --
  -- Example:
  --   set_xy('center')
  --
  -- Returns nothing
  function box_graphics:set_xy(position)
    x, y = compute_position(box_graphics.box_img, position, nil) 
    box_graphics.box_img:set_xy(x + box_graphics.x_offset, y + box_graphics.y_offset)
  end

  return box_graphics
end

return dialog_box_graphics