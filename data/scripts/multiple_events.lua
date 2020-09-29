-- Script that allows you to specify multiple callbacks for Solarus events

-- Usage:
-- local multiple_events = require("scripts/multiple_events")
--
-- Once you've required it all Solarus Object will automatically
-- have the register_event functionality added to it.
--
-- Check the register_event function for more info
--
-- You can also add register_event functionality to lua objects
-- Check the register_callback function docs for more info
--
-- NOTE: You can still register a callback via the Solarus way e.g.
--  function game:on_started()
--   ...
--  end
--
-- BUT YOU CANNOT USE THIS SCRIPT AND THE SOLARUS CALLBACK ON THE SAME OBJECT

local multiple_events = {}
-- A function wrapper which will add the callback to the list of callbacks
-- to be called when the event is triggered.
--
-- object - The solarus object/lua table the callback is specified on
-- event_name - A string containing the event to listen for
-- callback - the function object to call
--
-- Examples:
--   game:register_event("on_started", my_function)
--
--   game_meta:register_event("on_started", another_function)
--
-- Returns nothing
local function register_event(object, event_name, callback)
  local previous_callbacks = object[event_name] or function() end
  object[event_name] = function(...)
    return previous_callbacks(...) or callback(...)
  end
end

-- Adds register_event functionality to a lua object.
--
-- object (userdata, userdata metatable or table)
--
-- Examples:
--   multiple_events:register_callback(sol.main)
--
-- Returns nothing
function multiple_events:register_callback(object)
  object.register_event = register_event
end

local solarus_objects = {
  "arrow",
  "block",
  "bomb",
  "boomerang",
  "carried_object",
  "camera",
  "chest",
  "circle_movement",
  "crystal",
  "crystal_block",
  "custom_entity",
  "destination",
  "destructible",
  "door",
  "dynamic_tile",
  "enemy",
  "explosion",
  "fire",
  "game",
  "hero",
  "hookshot",
  "item",  
  "jumper",
  "jump_movement",
  "map",
  "movement",
  "npc",
  "path_finding_movement",
  "path_movement",
  "pickable",
  "pixel_movement",
  "random_movement",
  "random_path_movement",
  "sensor",
  "separator",
  "shop_treasure",
  "sprite",
  "stairs",
  "stream",
  "straight_movement",
  "surface",
  "switch",
  "target_movement",
  "teletransporter",
  "text_surface",
  "timer",
  "wall"
}

-- Add register_event function to all solarus_objects.
for _, object in ipairs(solarus_objects) do
  local meta = sol.main.get_metatable(object)
  if meta ~= nil then multiple_events:register_callback(meta) end
end

-- needed to listen for sol.main callbacks (just here a niceity)
multiple_events:register_callback(sol.main)

return multiple_events
