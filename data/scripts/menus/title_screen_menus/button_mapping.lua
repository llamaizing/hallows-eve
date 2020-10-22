local menu = {}
local parent_menu

require"scripts/misc/command_binding_manager"


function menu:on_started()
  sol.main.title_menus[menu] = menu

  local width, height = sol.video.get_quest_size()
  local center_x, center_y = width / 2, height / 2

  self.background_image = sol.surface.create("menus/button_mapping_background.png")

  self.column_color = { 255, 255, 255}
  self.text_color = { 115, 59, 22 }

  self.command_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.commands_column",
    color = self.column_color,
  }
  self.command_column_text:set_xy(center_x - 76, center_y - 37)

  self.keyboard_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.keyboard_column",
    color = self.column_color,
  }
  self.keyboard_column_text:set_xy(center_x - 7, center_y - 37)

  self.joypad_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.joypad_column",
    color = self.column_color,
  }
  self.joypad_column_text:set_xy(center_x + 69, center_y - 37)

  self.cancel_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "menu.title.cancel",
    color = self.column_color,
  }
  self.cancel_text:set_xy(132, 72)

  self.commands_surface = sol.surface.create(215, 160)
  self.commands_surface:set_xy(center_x - 107, center_y - 18)
  self.commands_highest_visible = 1
  self.commands_visible_y = 0

  self.command_texts = {}
  self.keyboard_texts = {}
  self.joypad_texts = {}
  self.command_names = { "action", "attack", "item_1", "item_2", "pause", "left", "right", "up", "down" }
  for i = 1, #self.command_names do

    self.command_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      text_key = "options.command." .. self.command_names[i],
      color = self.text_color,
    }

    self.keyboard_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      color = self.text_color,
    }

    self.joypad_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      color = self.text_color,
    }
  end

  self:load_command_texts()

  self.up_arrow_sprite = sol.sprite.create("menus/arrow")
  self.up_arrow_sprite:set_direction(1)
  self.up_arrow_sprite:set_xy(center_x - 64, center_y - 24)
  self.down_arrow_sprite = sol.sprite.create("menus/arrow")
  self.down_arrow_sprite:set_direction(3)
  self.down_arrow_sprite:set_xy(center_x - 64, center_y + 62)
  self.cursor_sprite = sol.sprite.create("menus/cursor")
  self.cursor_position = nil
  self:set_cursor_position(1)

end



function menu:set_parent_menu(dad)
  parent_menu = dad
end



-- Loads the text displayed for each game command, for the
-- keyboard and the joypad.
function menu:load_command_texts()

  self.commands_surface:clear()
  for i = 1, #self.command_names do
print("Keyboard binding to get", self.command_names[i])
    local keyboard_binding = sol.main:get_command_keyboard_binding(self.command_names[i])
    local joypad_binding = sol.main:get_command_joypad_binding(self.command_names[i])
    self.keyboard_texts[i]:set_text(keyboard_binding:sub(1, 9))
    self.joypad_texts[i]:set_text(joypad_binding:sub(1, 9))

    local y = 16 * i - 14
    self.command_texts[i]:draw(self.commands_surface, 4, y)
    self.keyboard_texts[i]:draw(self.commands_surface, 74, y)
    self.joypad_texts[i]:draw(self.commands_surface, 143, y)
  end
end

function menu:set_cursor_position(position)

  if position ~= self.cursor_position then

    local width, height = sol.video.get_quest_size()

    self.cursor_position = position
    if position == 1 then --cancel
      self.cursor_sprite.x = width / 2 - 105
      self.cursor_sprite.y = 72

    else  -- Customization of a command.
      --self:set_caption("options.caption.press_action_customize_key")

      -- Make sure the selected command is visible.
      while position <= self.commands_highest_visible do
        self.commands_highest_visible = self.commands_highest_visible - 1
        self.commands_visible_y = self.commands_visible_y - 16
      end

      while position > self.commands_highest_visible + 5 do
        self.commands_highest_visible = self.commands_highest_visible + 1
        self.commands_visible_y = self.commands_visible_y + 16
      end

      self.cursor_sprite.x = width / 2 - 105
      self.cursor_sprite.y = height / 2 - 32 + 16 * (position - self.commands_highest_visible)
    end
  end
end

function menu:on_draw(dst_surface)

  --self:draw_background(dst_surface)
  --self:draw_caption(dst_surface)

  self.background_image:draw(dst_surface)

  -- Cursor.
  self.cursor_sprite:draw(dst_surface, self.cursor_sprite.x, self.cursor_sprite.y)

  -- Text.
  self.command_column_text:draw(dst_surface)
  self.keyboard_column_text:draw(dst_surface)
  self.joypad_column_text:draw(dst_surface)
  self.cancel_text:draw(dst_surface)
  self.commands_surface:draw_region(0, self.commands_visible_y, 215, 84, dst_surface)

  -- Arrows.
  if self.commands_visible_y > 0 then
    self.up_arrow_sprite:draw(dst_surface)
    self.up_arrow_sprite:draw(dst_surface, 115, 0)
  end

  if self.commands_visible_y < 60 then
    self.down_arrow_sprite:draw(dst_surface)
    self.down_arrow_sprite:draw(dst_surface, 115, 0)
  end

end




function menu:on_key_pressed(key)
  if self.command_customizing then
    print("command to customize:", self.command_to_customize)
    print("command customizing, new key:", key)
    sol.audio.play_sound("danger")
    self.cursor_sprite:set_animation("small")
    self:load_command_texts()

  elseif key == "up" or key == "down" or key == "left" or key == "right" then
    menu:on_command_pressed(key)
  elseif key == "space" or key == "return" then
    menu:on_command_pressed("action")
  elseif key == "escape" or key == "c" or key == "d" then
    menu:on_command_pressed("attack")
  end
  return true
end

function menu:on_command_pressed(command)
  if self.command_customizing then
    -- We are customizing a command: any key pressed should have been handled before.
    error("options_submenu:on_command_pressed() should not called in this state")
  end

  local handled = false

  if not handled then
    if command == "up" then
      sol.audio.play_sound("cursor")
      self:set_cursor_position((self.cursor_position + 8) % 10 + 1)
      handled = true
    elseif command == "down" then
      sol.audio.play_sound("cursor")
      self:set_cursor_position(self.cursor_position % 10 + 1)
      handled = true
    elseif command == "action" then
      if self.cursor_position == 1 then
        sol.menu.stop(menu)
        handled = true
      else
        sol.audio.play_sound("danger")
        -- Customize a game command.
        self.cursor_sprite:set_animation("small_blink")
        self.command_customizing = true
        self.command_to_customize = self.command_names[self.cursor_position - 1]
        handled = true
      end

    elseif command == "attack" then
      sol.menu.stop(menu)
    end
  end

  return handled
end


return menu