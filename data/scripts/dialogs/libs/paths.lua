-- Provides a handy wrapper around hardcoded required paths.
-- This is to make it easy to update the paths without having
-- to track down each hardcoded path

local paths = {}

-- returns base config path.
function paths:config_path()
  return "scripts/dialogs/configs"
end

-- returns the path to all the visual novel sprites.
function paths:sprite_path()
  return "visual_novel"
end
-- returns the base path to the character configs
function paths:character_config_path()
  return paths:config_path().."/characters"
end

-- returns the base path to the character sprites
function paths:character_sprite_base_directory_path()
  return paths:sprite_path().."/characters"
end

-- returns the base path to the scene configs
function paths:scene_config_path()
  return paths:config_path().."/scenes"
end

return paths
