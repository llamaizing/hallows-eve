local object_meta = sol.main.get_metatable"carried_object"

object_meta:register_event("on_position_changed", function(self)
  local object = self
  if object:get_distance(object:get_map():get_hero()) < 19 and not object.object_has_been_thrown then
    local x, y, z = object:get_position()
    object:set_position(x, y - 8, z)
  end
end)

object_meta:register_event("on_thrown", function(self)
  local object = self
  object.object_has_been_thrown = true
end)

return true