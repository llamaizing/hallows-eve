local manager = {}

function sol.main.get_command_keyboard_binding(command)
  return "space"
end

function sol.main.set_command_keyboard_binding(command, key)
  --nothing
end

function sol.main.get_command_joypad_binding(command)
  return "space"
end

function sol.main.set_command_joypad_binding(command, key)
  --nothing
end

function sol.main:capture_command_binding(command, callback)

end

return manager