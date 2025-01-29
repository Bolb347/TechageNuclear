local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 100
local MAX_SIZE = 10

local CELLHEAT = 8
local COOLHEAT = -3

local WATERPERCOOLER = 8
local WATERTOSTEAM = 2

local STEAMTANKCAPA = 1000

local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer or {} end
local M = function(pos) return minetest.get_meta(pos) end

local liquid = networks.liquid
local N = tubelib2.get_node_lvm
local LQD = function(pos) return (minetest.registered_nodes[N(pos).name] or {}).liquid end

local function contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function get_allow_metadata_inventory_put(pos, listname, index, stack, player)
	local meta = M(pos)
	local owner = meta:get_string("owner")
	if owner == player.get_player_name(player) then
		if listname == "src" then
			local state = CRD(pos).State
			if state then
				state:start_if_standby(pos)
			end
		end
		return stack:get_count()
	end
end

local function get_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function get_allow_metadata_inventory_take(pos, listname, index, stack, player)
	local meta = M(pos)
	local owner = meta:get_string("owner")
	if owner == player.get_player_name(player) then
		return stack:get_count()
	end
end

local function get_form(self, pos)
    local nvm = techage.get_nvm(pos)
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[context;src;0,0;1,1;]"..
	"item_image[0,0;1,1;techage_nuclear:fuel_rod]"..
	"image[0,0;1,1;techage_form_mask.png]"..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, nvm).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;"..self:get_state_button_image(nvm)..";state_button;]"..
	"tooltip[3.5,2;1,1;"..self:get_state_tooltip(nvm).."]"..
	"list[context;dst;5,0;1,1;]"..
	"item_image[5,0;1,1;techage_nuclear:fuel_waste]"..
	"image[5,0;1,1;techage_form_mask.png]"..
	"list[current_player;main;0,4;8,4;]"..
	"listring[context;dst]"..
	"listring[current_player;main]"..
	"listring[context;src]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0, 4)
end

local function move_items(inventory, index, input_stack, output_stack)
    local input = input_stack
    local output = output_stack
    if inventory:contains_item("src", input) then
        if inventory:room_for_item("dst", ouput) then
            inventory:add_item("dst", output)
            inventory:remove_item("src", input)
            return 0
        else
            return 1
        end
    else
        return 2
    end
end

local function get_offsets(pos)
    local xPos = MAX_SIZE
    local xNeg = -MAX_SIZE
    local yPos = MAX_SIZE
    local yNeg = -MAX_SIZE
    local zPos = MAX_SIZE
    local zNeg = -MAX_SIZE
    local shellNodes = {"techage_nuclear:reactor_casing", "techage_nuclear:ta4_reactor_controller_pas", "techage_nuclear:ta4_reactor_controller_act", "techage_nuclear:reactor_pipe_in", "techage_nuclear:reactor_pipe_out"}
    for x = 0,MAX_SIZE do
        local node = minetest.get_node({x = pos.x + x, y = pos.y, z = pos.z})
        if not contains(shellNodes, tostring(node.name)) then
            xPos = x
            break
        end
    end
    for x = 0,MAX_SIZE do
        local node = minetest.get_node({x = pos.x - x, y = pos.y, z = pos.z})
        if not contains(shellNodes, tostring(node.name)) then
            xNeg = -x
            break
        end
    end
    for y = 0,MAX_SIZE do
        local node = minetest.get_node({x = pos.x, y = pos.y + y, z = pos.z})
        if not contains(shellNodes, tostring(node.name)) then
            yPos = y
            break
        end
    end
    for y = 0,MAX_SIZE do
        local node = minetest.get_node({x = pos.x, y = pos.y - y, z = pos.z})
        if not contains(shellNodes, tostring(node.name)) then
            yNeg = -y
            break
        end
    end
    for z = 0,MAX_SIZE do
        local node = minetest.get_node({x = pos.x, y = pos.y, z = pos.z + z})
        if not contains(shellNodes, tostring(node.name)) then
            zPos = z
            break
        end
    end
    for z = 0,MAX_SIZE do
        local node = minetest.get_node({x = pos.x, y = pos.y, z = pos.z - z})
        if not contains(shellNodes, tostring(node.name)) then
            zNeg = -z
            break
        end
    end
    return {x_pos = xPos - 1, x_neg = xNeg + 1, y_pos = yPos - 1, y_neg = yNeg + 1, z_pos = zPos - 1, z_neg = zNeg + 1}
