
return function(map)
  local routes = {"a", "b", "c"}
  for _, route in pairs(routes) do
    for treater in map:get_entities("sentry_treater_" .. route) do
      --find starting node
      local closest_node = nil
      local distance = 100000000
      for node in map:get_entities("waypoint_" .. route) do
        if treater:get_distance(node) < distance then
          distance = treater:get_distance(node)
          closest_node = node
        end
      end
      local node_number = closest_node:get_name():match("%d+")
      treater.current_node = node_number

      function treater:go_next_node()
        local m = sol.movement.create"target"
        m:set_speed(50)
        m:set_target(map:get_entity("waypoint_" .. route .. "_" .. treater.current_node))
        m:start(treater, function()
          treater.current_node = map:has_entity("waypoint_" .. route .. "_" .. treater.current_node + 1) and treater.current_node + 1 or 1
          treater:go_next_node()
        end)
      end

      treater:go_next_node()

      function treater:on_suspicion_lost()
        treater:go_next_node()
      end

    end
  end
end