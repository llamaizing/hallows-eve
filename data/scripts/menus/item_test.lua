local menu = {}

--convenience
local math__floor = math.floor
local math__abs = math.abs
local math__pi = math.pi
local math__cos = math.cos
local math__sin = math.sin

local X_RANGE = 16 --max x offset when item sprites spin
local Y_RANGE = 8 --max y offset when item sprites spin
local W_STEP = 25 --should be approx 1.6 times X_RANGE (movement resolution)
local MOVT_SPEED = 64 --speed of carousel animation; if equal to W_STEP then elapsed time of 1 sec

--list of item names that can be assigned to item slot #1
local ITEM_LIST = {
	"seed_shoot",
	"soccer_kick",
	"spin_kick",
}

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
	local game = sol.main.get_game() --TODO remove
	--set item_index to currently active item
	local active_item = game:get_item_assigned(1)
	local active_item_name = active_item and active_item:get_name()
	
	item_sprites = {}
	for i,item_name in ipairs(ITEM_LIST) do
		local item_sprite = sol.sprite.create"menus/inventory/items"
		item_sprite:set_animation(item_name)
		item_sprites[i] = item_sprite
		
		if active_item_name==item_name then item_index = i end
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

function menu:on_key_pressed(key)
	if key=="i" then self:advance(-1) return true end
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