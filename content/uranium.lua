techage.add_grinder_recipe({
    input = "techage:sieved_basalt_gravel",
	output = "techage_nuclear:U238_pile"
})

techage.recipes.add("ta4_doser", {
    output = "techage_nuclear:fuel_rod 1",
    waste = "techage_nuclear:U238_pile 2",
    input = {
        "techage_nuclear:U238_pile 5",
        "techage_nuclear:U235_pile 2"
    },
    catalyst = "techage:gibbsite_powder"
})