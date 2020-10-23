return {
	background = {
		image = {
			path = "default"
		},
    color = {0,0,0,20}
	},
  dialog_box = {
    close_delay = 0,
    image = {
      position = "center",
      y_offset = -4,
      path = "hud/dialog_box_background.png"
    },
    text = {
      max_displayed_lines = 3,
      x_offset = 8,
      y_offset = 14,
      line_space = 14,
      line = {
        speed = "fast",
        horizontal_alignment = "left",
        vertical_alignment = "middle",
        font = "enter_command",
        font_size = 16
      },
      question = {
        line_buffer = 7,
        question_marker = "$?",
        cursor_wrap = true,
        cursor = {
          image = {
            path = "menus/cursor",
            sprite = {
              "walking"
            },
            x_offset = 8,
          }
        }
      }
    },
    name_box = {
      image = {
        path = "hud/dialog_box_name.png",
        position = "outsidetopleft"
      },
      line = {
        x_offset = 8,
        y_offset = 7,
        horizontal_alignment = "left",
        vertical_alignment = "middle",
        font = "enter_command",
        font_size = 16 
      }
    }
  }
}