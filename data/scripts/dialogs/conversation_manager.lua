-- handles parsing the raw dialog text into the tags that the rest
-- of the dialog manager uses.

--Uses:
-- require("scripts/dialogs/conversation_manager")

local conversation_manager = {}

-- When passed a conversation array it returns the list of unique
-- speakers taking part in the conversation
--
-- Example
--   get_unique_speakers([{name = 'emily'}, {name = 'brutus' }])
-- Returns an array containing the speaker names
function conversation_manager:get_unique_speakers(conversation)
  local unique_speakers = {}
  for _, speaker in ipairs(conversation) do
    local is_unique = true
    for _, unique in ipairs(unique_speakers) do
      if unique == speaker.name then
        is_unique = false
        break
      end
    end

    if is_unique then table.insert(unique_speakers, speaker.name) end
  end

  return unique_speakers
end

-- When the $v flag is in the dialog and the game specifies an info parameter
-- This function handles replacing it in the dialog text.
--
-- dialog - A dialog table (view the Solarus docs for info on what's in this table)
-- info - The info string. an optional argument which replaces the $v in the text
--
-- Example
--   substitutions(
--     { 'id' = 'link.greeting', 'text' = '@Link ... === @Zelda Hand me that $v ===' },
--     'Jug of Milk'
--   )
--   #=> '@Link ... === @Zelda Hand me that Jug of Milk ==='
--
-- Returns A string with all $v replaced with info parameter
local function substitutions(dialog, info)
  if info ~= nil then return dialog.text:gsub("%$v", info) else return dialog.text end
end

-- parses raw dialog into an array of lines split on end of line (that's what the \n represents in the
-- example below)
--
-- raw_dialog - String
--
-- Example:
--   parse_dialog(
--     'When I joined the corps, we didn't have fancy shmancy tanks.\n We had two sticks and a rock for the whole platoon, \n and we had to share the rock! ==='
--   )
--   #=>
--     {[
--        'When I joined the corps, we didn't have fancy shmancy tanks.',
--        'We had two sticks and a rock for the whole platoon',
--        'and we had to share the rock!'
--    ]}
--
-- Returns an array of lines
local function parse_dialog(dialog)
  -- remove leading spaces
  local first, _ = dialog:find("%S")
  local cleaned_lines = dialog:sub(first) -- Each line including empty ones.

  -- unify line enders
  cleaned_lines = cleaned_lines:gsub("\r\n", "\n"):gsub("\r", "\n")

  local dialog_lines = {}
  for s in cleaned_lines:gmatch("[^\n]+") do
    if s ~= '===' then table.insert(dialog_lines, s) end
  end

  return dialog_lines
end

-- Handles parsing the name from the dialog line.
-- We assume the name will ALWAYS be present
--
-- lines - An Array of Strings
--
-- Example:
--   parse_name(['@Yoda', 'Control, Control! You must learn control!', 'Else to the dark side you will fall!'])
--     #=> Yoda, ['Control, Control! You must learn control!', 'Else to the dark side you will fall!']
--
-- Returns the name and the rmainder of the string
local function parse_name(lines)
  local name_matcher = '^@(.+)$'
  local name = string.match(lines[1], name_matcher) -- Name should only be on the first line

  -- Nasty way of shifting the lines index over (replace if cleaner way is found)
  local trimmed_lines = {}
  for index = 2, #lines do trimmed_lines[index-1] = lines[index] end

  return name, trimmed_lines
end

-- Removes the found flag and value from the line to be displayed
--
-- flag_first - index in the line where the flag starts
-- val_last - index in the line where the value ends
-- line - the line the flag and value were found in
--
-- Example:
-- remove_flag_info_from_line(4, 12, 'My $color=red$ remainder text is red')
--   #=> 'My remainder text is red'
--
-- Returns string without values between the two indexes
local function remove_flag_info_from_line(flag_first, val_last, line)
  local modified_line = ""
  if flag_first ~= 1 then
    modified_line = modified_line..string.sub(line, 1, flag_first - 1)
  end

  if val_last < line:len() then
    modified_line = modified_line..string.sub(line, val_last + 1)
  elseif val_last == line:len() then -- handles edge case when flag is at end of line
    modified_line = modified_line..' '
  end

  return modified_line
end

-- Searches the passed in array of strings for any parts that match this pattern:
-- $MY_KEY=MY_VALUE$ if it finds that it will parse them into a hash which contains the
-- mapped key information. Then removes it from the line. (the format for the return is
-- { FLAG = {LINE_INDEX_WHERE_FLAG_STARTS = { CHARACTER ON LINE FLAG STARTS (after flag removal) = VALUE OF FLAG } } } )
--
-- lines - An Array of Strings
--
-- Example:
--   parse_inline_options(
--    ['$color=red$ red $color=green$ green and $color=blue$ blue', '$font=italic$ This line has a new font']
--    #=> {color = {1 = {1 = [red]}, {5 = [green]}, {11 = [blue]}}, font = {2 = {1 = [italic]}}}, ['red green blue', 'This line has a new font']
--
-- Returns the name and the rmainder of the string
local function parse_inline_options(lines)
  local options = {}
  options['inline_options'] = {}
  local parsed_lines = {}
  for index, line in pairs(lines) do
    for flag_and_value in string.gmatch(line, '%b$$') do
      local flag, value = string.match(flag_and_value, '%$(%S+)=(%S+)%$')

      local flag_first, val_last = string.find(line, flag_and_value, 1, true) -- by default string.find matches patterns and $ is a special character.
      -- true option forces find by plain string

      if options['inline_options'][flag] == nil then options['inline_options'][flag] = {} end
      if options['inline_options'][flag][index] == nil then options['inline_options'][flag][index] = {} end
      if options['inline_options'][flag][index][flag_first] == nil then options['inline_options'][flag][index][flag_first] = {} end
      table.insert(options['inline_options'][flag][index][flag_first], value)

      line = remove_flag_info_from_line(flag_first, val_last, line)
    end

    table.insert(parsed_lines, line)
  end

  return options, parsed_lines
end
-- removes the options from the dialog and adds them to options table
--
-- lines - String
--
-- parse_options(
--   '@TODD'$b=default$ remainder of text')
--  #=> { { "name" => "Todd", "background" => "default" ...}, "remainder of text" }
--
-- returns a table containing the parsed options, and the remaining lines of dialog
local function parse_options(lines)
  local name
  local options

  lines = parse_dialog(lines)
  name, lines = parse_name(lines)
  options, lines = parse_inline_options(lines)

  -- tried to collapse these lines but the options table would read as nil if I
  -- didn't save them to variables first
  options['name'] = name
  options['lines'] = lines

  return options
end

-- This function sorts through the conversation looking for the speakers
-- and the lines directly beneath them as their lines
-- speakers are noted by @ before the speaker name and === go beneath their last
-- line before another speaker starts talking
--
-- dialog - A dialog table (view the Solarus docs for info on what's in this table)
-- info - The info string. an optional argument which replaces the $v in the text

-- Example:
--   conversation_parser(
--     { 'id' = 'link.greeting', 'text' = '@Link ... === @Zelda Hand me that $v ===' },
--     'Jug of Milk')
--     #=>
--      {
--          id = 'link.greeting',
--          0 = {
--            'name' = 'Link',
--            'lines' = '...'
--          },
--          1 = {
--            'name' = 'Zelda',
--            'lines' = 'Hand me that Jug of Milk'
--          },
--      }
--
--  conversation_parser(
--    { 'id' = 'no_speaker.dialog', text = [['I have no speaker $v']] },
--    ":("
--  )
--  #=>
--    {
--      "id" = "no_speaker.dialog",
--      [{ "name" = "NO SPEAKER", "lines" = "I have no speaker :(" }]
--    }
--
-- Returns a table containing the id of the dialog mapped to the ordered speakers list
function conversation_manager:conversation_parser(dialog, info)
  local conversation_text = substitutions(dialog, info)

  local speaker_list = { id = dialog.id }

  -- if the user forgot put in a @ give them a default name
  if string.match(conversation_text, '^@.+$') == nil then
    conversation_text = '@NO SPEAKER\n'..conversation_text
  end

  -- if the user forgot put in a === we assume it's at end of the text
  if string.match(conversation_text, '%s*===%s*$') == nil then
    conversation_text = conversation_text..'\n==='
  end

  for speaker_lines in string.gmatch(conversation_text, "@.-===") do
    local speaker = parse_options(speaker_lines)

    table.insert(speaker_list, speaker)
  end

  return speaker_list
end

return conversation_manager
