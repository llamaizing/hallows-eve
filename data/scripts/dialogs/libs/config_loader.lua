local config_loader = {}
local path_manager = require("scripts/dialogs/libs/paths")
local table_helper = require("scripts/dialogs/libs/table_helpers")
local directories_and_files = require('scripts/dialogs/libs/directories_and_files')

  -- loads the scene configuration. It does so by first loading the default then layering
  -- the options of the dialog name. Ex. After the default config is loaded. Assume that the
  -- id is "hero.greetings.friends.emily" first it will check the hero folder and apply
  -- any configs it finds there, then greetings, than friends, than emily. If no more specific
  -- folder is found it will stop.
  --
  -- id - String which is the dialog id
  --
  -- Example:
  --   load_scene_config('hero.greeting')
  --     #=> {}
  function config_loader:load_scene_config(id)
    -- load scene defaults if they exist
    local scene_config = {}

    if directories_and_files:is_module_available(path_manager:scene_config_path().."/default.lua") then
      scene_config = require(path_manager:scene_config_path().."/default.lua")
    end

    -- iterate down through scene groups and add or override the defaults
    local current_path = ""
    for w in (id .. "."):gmatch("([^.]*)") do
      current_path = current_path.."/"..w
      if directories_and_files:is_module_available(path_manager:scene_config_path()..current_path.."/config.lua") then
        local config = require(path_manager:scene_config_path()..current_path.."/config.lua")
        scene_config = table_helper:recursive_merge(scene_config, config)
      end
    end

    -- This error means that you probably messed up your paths.
    if next(scene_config) == nil then error("No Configuration Info Found For Scene: ".. id) end

    return scene_config
  end

  -- Load character config
  -- e.g. sprite information, position, etc.
  local function load_character_config(name)
    name = name:lower()
    local character = {}

    -- load specific character info if it exists
    if directories_and_files:is_module_available(path_manager:character_config_path().."/"..name..".lua") then
      for k,v in pairs(require(path_manager:character_config_path().."/"..name..".lua")) do character[k] = v end
    end

    return character
  end

  -- Loads default configs for all passed in characters
  --
  -- characters - Array of character names
  --
  -- Example:
  --   load_default_chacter_configs(['smith', 'noah', 'alexis'])
  --     => { 'smith' => { 'sprite' => 'default', 'tansition' => 'enter_right', etc } }
  --
  -- Returns a table of character information (sprite, position, transitions, etc.)
  function config_loader:load_default_character_configs(characters)
    local character_configs = {}

    for count = 1, #characters do
      local character = characters[count]
      local attributes = load_character_config(character)
      -- these steps are crap but we have to ensure all values are wiped after every run
      local config = {}
      for k, v in pairs(attributes) do config[k] = v end
      character_configs[character] = config
    end

    return character_configs
  end

  return config_loader
