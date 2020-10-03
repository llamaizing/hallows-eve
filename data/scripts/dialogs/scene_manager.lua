require("scripts/dialogs/libs/table_helpers")

-- scene manager handles the specific scene going on currently
-- In order to use it you must require then populate the conversation and config
-- attributes
scene_manager = {}

function scene_manager:create(game)
  local display_position = require("scripts/dialogs/libs/display_position")

  local scene = {
    conversation = nil, -- array containing the ordered list of speakers
    open = false, -- a variable to allow the vn manager to know when it's safe to start a new scene
    config = nil, -- contains scene configs (e.g. bg_config, character_config, etc)
    -- Creates and sets up the background
    background = require("scripts/dialogs/background"):create(game),
    -- Creates and sets up the characters for this scene
    characters = require("scripts/dialogs/character_manager"):create(game, display_position),
    -- Creates and sets up a dialog box for the specified game.
    dialog_box = require("scripts/dialogs/dialog_box/dialog_box_manager"):create(game, display_position),
  }

  -- This sets the scene dialog and display elements
  --
  -- conversation - A table of speakers (speakers are a character name and the text the speak)
  -- config - A table containing the scene config information
  --
  -- Example
  --   set_scene({'lines' => {...}})
  --
  -- Returns nothing
  function scene:set_scene(conversation, config)
    scene.conversation = conversation
    scene.config = config
  end

  -- Internal: Starts transitions
  --
  -- state - A string containing either 'enter' or 'exit'
  --
  -- Examples
  --   transition('enter')
  --
  --   transition('exit')
  --
  -- Returns nothing
  local function transition(state)
    scene.background:transition(state)
    scene.characters:transition(state)
    scene.dialog_box:transition(state)
  end

  -- Update the current scene
  --
  -- Returns nothing
  function scene:update()
    -- handle edge case where the scene is over but the dialog box hasn't closed
    -- yet. e.g. you set the close_delay to high number and the player spams the
    -- next button
    if scene:is_conversation_over() then return end
    scene.current_speaker = table.remove(scene.conversation, 1, 1)
    -- if no current speaker then scene is over
    if scene.current_speaker == nil then
      scene:stop()
      return
    end

    -- characters can overide dialog_box and backgrounds
    character_overrides = scene.config["characters"][scene.current_speaker['name']]

    dialog_box_config = (function() if character_overrides['dialog_box'] ~= nil then return recursive_merge(scene.config['dialog_box'], character_overrides['dialog_box']) else return scene.config['dialog_box'] end end)()
    scene.dialog_box:update(scene.current_speaker, dialog_box_config)

    background_config = (function() if character_overrides['background'] ~= nil then return recursive_merge(scene.config['background'], character_overrides['background']) else return scene.config['background'] end end)()
    scene.background:set_background(background_config)

    scene.characters:set_characters(scene.config['characters'], scene.dialog_box.box_graphic:get_box_surface())
  end

  function scene:is_conversation_over()
    if type(scene.conversation) ~= 'table' then return true else return false end
  end

  -- check the see if exit transition delay is greater then the  dialog box close delay if so update close close_delay_override
  --
  -- config: contains the exit tranistion dely
  --
  -- Example:
  -- close_delay_override({'delay'})
  --
  -- Reterns nothing
  function scene:transition_delay(state)
    config = scene.config
    delay = 0

    if scene.config ~= nil then 
      for _index, type in pairs({[1] = 'background', [2] = 'dialog_box'}) do
        if scene.config[type]['transitions'] ~= nil and scene.config[type]['transitions'][state] ~= nil and scene.config[type]['transitions'][state]['delay'] ~= nil then
          if scene.config[type]['transitions'][state]['delay'] > delay then delay = scene.config[type]['transitions'][state]['delay'] end
        end
      end

      if type(scene.characters) == 'table' and type(scene.characters.character_sprites) then
        for name, _object in pairs(scene.characters.character_sprites) do
          char_config = config['characters']
          if type(char_config) == 'table' and type(char_config[name]) == 'table' and type(char_config[name]['transitions']) == 'table' and type(char_config[name]['transitions'][state]) == 'table' and char_config[name]['transitions'][state]['delay'] ~= nil then
            if char_config[name]['transitions'][state]['delay'] > delay then delay = char_config[name]['transitions'][state]['delay'] end
          end
        end
      end
    end
    return delay * 30  -- * 30 to account for Solarus 30 fps
  end

  -- Stops the scene elements (not the scene object itself)
  --
  -- Example
  --   stop()
  --
  -- Returns nothing
  function scene:stop()
    delay = scene:transition_delay('exit')
    transition('exit')
    sol.timer.start(game, delay, function() 
      scene.dialog_box:stop(game)
      scene.open = false
    end)

    scene.conversation = nil
    scene.config = nil
  end

  -- Used to define custom commands. We pass it along if we find one and mark the even handled
  -- Otherwise we let the event continue propogating
  -- This is called by Solarus when user presses a key you shouldn't call it directly
  --
  -- Examples
  -- N/A
  --
  -- Returns boolean
  function scene:on_character_pressed(character)
    local handled = false
    if character == "h" then -- TODO probably need to find away to config the hide key
      scene:on_command_pressed("hide")
      handled = true
    end

    return handled
  end

  -- Called by the engine when dialog is active. Shouldn't be called by you
  --
  -- command - the command that was pressed
  --
  -- Examples:
  --   N/A
  --
  -- Returns true - to prevent command from propogating further down the object list
  function scene:on_command_pressed(command)
    if command == "action" then
      -- advance to next speaker if current speaker is finished
      if scene.dialog_box:text_finished() then scene:update() end
      if not scene:is_conversation_over() then scene.dialog_box:advance_text() end
    elseif command == "up" or command == "down" then
      scene.dialog_box:move_cursor(command)
    elseif command == "hide" then
      scene.dialog_box:hide()
    end

    return true
  end

  -- Called by the engine when sol.menu.start() is called on scene. Shouldn't be called by you
  --
  -- Examples:
  --   N/A
  --
  -- Returns nothing
  function scene:on_started()
    scene.open = true
    scene:update()
    sol.menu.start(scene, scene.background)
    sol.menu.start(scene, scene.characters)
    sol.menu.start(scene, scene.dialog_box)

    transition('enter')
    sol.timer.start(game, scene:transition_delay('enter'), function() scene.dialog_box:advance_text() end)
  end

  return scene
end

return scene_manager
