--[[ inventory.lua
	version 0.1a1
	15 Oct 2020
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This menu script is started when the game is paused, displaying the player's inventory
	and a world map. The d-pad is used to select the active item. A marker for the hero is
	placed on the world map based on the current map. An objective marker may appear on at
	the world map location where the player must go in order to advance the story.
	
	Usage:
	
	Setting objectives:
	game:set_value("current_objective", "outskirts/farm") --set an objective (go to map)
	game:set_value("current_objective", nil) --remove the objective
]]

local menu_manager = {}

--convenience
local math__floor = math.floor
local math__ceil = math.ceil
local math__pi = math.pi

local ITEM_LIST = {
	"seed_shoot",
	"soccer_kick",
	"spin_kick",
}

local PASSIVE_LIST = {
	"pumpkin_jordans",
}

local OPENING_TRANSITION_TIME = 180 --Note: choose multiple of 90ms (i.e. multiple of both 18 & 10)
local CLOSING_TRANSITION_TIME = 90
local INV_MAX_DIST = 108 --16 extra pixels beyond width to make multiple of 18

--TODO move these to language manager script
local FONT = "ComicNeue-Angular-Bold"
local FONT_SIZE = 16
local FONT_COLOR = {191, 96, 0}

local CONFIGURATIONS = {
	standard = {
		max_items = 3,
		max_passives = 1,
		bg_img_inv = "menus/inventory/bg_inv.png",
		bg_img_map = "menus/inventory/bg_map.png",
	},
	--[[
	dlc = {
		max_items = 6,
		max_passives = 2,
		bg_img_inv = "TBD",
		bg_img_map = "TBD",
	},
	]]
}

local MAP_COORDS = {
	--standard maps
	['suburbs/cemetery'] = {"world_map", 22, 33},
	['suburbs/dennys'] = {"world_map", 22, 33},
	['suburbs/downtown'] = {"world_map", 22, 33},
		['suburbs/video_store'] = {"world_map", 22, 33},
	['suburbs/neighborhood'] = {"world_map", 22, 33},
	['outskirts/barn'] = {"world_map", 212, 64},
	['outskirts/farm'] = {"world_map", 22, 33},
	['outskirts/forest'] = {"world_map", 22, 33},
	['outskirts/pumpkin_cove'] = {"world_map", 22, 33},
		['outskirts/pumpkin_inside'] = {"world_map", 22, 33},
	['haunted_house/outside'] = {"world_map", 48, 18},
		['haunted_house/'] = {"world_map", 48, 18},
	
	--DLC maps
	--['some_dlc_map'] = {"dlc_map", 24, 8},
}

local MAP_BG_LIST = {
	world_map = "menus/inventory/world_map.png",
	--dlc_map = "menus/inventory/dlc_map.png",
	default = "world_map",
}

local PLACEMENTS = {
	passive_items = {24, 32, 36, 0},
	pumpkin_seeds = {18, 64},
	items = {24, 136, 36, 36},
	
	bg_img_map = {92, 0},
	objective_marker = {92+16, 41},
	map_title_text = {92+166, 32},
	map_objective_text = {92+166, 224},
}

--y offset for bouncing objective marker, cycle through these using repeating timer
local BOUNCE_Y = {[0] = 0, 1, 2, 1, 0} --last entry unused but ensures #BOUNCE_Y is correct size

local INPUTS = {
	right = {"move_cursor", 1, 0},
	left = {"move_cursor", -1, 0},
	up = {"move_cursor", 0, -1},
	down = {"move_cursor", 0, 1},
	pause = "stop",
}

--// Use repeating timer to simulate a movement since Solarus cannot handle movements faster than 1000 pixels/sec
	--properties (table) - list of properties for the slide movement
		--object (table or userdata) - object to move
		--context (timer context, optional) - see sol.timer for info; default: sol.main
		--max_distance (number, positive) - distance of movement in pixels
		--total_time (number, positive) - total time of movement in ms (use multiple of 10)
		--direction (string) - 'left' or 'right' for direction of movement
		--callback (function, optional) - callback function to call at end of movement, passes object