end

local function check_shell(pos, owner_name)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg, y = pos.y + off.y_neg, z = pos.z + off.z_neg}
    local pos2 = {x = pos.x + off.x_pos, y = pos.y + off.y_pos, z = pos.z + off.z_pos}
    local in1 = {x = pos.x + off.x_neg + 1, y = pos.y + off.y_neg + 1, z = pos.z + off.z_neg + 1}
    local in2 = {x = pos.x + off.x_pos - 1, y = pos.y + off.y_pos - 1, z = pos.z + off.z_pos - 1}
    local _, node_tbl = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:reactor_casing", "techage_nuclear:ta4_reactor_controller_pas", "techage_nuclear:ta4_reactor_controller_act", "techage_nuclear:reactor_pipe_in", "techage_nuclear:reactor_pipe_out"})
    local _, in_tbl = minetest.find_nodes_in_area(in1, in2, {"techage_nuclear:reactor_casing", "techage_nuclear:ta4_reactor_controller_pas", "techage_nuclear:ta4_reactor_controller_act", "techage_nuclear:reactor_pipe_in", "techage_nuclear:reactor_pipe_out"})
    local length = off.x_pos - off.x_neg + 1
    local width = off.y_pos - off.y_neg + 1
    local height = off.z_pos - off.z_neg + 1
    local casing_size = (length * width * height) - ((length - 2) * (width - 2) * (height - 2))
    if (node_tbl["techage_nuclear:ta4_reactor_controller_pas"] + node_tbl["techage_nuclear:ta4_reactor_controller_act"]) > 1 then
        minetest.chat_send_player(owner_name, "Casing invalid: too many controllers")
        return false
    end
    if (node_tbl["techage_nuclear:reactor_casing"] + node_tbl["techage_nuclear:ta4_reactor_controller_pas"] + node_tbl["techage_nuclear:ta4_reactor_controller_act"] + node_tbl["techage_nuclear:reactor_pipe_in"] + node_tbl["techage_nuclear:reactor_pipe_out"]) == casing_size then
        if (in_tbl["techage_nuclear:reactor_casing"] + in_tbl["techage_nuclear:ta4_reactor_controller_pas"] + in_tbl["techage_nuclear:ta4_reactor_controller_act"] + in_tbl["techage_nuclear:reactor_pipe_in"] + in_tbl["techage_nuclear:reactor_pipe_out"]) == 0 then
            return true
        else
            minetest.chat_send_player(owner_name, "Casing invalid: no inputs or outputs")
            return false
        end
    else
        minetest.chat_send_player(owner_name, "Casing invalid: not enough casing blocks")
        return false
    end
end

local function check_cell_count(pos)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg + 1, y = pos.y + off.y_neg + 1, z = pos.z + off.z_neg + 1}
    local pos2 = {x = pos.x + off.x_pos - 1, y = pos.y + off.y_pos - 1, z = pos.z + off.z_pos - 1}
    local _, node_tbl = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:reactor_fuelcell"})
    return node_tbl["techage_nuclear:reactor_fuelcell"]
end

local function check_cooler_count(pos)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg + 1, y = pos.y + off.y_neg + 1, z = pos.z + off.z_neg + 1}
    local pos2 = {x = pos.x + off.x_pos - 1, y = pos.y + off.y_pos - 1, z = pos.z + off.z_pos - 1}
    local _, node_tbl = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:reactor_cooler"})
    return node_tbl["techage_nuclear:reactor_cooler"]
