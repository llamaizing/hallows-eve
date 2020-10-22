local manager = {}

manager.keyboard_bindings = {
  up = "up",
  down = "down",
  left = "left",
  right = "right",
  action = "space",
  attack = "c",
  pause = "d",
  item_1 = "item_1",
  item_2 = "item_2",
}

manager.joypad_bindings = {
  up = "up",
  down = "down",
  left = "left",
  right = "right",
  action = "space",
  attack = "c",
  pause = "d",
  item_1 = "item_1",
  item_2 = "item_2",
}


function sol.main:get_command_keyboard_binding(command)
print("Command = ", command)
  return manager.command_bindings[command]
end

function sol.main:set_command_keyboard_binding(command, key)
  --nothing
end

function sol.main:get_command_joypad_binding(command)
  return "space"
end

function sol.main:set_command_joypad_binding(command, key)
  --nothing
end

function sol.main:capture_command_binding(command, callback)

end

return manager