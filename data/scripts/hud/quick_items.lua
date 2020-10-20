--[[ quick_items.lua
	version 1.0
	19 Oct 2020
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This menu script is displayed on the HUD when the player scrolls through the available
	slot #1 items to quickly change items without opening the pause menu.
	
	Usage:
	Started automatically by the scripts/hud/hud.lua script
--]]

local quick_item_builder = {}

local INPUT_LIST = {
	key = {left="a", right="s", get_input="is_key_pressed"},
	joypad_button = {left=5, right=6, get_input="is_joypad_button_pressed"},
}

local ITEM_LIST = {
	"seed_shoot",
	"soccer_kick",
	"spin_kick",
}

local DIRECTIONS = {
	left = -1,
	right = 1,
}

function quick_item_builder:new(game, config)
	local menu = {}
	
	local INITIAL_DELAY = 750 --time in ms to begin scrolling when button held
	local REPEAT_DELAY = 500 --time in ms until moving to next item while scrolling
	
	local scroll_direction
	local timer
	
	local active_inputs = {}
	local item_list = {}
	local item_index
	
	local function next_item(direction)
		direction = direction or scroll_direction
		local amount = DIRECTIONS[direction]
		
		if #item_list > 1 and amount then
			item_index = (item_index + amount - 1)%#item_list + 1
			local new_item_name = item_list[item_index]
			local new_item = new_item_name and game:get_item(new_item_name)
			if new_item then game:set_item_assigned(1, new_item) end
			
			--TODO create movement
		end
	end
	
	local function start_timer()
		if timer then timer:stop() end
		timer = sol.timer.start(menu, INITIAL_DELAY, function()
			next_item()
			return REPEAT_DELAY
		end)
		timer:set_suspended_with_map(true)
	end
	
	local function input_pressed(direction, input_type)
		if not direction then return end
		if active_inputs[input_type] == direction then return end --ignore double-presses
		
		--clear any active inputs in different direction
		for input,dir in pairs(active_inputs) do
			if dir ~= direction then active_inputs[input] = nil end
		end
		active_inputs[input_type] = direction
		
		--direction changed, restart timer
		if scroll_direction ~= direction then
			scroll_direction = direction
			start_timer()
		else --already scrolling
			--advance item immediately if not in middle of movement
			--TODO
		end
	end
	
	local function input_released(direction, input_type)
		if not direction then return end
		if active_inputs[input_type] == direction then --ignore release if wasn't previously active
			active_inputs[input_type] = nil
			
			local is_scrolling = false --tentative
			for input,dir in pairs(active_inputs) do
				if dir == direction then --scrolling still active from other input
					is_scrolling = true
					break
				end
			end
			
			--no inputs active anymore, stop scrolling
			if not is_scrolling then
				scroll_direction = nil
				if timer then timer:stop() end
			end
		end
	end
	
	function menu:on_started()
		active_inputs = {} --reset
		item_list = {}
		item_index = nil
		
		--create list of current items
		local active_item = game:get_item_assigned(1)
		local active_item_name = active_item:get_name()
		for _,item_name in ipairs(ITEM_LIST) do
			local item_variant = game:get_item(item_name):get_variant()
			if item_variant > 0 then
				table.insert(item_list, item_name)
				if active_item_name==item_name then item_index = #item_list end
			end
		end
		
		--TODO create sprites
	end
	
	function menu:on_finished()
		if timer then timer:stop() end
		scroll_direction = nil
	end
	
	function menu:on_paused()
		--TODO fade out
	end
	
	function menu:on_unpaused()
		menu:rebuild_surface()
		--TODO fade in
		
		--remove any inputs that are not longer active when unpaused
		if scroll_direction then --only care if actively scrolling
			local is_stoped = false --tentative
			for input,dir in pairs(active_inputs) do
				local info = INPUT_LIST[input]
				if info then
					if not sol.input[info.get_input](dir) then --if input now no longer active
						if active_inputs[input]==scroll_direction then is_stopped = true end
						active_inputs[input] = nil
					end
				end
			end
			
			--if at least on input is now stopped then check if all are now stopped
			if is_stopped then
				local is_active = false --tentative
				for input,dir in pairs(active_inputs) do
					if dir==scroll_direction then
						is_active = true
						break --don't need to check if more than one is active
					end
				end
				
				--no inputs are now active, stop timer
				if not is_active then
					scroll_direction = nil
					if timer then timer:stop() end
				end
			end
		end
	end
	
	function menu:on_key_pressed(key)
		if not game:is_paused() then --ignore presses while paused
			if key=="a" then
				input_pressed("left", "key")
				return true
			elseif key=="s" then
				input_pressed("right", "key")
				return true
			end
		end
	end
	
	function menu:on_key_released(key)
		if not game:is_paused() then --ignore releases while paused
			if key=="a" then
				input_released("left", "key")
				return true
			elseif key=="s" then
				input_released("right", "key")
				return true
			end
		end
	end
	
	function menu:on_draw(dst_surface)
		
	end
	
	return menu
end

return quick_item_builder

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
