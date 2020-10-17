--[[
This file provides a short hand so you don't have to manually specify an x/y for every image

Using the window xy. This computes the realitive position for the passed in object
Below are all the positions that can be used:

            outsidetopleft            outsidetop         outsidetopright
            +-----------------------------------------------------------+
            |topleft, reset               top                   topright|
            |                                                           |
            |                                                           |
            |                                                           |
            |                                                           |
outsideleft |                          truecenter                       | outsideright
            |                                                           |
            |                                                           |
            |                                                           |
            |                                                           |
            |left                   center, default                right|
            +-----------------------------------------------------------+
            outsidebottomleft        outsidebottom    outsidebottomright

]]

local display_position = {}

-- gets size of object (if exists)
--
-- object the object to get the size for
--
-- Example:
--   get_object_size(sol.sprite.new())
--     #=> 123,67
--
--   get_object_size('invalid object')
--     #=> 0,0
--
-- Returns a pair of integers
local function get_object_size(object)
  local width, height = 0,0
  if object ~= nil and object['get_size'] ~= nil then width, height = object:get_size() end

  return width, height
end

-- gets size of object (if exists)
--
-- object the object to get the size for
--
-- Example:
--   get_window_size(sol.sprite.new())
--     #=> 123,67
--
--   get_window_size('invalid object')
--     #=> size of quest window
--
-- Returns a pair of integers
local function get_window_size(window)
  local width, height = get_object_size(window)
  if width == 0 and height == 0 then width, height = sol.video.get_quest_size() end
  return width, height
end

