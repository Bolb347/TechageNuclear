minetest.register_craftitem("techage_nuclear:steam", {
	description = ("Steam"),
	inventory_image = "techagenuclear_steam.png",
	groups = {ta_liquid = 1},
})

minetest.register_craftitem("techage_nuclear:cylinder_small_steam", {
	description = ("Steam Cylinder Small"),
	inventory_image = "techagenuclear_steam_cylinder_small.png",
	stack_max = 1,
})

minetest.register_craftitem("techage_nuclear:cylinder_large_steam", {
	description = ("Steam Cylinder Large"),
	inventory_image = "techagenuclear_steam_cylinder_large.png",
	stack_max = 1,
})

techage.register_liquid("techage_nuclear:cylinder_large_steam", "techage:ta3_cylinder_large", 6, "techage_nuclear:steam")
techage.register_liquid("techage_nuclear:cylinder_small_steam", "techage:ta3_cylinder_small", 1, "techage_nuclear:steam")