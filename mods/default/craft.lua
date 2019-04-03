--||||||||||||||||
-- ======================= Tools
--||||||||||||||||

minetest.register_craft({
	output="default:cudgel",
	recipe={{"default:stick","default:stick","default:stick"},},
})

--||||||||||||||||
-- ======================= Node-tools
--||||||||||||||||

minetest.register_craft({
	output="default:furnace",
	recipe={
		{"group:stone","group:stone","group:stone"},
		{"group:stone","","group:stone"},
		{"group:stone","group:stone","group:stone"},
	},
})

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
	output="default:torch_floor 4",
	recipe={
		{"","default:coal_lump",""},
		{"","default:stick",""},
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