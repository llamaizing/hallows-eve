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
function compute_position(object_to_compute, position, window_object)
  position = position or 'center'

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
  width, height = 0,0
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
  width, height = get_object_size(window)
  if width == 0 and height == 0 then width, height = sol.video.get_quest_size() end
  return width, height
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
function get_origin(object)
  origin_x, origin_y = 0,0
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
function get_xy(object)
  x, y = 0,0

  if object ~= nil and object['get_xy'] ~= nil then x, y = object:get_xy() end

  return x, y
end

-- Finds xy coordinates that ensures that the image appears at the left 
-- corner of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function left(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  return origin_x + window_x, (window_height - (object_height - origin_y)) + window_y
end

-- Finds xy coordinates that ensures that the image appears at the right 
-- corner of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function right(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = window_width - (object_width - origin_x) + window_x
  y = (window_height - (object_height - origin_y)) + window_y
  
  return x,y
end

-- Finds xy coordinates that ensures that the image appears at the bottom 
-- center of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function center(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = ((window_width - object_width)/2) + origin_x + window_x
  y = (window_height - (object_height - origin_y)) + window_y

  return x,y
end

-- Finds xy coordinates that ensures that the image appears at the top 
-- left corner of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function topleft(object, window)
  window_x, window_y = get_xy(window)
  origin_x, origin_y = get_origin(object)

  return origin_x + window_x, origin_y + window_y
end

-- Finds xy coordinates that ensures that the image appears at the top 
-- right corner of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function topright(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = window_width - (object_width - origin_x) + window_x

  return x, origin_y + window_y
end

-- Finds xy coordinates that ensures that the image appears at the top 
-- of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function top(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = ((window_width - object_width)/2) + origin_x + window_x

  return x, origin_y + window_y
end

-- Finds xy coordinates that ensures that the image appears at the exact 
-- center of the screen.
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function truecenter(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = ((window_width - object_width)/2) + origin_x + window_x
  y = ((window_height - object_height)/2) + origin_y + window_y

  return x,y
end

-- Finds xy coordinates for object to appear outside top left of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function outsidetopleft(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = origin_x + window_x

  return x, window_y - object_height + origin_y
end

-- Finds xy coordinates for object to appear outside top center of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function outsidetop(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = ((window_width - object_width)/2) + origin_x + window_x

  return x, window_y - object_height + origin_y
end

-- Finds xy coordinates for object to appear outside top right of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function outsidetopright(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = window_width - (object_width - origin_x) + window_x

  return x, window_y - object_height + origin_y
end

-- Finds xy coordinates for object to appear outside bottom left of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function outsidebottomleft(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  return origin_x + window_x, window_y + window_height + origin_y
end

-- Finds xy coordinates for object to appear outside bottom center of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function outsidebottom(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = ((window_width - object_width)/2) + origin_x + window_x

  return x, window_y + window_height + origin_y
end

-- Finds xy coordinates for object to appear outside bottom left of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function outsidebottomright(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = window_width - (object_width - origin_x) + window_x

  return x, window_y + window_height + origin_y
end

-- Finds xy coordinates for object to appear outside left of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function outsideleft(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = window_x - origin_x - object_width
  y = (window_height - object_height) + origin_y + window_y

  return x, y
end

-- Finds xy coordinates for object to appear outside right of the box
--
-- object - the object we are finding the postion for
-- window - the object we calcing relative to.
--
-- Returns the x and y coordinates for the object
function outsideright(object, window)
  window_x, window_y = get_xy(window)
  window_width, window_height = get_window_size(window)
  object_width, object_height = get_object_size(object)
  origin_x, origin_y = get_origin(object)

  x = window_x + window_width
  y = (window_height - object_height) + origin_y + window_y

  return x, y
end
