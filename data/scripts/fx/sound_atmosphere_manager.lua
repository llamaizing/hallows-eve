--Call start_atmosphere(map, "type") to start sound effects on a map
--Valid types are: "birds", "rain", "rain_inside", "ravens"


local sound_atmosphere_manager = {}
sound_atmosphere_manager.all_timers = {}

local bird_sounds = {
  "bird/bird_01",
  "bird/bird_02",
  "bird/bird_03",
  "bird/bird_04",
  "bird/bird_05",
  "bird/bird_06",
  "bird/bird_07",
  "bird/bird_08",
  "bird/bird_09",
  "bird/bird_10",
  "bird/bird_11",
  "bird/bird_12",
  "bird/bird_13",
  "bird/bird_14",
  "bird/bird_15",
  "bird/bird_16",
  "bird/bird_17",
  "bird/bird_18",
  "bird/bird_19",
  "bird/bird_20",
  "bird/bird_21",
  "bird/bird_22",
  "bird/bird_23",
  "bird/bird_24",
  "bird/bird_25",
  "bird/bird_26",
}

local robin_sounds = {
  "bird/robin_01",
  "bird/robin_02",
  "bird/robin_03",
  "bird/robin_04",
  "bird/robin_05",
  "bird/robin_06",
  "bird/robin_07",
  "bird/robin_08",
  "bird/robin_09",
  "bird/robin_10",
  "bird/robin_11",
  "bird/robin_12",
  "bird/robin_13",
  "bird/robin_14",
  "bird/robin_15",
  "bird/robin_16",
  "bird/robin_17",
  "bird/robin_18",
}

local raven_sounds = {
  "bird/raven_01",
  "bird/raven_02",
  "bird/raven_03",
  "bird/raven_04",
  "bird/raven_05",
  "bird/raven_06",
  "bird/raven_07",
  "bird/raven_08",
  "bird/raven_09",
  "bird/raven_10",
  "bird/raven_11",
  "bird/raven_12",
  "bird/raven_13",
  "bird/raven_14",
  "bird/raven_15",
  "bird/raven_16",
  "bird/raven_17",
  "bird/raven_18",
  "bird/raven_19",
  "bird/raven_20",
  "bird/raven_21",
  "bird/raven_22",
  "bird/raven_23",
  "bird/raven_24",
  "bird/raven_25",
}

local bird_long_sounds = {
  "bird/bird_long_01",
  "bird/bird_long_02",
  "bird/bird_long_03",
  "bird/bird_long_04",
  "bird/bird_long_05",
  "bird/bird_long_06",
  "bird/bird_long_07",
  "bird/bird_long_08",
  "bird/bird_long_09",
  "bird/bird_long_10",
  "bird/bird_long_11",
}

local rain_sounds = {
  "rain/rain_01",
  "rain/rain_02",
  "rain/rain_03",
  "rain/rain_04",
  "rain/rain_05",
}

local rain_inside_sounds = {
  "rain/rain_inside_01",
  "rain/rain_inside_02",
  "rain/rain_inside_03",
  "rain/rain_inside_04",
}

function sound_atmosphere_manager:start_atmosphere(map, type)

  if type == "birds" then
    local timer = sol.timer.start(map, math.random(1000, 1800), function()
      local sound
      local set = math.random(1, 3)
      if set <= 2 then sound = robin_sounds[math.random(1, #robin_sounds)]
      elseif set == 3 then sound = bird_long_sounds[math.random(1, #bird_long_sounds)] end
      sol.audio.play_sound(sound)
      return math.random(300, 1800)
    end)
    timer:set_suspended_with_map(false)
    local timer2 = sol.timer.start(map, math.random(300, 1800), function()
      sol.audio.play_sound(bird_sounds[math.random(1, #bird_sounds)])
    end)
    timer2:set_suspended_with_map(false)
    table.insert(sound_atmosphere_manager.all_timers, timer)
    table.insert(sound_atmosphere_manager.all_timers, timer2)
  end

  if type == "rain_inside" then
    local timer = sol.timer.start(map, 1, function()
      sol.audio.play_sound(rain_inside_sounds[math.random(1, #rain_inside_sounds)])
      return 3000
    end)
    timer:set_suspended_with_map(false)
    table.insert(sound_atmosphere_manager.all_timers, timer)
  end

  if type == "rain" then
    local timer = sol.timer.start(map, 1, function()
      sol.audio.play_sound(rain_sounds[math.random(1, #rain_sounds)])
      return 3000
    end)
    timer:set_suspended_with_map(false)
    table.insert(sound_atmosphere_manager.all_timers, timer)
  end

  if type == "ravens" then
    local timer = sol.timer.start(map, 1, function()
      local maybe_pause = math.random(1, 10)
      if maybe_pause == 1 then
        return math.random(2000, 3200)
      else
        sol.audio.play_sound(raven_sounds[math.random(1, #raven_sounds)])
        return math.random(150, 800)
      end
    end)
    timer:set_suspended_with_map(false)
    table.insert(sound_atmosphere_manager.all_timers, timer)
  end

end


function sound_atmosphere_manager:stop_sounds()
  for k,v in pairs(sound_atmosphere_manager.all_timers) do
    v:stop()
  end
end


return sound_atmosphere_manager