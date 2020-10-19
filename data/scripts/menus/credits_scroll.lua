-- ♡ Copying is an act of love. Please copy and share.

-- Game credits. Plays at the end of the game.

local end_credits = {}


-- https://stackoverflow.com/a/8316375/8811886
function build_array(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end


-- Called when the menu is started
function end_credits:on_started()
  local lh = 12 -- line height in pixels
  local speed = 24 -- scroll speed in px/s

  -- Credits dialog
  self.dialog = sol.language.get_dialog("credits_scroll")

  -- Break dialog text into a table of lines
  local lines = self.dialog.text
  lines = lines:gsub("\r\n", "\n"):gsub("\r", "\n")
  lines = build_array(lines:gmatch("([^\n]*)\n"))


  -- Screen Height and Width
  local screen_width, screen_height = sol.video.get_quest_size()

  -- Box where the credits go
  self.credits_surface = sol.surface.create(
    screen_width, -- center the surface on the screen
    (#lines * lh) -- surface is large enough to hold all lines
      + screen_height -- surface scrolls in from the bottom, so has a padding top equal to the screen size
      + 16 -- room for 8px top and bottom padding
  )

  -- Loop through all dialog lines and draw them
  for i, line in ipairs(lines) do
    local font, font_size = require("scripts/language_manager"):get_dialog_font()
    local line_surface =  sol.text_surface.create({
      font=font,
      font_size=font_size,
      horizontal_alignment = "center",
      text=line,
    })
    -- Draw the given line
    line_surface:draw(
      self.credits_surface,
      screen_width / 2, -- draw in center
      i * lh -- bump it down by line number and line height
        + 8 -- top padding for whole box
    )
  end

  -- Animate the text box upwards
  local m = sol.movement.create("straight")
  m:set_angle(math.pi / 2)
  m:set_speed(speed)
  m:start(self.credits_surface)

  function m:on_position_changed()
    local credits_surface = end_credits.credits_surface
    local x, y = credits_surface:get_xy()
    local w, h = credits_surface:get_size()

    -- log(string.format("Credits text box: (%d, %d)  ;;  y+h = %d", x, y, y+h))

    if y + h < 0 then
      -- Credits are out of view, end the menu
      -- log("Credits animation finished.")
      self:stop()
      sol.menu.stop(end_credits)
    end
  end

end


-- Called each frame
function end_credits:on_draw(dst_surface)
  dst_surface:clear()
  self.credits_surface:draw(dst_surface, 0, 144)
end


function end_credits:on_finished()
  if end_credits.started_from_menu then
    end_credits.started_from_menu = false
    sol.audio.stop_music()
    require("scripts/menus/initial_menus").start()
  else
    sol.timer.start(sol.main, 20, function() sol.main.reset() end)
  end
end

return end_credits