-- Finds xy coordinates that ensures that the image appears at the left
-- corner of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function left(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local _, window_height = get_window_size(window)
  local _, object_height = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  return origin_x + window_x, (window_height - (object_height - origin_y)) + window_y
end

-- Finds xy coordinates that ensures that the image appears at the right
-- corner of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function right(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, window_height = get_window_size(window)
  local object_width, object_height = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = window_width - (object_width - origin_x) + window_x
  local y = (window_height - (object_height - origin_y)) + window_y

  return x,y
end

-- Finds xy coordinates that ensures that the image appears at the bottom
-- center of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function center(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, window_height = get_window_size(window)
  local object_width, object_height = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = ((window_width - object_width)/2) + origin_x + window_x
  local y = (window_height - (object_height - origin_y)) + window_y

  return x,y
end

-- Finds xy coordinates that ensures that the image appears at the top
-- left corner of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function topleft(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local origin_x, origin_y = display_position:get_origin(object)

  return origin_x + window_x, origin_y + window_y
end

-- Finds xy coordinates that ensures that the image appears at the top
-- right corner of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function topright(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, _ = get_window_size(window)
  local object_width, _ = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = window_width - (object_width - origin_x) + window_x

  return x, origin_y + window_y
end

-- Finds xy coordinates that ensures that the image appears at the top
-- of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function top(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, _ = get_window_size(window)
  local object_width, _ = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = ((window_width - object_width)/2) + origin_x + window_x

  return x, origin_y + window_y
end

-- Finds xy coordinates that ensures that the image appears at the exact
-- center of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function truecenter(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, window_height = get_window_size(window)
  local object_width, object_height = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = ((window_width - object_width)/2) + origin_x + window_x
  local y = ((window_height - object_height)/2) + origin_y + window_y

  return x,y
end

-- Finds xy coordinates for object to appear outside top left of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function outsidetopleft(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local _, object_height = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = origin_x + window_x

  return x, window_y - object_height + origin_y
end

-- Finds xy coordinates for object to appear outside top center of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function outsidetop(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, _ = get_window_size(window)
  local object_width, object_height = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = ((window_width - object_width)/2) + origin_x + window_x

  return x, window_y - object_height + origin_y
end

-- Finds xy coordinates for object to appear outside top right of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function outsidetopright(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, _ = get_window_size(window)
  local object_width, object_height = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = window_width - (object_width - origin_x) + window_x

  return x, window_y - object_height + origin_y
end

-- Finds xy coordinates for object to appear outside bottom left of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function outsidebottomleft(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local _, window_height = get_window_size(window)
  local origin_x, origin_y = display_position:get_origin(object)

  return origin_x + window_x, window_y + window_height + origin_y
end

-- Finds xy coordinates for object to appear outside bottom center of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function outsidebottom(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, window_height = get_window_size(window)
  local object_width, _ = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = ((window_width - object_width)/2) + origin_x + window_x

  return x, window_y + window_height + origin_y
end

-- Finds xy coordinates for object to appear outside bottom left of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function outsidebottomright(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, window_height = get_window_size(window)
  local object_width, _ = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = window_width - (object_width - origin_x) + window_x

  return x, window_y + window_height + origin_y
end

-- Finds xy coordinates for object to appear outside left of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function outsideleft(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local _, window_height = get_window_size(window)
  local object_width, object_height = get_object_size(object)
  local origin_x, origin_y = display_position:get_origin(object)

  local x = window_x - origin_x - object_width
  local y = (window_height - object_height) + origin_y + window_y

  return x, y
end

-- Finds xy coordinates for object to appear outside right of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
local function outsideright(object, window)
  local window_x, window_y = display_position:get_xy(window)
  local window_width, window_height = get_window_size(window)
  local _, object_height = get_object_size(object)
  local _, origin_y = display_position:get_origin(object)

  local x = window_x + window_width
  local y = (window_height - object_height) + origin_y + window_y

  return x, y
end

-- Determines which function to call based on the passed in position
--
-- object_to_compute - the object we are finding the postion for
-- position - The string name of the position (Listed in the picture above)
-- window_object - the object we calcing relative to.
--
-- Examples:
--   compute_position(sol.surface.new(), 'center', sol.sprite.new())
--     #=> 0,200
--
-- Returns the xy coordinates
function display_position:compute_position(object_to_compute, position, window_object)
  -- If you'd like to make your own custom position you can add them to the positions list here,
  -- Then add the function in this file
  -- then you should be able to use them in your config files.
  local positions = {
      ['left'] = left,
      ['center'] = center,
      ['default'] = center,
      ['right'] = right,
      ['truecenter'] = truecenter,
      ['topleft'] = topleft,
      ['reset'] = topleft,
      ['top'] = top,
      ['topright'] = topright,
      ['outsidetopleft'] = outsidetopleft,
      ['outsidetop'] = outsidetop,
      ['outsidetopright'] = outsidetopright,
      ['outsidebottomleft'] = outsidebottomleft,
      ['outsidebottom'] = outsidebottom,
      ['outsidebottomright'] = outsidebottomright,
      ['outsideleft'] = outsideleft,
      ['outsideright'] = outsideright,
  }

  local func = positions[position:lower()]
  if(func) then
    return func(object_to_compute, window_object)
  else
    return center(object_to_compute, window_object)
  end
end

-- gets origin of object (if exists)
--
-- object the object to get the origin for
--
-- Example:
--   get_origin(sol.sprite.new())
--     #=> 123,67
--
--   get_origin('invalid object')
--     #=> 0,0
--
-- Returns a pair of integers
function display_position:get_origin(object)
  local origin_x, origin_y = 0,0
  if object ~= nil and object['get_origin'] ~= nil then origin_x, origin_y = object:get_origin() end
  return origin_x, origin_y
end

-- gets xy of object (if exists)
--
-- object the object to get the xy for
--
-- Example:
--   get_xy(sol.sprite.new())
--     #=> 123,67
--
--   get_xy('invalid object')
--     #=> 0,0
--
-- Returns a pair of integers
function display_position:get_xy(object)
  local x, y = 0,0

  if object ~= nil and object['get_xy'] ~= nil then x, y = object:get_xy() end

  return x, y
end

return display_position