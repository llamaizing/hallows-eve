local credits = {}

local font, font_size = require("scripts/language_manager"):get_dialog_font()

local FADE_IN_SPEED = 0
local FADE_OUT_SPEED  = 0
local CREDIT_TIME = 2000

credits.top = sol.text_surface.create{
    font = font, font_size = font_size,
    horizontal_alignment = "center",
    vertical_alignment = "top"
}
credits.top:set_opacity(0)
credits.bottom = sol.text_surface.create{
    font = font, font_size = font_size,
    horizontal_alignment = "center",
    vertical_alignment = "top"
}
credits.bottom:set_opacity(0)
credits.black = sol.surface.create()
--credits.black:fill_color{0,0,0}
credits.black:set_opacity(0)
credits.dialog_text = nil

function credits:on_started()
  local dialog = sol.language.get_dialog("credits") --refresh each time menu starts in case language changed since last time
  assert(dialog, "dialogs.dat entry 'credits' not found")
  self.dialog_text = dialog.text:gsub("\r\n", "\n"):gsub("\r", "\n") --standardize line breaks
  self:roll()
end

function credits:on_finished() self.dialog_text = nil end

function credits:roll()
  self.black:fade_in(10, function()
    sol.timer.start(self, 10, function()
      self.next_text = self.dialog_text:gmatch("([^\n]*)\n") --each line including empty ones
      self:show_next_name()
    end)
  end)
end

function credits:show_next_name()
  local line = self.next_text()
  if line then
    local line1,line2 = line:match("([^%:]*)%:?([^%:]*)") --separate text at colon
    self.top:set_text(line1)
    self.bottom:set_text(line2)
    self.top:fade_in(FADE_IN_SPEED)
    self.bottom:fade_in(FADE_IN_SPEED, function()
      sol.timer.start(self, CREDIT_TIME, function()
        self.top:fade_out(FADE_OUT_SPEED)
        self.bottom:fade_out(FADE_OUT_SPEED, function()
          self:show_next_name()
        end)
      end)
    end)
  else
    sol.timer.start(sol.main, 1000, function()
      sol.menu.stop(self)
      if sol.main:get_game() then
        sol.main.reset()
      else
        local title_logo = require("scripts/menus/title_screen_menus/background"):get_title_surface()
        title_logo:set_opacity(255)
        sol.audio.play_music"title_screen"
      end
    end)
  end
end

function credits:on_draw(dst_surface)
  credits.black:draw(dst_surface)
  credits.top:draw(dst_surface, 200, 120)
  credits.bottom:draw(dst_surface, 200, 140)
end

function credits:on_key_pressed()
  return true
end

function credits:on_joypad_button_pressed()
  return true
end


return credits
