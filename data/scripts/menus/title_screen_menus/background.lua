local title_screen = {}


local bg = sol.surface.create("menus/title_screen_background.png")
local black_fill = sol.surface.create()
local tint_surface = sol.surface.create()
tint_surface:set_blend_mode"multiply"
tint_surface:fill_color{255,200,130}
local title_surface = sol.surface.create("menus/title_screen.png")


function title_screen:on_started()

  title_surface:fade_in()
  sol.timer.start(self, 100, function()
    sol.audio.play_music("title_screen")
  end)
  black_fill:fill_color({0,0,0, 255})
  black_fill:fade_out(40)


  local fog1 = require("scripts/fx/fog").new()
  fog1:set_props{
  	fog_texture = {png = "fogs/pollen_1.png", mode = "blend", opacity = 60},
  	opacity_range = {0,70},
    drift = {10, 0, -1, 1}
  }
  sol.menu.start(title_screen, fog1)

  local fog2 = require("scripts/fx/fog").new()
  fog2:set_props{
  	fog_texture = {png = "fogs/pollen_2.png", mode = "blend", opacity = 10},
  	opacity_range = {0,40},
    drift = {15, 0, -1, 1},
    parallax_speed = 1.3,
  }
  sol.menu.start(title_screen, fog2)

  local fog3 = require("scripts/fx/fog").new()
  fog3:set_props{
  	fog_texture = {png = "fogs/pollen_3.png", mode = "blend", opacity = 60},
  	opacity_range = {10,110},
    drift = {25, 0, -1, 1},
    parallax_speed = 1.7,
  }
  sol.menu.start(title_screen, fog3)

end


function title_screen:on_draw(dst_surface)
  bg:draw(dst_surface)
  tint_surface:draw(dst_surface)
  title_surface:draw(dst_surface)
  black_fill:draw(dst_surface)
end

return title_screen
