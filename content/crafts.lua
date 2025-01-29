minetest.register_craft({
    output = "techage_nuclear:DU_plate",
    recipe = {
        {"techage_nuclear:U238_pile", "default:steel_ingot", "techage_nuclear:U238_pile"},
        {"default:steel_ingot", "", "default:steel_ingot"},
        {"techage_nuclear:U238_pile", "default:steel_ingot", "techage_nuclear:U238_pile"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:reactor_casing 16",
    recipe = {
        {"techage:alumium", "techage_nuclear:DU_plate", "techage:alumium"},
        {"techage_nuclear:DU_plate", "techage:alumium", "techage_nuclear:DU_plate"},
        {"techage:alumium", "techage_nuclear:DU_plate", "techage:alumium"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:ta4_centrifuge_pas",
    recipe = {
        {"techage_nuclear:DU_plate", "default:diamond", "techage_nuclear:DU_plate"},
        {"techage_nuclear:DU_plate", "techage:ta4_grinder_pas", "techage_nuclear:DU_plate"},
        {"techage_nuclear:DU_plate", "techage:ta4_wlanchip", "techage_nuclear:DU_plate"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:ta4_reactor_controller_pas",
    recipe = {
        {"default:mese", "techage_nuclear:DU_plate", "default:mese"},
        {"techage_nuclear:DU_plate", "techage_nuclear:ta4_centrifuge_pas", "techage_nuclear:DU_plate"},
        {"default:mese", "techage_nuclear:DU_plate", "default:mese"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:reactor_pipe_in",
    recipe = {
        {"techage_nuclear:reactor_casing", "techage:ta3_pipeS"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:reactor_pipe_out",
    recipe = {
        {"techage:ta3_pipeS", "techage_nuclear:reactor_casing"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:reactor_fuelcell",
    recipe = {
        {"techage_nuclear:fuel_rod", "techage_nuclear:reactor_casing"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:reactor_cooler",
    recipe = {
        {"bucket:bucket_water", "techage_nuclear:reactor_casing"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:turbine_casing 16",
    recipe = {
        {"", "default:steel_ingot", ""},
        {"default:steel_ingot", "techage:alumium", "default:steel_ingot"},
        {"", "default:steel_ingot", ""}
    }
})

minetest.register_craft({
    output = "techage_nuclear:turbine_pipe_in",
    recipe = {
        {"techage_nuclear:turbine_casing", "techage:ta3_pipeS"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:turbine_pipe_out",
    recipe = {
        {"techage:ta3_pipeS", "techage_nuclear:turbine_casing"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:turbine",
    recipe = {
        {"", "default:steel_ingot", ""},
        {"default:steel_ingot", "techage:ta5_ceramic_turbine", "default:steel_ingot"},
        {"", "default:steel_ingot", ""}
    }
})

minetest.register_craft({
    output = "techage_nuclear:cable_output",
    recipe = {
        {"techage_nuclear:turbine_casing", "techage:electric_cableS"}
    }
})

minetest.register_craft({
    output = "techage_nuclear:ta4_turbine_controller_pas",
    recipe = {
        {"", "techage_nuclear:turbine_casing", ""},
        {"techage_nuclear:turbine_casing", "techage:ta4_turbine", "techage_nuclear:turbine_casing"},
        {"", "techage_nuclear:turbine_casing", ""}
    }
})

minetest.register_craft({
    output = "techage_nuclear:ta4_rtg_pas",
    recipe = {
        {"", "techage_nuclear:reactor_casing", ""},
        {"techage_nuclear:reactor_casing", "techage_nuclear:Pu239_pile", "techage_nuclear:reactor_casing"},
        {"", "techage:electric_cableS", ""}
    }
})