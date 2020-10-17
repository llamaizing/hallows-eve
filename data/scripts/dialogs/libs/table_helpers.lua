local table_helpers = {}
--from http://lua-users.org/wiki/CopyTable
local deepcopy
deepcopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- This helper function recursively merges to tables together. Overwriting t1 values with those of t2
--
-- t1 - the table containing values that will be overwritten with values from the t2.
-- t2 - the table containging values to overwrite t1 with
--
-- Example
--    recursive_merge(
--      { outer_table = { inner_table = { mv_val1 = 7, my_val2 = 2 } } },
--      { outer_table = { inner_rable = { my_va11 = 1, my_val3 = 3 } } }
--    )
--    #=> { outer_table = { inner_table = { my_val1 = 1, my_val2 = 2, my_val3 = 3 } } }
--
-- Returns a table containing the merged values
function table_helpers:recursive_merge(t1, t2)
  local t1_copy = deepcopy(t1)

  local recursive_merge2
  recursive_merge2 = function(t1_dup, t2_dup)
    for k,v in pairs(t2_dup) do
      if type(v) == "table" then
        if type(t1_dup[k] or false) == "table" then
          recursive_merge2(t1_dup[k] or {}, v)
        else
          t1_dup[k] = deepcopy(v)
        end
      else
        t1_dup[k] = v
      end
    end
    return t1_dup
  end

  return recursive_merge2(t1_copy, t2)
end

return table_helpers
