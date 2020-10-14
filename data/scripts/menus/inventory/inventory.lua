--[[ inventory.lua
	version 0.1a1
	13 Oct 2020
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
]]

local menu_manager = {}

--convenience
local math__pi = math.pi

local ITEM_LIST = {
	"seed_shoot",
	"soccer_kick",
	"spin_kick",
}

--NOTE: speed can't be >1000 so transition time can't be much less than 350ms (https://gitlab.com/solarus-games/solarus/-/issues/1307)
local OPENING_TRANSITION_TIME = 350
local CLOSING_TRANSITION_TIME = 350

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
}

local INPUTS = {
	right = {"move_cursor", 1, 0},
	left = {"move_cursor", -1, 0},
	up = {"move_cursor", 0, -1},
	down = {"move_cursor", 0, 1},
	pause = "stop",
}
	
function menu_manager:init(game, config)
	local config = config or "standard"
	
	local menu = {}
	
	local item_sprites = {}
	local passive_sprites = {}
	
	--apply movements to these tables to affect position of left and right menu halves (horizontal component only!)
	local left_position = {x=0, y=0}
	local right_position = {x=0, y=0}
	
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
	local BG_INV_WIDTH = bg_img_inv:get_size()
	local bg_img_map = sol.surface.create(BG_MAP)
	local BG_MAP_WIDTH = bg_img_map:get_size()
	local cursor_sprite = sol.sprite.create"menus/inventory/selector"
	
	function menu:move_cursor(dx, dy)
		print("move cursor:", dx, dy)
	end
	
	function menu:stop()
		--TODO closing animation
		
		print"stop!"
		
		sol.menu.stop(self)
		game:set_paused(false)
	end
	
	function menu:on_started()
		--create item sprites for items player currently has in inventory
		item_sprites = {} --reset
		for i=1,MAX_ITEMS do
			local item_name = ITEM_LIST[i]
			local item_variant = game:get_item(item_name):get_variant()
			if item_variant > 0 then
				local item_sprite = sol.sprite.create"menus/inventory/items"
				item_sprite:set_animation(item_name)
				item_sprite:set_direction(item_variant-1)
				item_sprites[i] = item_sprite
			end
		end
		
		passive_sprites = {} --reset
		for i=1,MAX_PASSIVES do
		end
		
		--TODO opening animation
		--menus start offscreen
		left_position.x = -1*BG_INV_WIDTH
		right_position.x = BG_MAP_WIDTH
		
		local movt_inv = sol.movement.create"straight"
		movt_inv:set_speed(1000*BG_INV_WIDTH/OPENING_TRANSITION_TIME)
		movt_inv:set_angle(0)
		movt_inv:set_max_distance(BG_INV_WIDTH)
		
		local movt_map = sol.movement.create"straight"
		movt_map:set_speed(1000*BG_MAP_WIDTH/OPENING_TRANSITION_TIME)
		movt_map:set_angle(math__pi)
		movt_map:set_max_distance(BG_MAP_WIDTH)
		
		movt_map:start(right_position)
		movt_inv:start(left_position)
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
		
		--menu left side elements
		bg_img_inv:draw(dst_surface, 0+left_x, 0)
		
		--menu right side elements
		bg_img_map:draw(dst_surface, 92+right_x, 0)
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
