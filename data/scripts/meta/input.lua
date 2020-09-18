require"scripts/multi_events"

--Return direction 0-7 of fist two joypad axis (should be left stick), or nil if no direction
function sol.input.get_left_stick_direction8()
  --Axis 0 = left stick x-axis, axis 1 = left stick y axis
  local ax0 = sol.input.get_joypad_axis_state(0)   
  local ax1 = sol.input.get_joypad_axis_state(1)
  local coords = ax0 .. "," .. ax1
  local angletable = {["1,0"] = 0, ["1,-1"] = 1, ["0,-1"] = 2, ["-1,-1"] = 3, ["-1,0"] = 4,
  ["-1,1"] = 5, ["0,1"] = 6, ["1,1"] = 7, ["0,0"] = nil}

  return angletable[coords]
end
