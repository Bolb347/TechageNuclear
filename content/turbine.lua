local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 4
local MAX_SIZE = 10

local STEAMPERTURBINE = 2
local STEAMTOWATER = 2

local POWERPERSTEAM = 100

local STEAMTANKCAPA = 1000

local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer or {} end
local M = function(pos) return minetest.get_meta(pos) end

local liquid = networks.liquid
local N = tubelib2.get_node_lvm
local LQD = function(pos) return (minetest.registered_nodes[N(pos).name] or {}).liquid end

local Cable = techage.ElectricCable
local power = networks.power

local function contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function get_form(self, pos)
    local nvm = techage.get_nvm(pos)
	return "size[8,8]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"image[3.5,0;1,1;"..techage.get_power_image(pos, nvm).."]"..
	"image[3.5,1;1,1;techage_form_arrow.png]"..
	"image_button[3.5,2;1,1;"..self:get_state_button_image(nvm)..";state_button;]"..
	"tooltip[3.5,2;1,1;"..self:get_state_tooltip(nvm).."]"..
	"list[current_player;main;0,4;8,4;]"..
	default.get_hotbar_bg(0, 4)
end

local function get_offsets(pos)
    local xPos = MAX_SIZE
    local xNeg = -MAX_SIZE
    local yPos = MAX_SIZE
    local yNeg = -MAX_SIZE
    local zPos = MAX_SIZE
    local zNeg = -MAX_SIZE
    local shellNodes = {"techage_nuclear:turbine_casing", "techage_nuclear:ta4_turbine_controller_pas", "techage_nuclear:ta4_turbine_controller_act", "techage_nuclear:turbine_pipe_in", "techage_nuclear:turbine_pipe_out", "techage_nuclear:cable_output"}
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

local function check_shell(pos)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg, y = pos.y + off.y_neg, z = pos.z + off.z_neg}
    local pos2 = {x = pos.x + off.x_pos, y = pos.y + off.y_pos, z = pos.z + off.z_pos}
    local in1 = {x = pos.x + off.x_neg + 1, y = pos.y + off.y_neg + 1, z = pos.z + off.z_neg + 1}
    local in2 = {x = pos.x + off.x_pos - 1, y = pos.y + off.y_pos - 1, z = pos.z + off.z_pos - 1}
    local _, node_tbl = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:turbine_casing", "techage_nuclear:ta4_turbine_controller_pas", "techage_nuclear:ta4_turbine_controller_act", "techage_nuclear:turbine_pipe_in", "techage_nuclear:turbine_pipe_out", "techage_nuclear:cable_output"})
    local _, in_tbl = minetest.find_nodes_in_area(in1, in2, {"techage_nuclear:turbine_casing", "techage_nuclear:ta4_turbine_controller_pas", "techage_nuclear:ta4_turbine_controller_act", "techage_nuclear:turbine_pipe_in", "techage_nuclear:turbine_pipe_out", "techage_nuclear:cable_output"})
    local length = off.x_pos - off.x_neg + 1
    local width = off.y_pos - off.y_neg + 1
    local height = off.z_pos - off.z_neg + 1
    local casing_size = (length * width * height) - ((length - 2) * (width - 2) * (height - 2))
    if (node_tbl["techage_nuclear:ta4_turbine_controller_pas"] + node_tbl["techage_nuclear:ta4_turbine_controller_act"]) > 1 then
        return false
    end
    if (node_tbl["techage_nuclear:turbine_casing"] + node_tbl["techage_nuclear:ta4_turbine_controller_pas"] + node_tbl["techage_nuclear:ta4_turbine_controller_act"] + node_tbl["techage_nuclear:turbine_pipe_in"] + node_tbl["techage_nuclear:turbine_pipe_out"] + node_tbl["techage_nuclear:cable_output"]) == casing_size then
        if (in_tbl["techage_nuclear:turbine_casing"] + in_tbl["techage_nuclear:ta4_turbine_controller_pas"] + in_tbl["techage_nuclear:ta4_turbine_controller_act"] + in_tbl["techage_nuclear:turbine_pipe_in"] + in_tbl["techage_nuclear:turbine_pipe_out"] + in_tbl["techage_nuclear:cable_output"]) == 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end

