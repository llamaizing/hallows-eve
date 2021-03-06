local menu = {}

local white_surface = sol.surface.create()
white_surface:fill_color{255,255,255}

function menu:on_started()
  white_surface:set_opacity(0)
  white_surface:fade_in(menu.fade_in_time or 2)
end

function menu:fade_out(time)
  white_surface:fade_out(time, function()
    sol.menu.stop(self)
  end)
end

function menu:on_draw(dst)
  white_surface:draw(dst)
end

return menu