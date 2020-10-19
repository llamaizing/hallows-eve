local menu = {}

local screen_width, screen_height = sol.video.get_quest_size()
local surface = sol.surface.create(screen_width, 48)
surface:fill_color{100,100,100}

local font, font_size = require("scripts/language_manager"):get_dialog_font()

local text = sol.text_surface.create({
  font = font,
  font_size = font_size,
  vertical_alignment = "top",
  horizontal_alignment = "left",
})

function menu:update_font()
  font, font_size = require("scripts/language_manager"):get_menu_font()
  local surfaces_to_update = {text}
  for _, txt_s in pairs(surfaces_to_update) do
    txt_s:set_font(font)
    txt_s:set_font_size(font_size)
  end
end

function menu:on_started()
  sol.main.title_menus[menu] = menu
  text:set_text_key("menu.title.corrupted_save")
  text:draw(surface, 32, 16)
end

function menu:on_draw(dst)
  surface:draw(dst, 0, screen_height / 2 - 32)
end

function menu:on_key_pressed(command)
  menu:exit()
end
function menu:on_joypad_button_pressed(command)
  menu:exit()
end
function menu:on_joypad_hat_moved(command)
  menu:exit()
end
function menu:on_joypad_axis_moved(command)
  menu:exit()
end

function menu:exit()
  sol.menu.stop(self)
end

return menu