--[[ quick_items.lua
	version 1.0
	23 Oct 2020
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This menu script is displayed on the HUD when the player scrolls through the available
	slot #1 items to quickly change items without opening the pause menu.
	
	The menu is always active while a game is running to process user inputs, but the menu
	is no longer visible after a delay from the last time that the active item is changed.
	
	Usage:
	require("scripts/menus/quick_items.lua"):init(game)
	game.quick_menu --access the menu from other scripts
--]]

require"scripts/multi_events"

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

--list of items that can be assigned to slot #1
local ITEM_LIST = {
	"seed_shoot",
	"soccer_kick",
	"spin_kick",
}
for i,item_name in ipairs(ITEM_LIST) do ITEM_LIST[item_name] = i end --reverse lookup

--converts directions "right" and "left" to amounts to shift carousel
local DIRECTIONS = {
	left = -1,
	right = 1,
}


function quick_item_builder:init(game)
	local menu = {}
	local hero = game:get_hero()
	
	if game.quick_items then return end --only init once per game
	game.quick_items = menu
	
	local INITIAL_DELAY = 600 --time in ms to begin scrolling when button held
	local REPEAT_DELAY = 300 --time in ms until moving to next item while scrolling
	local HIDE_DELAY = 1000 --time in ms to hide menu after movement finished
	
	local is_visible = false --(boolean) menu only drawn if true (hide until button pressed)
	local scroll_direction --(string or nil) "right" or "left" for direction of scrolling when button held down; nil for not active
	local repeat_timer --(sol.timer) repeating timer for when scrolling button held down
	local hide_timer --(sol.timer) timer from end of movement to hide menu
	
	local active_inputs = {} --(table, key/value) keeps track of held down buttons; keys are "key" or "joy_button"
		--values are "right" or "left" corresponding to button held down, or nil for none
	--local item_list = {}
	
	local item_sprites = {} --(table, array) list of item sol.sprites player currently has in inventory (circular buffer)
	local item_index --(number, positive integer) item_sprites index for currently selected sprite
		--NOTE: nil until menu:on_started() and nil again after menu:on_finished()
	local carousel = {} --(table, array) list of item sol.sprites currently visible in on-screen selector
		--index 1 is item on left, index 2 is current item, index 3 is item on right
		--value is false for indices 1 & 3 when sprite no longer visible
		--NOTE: ensure same sprite does not exist in array more than one time or else both will have same x_scale (bad!)
	
	local carousel_movt --(sol.movement) equal to nil when movement not active
	local offset = {x=0, y=0} --movement object whose x value is used to calculate x, y & spin coordinates of carousel sprites
	local zero_w = 0 --(number, integer) left movements decrease by W_STEP, right movements increase by W_STEP, keeps track of position of current item
	local overflow = 0 --(number, integer) if items cycled faster than animation then keep track of excess here and skip animation ahead to keep up
		--negative integers add left motion, positive integers add right motion
	
	--// Returns an item sprite relative to the current item
		--offset (number, integer) - offset of zero is current item, -1 is item to left, +1 is item to right, etc.
		--return #1 (sol.sprite) - item sprite corresponding to the given offset value
	local function get_item_sprite(offset)
		local index = (item_index + offset - 1) % #item_sprites + 1
		return item_sprites[index]
	end
	
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
	
	--// Stops existing repeat_timer
	local function start_repeat_timer()
		if repeat_timer then repeat_timer:stop() end
		repeat_timer = sol.timer.start(menu, INITIAL_DELAY, function()
			if not scroll_direction then return end --abort if scroll_direction no longer set
			menu:advance(DIRECTIONS[scroll_direction])
			return REPEAT_DELAY
		end)
		repeat_timer:set_suspended_with_map(true)
	end
	
	local function start_hide_timer()
		if hide_timer then hide_timer:stop() end
		hide_timer = sol.timer.start(menu, HIDE_DELAY, function()
			is_visible = false
		end)
		hide_timer:set_suspended_with_map(true)
	end
	
	local function input_pressed(direction, input_type)
		if not direction then return end
		if active_inputs[input_type] == direction then return end --ignore double-presses
		
		assert(type(direction)=="string", "Bad argument #1 to 'input_pressed' (string expected)")
		local amount = DIRECTIONS[direction]
		assert(amount, "Bad argument #1 to 'input_pressed', invalid direction: "..direction)
		
		is_visible = true
		
		--clear any active inputs in different direction
		for input,dir in pairs(active_inputs) do
			if dir ~= direction then active_inputs[input] = nil end
		end
		active_inputs[input_type] = direction
		
		scroll_direction = direction
		menu:advance(amount)
		if not repeat_timer then start_repeat_timer() end
	end
	
	local function input_released(direction, input_type)
		if not direction then return end
		assert(type(direction)=="string", "Bad argument #1 to 'input_released' (string expected)")
		
		if active_inputs[input_type] == direction then
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
				if repeat_timer then repeat_timer:stop(); repeat_timer = nil end
				if not hide_timer then start_hide_timer() end
			end
		end --else ignore release if wasn't previously active
	end
	
	--// Advances carousel by amount
		--amount (number, integer) - amount to move carousel (positive moves right, negative left)
			--NOTE: if already moving then amount gets added to overflow and will take effect later
	function menu:advance(amount)
		amount = tonumber(amount or 0)
		assert(amount, "Bad argument #1 to 'advance' (number expected)")
		amount = math__floor(amount)
		
		if hide_timer then hide_timer:stop(); hide_timer = nil end
		
		overflow = overflow + amount
		if overflow==0 then return end --don't do anything if returned to original position (prevents same sprite from appearing twice in carousel)
		
		if math__abs(overflow) % #item_sprites == 0 then return end --do nothing if would spin back to current item
		
		is_visible = true
		
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
			start_hide_timer()
			
			--set active item
			local active_item_name = item_sprites[item_index]:get_animation()
			local active_item = game:get_item(active_item_name)
			game:set_item_assigned(1, active_item)
		else return end --else action will be processed when current movement is done
	end
	
	local function update_item_list()
		--set item_index to currently active item
		local active_item = game:get_item_assigned(1)
		local active_item_name = active_item and active_item:get_name()
		
		item_sprites = {}
		for i,item_name in ipairs(ITEM_LIST) do
			local item_variant = game:get_item(item_name):get_variant()
			if item_variant > 0 then
				local item_sprite = sol.sprite.create"menus/inventory/items"
				item_sprite:set_animation(item_name)
				table.insert(item_sprites, item_sprite)
			
				if active_item_name==item_name then item_index = #item_sprites end
			end
		end
		item_index = item_index or 1
		
		if carousel then carousel[2] = item_sprites[item_index] end
	end
	
	--// Each time the menu is started
	function menu:on_started()
		active_inputs = {} --reset
		
		update_item_list()
		
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
		
		if carouesl_movt then carousel_movt:stop(); carousel_movt = nil end
	end
	
	game:register_event("on_paused", function()
		is_visible = false
		if hide_timer then hide_timer:stop(); hide_timer = nil end
		
		--abort carousel if active
		if carousel_movt then carousel_movt:stop(); carousel_movt = nil end
		if carousel then
			carousel[1] = false
			carousel[3] = false
		end
		
		--advance to item that should be active
		if overflow ~= 0 then
			item_index = (item_index + overflow - 1) % #item_sprites + 1
			local active_item_name = item_sprites[item_index]:get_animation()
			local active_item = game:get_item(active_item_name)
			game:set_item_assigned(1, active_item)
			overflow = 0
		end
		
		--reset position
		offset.x = 0
		zero_w = 0
		
		--reset held any buttons
		actove_inputs = {}
		scroll_direction = nil
		if repeat_timer then repeat_timer:stop(); repeat_timer = nil end
	end, true) --ensure this event triggers before inventory menu on_paused event
	
	game:register_event("on_unpaused", function()
		update_item_list()
	end)
	
	function menu:on_key_pressed(key)
		if not game:is_suspended() then --ignore presses while suspended
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
		if is_visible then
			local camera = game:get_map():get_camera()
			local camera_x, camera_y = camera:get_position()
			local hero_x, hero_y = hero:get_position()
			local w = offset.x + zero_w
			
			for i,item_sprite in ipairs(carousel) do
				if item_sprite then
					local w = w + (i-2)*W_STEP
					local offset_x = X_RANGE * math__sin(w * math__pi/2 / W_STEP)
					local offset_y = -Y_RANGE/W_STEP^2 * w * w
					item_sprite:draw(
						dst_surface,
						hero_x - camera_x + offset_x,
						hero_y - camera_y - 40 + offset_y
					)
				end
			end
		end
	end
	
	
	local item_meta = sol.main.get_metatable"item"
	item_meta:register_event("on_obtaining", function(item, variant, savegame_variable)
		is_visible = false --hide so brandish animation is visible
		
		--only update list if new item is assignable to item slot
		if ITEM_LIST[item:get_name()] then update_item_list() end
	end)
	
	if not sol.menu.is_started(menu) then sol.menu.start(game, menu) end
	
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
