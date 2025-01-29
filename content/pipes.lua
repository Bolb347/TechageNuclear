local M = minetest.get_meta
local N = tubelib2.get_node_lvm
local LQD = function(pos) return (minetest.registered_nodes[N(pos).name] or {}).liquid end
local S = techage.S
local Pipe = techage.LiquidPipe
local liquid = networks.liquid

local CAPACITY = 1000

local function peek_liquid(pos, indir)
	local nvm = techage.get_nvm(pos)
	return liquid.srv_peek(nvm)
end

local function take_liquid(pos, indir, name, amount)
	local nvm = techage.get_nvm(pos)
	if (M(pos):get_int("keep_assignment") or 0) == 1 then
		amount = math.max(math.min(amount, ((nvm.liquid or {}).amount or 0) - 1), 0)
	end
	amount, name = liquid.srv_take(nvm, name, amount)
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
	end
	return amount, name
end

local function put_liquid(pos, indir, name, amount)
    local nvm = techage.get_nvm(pos)
    local leftover = liquid.srv_put(nvm, name, amount, LQD(pos).capa)
    if techage.is_activeformspec(pos) then
        M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
    end
    return leftover
end

local function untake_liquid(pos, indir, name, amount)
	local nvm = techage.get_nvm(pos)
	local leftover = liquid.srv_put(nvm, name, amount, LQD(pos).capa)
	if techage.is_activeformspec(pos) then
		M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
	end
	return leftover
end

local function on_rightclick(pos, node, clicker)
	local nvm = techage.get_nvm(pos)
	techage.set_activeformspec(pos, clicker)
	M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
	minetest.get_node_timer(pos):start(2)
end

local function node_timer(pos, elapsed)
	if techage.is_activeformspec(pos) then
		local nvm = techage.get_nvm(pos)
		M(pos):set_string("formspec", techage.liquid.formspec(pos, nvm))
		return true
	end
	return false
end

minetest.register_node("techage_nuclear:reactor_pipe_in", {
    description = "Water Inlet",
    tiles = {
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_pipe_in.png"
    },
    groups = {cracky = 2},
    networks = {
		pipe2 = {},
	},
    after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		meta:set_string("formspec", techage.liquid.formspec(pos, nvm))
		Pipe:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	on_timer = node_timer
})

minetest.register_node("techage_nuclear:reactor_pipe_out", {
    description = "Steam Outlet",
    tiles = {
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_casing.png",
        "techagenuclear_reactor_pipe_out.png"
    },
    groups = {cracky = 2},
    networks = {
		pipe2 = {},
	},
    after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		meta:set_string("formspec", techage.liquid.formspec(pos, nvm))
		Pipe:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	on_timer = node_timer
})

liquid.register_nodes({
	"techage_nuclear:reactor_pipe_in"
}, Pipe, "tank", {"F"}, {
    capa = CAPACITY,
    peek = peek_liquid,
    put = put_liquid,
    take = take_liquid,
    untake = untake_liquid
})

liquid.register_nodes({
	"techage_nuclear:reactor_pipe_out"
}, Pipe, "tank", {"F"}, {
    capa = CAPACITY,
    peek = peek_liquid,
    put = put_liquid,
    take = take_liquid,
    untake = untake_liquid
})

Pipe:add_secondary_node_names({"techage_nuclear:reactor_pipe_in", "techage_nuclear:reactor_pipe_out"})

minetest.register_node("techage_nuclear:turbine_pipe_in", {
    description = "Turbine Inlet",
    tiles = {
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_pipe_in.png"
    },
    groups = {cracky = 2},
    networks = {
		pipe2 = {},
	},
    after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		meta:set_string("formspec", techage.liquid.formspec(pos, nvm))
		Pipe:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	on_timer = node_timer
})

minetest.register_node("techage_nuclear:turbine_pipe_out", {
    description = "Turbine Outlet",
    tiles = {
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_casing.png",
        "techagenuclear_turbine_pipe_out.png"
    },
    groups = {cracky = 2},
    networks = {
		pipe2 = {},
	},
    after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.liquid = {}
		meta:set_string("formspec", techage.liquid.formspec(pos, nvm))
		Pipe:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		Pipe:after_dig_node(pos)
	end,
	on_rightclick = on_rightclick,
	can_dig = can_dig,
	paramtype2 = "facedir",
	on_rotate = screwdriver.disallow,
	groups = {cracky=2},
	on_timer = node_timer
})

liquid.register_nodes({
	"techage_nuclear:turbine_pipe_in"
}, Pipe, "tank", {"F"}, {
    capa = CAPACITY,
    peek = peek_liquid,
    put = put_liquid,
    take = take_liquid,
    untake = untake_liquid
})

liquid.register_nodes({
	"techage_nuclear:turbine_pipe_out"
}, Pipe, "tank", {"F"}, {
    capa = CAPACITY,
    peek = peek_liquid,
    put = put_liquid,
    take = take_liquid,
    untake = untake_liquid
})

Pipe:add_secondary_node_names({"techage_nuclear:turbine_pipe_in", "techage_nuclear:turbine_pipe_out"})