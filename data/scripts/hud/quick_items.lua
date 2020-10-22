--[[ quick_items.lua
	version 1.0
	21 Oct 2020
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

--convenience
local math__floor = math.floor
local math__abs = math.abs
local math__pi = math.pi
local math__cos = math.cos
local math__sin = math.sin

--constants
local X_RANGE = 16 --max x offset when item sprites spin
local Y_RANGE = 8 --max y offset when item sprites spin
local W_STEP = 25 --should be approx 1.6 times X_RANGE (movement resolution)
local MOVT_SPEED = 64 --speed of carousel animation; if equal to W_STEP then elapsed time of 1 sec

--list of item names that can be assigned to item slot #1
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



--// update x scale (spin effect) of carousel sprites based on current offset.x value
--called by movement:on_position_changed() event for offset object; don't want to update scale in on_draw()
local function update_scale()
	local w = offset.x + zero_w
	for i,item_sprite in ipairs(carousel) do
		if item_sprite then --ignore non-visible sprites (value of false)
			local scale_x = math__cos((w + (i-2)*W_STEP) * math__pi/2 / W_STEP)
			item_sprite:set_scale(scale_x, 1)
		end
	end
end

function quick_item_builder:new(game, config)
	local menu = {}
	
	local INITIAL_DELAY = 750 --time in ms to begin scrolling when button held
	local REPEAT_DELAY = 500 --time in ms until moving to next item while scrolling
	
	--local scroll_direction
	local timer
	
	local active_inputs = {}
	--local item_list = {}
	
	local item_sprites = {} --list of item sprites player currently has in inventory
	local item_index --item_sprites index for currently selected sprite
	local carousel = {} --list of item sprites currently visible in on-screen selector
		--index 1 is item on left, index 2 is current item, index 3 is item on right
		--value changed to false for indices 1 & 3 when sprite no longer visible
	
	local carousel_movt --(sol.movement) equal to nil when movement not active
	local offset = {x=0, y=0} --movement object whose x value is used to calculate x, y & spin coordinates of carousel sprites
	local zero_w = 0 --left movements decrease by W_STEP, right movements increase by W_STEP, keeps track of position of current item
	local overflow = 0 --if items cycled faster than animation then keep track of excess here and skip animation ahead to keep up
		--negative integers add left motion, positive integers add right motion
	
	--// Returns an item sprite relative to the current item
		--offset (number, integer) - offset of zero is current item, -1 is item to left, +1 is item to right, etc.
		--return #1 (sol.sprite) - item sprite corresponding to the given offset value
	local function get_item_sprite(offset)
		local index = (item_index + offset - 1) % #item_sprites + 1
		return item_sprites[index]
	end
	
	--[[
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
	]]
	
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
	
	function menu:advance(amount)
		amount = tonumber(amount or 0)
		assert(amount, "Bad argument #1 to 'advance' (number expected)")
		amount = math__floor(amount)
		
		overflow = overflow + amount
		if overflow==0 then return end --don't do anything if returned to original position
		
		if math__abs(overflow)%#item_sprites == 0 then return end --do nothing if would spin back to current item
		
		--take immediate action if movement not currently active
		if not carousel_movt then
			local is_right = overflow > 0 --true if motion is to right
			local angle --angle to use for carousel movement (0 to 2*pi)
			if is_right then --spin to right
				carousel[3] = get_item_sprite(overflow)
				angle = math__pi
			else --i.e. overflow is < 0; spin to left
				carousel[1] = get_item_sprite(overflow)
				angle = 0
			end
			item_index = (item_index - 1 + overflow) % #item_sprites + 1
			
			overflow = 0 --reset so can accumulate during movement
			
			--create carousel movement; always rotate 1 position regardless of number of items to pass through
			local movement = sol.movement.create"straight"
			movement:set_speed(MOVT_SPEED)
			movement:set_angle(angle)
			movement:set_max_distance(W_STEP)
			movement.on_position_changed = update_scale
			movement:start(offset, function()
				if is_right then
					--move carousel sprites by 1 to left and remove all but index 2
					table.remove(carousel, 1)
					carousel[1] = false
					carousel[3] = false
					zero_w = zero_w + W_STEP
				else --i.e. motion is to left
					--move carousel sprites by 1 to right and remove all but index 2
					table.insert(carousel, 1, false)
					carousel[3] = false
					carousel[4] = nil
					zero_w = zero_w - W_STEP
				end
				
				carousel_movt = nil
				
				if overflow ~= 0 then
					self:advance(0)
				end
			end)
			carousel_movt = movement
			--TODO set active item
			--TODO start timer to close menu
		else return end --else action will be processed when current movement is done
	end
	
	--// Each time the menu is started
	function menu:on_started()
		active_inputs = {} --reset
		
		--set item_index to currently active item
		local active_item = game:get_item_assigned(1)
		local active_item_name = active_item and active_item:get_name()
		
		item_sprites = {}
		for i,item_name in ipairs(ITEM_LIST) do
			local item_variant = game:get_item(item_name):get_variant()
			if item_variant > 0 then
				local item_sprite = sol.sprite.create"menus/inventory/items"
				item_sprite:set_animation(item_name)
				item_sprites[i] = item_sprite
			
				if active_item_name==item_name then item_index = #item_sprites end
			end
		end
		item_index = item_index or 1
		
		offset = {x=0, y=0}
		zero_w = 0
		overflow = 0
		
		carousel = {false, item_sprites[item_index], false}
		update_scale()
	end
	
	--// Actions to perform when menu closes
	function menu:on_finished()
		item_sprites = nil
		carousel = nil
		offset = nil
		
		if carouesl_movt then
			carousel_movt:stop()
			carousel_movt = nil
		end
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
		--if key=="i" then self:advance(-1) return true end --OBSOLETE
		
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
		local game = sol.main:get_game()
		local hero = game:get_hero()
		local hero_x, hero_y = hero:get_position()
		local w = offset.x + zero_w
		
		for i,item_sprite in ipairs(carousel) do
			if item_sprite then
				local w = w + (i-2)*W_STEP
				local offset_x = X_RANGE * math__sin(w * math__pi/2 / W_STEP)
				local offset_y = -Y_RANGE/W_STEP^2 * w * w
				item_sprite:draw(dst_surface, hero_x+offset_x, hero_y-40+offset_y)
			end
		end
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
