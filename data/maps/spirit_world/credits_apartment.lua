local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level({230,200,230})
  
  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/dust_1.png", mode = "blend", opacity = 60},
  	opacity_range = {40,100},
    drift = {10, 0, -1, 1}
  }
  --sol.menu.start(map, fog2)


  game:get_hud():set_enabled(false)
  door:set_enabled(true)

  hero:set_visible(false)
  ichabod:get_sprite():set_animation"feet_up"
  zach:get_sprite():set_animation"feet_up"
end)


function map:on_opening_transition_finished()
  hero:freeze()
  credits = require"scripts/menus/credits"
  sol.menu.start(map, credits)
end
