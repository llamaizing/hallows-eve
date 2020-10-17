-- This wrapper is used to handle special logic when the dialog text poses a question to the player.

local image_helper = require("scripts/dialogs/libs/image_helper")

-- Usage:
-- require("scripts/dialogs/dialog_box/libs/text/question_wrapper"):create()
--
local question_wrapper = {}
local question

function question_wrapper:create()
  question = {
    line_buffer = 4, -- The amount of spaces to append to each question line (to leave room for the cursor)
    question_marker = "$?", -- The markers used to denote question answers (e.g. yes and no answers in a dialog box)
    cursor_wrap = true, -- Allow the cursor to wrap (i.e. if pressing up from top option move cursor to bottom option and vice versa)
    cursor = { -- config options for how the cursor should be displayed (either sprite or icon)
      -- The cursor offsets exist because I can't know where you want your cursor in relation to the text. So I'm leaving it to you to fine tune it
      x_offset = 0, -- x cursor offset from the start of the text surface
      y_offset = 0, -- y cursor offset from the start of the text surface

    },
    cursor_image = nil, -- the cursor (created via options from the cursor config)
    question_indexes = {}, -- contains indexes of displayed lines which are marked by the question marker.
    cursor_index = nil, -- the line index that the cursor is at (i.e. the line the player is selecting currently)
    move_sound = '', -- sound to play when cursor is moved
    selection_sound = '', -- sound to play when player makes their choice
    answer = {}, -- the config handling options when the player selects an answer
    answer_selected = false, -- if the player has selected an answer
  }

  -- Updates the question_wrapper attributes
  --
  -- config - a table containing the options to update
  --
  -- Example
  --   update( {
  --     line_buffer = 6,
  --     question_marker = "//",
  --     cursor_wrap = false,
  --     ...
  --   })
  --
  -- Returns nothing
  function question:update(config, _)
    for k,v in pairs(config) do
      if question[k] ~= v and question[k] ~= nil then
        question[k] = v
      end
    end
  end

  -- Gets cursor image from a png sheet of icons. Use icon width and height
  -- to divide sheet into rows and columns. Then uses the row and column to
  -- determine which icon from the sheet to use
  --
  -- cursor - a table of options on where to draw the cursor
  --
  --  Example:
  --    load_icon_cursor({ 'image' => 'my_cursor', 'icon' = {...} })
  --      #=> sol.surface
  --
  -- Returns a surface object containing the cursor
  local function load_cursor_from_sheet(cursor)
    local icon_sheet = sol.surface.create(cursor.path)
    local icon = cursor.icon
    local cursor_image = sol.surface.create()

    icon_sheet:draw_region(
      icon.width * icon.column,
      icon.height * icon.row,
      icon.width,
      icon.height,
      cursor_image)

    return cursor_image
  end

  -- Determines what kind of cursor we are loading. It can be either a static image or an animated sprite
  --
  -- cursor_config - a table containg either the sprite, image, or icon config tables
  -- cursor_image - the cursor object (can be nil, sol.surface, or sprite)
  --
  -- Examples
  --   load_cursor({...}, nil)
  --     #=> sol.surface
  --
  --  load_cursor({icon = {}, ...}, nil)
  --    #=> sol.surface
  --
  --  load_cursor({icon = {}, ...}, sol.surface)
  --    #=> sol.surface
  --
  --  load_cursor({sprite = {}, ...}, nil)
  --    #=> sol.sprite
  --
  --  load_cursor({sprite = {}, ...}, sol.sprite)
  --    #=> sol.sprite
  --
  -- Returns the cursor we want to draw (either a sol.surface or a sol.sprite)
  local function load_cursor(config, cursor_image)
    -- if loading cursor from png file of icons
    if type(config['icon']) == "table" then return load_cursor_from_sheet(config) end
    -- if cursor already set to config sprite just return current sprite
    if cursor_image ~= nil and cursor_image['get_animation_set'] ~= nil and cursor_image:get_animation_set() == config['path'] then
      return cursor_image
    end

    return image_helper:get_image(config)
  end

  -- Gets the xy position to set the cursor to. Since cursors and can be different sizes
  -- and shapes we use the user defined offsets in cursor config to allow you to fine tune
  -- them via the config files.
  --
  -- cursor - A table which contains the x and y offsets to apply
  -- x - The current x value of the line the cursor is on
  -- y - The current y value of the line the cursor is on
  --
  -- Example
  --   get_cursor_position({ x_offset = 12, y_offset = -14, ...}, 12 ,0)
  --   #=> 24, -14
  --
  -- Returns two values (x and y) that we want to draw the cursor at
  local function get_cursor_position(cursor, x, y)
    local cursor_x = (function() if cursor.x_offset ~= nil then return x + cursor.x_offset else return x end end)()
    local cursor_y = (function() if cursor.y_offset ~= nil then return y + cursor.y_offset else return y end end)()

    return cursor_x, cursor_y
  end

  -- Determines if the passed array of lines contain a questions.
  -- Populates question attributes and removes the markers from the lines
  --
  -- lines - an array of strings
  --
  -- Examples:
  --   contains_question([ --assuming that $? is the question_marker
  --      "Do you wish to call in an air strike?",
  --      "$? YEAH!",
  --      "$? HELL YEAH!"
  --   ])
  --   #=> [
  --         "Do you wish to call in an air strike?",
  --         "   YEAH!",
  --         "   HELL YEAH!"
  --       ]
  --
  --   contains_question(["I didn't ask your opinion scrub!"])
  --   #=> ["I didn't ask your opinion scrub!"]
  --
  -- Returns an array of strings with the question markers removed (if they were present)
  local function set_question_indexes(lines)
    question.question_indexes = {}

    local question_indexes = {}
    local is_question_box = false

    for i = 1, #lines do
      if string.sub(lines[i]['line'], 1, #question.question_marker) == question.question_marker then
        table.insert(question_indexes, i)
        -- A question box must have at least 2 consecutive lines that start with the question_marker
        if #question_indexes >= 2 and question_indexes[#question_indexes-1] == i-1 then
          is_question_box = true
        else -- handling tricky edge cases where 2 lines might be consecutive than another one isn't
          is_question_box = false
        end
      end
    end

    if is_question_box then
      question.question_indexes = question_indexes
      question.cursor_index = question_indexes[1]
    end
  end

  -- Checks if lines contains a question. If no lines are passed
  -- it will return the cached results of the previous lines it checked.
  --
  -- lines - optional table
  --
  -- Examples:
  --    is_a_question(
  --      { 'line' => 'my first line', ...},
  --      { 'line' => 'my second line', ...},
  --        ...
  --    )
  --      #=> false
  --
  --    is_a_question()
  --      #=> true
  --
  -- Returns boolean
  function question:is_a_question(dialog)
    if type(dialog) == 'table' and next(dialog) ~= nil then set_question_indexes(dialog) end

    if type(question.question_indexes) == 'table' and next(question.question_indexes) ~= nil then
      return true
    end

    return false
  end

  -- Formats all question lines
  --
  -- lines - an array of strings
  --
  -- Examples:
  --   --assuming that $? is the question_marker
  --   format_question_lines(
  --    [
  --      { 'line' => "Do you wish to call in an air strike?", ...},
  --      { 'line' => "$? YEAH!", ...},
  --      { 'line' => "$? HELL YEAH!", ...},
  --    ]
  --   )
  --   #=>
  --        [
  --          { 'line' => "Do you wish to call in an air strike?", ...},
  --          { 'line' => "   YEAH!", ...},
  --          { 'line' => "   HELL YEAH!", ...},
  --        ]
  --
  -- Returns an array of strings with the question markers removed
  function question:convert_dialog_to_question(lines)
    for i = 1, #question.question_indexes do
      local line = lines[question.question_indexes[i]]['line']
      -- remove question_marker
      line = string.sub(line, #question.question_marker + 1 )
      -- trim the string
      line = string.gsub(line,"^%s*(.-)%s*$", "%1")
      -- buffer space at the beginning of the line (to leave room for the cursor)
      lines[question.question_indexes[i]]['line'] = string.rep(" ", question.line_buffer)..line
    end
    return lines
  end

  -- Draws the cursor on the passed in surface
  --
  -- surface - The sol.surface we are drawing the cursor on
  -- lines - An array of text surfaces containg the currently displayed lines
  --
  --  Example:
  --    draw_cursor(sol.surface.create('path/to/a/dialog/box/img'),
  --      [
  --        "Do you wish to save the world?",
  --        "   YEAH!",
  --        "   HELL YEAH!"
  --      ])
  --   #=> surface
  --
  -- Returns the passed in surface with the cursor drawn on it
  function question:draw_cursor(surface, lines)
    local config = question.cursor

    if question.answer_selected == true and next(question.answer) ~= nil then
      config = question.answer
    end

    local cursor_image = load_cursor(config['image'], question.cursor_image)
    cursor_image:set_xy(
      get_cursor_position(
        config['image'],
        lines:get_line_at_index(question.cursor_index):get_xy()
      )
    )
    cursor_image:draw(surface)

    question.cursor_image = cursor_image
    return surface
  end

  -- When the dialog box is displaying a question this allows the players to move the selection
  -- cursor up or down
  --
  -- Examples
  --   move_cursor("up")
  --   move_cursor("down")
  --
  -- Returns nothing
  function question:move_cursor(command)
    -- don't allow player to move cursor if this isn't a if they have already made a selection
    -- question box closes or if there's no question indexes
    if not question:is_a_question() or question.answer_selected == true then return end

    -- Making the assumption that all selectable lines are consecutive
    local first_index = question.question_indexes[1]
    local last_index = question.question_indexes[#question.question_indexes]

    local line_iter = (function() if command == "up" then return -1 else return 1 end end)()
    question.cursor_index = question.cursor_index + line_iter

    if question.cursor_index < first_index then
      question.cursor_index = (function() if question.cursor_wrap == true then return last_index else return first_index end end)()
    elseif question.cursor_index > last_index then
      question.cursor_index = (function() if question.cursor_wrap == true then return first_index else return last_index end end)()
    end

    if question.move_sound ~= '' then sol.audio.play_sound(question.move_sound) end
  end

  -- When the player selects an answer play sounds and perform any
  -- final question actions (e.g. switching over answer cursor)
  --
  -- Returns nothing
  function question:select_answer()
    question.answer_selected = true
    if question.selection_sound ~= '' then sol.audio.play_sound(question.selection_sound) end
  end

  -- Returns the index of the line that the player selected.
  -- Is called once the dialog box closes
  --
  -- Returns the index of the line the player selected
  function question:get_answer()
    return question.cursor_index
  end

  return question
end

return question_wrapper
