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
-- ======================= Node-tools
--||||||||||||||||

minetest.register_craft({
	output="default:workbench",
	recipe={
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"default:wood","default:wood","default:wood"},
		{"default:tree","default:wood","default:tree"},
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
	output = "default:glass",
	recipe = "group:sand",
})

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
	cooktime = 100,
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

minetest.register_craft({
	type = "fuel",
	recipe = "default:coal_lump",
	burntime = 40,
})
--||||||||||||||||
-- ======================= Metal
--||||||||||||||||
minetest.register_craft({
	output="default:ironblock",
	recipe={
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
	},
})
minetest.register_craft({
	output="default:iron_ingot",
	recipe={{"default:ironblock"}}
})
minetest.register_craft({
	output="default:goldblock",
	recipe={
		{"default:gold_ingot","default:gold_ingot","default:gold_ingot"},
		{"default:gold_ingot","default:gold_ingot","default:gold_ingot"},
		{"default:gold_ingot","default:gold_ingot","default:gold_ingot"},
	},
})
minetest.register_craft({
	output="default:gold_ingot",
	recipe={{"default:goldblock"}}
})
minetest.register_craft({
	output="default:silverblock",
	recipe={
		{"default:silver_ingot","default:silver_ingot","default:silver_ingot"},
		{"default:silver_ingot","default:silver_ingot","default:silver_ingot"},
		{"default:silver_ingot","default:silver_ingot","default:silver_ingot"},
	},
})
minetest.register_craft({
	output="default:silver_ingot 9",
	recipe={{"default:silverblock"}}
})
minetest.register_craft({
	output="default:uraniumblock",
	recipe={
		{"default:uranium_ingot","default:uranium_ingot","default:uranium_ingot"},
		{"default:uranium_ingot","default:uranium_ingot","default:uranium_ingot"},
		{"default:uranium_ingot","default:uranium_ingot","default:uranium_ingot"},
	},
})
minetest.register_craft({
	output="default:uranium_ingot 9",
	recipe={{"default:uraniumblock"}}
})
minetest.register_craft({
	output="default:copperblock",
	recipe={
		{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
		{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
		{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
	},
})
minetest.register_craft({
	output="default:copper_ingot 9",
	recipe={{"default:copperblock"}}
})
minetest.register_craft({
	output="default:steelblock",
	recipe={
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	},
})
minetest.register_craft({
	output="default:steel_ingot 9",
	recipe={{"default:steelblock"}}
})
minetest.register_craft({
	output="default:tinblock",
	recipe={
		{"default:tin_ingot","default:tin_ingot","default:tin_ingot"},
		{"default:tin_ingot","default:tin_ingot","default:tin_ingot"},
		{"default:tin_ingot","default:tin_ingot","default:tin_ingot"},
	},
})
minetest.register_craft({
	output="default:tin_ingot 9",
	recipe={{"default:tinblock"}}
})
minetest.register_craft({
	output="default:bronzeblock",
	recipe={
		{"default:bronze_ingot","default:bronze_ingot","default:bronze_ingot"},
		{"default:bronze_ingot","default:bronze_ingot","default:bronze_ingot"},
		{"default:bronze_ingot","default:bronze_ingot","default:bronze_ingot"},
	},
})
minetest.register_craft({
	output="default:bronze_ingot 9",
	recipe={{"default:bronzeblock"}},
})
minetest.register_craft({
	output="default:uraniumactiveblock",
	recipe={
		{"default:uraniumactive_ingot","default:uraniumactive_ingot","default:uraniumactive_ingot"},
		{"default:uraniumactive_ingot","default:uraniumactive_ingot","default:uraniumactive_ingot"},
		{"default:uraniumactive_ingot","default:uraniumactive_ingot","default:uraniumactive_ingot"},
	},
})
minetest.register_craft({
	output="default:uraniumactive_ingot 9",
	recipe={{"default:uraniumactiveblock"}},
})