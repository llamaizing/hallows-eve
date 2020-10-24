local submenu = require("scripts/menus/pause_submenu")
local language_manager = require("scripts/language_manager")

local options_submenu = submenu:new()


function options_submenu:on_finished()
  sol.main.get_game():set_suspended(false)
end

function options_submenu:on_started()
  local game = sol.main.get_game()
  game:set_suspended(true)

  submenu.on_started(self)

  local font, font_size = language_manager:get_menu_font()
  local width, height = sol.video.get_quest_size()
  local center_x, center_y = width / 2, height / 2

  self.column_color = { 255, 255, 255}
  self.text_color = { 255, 255, 255 }

  self.video_mode_label_text = sol.text_surface.create{
    horizontal_alignment = "left",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "selection_menu.options.video_mode",
    color = self.text_color,
  }
  self.video_mode_label_text:set_xy(center_x - 50, center_y - 58)

  self.video_mode_text = sol.text_surface.create{
    horizontal_alignment = "right",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text = sol.video.get_mode(),
    color = self.text_color,
  }
  self.video_mode_text:set_xy(center_x + 104, center_y - 58)

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

  self.commands_surface = sol.surface.create(215, 160)
  self.commands_surface:set_xy(center_x - 107, center_y - 18)
  self.commands_highest_visible = 1
  self.commands_visible_y = 0

  self.command_texts = {}
  self.keyboard_texts = {}
  self.joypad_texts = {}
  self.command_names = { "action", "attack", "item_1", "item_2", "pause", "left", "right", "up", "down"}
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
  self.cursor_sprite = sol.sprite.create("menus/options_cursor")
  self.cursor_position = nil
  self:set_cursor_position(1)

end

-- Loads the text displayed for each game command, for the
-- keyboard and the joypad.
function options_submenu:load_command_texts()

  self.commands_surface:clear()
  for i = 1, #self.command_names do
    local keyboard_binding = self.game:get_command_keyboard_binding(self.command_names[i])
    local joypad_binding = self.game:get_command_joypad_binding(self.command_names[i])
    self.keyboard_texts[i]:set_text(keyboard_binding:sub(1, 9))
    self.joypad_texts[i]:set_text(joypad_binding:sub(1, 9))

    local y = 16 * i - 14
    self.command_texts[i]:draw(self.commands_surface, 4, y)
    self.keyboard_texts[i]:draw(self.commands_surface, 74, y)
    self.joypad_texts[i]:draw(self.commands_surface, 143, y)
  end
end

function options_submenu:set_cursor_position(position)

  if position ~= self.cursor_position then

    local width, height = sol.video.get_quest_size()

    self.cursor_position = position
    if position == 1 then  -- Video mode.
      self:set_caption("options.caption.press_action_change_mode")
      self.cursor_sprite.x = width / 2 - 58
      self.cursor_sprite.y = height / 2 - 59
      self.cursor_sprite:set_animation("big")
    else  -- Customization of a command.
      self:set_caption("options.caption.press_action_customize_key")

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
      self.cursor_sprite:set_animation("small")
    end
  end
end

function options_submenu:on_draw(dst_surface)

  self:draw_background(dst_surface)
  self:draw_caption(dst_surface)

  -- Cursor.
  self.cursor_sprite:draw(dst_surface, self.cursor_sprite.x, self.cursor_sprite.y)

  -- Text.
  self.video_mode_label_text:draw(dst_surface)
  self.video_mode_text:draw(dst_surface)
  self.command_column_text:draw(dst_surface)
  self.keyboard_column_text:draw(dst_surface)
  self.joypad_column_text:draw(dst_surface)
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

  self:draw_save_dialog_if_any(dst_surface)
end

function options_submenu:on_command_pressed(command)

  if self.command_customizing ~= nil then
    -- We are customizing a command: any key pressed should have been handled before.
    error("options_submenu:on_command_pressed() should not called in this state")
  end

  local handled = submenu.on_command_pressed(self, command)

  if not handled then
    if command == "left" then
      handled = true
    elseif command == "right" then
      handled = true
    elseif command == "up" then
      sol.audio.play_sound("cursor")
      self:set_cursor_position((self.cursor_position + 8) % 10 + 1)
      handled = true
    elseif command == "down" then
      sol.audio.play_sound("cursor")
      self:set_cursor_position(self.cursor_position % 10 + 1)
      handled = true
    elseif command == "action" then
      sol.audio.play_sound("danger")
      if self.cursor_position == 1 then
        -- Change the video mode.
        sol.video.switch_mode()
        self.video_mode_text:set_text(sol.video.get_mode())
      else
        -- Customize a game command.
        self:set_caption("options.caption.press_key")
        self.cursor_sprite:set_animation("small_blink")
        local command_to_customize = self.command_names[self.cursor_position - 1]

        local orig_keyboard_bind = self.game:get_command_keyboard_binding(command_to_customize)
        self.is_prevent_close = true
        self.game:capture_command_binding(command_to_customize, function()
          self.is_prevent_close = false
          local new_keyboard_bind = self.game:get_command_keyboard_binding(command_to_customize)
          if new_keyboard_bind:match"^f%d+$" then --revert and do nothing
            sol.audio.play_sound("no")
            self.game:set_command_keyboard_binding(command_to_customize, orig_keyboard_bind)
          else
            sol.audio.play_sound("danger")
            self:load_command_texts()
            -- TODO restore HUD icons.
          end
          self:set_caption("options.caption.press_action_customize_key")
          self.cursor_sprite:set_animation("small")
        end)

        -- TODO grey over HUD icons, make the icon of the command blink.
      end
      handled = true

    elseif command == "pause" or command == "attack" then
      sol.menu.stop(self)
    end
  end

  return handled
end


--Avoid analog stick wildly jumping
local joy_avoid_repeat = {-2, -2}

function options_submenu:on_joypad_axis_moved(axis, state)

  local handled = joy_avoid_repeat[axis % 2] == state
  joy_avoid_repeat[axis % 2] = state

  return handled
end


function options_submenu:on_key_pressed(key)

end

return options_submenu

