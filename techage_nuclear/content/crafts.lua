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
        {"", "techage_nuclear:DU_plate", ""},
        {"techage_nuclear:DU_plate", "", "techage_nuclear:DU_plate"},
        {"", "techage_nuclear:DU_plate", ""}
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