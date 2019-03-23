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
	output="default:furnace",
	recipe={
		{"group:stone","group:stone","group:stone"},
		{"group:stone","","group:stone"},
		{"group:stone","group:stone","group:stone"},
	},
})

minetest.register_craft({
	output="default:sand",
	recipe={
		{"default:sand","default:sand","default:sand"},
	},
})

minetest.register_craft({
	output="default:sandstone 3",
	recipe={
		{"default:sand","default:sand","default:sand"},
		{"default:sand","default:sand","default:sand"},
		{"default:sand","default:sand","default:sand"},
	},
})

minetest.register_craft({
	output="default:bronze_ingot 9",
	recipe={
		{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
		{"default:copper_ingot","default:tin_ingot","default:copper_ingot"},
		{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
	},
})

--||||||||||||||||
-- ======================= COOKING
--||||||||||||||||

minetest.register_craft({
	type = "cooking",
	output = "default:copper_ingot",
	recipe = "default:copper_lump",
	cooktime = 5,
})

minetest.register_craft({
	type = "cooking",
	output = "default:tin_ingot",
	recipe = "default:tin_lump",
	cooktime = 5,
})

minetest.register_craft({
	type = "cooking",
	output = "default:uranium_ingot",
	recipe = "default:uranium_lump",
	cooktime = 20,
})

minetest.register_craft({
	type = "cooking",
	output = "default:uraniumactive_ingot",
	recipe = "default:uranium_ingot",
	cooktime = 500,
})

minetest.register_craft({
	type = "cooking",
	output = "default:gold_ingot",
	recipe = "default:gold_lump",
	cooktime = 5,
})

minetest.register_craft({
	type = "cooking",
	output = "default:iron_ingot",
	recipe = "default:iron_lump",
	cooktime = 5,
})

minetest.register_craft({
	type = "cooking",
	output = "default:silver_ingot",
	recipe = "default:silver_lump",
	cooktime = 5,
})

minetest.register_craft({
	type = "cooking",
	output = "default:steel_ingot",
	recipe = "default:iron_ingot",
	cooktime = 10,
})

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