--TODO make this its own script?
local function slide(properties)
	--TODO assumes a fast speed that needs update every 10ms; could be smarter by choosing a slower than 10ms refresh rate
	
	local DIRECTIONS = {
		left = -1,
		right = 1,
	}
	
	assert(type(properties)=="table", "Bad argument #1 to 'slide' (table expected)")
	local object = properties.object
	assert(type(object)=="table" or type(object)=="userdata", "Bad property 'object' to 'slide' (table or userdata expected)")
	local context = properties.context or sol.main
	assert(type(context)=="table" or type(context)=="userdata", "Bad property 'context' to 'slide' (table or userdata or nil expected)")
	local max_distance = tonumber(properties.distance)
	assert(max_distance, "Bad property 'max_distance' to 'slide' (number expected)")
	max_distance = math__floor(max_distance)
	assert(max_distance > 0, "Bad property 'max_distance' to 'slide' (positive value expected)")
	local total_time = tonumber(properties.time)
	assert(total_time, "Bad property 'total_time' to 'slide' (number expected)")
	total_time = math__ceil(total_time/10)*10 --round up total time to nearest 10ms
	assert(total_time>0, "Bad property 'total_time' to 'slide' (positive value expected)")
	local direction = properties.direction
	assert(type(direction)=="string", "Bad property 'direction' to 'slide' (string expected)")
	direction = DIRECTIONS[direction]
	assert(direction, "Bad property 'direction' to 'slide' ('right' or 'left' expected)")
	local callback = properties.callback
	assert(not callback or type(callback)=="function", "Bad property 'callback' to 'slide' (function or nil expected)")
	
	--determine refresh rate (multiple of 10ms)
	local refresh_rate = 10*max_distance/total_time
	if refresh_rate <1 then
		refresh_rate = math__ceil(1/refresh_rate)*10 --multiple of 10ms
	else refresh_rate = 10 end --fastest refresh rate is 10ms
	
	total_time = math__ceil(total_time/refresh_rate)*refresh_rate --round up to nearest time interval
	local speed = math__ceil(refresh_rate*max_distance/total_time) --pixels per time interval
	local dir_speed = direction*speed --convenience
	
	local current_distance = 0
	
	--local max_time = math__ceil(max_distance/speed)*refresh_rate
	--print("slide!", total_time, speed, refresh_rate, max_time, speed*max_time/refresh_rate, max_distance)
	
	local timer = sol.timer.start(context, refresh_rate, function()
		current_distance = current_distance + speed
		if current_distance > max_distance then --exceeded max dist, increment by smaller amount for last step
			dir_speed = dir_speed - (current_distance - max_distance)
			print("adjust:", dir_speed)
		end
		object.x = object.x + dir_speed
		
		local is_repeat = current_distance < max_distance --keep going if not reached full distance yet
		if not is_repeat and callback then callback(object) end --call callback if done
		
		return is_repeat
	end)
end
	
