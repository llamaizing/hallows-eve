--Fog script, written by Max Mraz and Llamazing

local fog_menu = {}

--Fog parallax multiplier
local PARALLAX_MULT = 1.2

local surface = sol.surface.create("fogs/fog.png")
surface:set_blend_mode"blend"
surface:set_opacity(100)
local width, height = surface:get_size()

local opacity_min, opacity_max = 50, 150

fog_menu.drift_x = 0
fog_menu.drift_y = 0

function fog_menu:on_started()
	sol.timer.start(fog_menu, 100, function()
		fog_menu.drift_x = fog_menu.drift_x + 1
		fog_menu.drift_y = fog_menu.drift_y + 1
		return true
	end)

	sol.timer.start(fog_menu, 100, function()

	end)

end




local function tile_draw(x_offset, y_offset, dst_surface, x, y)
    local region_x = x_offset % width
    local region_y = y_offset % height
    
    local region_width = width - region_x
    local region_height = height - region_y
    
    --draw region 4
    surface:draw_region(region_x, region_y, region_width, region_height, dst_surface, x, y)
    
    --draw region 3
    if region_width>0 then
        surface:draw_region(0, region_y, region_x, region_height, dst_surface, x+width-region_x, y)
    end
    
    --draw region 2
    if region_height>0 then
        surface:draw_region(region_x, 0, region_width, region_y, dst_surface, x, y+height-region_y)
    end
    
    --draw region 1
    if region_width>0 and region_height>0 then
        surface:draw_region(0, 0, region_x, region_y, dst_surface, x+width-region_x, y+height-region_y)
    end
end


function fog_menu:on_draw(dst_surface)
  local camera_x, camera_y = sol.main.get_game():get_map():get_camera():get_position()
  tile_draw(
  	fog_menu.drift_x + math.floor(camera_x * PARALLAX_MULT)%width,
  	fog_menu.drift_y + math.floor(camera_y * PARALLAX_MULT)%height,
  	dst_surface, 0, 0
  	)
end

return fog_menu