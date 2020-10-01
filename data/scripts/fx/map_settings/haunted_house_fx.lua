local setter = {}

function setter:set_fx(map)
  map.light_fx:set_darkness_level("haunted_house")

  local fog1 = require("scripts/fx/fog").new()
  fog1:set_props{
  	fog_texture = {png = "fogs/dust_1.png", mode = "blend", opacity = 10},
  	opacity_range = {20,80},
    drift = {10, 0, -1, 1},
    parallax_speed = 1.1,
  }
  sol.menu.start(map, fog1)

  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/dust_2.png", mode = "blend", opacity = 60},
  	opacity_range = {0,40},
    drift = {5, 0, -1, 1},
    parallax_speed = 1.4
  }
  sol.menu.start(map, fog2)

end

return setter