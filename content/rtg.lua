local STANDBY_TICKS = 3
local COUNTDOWN_TICKS = 4
local CYCLE_TIME = 1

local POWER = 40

local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer or {} end
local M = function(pos) return minetest.get_meta(pos) end

local Cable = techage.ElectricCable
local power = networks.power

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

local function supply_power(pos, amount)
    local nvm = techage.get_nvm(pos)
    local meta = M(pos)
    local outdir = meta:get_int("outdir")
	-- if oudir == 5 then
	-- 	outdir = 2
	-- end
    local amnt = power.provide_power(pos, Cable, outdir, amount)
    return amnt
end

local function run(pos)
    supply_power(pos, POWER)
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
    "techagenuclear_rtg.png"
}

local _, _, node_name_ta4 = 
techage.register_consumer("rtg", "Radioisotope Thermoelectric Generator", {act = tiles, pas = tiles}, {
    after_place_node = function(pos)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
    drawtype = "normal",
    paramtype = "light",
    cycle_time = CYCLE_TIME,
    standby_ticks = STANDBY_TICKS,
    on_rightclick = function(pos, node, clicker)
        techage.set_activeformspec(pos, clicker)
    end,
    formspec = get_form,
    paramtype2 = "facedir",
    tubing = {},
    node_timer = keep_running,
    on_rotate = screwdriver.disallow,
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

power.register_nodes({"techage_nuclear:ta4_rtg_pas", "techage_nuclear:ta4_rtg_act"}, Cable, "con", {"R"})