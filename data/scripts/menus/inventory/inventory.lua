--[[ guess_analyzer.lua
	version 0.1a1
	12 Oct 2020
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

local ITEM_LIST = {
	"seed_shoot",
	"soccer_kick",
	"spin_kick",
}

local CONFIGURATIONS = {
	standard = {
		max_items = 3,
		max_passives = 1,
		map_img = "standard",
		bg_img = "standard",
		coords = {
			--TODO
		}
	},
	--[[
	dlc = {
		max_items = 6,
		max_passives = 2,
		map_img = "TBD",
		bg_img = "TBD"
	},
	]]
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
	
	assert(sol.main.get_type(game)=="game", "Bad argument #1 to 'init' (sol.game expected)")
	assert(type(config)=="string", "Bad argument #2 to 'init' (string or nil expected)")
	local config_data = CONFIGURATIONS[config]
	assert(config_data, "Bad argument #2 to 'init', invalid configuration name: "..config)
	
	local MAX_ITEMS = config_data.max_items
	local MAP_IMG = config_data.map_img
	local BG_IMG_INV = config_data.bg_img.."_inv"
	local BG_IMG_MAP = config_data.bg_img.."_map"
	
	if game.inventory_menu then return end --menu has already been initialized for game
	game.inventory_menu = menu --save reference to menu
	function game:on_paused() sol.menu.start(game, menu) end
	
	--// create menu sprites
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
