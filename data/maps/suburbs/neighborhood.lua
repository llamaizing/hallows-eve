local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level(game:get_value("darkness_level"))
  map.light_fx:set_darkness_level("dusk")

end)


for entity in map:get_entities("sentry_adult") do
  function entity:alert()
    print"Alerted!"
    sol.audio.play_sound("picked_small_key")
    sol.timer.stop_all(entity)
    entity:set_layer(map:get_max_layer())

    --Make adult run away
    local m = sol.movement.create"straight"
    m:set_angle(hero:get_angle(entity))
    m:set_speed(180)
    m:set_ignore_obstacles(true)
    m:start(entity)
    sol.timer.start(entity, 300, function()
      if map:is_on_screen(entity) then
        return true
      else
        entity:remove()
      end
    end)

    --Summon enemies
    local x, y, z = hero:get_position()
    for i=0, 3 do
      map:create_poof(x + 48 * math.cos(math.pi / 2 * i), y + 48 * math.sin(math.pi / 2 * i), z)
      map:create_enemy{
        x = x + 48 * math.cos(math.pi / 2 * i),
        y = y + 48 * math.sin(math.pi / 2 * i),
        layer = z, direction = 0,
        breed = "spider_thing", 
        }
    end

  end
end