function menu_manager:init(game, config)
	local config = config or "standard"
	
	local menu = {}
	
	local objective_x, objective_y = 0, 0 --coordinates of objective marker (if visible)
	local bounce_index = 0 --increment with repeating timer, the current index from BOUNCE_Y
	local objective_offset = 0 --vertical offset to apply to objective_marker, update via repeating timer
	local cursor_index
	
	--sprites
	local item_sprites = {}
	local passive_sprites = {}
	local pumpkin_seeds_sprite
	local objective_marker
	
	local world_map_surface
	
	--text
	local map_title_text = sol.text_surface.create{
		font = FONT,
		font_size = FONT_SIZE,
		color = FONT_COLOR,
		rendering_mode = "solid",
		horizontal_alignment = "center",
		vertical_alignment = "bottom",
		text_key = "menu.pause.map_title",
	}
	map_title_text:set_xy(unpack(PLACEMENTS.map_title_text))
	local map_objective_text = sol.text_surface.create{
		font = FONT,
		font_size = FONT_SIZE,
		color = FONT_COLOR,
		rendering_mode = "solid",
		horizontal_alignment = "center",
		vertical_alignment = "bottom",
		text = "",
	}
	map_objective_text:set_xy(unpack(PLACEMENTS.map_objective_text))
	
	--apply movements to these tables to affect position of left and right menu halves (horizontal component only!)
	local left_position = {x=0}
	local right_position = {x=0}
	
	assert(sol.main.get_type(game)=="game", "Bad argument #1 to 'init' (sol.game expected)")
	assert(type(config)=="string", "Bad argument #2 to 'init' (string or nil expected)")
	local config_data = CONFIGURATIONS[config]
	assert(config_data, "Bad argument #2 to 'init', invalid configuration name: "..config)
	
	local MAX_ITEMS = config_data.max_items
	local MAX_PASSIVES = config_data.max_passives
	local BG_INV = config_data.bg_img_inv
	local BG_MAP = config_data.bg_img_map
	
	if game.inventory_menu then return end --menu has already been initialized for game
	game.inventory_menu = menu --save reference to menu
	function game:on_paused() sol.menu.start(game, menu) end
	
	--// create menu sprites
	local bg_img_inv = sol.surface.create(BG_INV)
	local bg_fill = sol.surface.create() --semi-transparent background behind menu
	bg_fill:fill_color{0, 0, 0, 180}
	local BG_INV_WIDTH = bg_img_inv:get_size()
	local bg_img_map = sol.surface.create(BG_MAP)
	bg_img_map:set_xy(unpack(PLACEMENTS.bg_img_map))
	local BG_MAP_WIDTH = bg_img_map:get_size()
	local cursor_sprite = sol.sprite.create"menus/inventory/selector"
	
	function menu:move_cursor(dx, dy)
		print("move cursor:", dx, dy)
	end
	
	function menu:stop()
		--do closing animation
		slide{ --movement to left for inventory pane
			context = self,
			object = left_position,
			direction = "left",
			distance = INV_MAX_DIST,
			time = CLOSING_TRANSITION_TIME,
		}
		slide{ --movement to right for map pane
			context = self,
			object = right_position,
			direction = "right",
			distance = BG_MAP_WIDTH,
			time = CLOSING_TRANSITION_TIME,
			callback = function() --close menu when animation complete
				sol.menu.stop(self)
				game:set_paused(false)
				
				--remove sprites
				item_sprites = {}
				passive_sprites = {}
				pumpkin_seeds_sprite = nil
				world_map_surface = nil
				objective_marker = nil
			end,
		}
	end
	
	function menu:on_started()
		--create item sprites for items player currently has in inventory
		item_sprites = {max_count=0} --reset
		for i=1,MAX_ITEMS do
			local item_name = ITEM_LIST[i]
			local item_variant = game:get_item(item_name):get_variant()
			if item_variant > 0 then
				local item_sprite = sol.sprite.create"menus/inventory/items"
				item_sprite:set_animation(item_name)
				item_sprite:set_direction(item_variant-1)
				local offset_x, offset_y, dx, dy = unpack(PLACEMENTS.items)
				local x = math__floor((i-1) / 3) --x position in grid (0-1)
				local y = (i-1) % 3 --y position in grid (0-2)
				item_sprite:set_xy(offset_x + dx*x, offset_y + dy*y)
				item_sprites[i] = item_sprite
				item_sprites.max_count = i --tentative
			end
		end
		
		--create item sprites for passive items
		passive_sprites = {max_count=0} --reset
		for i=1,MAX_PASSIVES do
			local item_name = PASSIVE_LIST[i]
			local item_variant = game:get_item(item_name):get_variant()
			if item_variant > 0 then
				local item_sprite = sol.sprite.create"menus/inventory/items"
				item_sprite:set_animation(item_name)
				item_sprite:set_direction(item_variant-1)
				local offset_x, offset_y, dx, dy = unpack(PLACEMENTS.passive_items)
				item_sprite:set_xy(offset_x+dx*(i-1), offset_y)
				passive_sprites[i] = item_sprite
				passive_sprites.max_count = i --tentative
			end
		end
		
		--create sprite for pumpkin seeds
		local seed_count = game:get_item"pumpkin_seed":get_amount() or 0
		if seed_count>5 then seed_count = 5 end
		pumpkin_seeds_sprite = sol.sprite.create"menus/pumpkin_seeds"
		pumpkin_seeds_sprite:set_direction(seed_count)
		pumpkin_seeds_sprite:set_xy(unpack(PLACEMENTS.pumpkin_seeds))
		
		--update world map image
		local map = game:get_map()
		local map_id = map and map:get_id() or ""
		local world_map_name = MAP_COORDS[map_id]
		if not world_map_name then --use upper directory as id instead of map_id
			world_map_name = MAP_COORDS[map_id:match".-/"] or ""
		end
		world_map_name = world_map_name and world_map_name[1] or MAP_BG_LIST.default
		local world_map_path = MAP_BG_LIST[world_map_name]
		if world_map_path then
			world_map_surface = sol.surface.create(world_map_path)
			world_map_surface:set_xy(unpack(PLACEMENTS.objective_marker))
		else world_map_surface = nil end
		
		--update map objectives
		local objective_map = game:get_value"current_objective"
		objective_marker = sol.sprite.create"menus/arrow"
		objective_marker:set_direction(3) --down
		local objective_text = objective_map and sol.language.get_string"menu.pause.objective" or ""
		if objective_map then
			local sub_text = sol.language.get_string("map.location."..objective_map)
			if sub_text then
				objective_text = string.format(
					objective_text,
					sol.language.get_string("map.location."..objective_map)
				)
			else objective_text = "" end
			
			--update marker sprite position
			local coords = MAP_COORDS[objective_map]
			if coords then
				objective_marker:set_opacity(255)
				objective_x, objective_y = unpack(coords, 2)
				
				--create timer for bouncing objective_marker
				sol.timer.start(self, 250, function()
					bounce_index = (bounce_index + 1) % #BOUNCE_Y
					objective_offset = BOUNCE_Y[bounce_index]
					return true
				end)
			else objective_marker:set_opacity(0) end
		else objective_marker:set_opacity(0) end
		map_objective_text:set_text(objective_text)
		
		--start menus off-screen
		left_position.x = -1*INV_MAX_DIST
		right_position.x = BG_MAP_WIDTH
		
		--opening animation
		
		slide{
			context = self,
			object = left_position,
			direction = "right",
			distance = INV_MAX_DIST,
			time = OPENING_TRANSITION_TIME,
		}
		
		slide{
			context = self,
			object = right_position,
			direction = "left",
			distance = BG_MAP_WIDTH,
			time = OPENING_TRANSITION_TIME,
		}
	end
	
	function menu:on_command_pressed(command)
		local list = INPUTS[command]
		if type(list)=="string" then
			self[list](self)
			return true
		elseif type(list)=="table" then
			self[ list[1] ](self, unpack(list, 2))
			return true
		end
	end
	
	function menu:on_draw(dst_surface)
		--convenience
		local left_x = left_position.x
		local right_x = right_position.x
		
		bg_fill:draw(dst_surface)
		
		--menu left side elements
		bg_img_inv:draw(dst_surface, left_x, 0)
		for i=1,passive_sprites.max_count do
			local item_sprite = passive_sprites[i]
			if item_sprite then item_sprite:draw(dst_surface, left_x, 0) end
		end
		pumpkin_seeds_sprite:draw(dst_surface, left_x, 0)
		for i=1,item_sprites.max_count do
			local item_sprite = item_sprites[i]
			if item_sprite then item_sprite:draw(dst_surface, left_x, 0) end
		end
		
		--menu right side elements
		bg_img_map:draw(dst_surface, right_x, 0)
		if world_map_surface then world_map_surface:draw(dst_surface, right_x, 0) end
		objective_marker:draw(dst_surface, objective_x+right_x, objective_y+objective_offset)
		map_title_text:draw(dst_surface, right_x, 0)
		map_objective_text:draw(dst_surface, right_x, 0)
	end
	
	return menu
end

return menu_manager

--[[ Copyright 2020 Llamazing
  [] 
  [] This program is free software: you can redistribute it and/or modify it under the
  [] terms of the GNU General Public License as published by the Free Software Foundation,
  [] either version 3 of the License, or (at your option) any later version.
  [] 
  [] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  [] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  [] PURPOSE.  See the GNU General Public License for more details.
  [] 
  [] You should have received a copy of the GNU General Public License along with this
  [] program.  If not, see <http://www.gnu.org/licenses/>.
  ]]
