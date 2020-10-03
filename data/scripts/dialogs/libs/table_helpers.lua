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
function recursive_merge(t1, t2)
  for k,v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        recursive_merge(t1[k] or {}, t2[k] or {})
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end
