--||||||||||||||||
-- ======================= Tools
--||||||||||||||||

minetest.register_craft({
	output="default:cudgel",
	recipe={{"default:stick","default:stick","default:stick"},},
})

minetest.register_craft({
	output="default:pick_flint",
	recipe={
		{"default:gravel","default:gravel","default:gravel"},
		{"","default:stick",""},
		{"","default:stick",""},
	},
})

minetest.register_craft({
	output="default:shovel_flint",
	recipe={
		{"","default:gravel",""},
		{"","default:stick",""},
		{"","default:stick",""},
	},
})

minetest.register_craft({
	output="default:axe_flint",
	recipe={
		{"default:gravel","default:gravel",""},
		{"default:gravel","default:stick",""},
		{"","default:stick",""},
	},
})

minetest.register_craft({
	output="default:hoe_flint",
	recipe={
		{"default:gravel","default:gravel",""},
		{"","default:stick",""},
		{"","default:stick",""},
	},
})
minetest.register_craft({
	output="default:vineyardknife_flint",
	recipe={
		{"default:gravel","default:gravel",""},
		{"","default:stick",""},
		{"","default:stick",""},
	},
})

--||||||||||||||||
-- ======================= Items
--||||||||||||||||

minetest.register_craft({
	output="default:stick 4",
	recipe={{"default:wood"}},
})

minetest.register_craft({
	output="default:flint",
	recipe={
		{"default:gravel","default:gravel","default:gravel"},
		{"default:gravel","default:gravel","default:gravel"},
		{"default:gravel","default:gravel","default:gravel"},
	},
})

--||||||||||||||||
-- ======================= Nodes
--||||||||||||||||

minetest.register_craft({
	output="default:wood 4",
	recipe={{"default:tree"}},
})

minetest.register_craft({
	output="default:cobble",
	recipe={{"default:stick","default:stick","default:stick"},},
})
minetest.register_craft({
	output="default:furnace",
	recipe={
		{"group:stone","group:stone","group:stone"},
		{"group:stone","","group:stone"},
		{"group:stone","group:stone","group:stone"},
	},
})

--||||||||||||||||
-- ======================= COOKING
--||||||||||||||||

minetest.register_craft({
	type = "cooking",
	output = "default:stone",
	recipe = "default:cobble",
})

--||||||||||||||||
-- ======================= FUEL
--||||||||||||||||

minetest.register_craft({
	type = "fuel",
	recipe = "group:wood",
	burntime = 5,
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:tree",
	burntime = 20,
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:stick",
	burntime = 1,
})