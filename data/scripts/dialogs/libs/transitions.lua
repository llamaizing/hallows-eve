-- This class handles transitions between elements on screen
-- (dialog_box, name_box, sprites, sounds, etc)

-- Internal: Applies fade transition to display objects in accordance to the config file
--
-- object: The display object the fade transition will be applied to
-- config: Contains information on what type of fade effect and it's duration
--
-- Example:
-- fade(object, {"type", "delay"})
--
-- Reterns nothing
local function fade(object, config)
  if config['type'] == 'fade_in' then object:fade_in(config['delay']) elseif config['type'] == 'fade_out' then object:fade_out(config['delay']) end
end

-- Internal: applies movement to an object
--
-- object - a sol.surface or sol.sprite object
-- movement_type - a string containing the type of movement to use (list available in solarus documentation)
-- angle - a number containing the angle to move on
-- distance - the distance to move the object
-- speed - how fast to move the object
--
-- Example:
--  move(sol.sprite, 'straight', 12.3, 34, 55)
--
--  move(sol.surface, 'straight', 12.3, 34, 55)
--
-- Returns nothing
local function move(object, movement_type, angle, distance, speed)
  movement = sol.movement.create(movement_type)
  movement:set_angle(angle)
  movement:set_max_distance(distance)
  movement:set_speed(speed)
  movement:start(object)
end

-- Internal: Does the slide transition for any object displayed on screen
--
-- object: Display object the slide transition will be applied to
-- config: contain the direction the object  and the duration of the slide transition
--
-- Example:
-- slide(object,{'type','delay','slide_direction'})
--
-- Returns nothing
local function slide(object, config)
    x,y = object:get_xy()
    screen_width, screen_height = sol.video.get_quest_size()
    width,height = object:get_size()
    angle = 0
    distance = 0

  if config['slide_direction'] == 'right' then
    angle = 0 --West
    if config['type'] == 'slide_in' then
      object:set_xy(-width,y)
      distance = width + x
    elseif config['type'] == 'slide_out' then distance = screen_width - x end
  end

  if config['slide_direction'] == 'left' then
    angle = math.pi -- East
    if config['type'] == 'slide_in' then
      object:set_xy(screen_width,y)
      distance = screen_width - x
    elseif config['type'] == 'slide_out' then distance = width + x end
  end

  if config['slide_direction'] == 'up' then
    angle = math.pi/2 -- North
    if config['type'] == 'slide_in' then
      object:set_xy(x,screen_height)
      distance = screen_height - y
    elseif config['type'] == 'slide_out' then distance = height + y end
  end

  if config['slide_direction'] == 'down' then
    angle = 3 * math.pi/2 -- South
    if config['type'] == 'slide_in'then
      object:set_xy(x,-height)
      distance = height + y
    elseif config['type'] == 'slide_out' then distance = screen_height - y end
  end

  move(object, 'straight', angle, distance, distance/(config['delay']*30/1000))
end

-- Public: Used to determining which transition function need to be called
--
-- state: determins in this is a enter transition or an exit transition
-- object: the display object the transition will be applied to 
-- config: contains the config data for all display objects in the scene
--
-- Example:
-- set_transition('enter',object,{'type'})
--
-- Reterns nothing
function transition(state, object, config)
  transitions = {
    ['fade_in'] = fade,
    ['fade_out'] = fade,
    ['slide_in'] = slide,
    ['slide_out'] = slide,
  }

  if type(config) ~= "table" or type(config[state]) ~= "table" or type(config[state]['type']) ~= "string" then return end
  transitions[config[state]['type']](object, config[state])
end
