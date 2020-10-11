local map = ...
local game = map:get_game()

function caleb:on_interaction()
  local sprite = caleb_dummy:get_sprite()
  --First interaction
  if not game:get_value("caleb_convo_counter") then
    game:set_value("caleb_convo_counter", 1)
    map:start_coroutine(function()
      sprite:set_animation"desk"
      dialog"video_store.welcome_costume"
      dialog"video_store.costume_response"
      dialog"video_store.1"
      sprite:set_animation("move_arm", "leaning")
      wait(800)
      dialog"video_store.2"
      sprite:set_animation"tapping_hand"
      dialog"video_store.3"
      dialog"video_store.4"
      dialog"video_store.5"
      dialog"video_store.6"
    end)
  elseif game:get_value("caleb_convo_counter") == 1 then
    map:start_coroutine(function()
      sprite:set_animation"desk"
      dialog"video_store.forgot_directions"
      sprite:set_animation("move_arm", "leaning")
      wait(800)
      sprite:set_animation"tapping_hand"
    end)

  elseif game:get_value("caleb_convo_counter") == 2 then
    map:start_coroutine(function()
      sprite:set_animation"desk"
      dialog"video_store.seen_zach"
      sprite:set_animation("move_arm", "leaning")
      wait(800)
      sprite:set_animation"tapping_hand"
    end)


  end
end