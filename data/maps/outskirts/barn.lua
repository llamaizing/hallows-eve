local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level(game:get_value("darkness_level"))

  local fog1 = require("scripts/fx/fog").new()
  fog1:set_props{
  	fog_texture = {png = "fogs/dust_1.png", mode = "blend", opacity = 60},
  	opacity_range = {0,70},
    drift = {10, 0, -1, 1}
  }
  sol.menu.start(map, fog1)

  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/dust_2.png", mode = "blend", opacity = 10},
  	opacity_range = {0,40},
    drift = {15, 0, -1, 1},
    parallax_speed = 1.3,
  }
  sol.menu.start(map, fog2)

end)

function seed_chest:on_opened(treasure_item, variant, variable)
  hero:start_treasure(treasure_item:get_name(), 1, nil, function()
    for e in map:get_entities_by_type("enemy") do
      local x,y,z = e:get_position()
      map:create_poof(x,y+2,z)
      e:set_enabled(true)
    end
  end)
end