end

local function get_inlets(pos)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg, y = pos.y + off.y_neg, z = pos.z + off.z_neg}
    local pos2 = {x = pos.x + off.x_pos, y = pos.y + off.y_pos, z = pos.z + off.z_pos}
    local positions, _ = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:reactor_pipe_in"})
    return positions
end

local function get_outlets(pos)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg, y = pos.y + off.y_neg, z = pos.z + off.z_neg}
    local pos2 = {x = pos.x + off.x_pos, y = pos.y + off.y_pos, z = pos.z + off.z_pos}
    local positions, _ = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:reactor_pipe_out"})
    return positions
end

local function take_from_inlet(pos, amount, name)
    local nvm = techage.get_nvm(pos)
    local amnt, _ = liquid.srv_take(nvm, name, amount)
    if amnt == amount or amnt == 0 then
        return 0
    else
        return amnt
    end
end

local function add_to_outlet(pos, amount, name)
    local nvm = techage.get_nvm(pos)
    local rest = liquid.srv_put(nvm, name, amount, STEAMTANKCAPA)
    if rest == amount or amnt == 0 then
        return 0
    else
        return amount - rest
    end
end

local function run(pos)
    local owner_name = M(pos):get_string("owner")
    local fueled = false
    local nvm = techage.get_nvm(pos)
    if not check_shell(pos, owner_name) then
        CRD(pos).State:idle(pos, nvm)
        return
    end
    local inventory = M(pos):get_inventory()
    local cellCount = check_cell_count(pos)
    local coolerCount = check_cooler_count(pos)
    local netHeat = (cellCount * CELLHEAT) + (coolerCount * COOLHEAT)
    local inlets = get_inlets(pos)
    local outlets = get_outlets(pos)
    local waterCount = 0
    if netHeat > 0 then
        CRD(pos).State:idle(pos, nvm)
        return
    end
    for _, pos in ipairs(inlets) do
        if techage.get_nvm(pos).liquid.amount ~= nil then
            waterCount = waterCount + techage.get_nvm(pos).liquid.amount
        end
    end
    WATERPERCOOLER = math.ceil(WATERPERCOOLER / (math.abs(netHeat - 1)))
    if waterCount < coolerCount * WATERPERCOOLER then
        CRD(pos).State:idle(pos, nvm)
        minetest.chat_send_player(owner_name, "Reactor Error: Reactor does not have enough water!")
        return
    else
        CRD(pos).State:keep_running(pos, nvm, COUNTDOWN_TICKS)
    end
    local steamSpace = STEAMTANKCAPA * #outlets
    for _, pos in ipairs(outlets) do
        if techage.get_nvm(pos).liquid.amount ~= nil then
            steamSpace = steamSpace - techage.get_nvm(pos).liquid.amount
        end
    end
    if steamSpace < coolerCount * WATERPERCOOLER * WATERTOSTEAM then
        CRD(pos).State:blocked(pos, nvm)
        minetest.chat_send_player(owner_name, "Reactor Error: Reactor is full of steam!")
        return
    else
        CRD(pos).State:keep_running(pos, nvm, COUNTDOWN_TICKS)
    end
    local rodCount = 0
    for index, stack in ipairs(inventory:get_list("src")) do
        if not stack:is_empty() then
            rodCount = rodCount + stack:get_count()
        end
    end
    if rodCount < cellCount then
        CRD(pos).State:idle(pos, nvm)
        minetest.chat_send_player(owner_name, "Reactor Error: Reactor does not have enough fuel rods!")
        return
    else
        CRD(pos).State:keep_running(pos, nvm, COUNTDOWN_TICKS)
    end
    for index, stack in ipairs(inventory:get_list("src")) do
        if not stack:is_empty() then
            local i_stack = ItemStack("techage_nuclear:fuel_rod")
            i_stack:set_count(cellCount)
            local o_stack = ItemStack("techage_nuclear:fuel_waste")
            o_stack:set_count(cellCount)
            local moved = move_items(inventory, index, i_stack, o_stack)
            if moved == 0 then
                CRD(pos).State:keep_running(pos, nvm, COUNTDOWN_TICKS)
            elseif moved == 1 then
                CRD(pos).State:blocked(pos, nvm)
                minetest.chat_send_player(owner_name, "Reactor Error: Reactor is full of nuclear waste!")
                return
            elseif moved == 2 then
                CRD(pos).State:idle(pos, nvm)
                minetest.chat_send_player(owner_name, "Reactor Error: Reactor does not have enough fuel rods!")
                return
            end
        end
    end
    local taken = 0
    local put = 0
    local validInlets = {}
    local validOutlets = {}
    for _, position in ipairs(inlets) do
        table.insert(validInlets, position)
    end
    while taken < coolerCount * WATERPERCOOLER do
        if #validInlets == 0 then
            CRD(pos).State:idle(pos, nvm)
            break
        end
        for i, position in ipairs(validInlets) do
            if ((coolerCount * WATERPERCOOLER) / #validInlets) == 0 then
                break
            end
            amount = take_from_inlet(position, (coolerCount * WATERPERCOOLER) / #validInlets, "techage:water")
            taken = taken + amount
            if amount == 0 then
                table.remove(validInlets, i)
                break
            end
        end
    end

    for _, position in ipairs(outlets) do
        table.insert(validOutlets, position)
    end
    while put < coolerCount * WATERPERCOOLER * WATERTOSTEAM do
        if #validOutlets == 0 then
            CRD(pos).State:idle(pos, nvm)
            break
        end
        for i, position in ipairs(validOutlets) do
            if ((coolerCount * WATERPERCOOLER) / #validOutlets) == 0 then
                break
            end
            amount = add_to_outlet(position, (coolerCount * WATERPERCOOLER * WATERTOSTEAM) / #validOutlets, "techage_nuclear:steam")
            put = put + amount
            if amount == 0 then
                table.remove(validOutlets, i)
                break
            end
        end
    end
end

local function keep_running(pos, elapsed)
    run(pos)
end

local function get_on_receive_fields(pos, fields, player)
	local meta = M(pos)
	local owner = meta:get_string("owner")
	if owner == player.get_player_name(player) then
		CRD(pos).State:state_button_event(pos, techage.get_nvm(pos), fields)
	end
end

local function get_can_dig(pos, player)
	local meta = M(pos)
	local owner = meta:get_string("owner")
	if owner == player.get_player_name(player) then
		if CRD(pos).State ~= "running" then
			local inventory = M(pos):get_inventory()
			return inventory:is_empty("dst") and inventory:is_empty("src")
		end
	else
		return false
	end
end

local tiles = {
    "techagenuclear_reactor_casing.png",
    "techagenuclear_reactor_casing.png",
    "techagenuclear_reactor_controller_tube_side2.png",
    "techagenuclear_reactor_controller_tube_side1.png",
    "techagenuclear_reactor_casing.png",
    "techagenuclear_reactor_controller_front.png"
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
techage.register_consumer("reactor_controller", "Reactor Controller", {act = tiles, pas = tiles}, {
    after_place_node = function(pos, placer)
        local inv = M(pos):get_inventory()
        inv:set_size('src', 1)
        inv:set_size('dst', 1)
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
        get_on_receive_fields(pos, fields, player)
        techage.set_activeformspec(pos, player)
    end,
    groups = {cracky = 2},
    can_dig = get_can_dig,
    sounds = default.node_sound_metal_defaults(),
    allow_metadata_inventory_put = get_allow_metadata_inventory_put,
    allow_metadata_inventory_move = get_allow_metadata_inventory_move,
    allow_metadata_inventory_take = get_allow_metadata_inventory_take,
}, {false, false, false, true}, "techage_nuclear:ta")