local function check_turbine_count(pos)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg + 1, y = pos.y + off.y_neg + 1, z = pos.z + off.z_neg + 1}
    local pos2 = {x = pos.x + off.x_pos - 1, y = pos.y + off.y_pos - 1, z = pos.z + off.z_pos - 1}
    local _, node_tbl = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:turbine"})
    return node_tbl["techage_nuclear:turbine"]
end

local function get_inlets(pos)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg, y = pos.y + off.y_neg, z = pos.z + off.z_neg}
    local pos2 = {x = pos.x + off.x_pos, y = pos.y + off.y_pos, z = pos.z + off.z_pos}
    local positions, _ = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:turbine_pipe_in"})
    return positions
end

local function get_outlets(pos)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg, y = pos.y + off.y_neg, z = pos.z + off.z_neg}
    local pos2 = {x = pos.x + off.x_pos, y = pos.y + off.y_pos, z = pos.z + off.z_pos}
    local positions, _ = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:turbine_pipe_out"})
    return positions
end

local function get_power_outlets(pos)
    local off = get_offsets(pos)
    local pos1 = {x = pos.x + off.x_neg, y = pos.y + off.y_neg, z = pos.z + off.z_neg}
    local pos2 = {x = pos.x + off.x_pos, y = pos.y + off.y_pos, z = pos.z + off.z_pos}
    local positions, _ = minetest.find_nodes_in_area(pos1, pos2, {"techage_nuclear:cable_output"})
    return positions
end

local function supply_power(pos, amount)
    local nvm = techage.get_nvm(pos)
    local meta = M(pos)
    local outdir = meta:get_int("outdir")
    local amnt = power.provide_power(pos, Cable, outdir, amount)
    return amnt
end

local function take_from_inlet(pos, amount, name)
    local nvm = techage.get_nvm(pos)
    local amnt, _ = liquid.srv_take(nvm, name, amount)
    if amnt == amount then
        return 0
    else
        return amnt
    end
end

local function add_to_outlet(pos, amount, name)
    local nvm = techage.get_nvm(pos)
    local amnt = liquid.srv_put(nvm, name, amount, STEAMTANKCAPA)
    if amnt == 0 then
        return 0
    else
        return amnt
    end
end

