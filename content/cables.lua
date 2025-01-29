local M = minetest.get_meta

local Cable = techage.ElectricCable
local power = networks.power

minetest.register_node("techage_nuclear:cable_output", {
    description = "Cable Output",
    tiles = {
		"techagenuclear_turbine_casing.png",
		"techagenuclear_turbine_casing.png",
		"techagenuclear_turbine_cable_output.png",
		"techagenuclear_turbine_casing.png",
		"techagenuclear_turbine_casing.png",
		"techagenuclear_turbine_casing.png",
	},
    after_place_node = function(pos)
		M(pos):set_int("outdir", networks.side_to_outdir(pos, "R"))
		Cable:after_place_node(pos)
	end,
	after_dig_node = function(pos, oldnode)
		Cable:after_dig_node(pos)
		techage.del_mem(pos)
	end,
    paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	on_rotate = screwdriver.disallow,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults()
})

power.register_nodes({"techage_nuclear:cable_output"}, Cable, "con", {"R"})