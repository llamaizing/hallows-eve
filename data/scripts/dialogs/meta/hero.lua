local hero_meta = sol.main.get_metatable("hero")
local hero = nil
local sprite = nil
local locked_direction
local locked_stopped_animation
local locked_walking_animation

-- Initializes functions used by the hero when it's created
--
-- Example
-- N/A
-- Returns nothing
function hero_meta:on_created()
  hero = self
  hero:set_tunic_sprite_id("hero/tunic1")
  hero:initialize_lock_direction_functions() -- Used to fix direction and animations.
end

-- Function sets varables to lock the hero in a direction
--
-- stopped_animation - contains the name of the stopped animation
-- walking_animation - contains the name of the walking animation
-- direction - contains the directions number the hero is locked to
--
-- Example
--   lock_direction("bow_stopped","bow_walking", 2)
--
-- Returns nothing
function hero_meta:lock_direction(stopped_animation, walking_animation, direction)
  locked_direction = direction
  locked_stopped_animation = stopped_animation
  locked_walking_animation = walking_animation
end

-- Initialize the lock direction functions needed to keep the hero facing a fixed direction.
--
-- Example
-- N/A
-- Return nothing
function hero_meta:initialize_lock_direction_functions()
  sprite = hero:get_sprite("tunic")

  -- When the hero animation changes checks and changes the animation if locked direction
  --
  -- _animation - Name of the new animation (Varable not used)
  -- Example
  -- N/A
  -- Return nothing
  function sprite:on_animation_changed(_)
    local current_animation = sprite:get_animation()
    if current_animation == "stopped" and locked_stopped_animation ~= nil and locked_stopped_animation ~= current_animation then
        sprite:set_animation(locked_stopped_animation)
    elseif current_animation == "walking" and locked_walking_animation ~= nil and locked_walking_animation ~= current_animation then
        sprite:set_animation(locked_walking_animation)
    end
  end

  -- When the hero's direction changes, change it back to the locked direction if it's set
  --
  -- tunic_direction - is the current direction the hero is facing
  -- Example
  -- N/A
  -- Returns nothing
  function sprite:on_direction_changed(_, _)
    local tunic_direction = sprite:get_direction()
    if locked_direction ~= nil and locked_direction ~= tunic_direction then
      sprite:set_direction(locked_direction)
    end
  end
end

return true