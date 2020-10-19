local validator = {}

--From Llamazing: https://gitlab.com/llamazing/solarus-scripts/-/blob/master/data/scripts/settings.lua
--GPLv3
--// Loads settings values from file into memory (creates new file if does not exist)
	--call one time initially in main.lua, behaves similarly to sol.main.load_settings()
function validator:is_valid(file_name)
	data = {} --clear any existing data
	
  local env = setmetatable({}, {__newindex = function(self, key, value)
		data[key] = value
	end})
	
	local chunk = sol.main.load_file(file_name)

  if chunk == nil then return false end

	setfenv(chunk, env)
	local status, err = pcall(chunk)
  return status
end

return validator