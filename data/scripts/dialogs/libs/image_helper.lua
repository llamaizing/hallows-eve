-- -- figures out what the image is and creates it using passed in config

local image_helper = {}

-- Internal: Provides a character sprite using the config information
--
-- config - This is the config for the sprite
--
-- Example
--   config = { 'image_path' => 'path/to/a/sprite', sprite = { 'animation' => 'animation/name', 'direction' => number }, ... }
--
--   load_sprite(config)
--     #=> sol.sprite
--
-- Returns a sol.sprite object
local function load_sprite(config)
  local sprite = sol.sprite.create(config['path'])

  if config['sprite'].animation ~= nil and sprite:get_animation() ~= config['sprite'].animation then
    sprite:set_animation(config['sprite'].animation)
  end

  if config['sprite'].direction ~= nil and sprite:get_direction() ~= config['sprite'].direction then
    sprite:set_direction(config['sprite'].direction)
  end

  return sprite
end

-- Internal: Provides a character image using the config information
--
-- config - This is the config for the character image
--
-- Example
--  load_image({ 'image_path' => 'path/to/a/image', ...})
--    #=> sol.surface
--
-- Returns sol.surface object
local function load_image(config)
  if config['path'] then return sol.surface.create(config['path']) end
end

-- Public: gets the image from the passed in config
--
-- config - a table containing options
--
-- Example:
--   get_image({'path' = '/path/to/image'})
--     #=> sol.surface
--
--   get_image({'path' = '/path/to/image', sprite => {...}})
--     #=> sol.sprite
--
-- Returns nothing
function image_helper:get_image(config)
  if type(config) ~= 'table' then return end

  if type(config['sprite']) == 'table' then
    return load_sprite(config)
  else
    return load_image(config)
  end
end

return image_helper