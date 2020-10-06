-- This class handles all elements on screen during a dialog.
-- (dialog_box, name_box, sprites, sounds, etc)
require("scripts/dialogs/conversation_manager")
require("scripts/dialogs/libs/config_loader")
require("scripts/dialogs/libs/table_helpers")
require("scripts/multi_events")

local function initialize_vn(game)
  -- Creates a scene object if one doesn't already exist
  if scene_manager ~= nil then return end
  local scene_manager = require("scripts/dialogs/scene_manager"):create(game)


  -- Loads all the information for the scene manager to do his job
  -- e.g. which background, characters, transitions, etc
  -- Priority is conversation > scene_config > character_config
  --
  -- Which means that you CAN specify character attributes (sprites and the like) in the
  -- scene config and that will overwrite the character config
  --
  -- conversation - The raw dialog table that Solarus gives us. We use it's attributes
  --                to determine what configs to load and what to populate them with
  -- 
  -- Example:
  --   load_scene({ 
  --     'name' = 'Todd', 
  --     'dialog_id' = 'todd.greeting',  
  --     ... 
  --   })
  --   #=> { 
  --    'background' = 'starry_night', 
  --    'characters' = { CHARACTER CONFIGURATIONS }, 
  --    ... 
  --   }
  --
  -- Returns a table containing the config that the scene will use.
  local function load_scene(conversation)
    scene_config = {}
    scene_config['characters'] = load_default_character_configs(get_unique_speakers(conversation))
    scene_config = recursive_merge(scene_config, load_scene_config(conversation.id))

    return scene_config
  end

  -- Initalize scene when dialog is started
  -- Solarus passes args to this function which we capture with the inner function. 
  -- See the Solarus docs for info on them
  game:register_event("on_dialog_started", function(game, dialog, info)
    conversation = conversation_parser(dialog, info)
    
    delay = scene_manager:transition_delay('exit')
    transition('exit')
    sol.timer.start(game, delay + 10, function() -- gave an extra 10 miliseconds for scene to wrap up past it's close
      scene_manager:set_scene(conversation, load_scene(conversation))
      sol.menu.start(game, scene_manager)
    end)  
  end)

  -- Stop scene when dialog is finished
  -- Solarus passes args to this function which we capture with the inner function. 
  -- See the Solarus docs for info on them
  game:register_event("on_dialog_finished", function(game, dialog)
    sol.menu.stop(scene_manager)
  end)
end

-- Start the visual novel system when the game starts
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialize_vn)
