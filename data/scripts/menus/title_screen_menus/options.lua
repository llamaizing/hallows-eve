local menu = {}
local parent_menu
local game_manager = require("scripts/game_manager")

local selection_options = {
 "credits",
 "button_mapping",
 "return"
}

local font, font_size = require("scripts/language_manager"):get_menu_font()

local cursor_sprite = sol.sprite.create("menus/cursor")
local selection_surface = sol.surface.create(144, 96)
local text_surface = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
local text_surface2 = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
local text_surface3 = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})

local cursor_index
local MAX_CURSOR_INDEX = 2



function menu:update_font()
  font, font_size = require("scripts/language_manager"):get_menu_font()
  local surfaces_to_update = {text_surface, text_surface2, text_surface3}
  for _, txt_s in pairs(surfaces_to_update) do
    txt_s:set_font(font)
    txt_s:set_font_size(font_size)
  end
end


function menu:on_started()
  sol.main.title_menus[menu] = menu
  cursor_index = 0
end

function menu:set_parent_menu(dad)
  parent_menu = dad
end

function menu:on_draw(dst_surface)
  local x = 340
  local y = 175

  --Set text keys on_draw so that when lenguage is updated, this menu updates immediately
  selection_surface:clear()
  text_surface:set_text_key("menu.title.credits")
  text_surface:draw(selection_surface, 12, 0)
  text_surface2:set_text_key("menu.title.button_mapping")
  text_surface2:draw(selection_surface, 12, 16)
  text_surface3:set_text_key("menu.title.cancel")
  text_surface3:draw(selection_surface, 12, 32)

  selection_surface:draw(dst_surface, x, y)
  cursor_sprite:draw(dst_surface, x + 3, y + 4 + cursor_index * 16)
end


function menu:process_input(command)
  if command == "down" then
      sol.audio.play_sound("cursor")
      cursor_index = cursor_index + 1
      if cursor_index > MAX_CURSOR_INDEX then cursor_index = 0 end
  elseif command == "up" then
      sol.audio.play_sound("cursor")
      cursor_index = cursor_index - 1
      if cursor_index <0 then cursor_index = MAX_CURSOR_INDEX end


  elseif command == "space" then
    menu:process_selected_option(selection_options[cursor_index + 1])
  end
end


function menu:process_selected_option(selection)
    if selection == "credits" then
      local credits = require("scripts/menus/credits")
      sol.audio.play_music("funky-fresh-credits")
--      sol.menu.stop(menu)
--      sol.menu.stop(parent_menu)
--      sol.menu.stop_all(sol.main)
      local title_logo = require("scripts/menus/title_screen_menus/background"):get_title_surface()
      title_logo:set_opacity(0)
      sol.menu.start(sol.main, credits)
      credits.started_from_menu = true


    elseif selection == "button_mapping" then
      sol.menu.start(sol.main, require("scripts/menus/title_screen_menus/button_mapping"))

    --Return
    elseif selection == "return" then
      sol.audio.play_sound("no")
      local new_cont_etc = require"scripts/menus/title_screen_menus/new_continue_etc"
      sol.menu.start(parent_menu, new_cont_etc)
      parent_menu:set_current_submenu(new_cont_etc)
      new_cont_etc:set_parent_menu(parent_menu)
      sol.menu.stop(menu)

    end --end cursor index cases
end


return menu