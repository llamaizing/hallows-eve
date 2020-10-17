-- Checks if file exists
-- file - path to the file (including file name)
--
-- Example:
--  is_module_available('scripts/config/default.lua')
--     true
--
local directories_and_files = {}

function directories_and_files:is_module_available(name)
  if package.loaded[name] then
    return true
  else
    for _, searcher in ipairs(package.searchers or package.loaders) do
      local loader = searcher(name)
      if type(loader) == 'function' then
        package.preload[name] = loader
        return true
      end
    end
    return false
  end
end

return directories_and_files
