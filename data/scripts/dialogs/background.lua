-- Script that handles background transitions

-- Usage:
-- local background_manager = require("scripts/background")

local transition_manager = require("scripts/dialogs/libs/transitions")
local image_helper = require("scripts/dialogs/libs/image_helper")

local background_manager = {}

function background_manager:create(game)
  background = {
    transitions = {}, -- table of transition information for background
    image = sol.surface.create(sol.video.get_quest_size())
  }
  
  function background:on_draw(dst_surface)
    background.image:draw(dst_surface)
  end

  -- Public: Sets up background properties and displays the background
  --
  -- background_config - Background Config file containing image information to apply and display
  --
  -- Example:
  --
  --    set_background({'image' =>  {'path' => 'my/image/path', 'x_offset' => 12, 'sprite' => {...}}})
  --
  -- Returns nothing
  function background:set_background(config)
    if config == nil  or type(config) ~= 'table' or type(config['image']) ~= 'table' then return end -- if no background specified then just keep old one

    if config['image']['path'] == 'default' then
      background.image = sol.surface.create(sol.video.get_quest_size())
      background.image:fill_color({0, 0, 64, 192})
    else
      background.image = image_helper:get_image(config['image'])
    end
    background.transitions = config['transitions']

    x, y = background.image:get_xy()
    if config['image']['x_offset'] ~= nil then x = x + config['image']['x_offset'] end
    if config['image']['y_offset'] ~= nil then y = y + config['image']['y_offset'] end
    background.image:set_xy(x,y)
  end

  -- Public Transitions background
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
  function background:transition(state)
    if type(background['transitions']) == 'table' and next(background['transitions']) ~= nil then
      transition(state, background.image, background['transitions'])
    end
  end

  function background:transition(state)
    if type(background['transitions']) == 'table' and next(background['transitions']) ~= nil then
      transition(state, background.image, background['transitions'])
    end
  end

  return background
end


return background_manager