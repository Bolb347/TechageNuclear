local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 4

local RECIPES = {}

local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer or {} end
local M = function(pos) return minetest.get_meta(pos) end

local function get_allow_metadata_inventory_put(pos, listname, index, stack, player)
	if listname == "src" then
		local state = CRD(pos).State
		if state then
			state:start_if_standby(pos)
		end
	end
	return stack:get_count()
end

local function get_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function get_allow_metadata_inventory_take(pos, listname, index, stack, player)
	return stack:get_count()
end

local function get_form(self, pos)
    local nvm = techage.get_nvm(pos)
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;3,3;]"..
	"item_image[0,0;1,1;techage_nuclear:fuel_waste]"..
	"image[0,0;1,1;techage_form_mask.png]"..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, nvm).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;"..self:get_state_button_image(nvm)..";state_button;]"..
	"tooltip[3.5,2;1,1;"..self:get_state_tooltip(nvm).."]"..
	"list[context;dst;5,0;3,3;]"..
	"item_image[5,0;1,1;techage_nuclear:U238_pile]"..
	"item_image[6,0;1,1;techage_nuclear:U235_pile]"..
	"item_image[7,0;1,1;techage_nuclear:Pu239_pile]"..
	"image[5,0;1,1;techage_form_mask.png]"..
    "image[6,0;1,1;techage_form_mask.png]"..
    "image[7,0;1,1;techage_form_mask.png]"..
	"list[current_player;main;0,4;8,4;]"..
	"listring[context;dst]"..
	"listring[current_player;main]"..
	"listring[context;src]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0, 4)
end

local function move_items(inventory, index, input_stack, output_stacks)
    local input = input_stack
    local room = true
    if inventory:contains_item("src", input) then
        for _, output in ipairs(output_stacks) do
            if not inventory:room_for_item("dst", ouput) then
                room = false
            end
        end
    else
        return 2
    end
    if room == false then
        return 1
    else
        inventory:remove_item("src", input)
        for _, output in ipairs(output_stacks) do
            inventory:add_item("dst", output)
        end
    end
end

local function reprocess(pos)
    local inventory = M(pos):get_inventory()
    local nvm = techage.get_nvm(pos)
    for _, recipe in ipairs(RECIPES) do
        for index, stack in ipairs(inventory:get_list("src")) do
            if not stack:is_empty() then
                local moved = move_items(inventory, index, recipe.input_stack, recipe.output_stacks)
                if moved == 0 then
                    CRD(pos).State:keep_running(pos, nvm, COUNTDOWN_TICKS)
                elseif moved == 1 then
                    CRD(pos).State:blocked(pos, nvm)
                elseif moved == 2 then
                    CRD(pos).State:idle(pos, nvm)
                end
            end
        end
    end
end

local function keep_running(pos, elapsed)
    reprocess(pos)
end

local function get_on_receive_fields(pos, fields)
	CRD(pos).State:state_button_event(pos, techage.get_nvm(pos), fields)
end

local function get_can_dig(pos)
	local inventory = M(pos):get_inventory()
	return inventory:is_empty("dst") and inventory:is_empty("src")
end

local tiles = {
    "techagenuclear_reprocessor_top.png",
    "techagenuclear_reprocessor_top.png",
    "techagenuclear_reprocessor_tube_side2.png",
    "techagenuclear_reprocessor_tube_side1.png",
    "techagenuclear_reprocessor_back.png",
    "techagenuclear_reprocessor_front.png"
}

local get_tubing = {
	on_pull_item = function(pos, in_dir, num)
		if M(pos):get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.get_items(pos, inv, "dst", num)
		end
	end,
	on_push_item = function(pos, in_dir, stack)
		if M(pos):get_int("push_dir") == in_dir or in_dir == 5 then
			local inv = M(pos):get_inventory()
			return techage.put_items(inv, "src", stack)
		end
	end,
	on_unpull_item = function(pos, in_dir, stack)
		if M(pos):get_int("pull_dir") == in_dir then
			local inv = M(pos):get_inventory()
			return techage.put_items(inv, "dst", stack)
		end
	end
}

local _, _, node_name_ta4 = 
techage.register_consumer("reprocessor", "Reprocessor", {act = tiles, pas = tiles}, {
    after_place_node = function(pos, placer)
        local inv = M(pos):get_inventory()
        inv:set_size('src', 9)
        inv:set_size('dst', 9)
    end,
    drawtype = "normal",
    paramtype = "light",
    cycle_time = CYCLE_TIME,
    standby_ticks = STANDBY_TICKS,
    on_rightclick = function(pos, node, clicker)
        techage.set_activeformspec(pos, clicker)
    end,
    formspec = get_form,
    tubing = get_tubing,
    node_timer = keep_running,
    on_receive_fields = function(pos, formname, fields, player)
        get_on_receive_fields(pos, fields)
        techage.set_activeformspec(pos, player)
    end,
    groups = {cracky = 2},
    can_dig = get_can_dig,
    sounds = default.node_sound_metal_defaults(),
    power_consumption = {0, 20, 20, 20},
    power_sides = {B = 1},
    allow_metadata_inventory_put = get_allow_metadata_inventory_put,
    allow_metadata_inventory_move = get_allow_metadata_inventory_move,
    allow_metadata_inventory_take = get_allow_metadata_inventory_take,
}, {false, false, false, true}, "techage_nuclear:ta")

local i_stack = ItemStack("techage_nuclear:fuel_waste")
i_stack:set_count(10)
local u235_stack = ItemStack("techage_nuclear:U235_pile")
u235_stack:set_count(8)
local u238_stack = ItemStack("techage_nuclear:U238_pile")
u238_stack:set_count(25)
local pu239_stack = ItemStack("techage_nuclear:Pu239_pile")
pu239_stack:set_count(3)
local o_stacks = {u238_stack, u235_stack, pu239_stack}
table.insert(RECIPES, {input_stack = i_stack, output_stacks = o_stacks})