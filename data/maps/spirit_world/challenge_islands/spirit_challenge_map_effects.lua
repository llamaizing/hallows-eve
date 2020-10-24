local manager = {}

function manager:set_fx(map)
  local game = map:get_game()
  map.light_fx:set_darkness_level({200,180,240})
  -- map.light_fx:set_darkness_level({230,180,250})

  local world = map:get_world()
  game:set_world_rain_mode(world, "rain")
  local rain_manager = require("scripts/weather/rain_manager")

  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")

  local fog1 = require("scripts/fx/fog").new()
  fog1:set_props{
  	fog_texture = {png = "fogs/spirit_fog_1.png", mode = "blend", opacity = 0},
  	opacity_range = {0,40},
    drift = {9, 0, -1, 1}
  }
  sol.menu.start(map, fog1)

  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/spirit_fog_2.png", mode = "blend", opacity = 60},
  	opacity_range = {10,60},
    drift = {13, 0, -1, 1}
  }
  sol.menu.start(map, fog2)

  local fog3 = require("scripts/fx/fog").new()
  fog3:set_props{
  	fog_texture = {png = "fogs/spirit_fog_3.png", mode = "blend", opacity = 20},
  	opacity_range = {10,50},
    drift = {18, 0, -1, 1}
  }
  sol.menu.start(map, fog3)


  local enemy_sets = {"a", "b", "c", "d", "e"}
  for _, set in pairs(enemy_sets) do
    for enemy in map:get_entities("group_" .. set .. "_enemy") do
      function enemy:on_dead()
        if not map:has_entities("group_" .. set .. "_enemy") then
          map:focus_on(map:get_entity("door_" .. set), function()
            map:open_doors("door_" .. set)
          end)
        end
      end
    end

  end
end

return manager