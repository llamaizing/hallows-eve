local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map.light_fx:set_darkness_level(game:get_value("darkness_level"))

  require("maps/suburbs/treater_routes")(map)
end)


function map:on_opening_transition_finished()
  sol.timer.start(map, 500, function()
    eye_rune:set_enabled(false)
  end)
  if not game:get_value("seen_acimonia_neighborhood_scene") then
    map:acimonia_cutscene()
  end
end



for entity in map:get_entities("sentry") do
  entity:set_alert_threshold(10)
  function entity:on_suspicious()
    entity:stop_movement()
    entity:get_sprite():set_direction(entity:get_direction4_to(hero))
    if entity:get_distance(hero) <= 32 then
      entity:on_alerted()
    end
  end

  function entity:on_alerted()
    sol.audio.play_sound("picked_small_key")
    sol.timer.stop_all(entity)
    entity:set_layer(map:get_max_layer())

    --Make sentry run away
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

    --Summon enemy
    local x, y, z = entity:get_position()
    local summoned_enemy = map:create_enemy{
      x = x,
      y = y,
      layer = hero:get_layer(), direction = 0,
      breed = "hand",
      }

  end
end


local function walk_back_and_forth(entity)
  entity.walk_angle = entity.walk_angle + math.pi
  local m = sol.movement.create"straight"
  m:set_angle(entity.walk_angle)
  m:set_speed(40)
  m:start(entity)
  function m:on_obstacle_reached()
    entity:stop_movement()
    walk_back_and_forth(entity)
  end
end


for entity in map:get_entities("sentry_adult_horizontal") do
  entity.walk_angle = 0
  walk_back_and_forth(entity)
  function entity:on_suspicion_lost()
    walk_back_and_forth(entity)
  end
end


local function spin_around(entity)
  sol.timer.start(entity, 1000, function()
    if not entity.suspicious then
      entity:get_sprite():set_direction((entity:get_sprite():get_direction() + 1) % 4)
    end
    return true
  end)
end

for entity in map:get_entities("sentry_adult_spin") do
  spin_around(entity)
end



function map:acimonia_cutscene()
  map:start_coroutine(function()
    hero:freeze()
    hero:set_animation"walking"
    local m = sol.movement.create"path"
    m:set_path{2,2,2,2,2,2,2,2}
    movement(m, hero)
    hero:set_animation"stopped"
    local x,y,z = hero:get_position()
    map:create_poof(x,y-48,z)
    acimonia:set_position(x,y-48,z)
    wait(1000)
    dialog"neighborhood.acimonia_scene.1"
    dialog"neighborhood.acimonia_scene.2"
    dialog"neighborhood.acimonia_scene.3"
    dialog"neighborhood.acimonia_scene.4"
    dialog"neighborhood.acimonia_scene.5"
    dialog"neighborhood.acimonia_scene.6"
    dialog"neighborhood.acimonia_scene.7"
    map:create_poof(acimonia:get_position())
    acimonia:remove()
    game:set_value("seen_acimonia_neighborhood_scene", true)
    hero:unfreeze()
  end)
end