local function run(pos)
    local meta = M(pos)
	local owner_name = meta:get_string("owner")
    local fueled = false
    local nvm = techage.get_nvm(pos)
    if not check_shell(pos) then
        CRD(pos).State:idle(pos, nvm)
        return
    end
    local turbineCount = check_turbine_count(pos)
    local inlets = get_inlets(pos)
    local outlets = get_outlets(pos)
    local powerOutlets = get_power_outlets(pos)
    local steamCount = 0
    for _, pos in ipairs(inlets) do
        if techage.get_nvm(pos).liquid.amount ~= nil then
            steamCount = steamCount + techage.get_nvm(pos).liquid.amount
        end
    end
    if steamCount < turbineCount * STEAMPERTURBINE then
        CRD(pos).State:idle(pos, nvm)
        return
    else
        CRD(pos).State:keep_running(pos, nvm, COUNTDOWN_TICKS)
    end
    local waterSpace = STEAMTANKCAPA * #outlets
    for _, pos in ipairs(outlets) do
        if techage.get_nvm(pos).liquid.amount ~= nil then
            waterSpace = waterSpace - techage.get_nvm(pos).liquid.amount
        end
    end
    if waterSpace < (turbineCount * STEAMPERTURBINE) / STEAMTOWATER then
        minetest.chat_send_player(owner_name, "Turbine Error: Not enough water storage space")
        CRD(pos).State:blocked(pos, nvm)
        return
    else
        CRD(pos).State:keep_running(pos, nvm, COUNTDOWN_TICKS)
    end
    local taken = 0
    local put = 0
    local power_put = 0
    local validInlets = {}
    local validOutlets = {}
    local validPowerOutlets = {}
    for _, position in ipairs(inlets) do
        table.insert(validInlets, position)
    end
    while taken < turbineCount * STEAMPERTURBINE do
        if #validInlets == 0 then
            minetest.chat_send_player(owner_name, "Turbine Error: Not enough valid steam inlets")
            CRD(pos).State:idle(pos, nvm)
            break
        end
        for i, position in ipairs(validInlets) do
            if ((turbineCount * STEAMPERTURBINE) / #validInlets) == 0 then
                break
            end
            local amount = take_from_inlet(position, (turbineCount * STEAMPERTURBINE) / #validInlets, "techage_nuclear:steam")
            taken = taken + amount
            if amount == 0 then
                table.remove(validInlets, i)
                break
            end
        end
        if #validInlets == 0 then
            break
        end
    end

    for _, position in ipairs(outlets) do
        table.insert(validOutlets, position)
    end
    while put < (turbineCount * STEAMPERTURBINE) / STEAMTOWATER do
        if #validOutlets == 0 then
            minetest.chat_send_player(owner_name, "Turbine Error: Not enough valid steam outlets")
            CRD(pos).State:idle(pos, nvm)
            break
        end
        for i, position in ipairs(validOutlets) do
            if (((turbineCount * STEAMPERTURBINE) / STEAMTOWATER) / #validOutlets) == 0 then
                break
            end
            local amount = add_to_outlet(position, ((turbineCount * STEAMPERTURBINE) / STEAMTOWATER) / #validOutlets, "techage:water")
            put = put + amount
            if amount == 0 then
                table.remove(validOutlets, i)
                break
            end
        end
        if #validOutlets == 0 then
            break
        end
    end

    for _, position in ipairs(powerOutlets) do
        table.insert(validPowerOutlets, position)
    end
    for i, position in ipairs(validPowerOutlets) do
        local powerNeed = (turbineCount * STEAMPERTURBINE * POWERPERSTEAM) / #validPowerOutlets
        if powerNeed == 0 then
            break
        end
        local amount = supply_power(position, powerNeed)
        power_put = power_put + amount
        if amount == 0 then
            break
        end
        if amount >= (turbineCount * STEAMPERTURBINE * POWERPERSTEAM) / #validPowerOutlets - 0.5 then
            break
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
			return true
		else
			return false
		end
	else
		return false
	end
end

local tiles = {
    "techagenuclear_turbine_casing.png",
    "techagenuclear_turbine_casing.png",
    "techagenuclear_turbine_casing.png",
    "techagenuclear_turbine_casing.png",
    "techagenuclear_turbine_casing.png",
    "techagenuclear_turbine_controller_front.png"
}

local _, _, node_name_ta4 = 
techage.register_consumer("turbine_controller", "Turbine Controller", {act = tiles, pas = tiles}, {
    after_place_node = function(pos, placer)
    end,
    drawtype = "normal",
    paramtype = "light",
    cycle_time = CYCLE_TIME,
    standby_ticks = STANDBY_TICKS,
    on_rightclick = function(pos, node, clicker)
        techage.set_activeformspec(pos, clicker)
    end,
    formspec = get_form,
    tubing = {},
    node_timer = keep_running,
    on_receive_fields = function(pos, formname, fields, player)
        get_on_receive_fields(pos, fields, player)
        techage.set_activeformspec(pos, player)
    end,
    groups = {cracky = 2},
    can_dig = get_can_dig,
    sounds = default.node_sound_metal_defaults(),
    allow_metadata_inventory_put = false,
    allow_metadata_inventory_move = false,
    allow_metadata_inventory_take = false,
}, {false, false, false, true}, "techage_nuclear:ta")