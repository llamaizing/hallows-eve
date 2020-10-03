local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_spin_kick")
  item:set_assignable(true)
end

function item:on_using()
  local map = item:get_map()
  local hero = map:get_hero()
  local slot_assigned = (game:get_item_assigned(1) == item and 1) or 2
  hero:start_attack_loading(0)
  item:set_finished()
end


