-- Used to keep track of what options are currently configued on the text surfaces

-- Usage:
-- require("scripts/dialogs/dialog_box/libs/text/lines_wrapper"):create(game)

local lines_wrapper = {}

-- handles displaying lines and anything related to that (font color etc.)
--
-- game - The Game Object
function lines_wrapper:create(game, line_space)
  local lines_config = {
    lines = {}, -- INTERNAL ONLY DO NOT SET! Array of line_wrapper object of size max displayed lines
    line_space = line_space, -- The space between each line
    speeds = { slow = 60, medium = 40, fast = 20, instant = 0}, -- These are some string shortcuts to various speeds
    speed = 20,  -- How long (in miliseconds) to wait before displaying the next character
    apply_speed_to_spaces = false, -- apply speed delay to spaces? (will display instantly otherwise)
    letter_sound = '',  -- what sound to play while text is being added to the screen
    letter_sound_delay = 0, -- how long after the character is displayed to play a letter sound
    should_play_letter_sound = true, -- INTERNAL ONLY DO NOT SET! Should we play a letter sound
    end_sound = '',  -- what sound to play when text is done displaying
  }

  -- Updates the text wrapper using the passed in table
  --
  -- config - the table of config options
  -- num_of_lines - the number of lines to display at a time
  --
  -- Example
  --  update({ horizontal_alignment = "left", vertical_alignment = "top", ... }, 4)
  --
  -- Returns nothing
  function lines_config:update(config, num_of_lines)
    for k,v in pairs(config) do
      if lines_config[k] ~= v and lines_config[k] ~= nil then
        -- if the speed passed was a string (e.g. fast, medium, slow etc.) we use the mapped value
        if k == 'speed' and type(v) == 'string' then
          lines_config[k] = lines_config.speeds[v]
        else
          lines_config[k] = v
        end
      end
    end

    lines_config.lines = {}

    for i = 1, num_of_lines do
      lines_config.lines[i] = require("scripts/dialogs/dialog_box/box_text/lines/line/line_wrapper"):create(game)
      lines_config.lines[i]:update(config)
    end
  end

  -- Checks to see if all line surfaces are filled (i.e. we're done displaying text)
  --
  -- Returns a boolean (true if all lines are full. false if they are not)
  function lines_config:all_lines_filled()
    for _,line in pairs(lines_config.lines) do
      if line.is_full() == false then return false end
    end

    return true
  end

  -- Gets the text surface at the displayed line index
  --
  -- index - A number between 1 and max_displayed_line_index
  --
  -- Example:
  --   get_line_at_index()
  --
  -- Returns a line_wrapper object
  function lines_config:get_line_at_index(index)
    return lines_config.lines[index]
  end

  -- If the lines are being displayed gradually we need to know what line isn't fully
  -- displayed yet.
  --
  -- Example:
  --   get_current_line_index()
  --     => 2
  --
  --   get_current_line_index()
  --     => 0
  --
  -- Returns a number between 1-number of line surfaces (or 0 if all lines have been displayed)
  local function get_current_line_index()
    for index,line in pairs(lines_config.lines) do
      if line:is_full() == false then
        return index
      end
    end

    return 0
  end

  -- Clears currently displayed lines
  --
  -- Returns nothing
  local function clear_lines()
    for _, line in pairs(lines_config.lines) do
      line:clear()
    end
  end

  -- Handles adding the next character in line. Uses a timer with recursion to space the
  -- adding of the character.
  --
  -- Examples:
  --   add_next_character()
  --
  -- Returns nothing
  local function add_next_character()
    local line_index = get_current_line_index()
    -- if we get an index that's out of bounds then we shouldn't try to display that line
    if line_index < 1 or line_index > #lines_config.lines then return end

    -- add character to display
    lines_config.lines[line_index]:add_next_character()

    -- set delay before displaying next letter
    local speed = lines_config.speed
    if lines_config.lines[line_index].current_character_displayed == " "  and lines_config.apply_speed_to_spaces == false then speed = 0 end
    sol.timer.start(game, speed, add_next_character)

    -- play letter sound if set (along with delay)
    if lines_config.should_play_letter_sound and lines_config.letter_sound ~= '' then
      sol.audio.play_sound(lines_config.letter_sound)
      lines_config.should_play_letter_sound = false
      sol.timer.start(game, lines_config.letter_sound_delay, function()
        lines_config.should_play_letter_sound = true
      end)
    end

    -- play message end sound if set
    if lines_config:all_lines_filled() == true and lines_config.end_sound ~= '' then
      sol.audio.play_sound(lines_config.end_sound)
    end
  end

  -- Handles advancing the text on screen (e.g. changing to a new set of lines to display)
  --
  -- lines - An array of lines to display (includes midline options)
  --
  -- Example
  --   display_text(
  --     [{ 'line' => 'The President has been kidnapped by ninjas.', 'sprite' => {13 => 'president'}, 'image' => 'ninja.png'},
  --      { 'line' => 'Are you a bad enough dude to rescue the President?'])
  --
  -- Returns nothing
  function lines_config:advance_text(lines)
    clear_lines()
    for index, line in pairs(lines) do
      lines_config.lines[index].text = line['line']
      lines_config.lines[index].inline_options = line['inline_options']
    end

    local speed = lines_config.speed
    sol.timer.start(game, speed, add_next_character)
  end

  -- Draws text on passed in surfaces
  --
  -- surface - A sol.surface
  --
  -- Returns the passed in surface with the text drawn on it
  function lines_config:draw_lines(surface,x ,y)
    for index, line in pairs(lines_config.lines) do
      line:set_xy(x, lines_config.line_space * (index - 1) + y)
      line:draw(surface)
    end
  end

  return lines_config
end

return lines_wrapper