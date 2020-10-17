-- Script that handles character transitions

-- Usage:
-- local character_manager = require("scripts/character_manager")

local transition_manager = require("scripts/dialogs/libs/transitions")
local image_helper = require("scripts/dialogs/libs/image_helper")
--local display_position = require("scripts/dialogs/libs/display_position")

local character_manager = {}

-- Require library so we can easily set positions of display objects
-- Creates the character manager
--
-- game - a game object
-- display_position - An instace of the display_position class
function character_manager:create(_, display_position)
  local characters = {}

  -- Public: Draw character sprites on destination surface
  -- This is called by Solarus. DO NOT CALL MANUALLY!
  --
  -- dst_surface - Surface the characters will be drawn on
  --
  -- Example
  --   on_draw(sol.surface)
  --
  -- Returns nothing
  function characters:on_draw(dst_surface)
    for k, _ in pairs(self.character_sprites) do
      self.character_sprites[k]:draw(dst_surface)
    end
  end

  -- Internal: Set the character's X and Y using the provided config file
  --
  -- character - The character that is going to have it's XY set
  -- config - file containing the information to use set the character's XY
  -- dialog_box_grahic - a sol.surface or sol.sprite image
  --
  -- Example
  --   set_xy(sol.sprite.new(), { 'x_offset' => number, 'y_offset' => number, ... }, sol.suface object)
  --     #=> sol.sprite
  --
  --   set_xy(sol.surface.new(), { 'x_offset' => number, 'y_offset' => number, ... }, sol.sprite object)
  --     #=> sol.surface
  --
  -- Returns sprite or surface that has been set to the correct XY
  local function set_xy(character, config, dialog_box_grahic)
    local x, y = 0,0
    if config.position ~= nil then
      local window = (function() if config['relative_to_dialog_box'] == true then return dialog_box_grahic else return nil end end)()
      x, y = display_position:compute_position(character, config.position, window)
    end

    if config['x_offset'] ~= nil then x = x + config['x_offset'] end
    if config['y_offset'] ~= nil then y = y + config['y_offset'] end

    character:set_xy(x, y)

    return character
  end

  -- Internal: Function to set up the character and add it to the character_sprites table
  --
  -- characters - Table containg character set up information
  -- dialog_box_grahic - A sol.surface or sol.sprite object
  --
  --  Example:
  --    set_character({'Tom' => { 'image' => { 'path' => '/a/path', ... } }, 'Bill' => {...}, ... }, sol.surface.new())
  --
  --  Returns Nothing
  function characters:set_characters(config, dialog_box_grahic)
    characters.config = config -- table of all character configs
    characters.character_layer = sol.surface.create(sol.video.get_quest_size()) -- layer to draw characters on
    characters.character_sprites = {} -- Table containg the currently displayed sprites

    for name,attributes in pairs(config) do
      if type(attributes['image']) == 'table' then
        self.character_sprites[name] = set_xy(
          image_helper:get_image(attributes['image']),
          attributes['image'],
          dialog_box_grahic
        )
      end
    end
  end

  -- Public: transitions character
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
  function characters:transition(state)
    for name, object in pairs(characters.character_sprites) do
      local char_config = characters.config[name]
      if type(char_config) == 'table' and type(char_config['transitions']) == 'table' then
        transition_manager:transition(state, object, char_config['transitions'])
      end
    end
  end

  return characters
end
return character_manager
