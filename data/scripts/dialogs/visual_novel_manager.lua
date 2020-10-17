-- This class handles all elements on screen during a dialog.
-- (dialog_box, name_box, sprites, sounds, etc)
local conversation_manager = require("scripts/dialogs/conversation_manager")
local config_loader = require("scripts/dialogs/libs/config_loader")
local table_helper = require("scripts/dialogs/libs/table_helpers")
require("scripts/multi_events")

local  transition_manager = require("scripts/dialogs/libs/transitions")

local function initialize_vn(game)
  -- Creates a scene object
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
    local scene_config = {}
    scene_config['characters'] = config_loader:load_default_character_configs(conversation_manager:get_unique_speakers(conversation))
    scene_config = table_helper:recursive_merge(scene_config, config_loader:load_scene_config(conversation.id))

    return scene_config
  end

  -- Initalize scene when dialog is started
  -- Solarus passes args to this function which we capture with the inner function.
  -- See the Solarus docs for info on them
  game:register_event("on_dialog_started", function(game_obj, dialog, info)
    local conversation = conversation_manager:conversation_parser(dialog, info)

    local delay = scene_manager:transition_delay('exit')
    transition_manager:transition('exit')
    sol.timer.start(game_obj, delay + 10, function() -- gave an extra 10 miliseconds for scene to wrap up past it's close
      scene_manager:set_scene(conversation, load_scene(conversation))
      sol.menu.start(game_obj, scene_manager)
    end)
  end)

  -- Stop scene when dialog is finished
  -- Solarus passes args to this function which we capture with the inner function.
  -- See the Solarus docs for info on them
  game:register_event("on_dialog_finished", function(_, _)
    sol.menu.stop(scene_manager)
  end)
end

-- Start the visual novel system when the game starts
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialize_vn)
