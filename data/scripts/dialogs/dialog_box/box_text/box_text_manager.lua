-- Script which handles displaying the dialog box text

-- Usage:
-- require("scripts/dialogs/dialog_box/libs/dialog_box_text"):create()

local dialog_box_text = {}

-- handles the dialog box text. e.g. the "text" displayed in the dialog box.
function dialog_box_text:create(game)
  box_text = {
    dialog = nil, -- A table containing dialog information (speaker, lines, etc)
    dialog_surface = sol.surface.create(sol.video.get_quest_size()), -- the surface we are drawing the text surfaces on
    lines_wrapper = require("scripts/dialogs/dialog_box/box_text/lines/lines_wrapper"):create(game), -- wrapper for line surfaces
    question_wrapper = require("scripts/dialogs/dialog_box/box_text/question/question_wrapper"):create(), -- wrapper for handling question specific logic
    max_displayed_lines = 4, -- The max number of lines to display at a time.
    last_displayed_line_index = 0, -- the index position of the last displayed line. (0 is the starting position so it increments correctly)
    x_offset = 8, -- The offset so the text appears inside the dialog box border
    y_offset = 8, -- The offset for the first line from the top of the box
    line_space = 14, -- The space between each line
    inline_options = {}, -- INTERNAL ONLY DO NOT SET! -- For midline changes (e.g. if we want to change the color midway through the line) populated from conversation_parser
  }
  -- Updates the text in the dialog box and the dialog box config options
  --
  -- dialog - a table of dialog information
  -- config - a table of display options for the dialog box
  --
  -- Example
  --  update({
  --     name = 'Todd', 
  --     dialog_id = 'todd.greeting',  
  --     lines = ['my', 'spoken', 'lines'],
  --     inline_options = {...}
  --  },
  --  { line = {...}, question = {...} })
  --
  -- Returns nothing
  function box_text:update(dialog, config)
    for k,v in pairs(config) do
      if box_text[k] ~= v and box_text[k] ~= nil then 
        box_text[k] = v
      end
    end

    box_text.question_wrapper:update(config['question'])

    box_text.dialog = dialog
    box_text.inline_options = dialog['inline_options']

    box_text.last_displayed_line_index = 0
    box_text.lines_wrapper:update(config['line'], box_text.max_displayed_lines)
  end

  -- Finds options (if any) for the passed in line index
  --
  -- line_index - the line index to get inline options for
  --
  -- Example:
  -- Assume the layout of the inline_options table is:
  -- { OPTION1 => { LINE_INDEX => { CHARACTER_ON_LINE_INDEX => VALUE, ...}, ...}
  --
  -- for the example below assume this is the inline options table:
  -- { color => { 1 => { 15 => 'blue' }, { 18 => 'yellow' } }, 2 => { 2 = > 'orange' } },
  --   font => {2 => { 6 = > 'Times New Roman'} }
  --
  -- inline_options_for_line(1)
  --   #=> { color => { 15 => 'blue' }, { 18 => 'yellow' } }
  --
  -- inline_options_for_line(2)
  --   #=> { color => { 2 = > 'orange' }, font => { 6 = > 'Times New Roman'} }
  --
  -- Returns a table containg the options for that line
  local function inline_options_for_line(line_index)
    line_options = {}
    for option, locations in pairs(box_text.inline_options) do
      if locations[line_index] then line_options[option] = locations[line_index] end
    end

    return line_options
  end

  -- figures out the lines that we are going to display in the dialog box
  --
  -- Example
  --
  --   lines_to_display(
  --     ['When life gives you lemons, don't make lemonade.', 
  --      'Make life take the lemons back!',
  --      'Get mad!',
  --      'I don't want your damn lemons, what the hell am I supposed to do with these?',
  --      'Demand to see life's manager!',
  --      'Make life rue the day it thought it could give Cave Johnson lemons!',
  --      'Do you know who I am?',
  --      'I'm the man who's gonna burn your house down!',
  --      'With the lemons!',
  --      "I'm gonna get my engineers to invent a combustible lemon that burns your house down!"]
  --    )
  --    #=> ['Demand to see life's manager!', 
  --         'Make life rue the day it thought it could give Cave Johnson lemons!',
  --         'Do you know who I am?',
  --         'I'm the man who's gonna burn your house down!']
  --
  -- Returns a table containing the lines we are going to display next in the dialog box
  local function next_lines_to_display(lines)
    lines_to_display = {}
    for i = 1, box_text.max_displayed_lines do
      box_text.last_displayed_line_index = box_text.last_displayed_line_index + 1
      line = lines[box_text.last_displayed_line_index]
      if line == nil then line = '' end

      line_info = {}
      line_info['line'] = line
      line_info['inline_options'] = inline_options_for_line(box_text.last_displayed_line_index)
      table.insert(lines_to_display, line_info)
    end

    if box_text.question_wrapper:is_a_question(lines_to_display) then
      lines_to_display = box_text.question_wrapper:convert_dialog_to_question(lines_to_display)
    end

    return lines_to_display
  end

  -- Advances the dialog text
  --
  -- Returns nothing
  function box_text:advance_text()
    lines = box_text.dialog['lines']
    -- if no text passed in then do nothing
    if next(lines) == nil then return
    -- if user pressed button before we were done displaying text then display all text instantly
    elseif box_text.lines_wrapper:all_lines_filled() == false then
      box_text.lines_wrapper.speed = 0
    else -- else we're done displaying text and should display next text
      box_text.lines_wrapper:advance_text(next_lines_to_display(lines))
    end
  end

  -- Checks to see if all text in the dialog box has been displayed
  --
  -- returns boolean
  function box_text:text_finished()
    if box_text.lines_wrapper:all_lines_filled() == false then return false end

    display_index = box_text.last_displayed_line_index

    if type(display_index) ~= 'number' or type(#box_text.dialog.lines) ~= 'number' then return false end

    return display_index >= #box_text.dialog.lines
  end

  -- When the dialog box is displaying a question this allows the players to move the selection
  -- cursor up or down
  --
  -- Examples
  --   move_cursor("up")
  --   move_cursor("down")
  --
  -- Returns nothing
  function box_text:move_cursor(command)
    if box_text.question_wrapper:is_a_question() then
      box_text.question_wrapper:move_cursor(command)
    end
  end

  -- tells the box_text that it's closing and so it needs to start performing any
  -- final actions it needs to do
  --
  -- returns nothing
  function box_text:stop()
    box_text.question_wrapper:select_answer()
  end

  -- If the dialog box is a question it returns the line the user has selected.
  --
  -- Examples:
  --  get_answer()
  --    #=> 3
  --
  -- get_answer()
  --   #=> nil
  --
  -- Returns the index of the currently selected line or nil if it's not a question
  function box_text:get_answer()
    return box_text.question_wrapper:get_answer()
  end

  -- Gets the dialog surface. It requries the x and y coordinates of the dialog box 
  -- image so that it can draw the text on it correctly
  --
  -- box_x - the x position of the dialog box image
  -- box_y - the y position of the dialog box image
  --
  -- Example
  --   get_text_surface(12,45)
  --     #=> sol.surface object
  --
  -- Returns a sol.surface with the dialog box text drawn on it.
  function box_text:get_text_surface(box_x, box_y)
    box_text.dialog_surface:clear()

    x = box_x + box_text.x_offset
    y = box_y + box_text.y_offset
    box_text.lines_wrapper:draw_lines(box_text.dialog_surface, x, y)

    if box_text.question_wrapper:is_a_question() and box_text.lines_wrapper:all_lines_filled() then
      box_text.question_wrapper:draw_cursor(box_text.dialog_surface, box_text.lines_wrapper)
    end

    return box_text.dialog_surface
  end


  function box_text:fade_in(delay)
    box_text.dialog_surface:fade_in(delay)
  end

  function box_text:fade_out(delay)
    box_text.dialog_surface:fade_out(delay)
  end

  return box_text
end

return dialog_box_text