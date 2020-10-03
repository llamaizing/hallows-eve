-- Used for single line options e.g if we want to change a single word in a line to a different color or font.
-- or if we want to add midline effects (like an image in the middle of the line or a SFX)
require("scripts/dialogs/libs/color_helper")

local line_wrapper = {}

function line_wrapper:create(game)
  local line_config = {
    line =  {}, -- INTERALLY POPULATED DO NOT SET! an array of sol.text.surfaces (min 1)
    text_config = {}, -- INTERNALLY POPULATED DO NOT SET The current text configuration (basically what options to use for text after overrides appled)
    config = {}, -- options from dialog_box config (overridden by the inline_options if applicable)
    inline_options = {}, -- a table containing any unique options for this line (e.g. change font, color, etc midline)
    text = '', -- The text of the line
    current_character_displayed = '' -- which character did we just display
  }

  -- Updates the line config object
  --
  -- config - A table containing configuration options for a sol.text_surface
  -- inline_options - A table containing override options for config
  --
  -- Example:
  --   please see the sol.text_surface documentation for a complete list
  --   config - { 
  --     horizontal_alignment = 'left',
  --     vertical_alignment = 'top',
  --     font = 'my_cool_cont', 
  --     font_size = 12,
  --     color = {255,0,0},
  --     image_path = 'dialog_test_art_assets/hud/text_images'
  --   }
  --
  --   update(config)
  --
  -- Returns nothing
  function line_config:update(config)
    -- These values were copied from the Solaurs 1.6 docs. If they change in the future this list will need to updated.
    -- I hate doing this but I can't figure out how to dynamically get these from a text_surface object.
    for _index, value in pairs({ 'horizontal_alignment', 'vertical_alignment', 'font', 'rendering_mode', 'color', 'font_size', 'text', 'text_key' }) do
      if config[value] then
        if value == 'color' then
          line_config.text_config[value] = get_color(config[value])
        else
          line_config.text_config[value] = config[value]
        end
      end
    end

    line_config.config = config
    line_config.line[1] = sol.text_surface.create(line_config.text_config) -- a line must have a minimum of one text section
  end

  -- Adds the next character to the line
  --
  -- Example:
  --   add_new_character()
  --
  -- Returns nothing
  function line_config:add_next_character()
    next_char_index = line_config.get_text():len() + 1
    next_char = line_config.text:sub(next_char_index, next_char_index)

    override_options = line_config:character_position_overrides(next_char_index)
    if next(override_options) ~= nil then
      line_config:add_line_section(override_options) 
    end

    line_section = line_config.line[#line_config.line]
    line_section:set_text(line_section:get_text().. next_char)
    line_config.current_character_displayed = next_char
  end

  -- Gets any overrides for a character index
  --
  -- char_index - the index of the chracter to get overrides for (integer)
  --
  -- Examples:
  --   character_postition_overrides(2)
  --    #=> {'font' => ['a_cool_font'] }
  --     
  --   character_position_overrides(99)
  --    #=> {}
  --
  -- Returns a table containg overrides (empty if none found)
  function line_config:character_position_overrides(char_index)
    override_options = {}
    for option, char_location in pairs(line_config.inline_options) do
      if char_location[char_index] ~= nil then
        override_options[option] = char_location[char_index]
      end
    end
    return override_options
  end

  -- Determines if what kind of override there is. If a non text surface
  -- It will add it, Then add a new text surface immediately following it
  -- This ensures the last element of lines is always a text_surface
  -- 
  -- Example:
  --   add_line_section({9 => ['my_image.png']})
  --
  -- Returns nothing
  function line_config:add_line_section(override_options)
    -- check for and add any non_text surfaces
    line_config:add_non_text_sections(override_options)

    -- should always add a text surface at the end of the line
    for override_name, values in pairs(override_options) do
      for _index, value in pairs(values) do
        if override_name == 'color' then 
          line_config.text_config[override_name] = get_color(value)
        else
          line_config.text_config[override_name] = value
        end
      end
    end

    line_config.line[#line_config.line + 1] = sol.text_surface.create(line_config.text_config)
  end

  -- Adds non text surfaces to the line
  --
  -- override_options - A table of override options
  --
  -- Example:
  --   add_non_text_sections({'sprite' => ['sprite1', 'sprite2'], 'image' => ['image.png', 'image2_png' ]})
  --
  -- Returns nothing
  function line_config:add_non_text_sections(override_options)
    for override_type, values in pairs(override_options) do
      for _index, value in pairs(values) do
        config = line_config.config[override_type]
        if (override_type == 'image' or override_type == 'sprite') and type(config) == 'table' then
          if override_type == 'sprite' then
            non_text_section = sol.sprite.create(config['path']..'/'..value)
            if config['animation'] ~= nil then non_text_section:set_animation(config['animation']) end
            if config['direction'] ~= nil then non_text_section:set_direction(config['direction']) end
          else
            non_text_section = sol.surface.create(config['path']..'/'..value)
          end

          line_config.line[#line_config.line + 1] = non_text_section
        end
      end
    end
  end

  -- Gets XY of first line section (which is where the start of the line is)
  --
  -- Example:
  --   get_xy()
  --    #=>[12,45]
  --
  -- Return xy pair as array 
  function line_config:get_xy()
    return line_config.line[1]:get_xy()
  end

  -- Sets the xy value of the first line section
  -- We use the first section's placement in order to figure out
  -- where the rest of the line sections should be placed
  --
  -- x - The x value to set
  -- y - The y value to set
  --
  -- Exanple:
  --   set_xy(12.7, 87.9)
  --
  -- Returns nothing
  function line_config:set_xy(x,y)
    for index, section in pairs(line_config.line) do
      if index == 1 then
        section:set_xy(x, y)
      elseif index > 1 then
        prev_section = line_config.line[index - 1]
        prev_x, _prev_y = prev_section:get_xy()
        prev_width, _prev_height = prev_section:get_size()

        prev_x = prev_x + prev_width
        y_offset = y

        if section['get_text'] == nil then
          surface = (function() if section['get_animation_set'] ~= nil then return 'sprite' else return 'image' end end)()
          if line_config.config[surface].x_offset ~= nil then prev_x = prev_x + line_config.config[surface].x_offset end
          if line_config.config[surface].y_offset ~= nil then y_offset = y_offset + line_config.config[surface].y_offset end
        end

        section:set_xy(prev_x, y_offset)
      end
    end
  end

  -- wrapper around the set opacity
  -- ensures that all sections opacity of a line are set
  --
  -- opacity - integer between 0-255
  --
  -- Example:
  --   set_opacity(200)
  --
  -- Returns nothing
  function line_config:set_opacity(opactiy)
    for _index, section in pairs(line_config.line) do section:set_opacity(opactiy) end
  end

  -- wrapper around the draw function
  -- ensures that all sections of a line get drawn
  --
  -- surface - a sol.surface object
  --
  -- Example:
  --   draw(sol.surface.create())
  --
  -- Returns nothing
  function line_config:draw(surface)
    for _index, section in pairs(line_config.line) do
      section:draw(surface)
    end
  end

  -- Gets full text of all sections of line
  --
  -- Example:
  --   get_text()
  --     #=> "All Your Base Are Belong To Us!"
  --
  -- Returns string
  function line_config:get_text()
    text = ''
    for _index, section in pairs(line_config.line) do
      if section.get_text ~= nil then text = text..section:get_text() end
    end
    return text
  end

  -- clears line
  --
  -- Example:
  --   clear()
  --
  -- Returns nothing
  function line_config:clear()
    -- if we don't have the base options we can't create the line surfaces yet
    if line_config.config == {} then return end
    line_config.line = {}
    line_config.line[1] = sol.text_surface.create(line_config.text_config)
  end

  -- Checks that the line is full
  --
  -- Example:
  --   is_full()
  --
  -- Returns boolean
  function line_config:is_full()
    return line_config.text:len() == line_config:get_text():len()
  end

  function line_config:fade_in(delay)
    for _index, line_section in pairs(line_config.line) do
      line_section:fade_in(delay)
    end
  end

  function line_config:fade_out(delay)
    for _index, line_section in pairs(line_config.line) do
      line_section:fade_out(delay)
    end
  end

  return line_config
end

return line_wrapper
