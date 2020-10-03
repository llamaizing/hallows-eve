-- Provides a handy wrapper around hardcoded required paths.
-- This is to make it easy to update the paths without having
-- to track down each hardcoded path

-- returns base config path.
function config_path()
  return "scripts/dialogs/configs"
end

-- returns the path to all the visual novel sprites.
function sprite_path()
  return "visual_novel"
end
-- returns the base path to the character configs
function character_config_path()
  return config_path().."/characters"
end

-- returns the base path to the character sprites
function character_sprite_base_directory_path()
  return sprite_path().."/characters"
end

-- returns the base path to the scene configs
function scene_config_path()
  return config_path().."/scenes"
end