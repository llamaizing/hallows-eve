require("scripts/dialogs/libs/paths")
require("scripts/dialogs/libs/table_helpers")

-- Loads JSON files
--
-- file - the json filepath to load (relative to project)
--
-- Example:
--   load_json('scripts/dialogs/configs/scenes/cabin/entrance/config.json')
--       #=> {'background' => {...}, 'dialog_box' => {...}, ...}
--
-- Returns a table of the parsed JSON data
local function load_json(file)
  json = require("scripts/dialogs/libs/lunajson/lunajson.lua")
  local file = sol.file.open(file, "r" )
  if file ~= nil then
    local contents = file:read( "*a" )
    myTable = json.decode(contents)
    io.close( file )

    return myTable
  end
  return {}
end

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
  function load_scene_config(id)    
    local scene_config = {}

  -- load scene defaults
    scene_config = load_json(scene_config_path().."/default.json")

    -- iterate down through scene groups and add or override the defaults
    local current_path = ""
    for w in (id .. "."):gmatch("([^.]*)") do
      current_path = current_path.."/"..w
      config = load_json(scene_config_path()..current_path.."/config.json")
      scene_config = recursive_merge(scene_config, config)
    end

    -- This error means that you probably messed up your paths.
    if next(scene_config) == nil then print("WARNING: No Configuration Info Found For Scene: ".. id) end

    return scene_config
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
  function load_default_character_configs(characters)
    character_configs = {}

    for count = 1, #characters do
      name = characters[count]
      character_configs[name] = load_json(character_config_path().."/"..name:lower()..".json")
    end

    for name, attributes in pairs(character_configs) do
      -- load character defaults. e.g. attributes that we wish to include in every character
      -- (characters can override these if they wish)
      -- We have to reload the default everytime because lua seems to have problems letting go of
      -- old data
      default = load_json(character_config_path().."/".."default.json")
      character_configs[name] = recursive_merge(default, load_json(character_config_path().."/"..name..".json"))
    end

    return character_configs
  end
