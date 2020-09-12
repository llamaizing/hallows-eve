--[[
Fog script, written by Max Mraz and Llamazing

Configurable options can be set with
fog_menu:set_props({
	drift = {speed_x, speed_y, x direction multiplier, y direction multiplier} --for example {10, 10, -1, 1} goes up 10px and right 10px
	fog_textures = {
		{png = "fog/fog.png", mode = "blend", opacity = opacity}
	}
})

--]]

local fog_menu = {}


local surface = sol.surface.create()
local width, height = surface:get_size()

local opacity_min, opacity_max = 50, 150

fog_menu.drift_x = 0
fog_menu.drift_y = 0



function fog_menu:set_props(props)
	fog_menu.drift = props and props.drift or {8, 0, -1, 1}
	fog_menu.parallax_speed = props and props.parallax_speed or 1

	fog_menu.texture = props and props.fog_textures or {png = "fogs/fog.png", mode = "blend", opacity = 200} --temp, should be blank

	fog_menu.props_set = true
end


function fog_menu:on_started()
	if not fog_menu.props_set then fog_menu:set_props() end

	local s = sol.surface.create(fog_menu.texture.png)
	s:set_blend_mode(fog_menu.texture.mode or "blend")
	s:set_opacity(fog_menu.texture.opacity or 255)
	s:draw(surface)

	--Drift
	if fog_menu.drift[1] ~= 0 then
		sol.timer.start(fog_menu, 1000 / fog_menu.drift[1], function()
			fog_menu.drift_x = fog_menu.drift_x + 1 * (fog_menu.drift[3] or 1)
			return true
		end)
	end
	if fog_menu.drift[2] ~= 0 then
		sol.timer.start(fog_menu, 1000 / fog_menu.drift[2], function()
			fog_menu.drift_y = fog_menu.drift_y + 1 * (fog_menu.drift[4] or 1)
			return true
		end)
	end

	--Opacity Pulse
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
  	fog_menu.drift_x + math.floor(camera_x * fog_menu.parallax_speed)%width,
  	fog_menu.drift_y + math.floor(camera_y * fog_menu.parallax_speed)%height,
  	dst_surface, 0, 0
  	)
end

return fog_menu