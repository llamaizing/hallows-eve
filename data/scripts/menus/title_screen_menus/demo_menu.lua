local menu = {}
local parent_menu
local game_manager = require("scripts/game_manager")

local selection_options = {
 "full",
 "beach",
 "boss",
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
local text_surface4 = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})

local cursor_index
local MAX_CURSOR_INDEX = 3


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

  selection_surface:clear()
  text_surface:set_text_key("menu.title.full_demo")
  text_surface:draw(selection_surface, 12, 0)
  text_surface2:set_text_key("menu.title.beach_demo")
  text_surface2:draw(selection_surface, 12, 16)
  text_surface3:set_text_key("menu.title.boss_demo")
  text_surface3:draw(selection_surface, 12, 32)
  text_surface4:set_text_key("menu.title.cancel")
  text_surface4:draw(selection_surface, 12, 48)

end

function menu:set_parent_menu(dad)
  parent_menu = dad
end

function menu:on_draw(dst_surface)
  local x = 340
  local y = 175
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
    --From Intro
    if selection == "full" then
      sol.audio.play_sound("elixer_upgrade")
      local game = game_manager:create("demo.dat")
      if not game:get_value"fykonos_have_ticket" then
        game:set_starting_location("fykonos/intro/goatshead", "from_inn")
        game:set_max_life(14)
        game:set_life(game:get_max_life())
        game:set_money(100)
        game:set_value("defense", 5)
        game:set_value("sword_damage", 5)
        game:set_value("bow_damage", 6)
        game:get_item("sword"):set_variant(1)
        game:get_item("bow"):set_variant(1)
        game:get_item("bow"):add_amount(20)
        game:get_item("boomerang"):set_variant(1)
        game:get_item("barrier"):set_variant(1)
        game:get_item("bombs_counter_2"):set_variant(1)
        game:get_item("bombs_counter_2"):set_amount(15)
      end
      sol.main:start_savegame(game)
      sol.menu.stop(parent_menu)

    --Start at shipwreck on beach
    elseif selection == "beach" then
      sol.audio.play_sound("elixer_upgrade")
      local game = game_manager:create("demo.dat")
      if not game:get_value"fykonos_shipwreck_scene" then
        game:set_starting_location("fykonos/beach", "from_shipwreck")
        game:set_max_life(14)
        game:set_life(game:get_max_life())
        game:set_money(100)
        game:set_value("defense", 5)
        game:set_value("sword_damage", 5)
        game:set_value("bow_damage", 6)
      end
      sol.main:start_savegame(game)
      sol.menu.stop(parent_menu)

    --Start at final boss
    elseif selection == "boss" then
      sol.audio.play_sound("elixer_upgrade")
      local game = game_manager:create("demo.dat")
      if not game:get_value"fykonos_seen_ophira" then
        game:set_starting_location("fykonos/caves/ophiras_tomb", "from_outside")
        game:set_max_life(14)
        game:set_life(game:get_max_life())
        game:set_money(100)
        game:set_value("defense", 5)
        game:set_value("sword_damage", 5)
        game:set_value("bow_damage", 6)
        game:get_item("sword"):set_variant(1)
        game:get_item("bow"):set_variant(1)
        game:get_item("bow"):add_amount(20)
        game:get_item("boomerang"):set_variant(1)
        game:get_item("barrier"):set_variant(1)
        game:get_item("spear"):set_variant(2)
        game:get_item("bombs_counter_2"):set_variant(1)
        game:get_item("bombs_counter_2"):set_amount(15)
        game:set_ability("lift", 1)
        game:get_item("berries"):set_variant(1)
        game:get_item("berries"):set_amount(15)
        game:get_item("apples"):set_variant(1)
        game:get_item("apples"):set_amount(4)
        game:set_value("fykonos_shipwreck_scene", true)
        game:set_value("fykonos_elder_counter", 1)
        game:set_value("fykonos_bombs_available", true)
        game:set_value("fykonos_bombino_counter", 3)
        game:set_value("fykonos_island_ophira_tomb_door", true)
      end
      sol.main:start_savegame(game)
      sol.menu.stop(parent_menu)

    --Cancel
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