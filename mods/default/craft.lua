minetest.register_craft({
	type = "toolrepair",
	additional_wear = -0.4
})
--||||||||||||||||
-- ======================= Tools
--||||||||||||||||

minetest.register_craft({
	output="default:quantum_pick",
	recipe={
		{"default:quantumblock","default:quantumblock","default:quantumblock"},
		{"","group:stick",""},
		{"","group:stick",""},
	},
})

minetest.register_craft({
	output="default:quantumblock",
	recipe={
		{"default:uraniumactive_ingot","default:uraniumactive_ingot","default:uraniumactive_ingot"},
		{"default:uraniumactive_ingot","default:electric_lump","default:uraniumactive_ingot"},
		{"default:uraniumactive_ingot","default:uraniumactive_ingot","default:uraniumactive_ingot"},
	},
})

minetest.register_craft({
	output="default:cudgel",
	recipe={{"default:stick","default:stick","default:stick"},},
})

minetest.register_craft({
	output="default:bucket",
	recipe={
		{"default:steel_ingot","","default:steel_ingot"},
		{"","default:steel_ingot",""},
	},
})

--||||||||||||||||
-- ======================= Node-tools
--||||||||||||||||


minetest.register_craft({
	output="default:recycling_mill",
	recipe={
		{"default:iron_ingot","default:steel_ingot","default:iron_ingot"},
		{"default:iron_ingot","default:copper_ingot","default:iron_ingot"},
		{"default:iron_ingot","default:iron_pick","default:iron_ingot"},
	},
})

minetest.register_craft({
	output="default:lamp 4",
	recipe={
		{"","default:glass_tabletop",""},
		{"default:glass_tabletop","default:electric_lump","default:glass_tabletop"},
		{"","default:glass_tabletop",""},
	},
})
minetest.register_craft({
	output="default:dye_workbench",
	recipe={
		{"group:wood","group:wood","group:wood"},
		{"group:wood","group:wood","group:wood"},
		{"default:stick","","default:stick"},
	},
})

minetest.register_craft({
	output="default:itemframe",
	recipe={
		{"default:stick","default:stick","default:stick"},
		{"default:stick","materials:piece_of_cloth","default:stick"},
		{"default:stick","default:stick","default:stick"},
	},
})

minetest.register_craft({
	output="default:tankstorage",
	recipe={
		{"default:glass","default:glass","default:glass"},
		{"default:glass","","default:glass"},
		{"default:glass","default:glass","default:glass"},
	},
})

minetest.register_craft({
	output="default:paper_compressor",
	recipe={
		{"group:wood","","group:wood"},
		{"group:wood","group:stick","group:wood"},
		{"group:wood","group:wood","group:wood"},
	},
})

minetest.register_craft({
	output="default:craftguide",
	recipe={
		{"group:stick","group:stick",""},
		{"group:stick","group:stick",""},
	},
})

minetest.register_craft({
	output="default:ladder 7",
	recipe={
		{"group:stick","","group:stick"},
		{"group:stick","group:stick","group:stick"},
		{"group:stick","","group:stick"},
	},
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
	output="default:workbench",
	recipe={
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
		{"group:wood","group:wood","group:wood"},
		{"group:tree","group:wood","group:tree"},
	},
})

--||||||||||||||||
-- ======================= Items
--||||||||||||||||

minetest.register_craft({
	output="default:wrench",
	recipe={
		{"","","default:iron_ingot"},
		{"","default:iron_ingot",""},
		{"default:iron_ingot","",""},
	},
})

minetest.register_craft({
	output="default:gold_lump",
	recipe={
		{"default:gold_flake","default:gold_flake","default:gold_flake"},
		{"default:gold_flake","default:gold_flake","default:gold_flake"},
		{"default:gold_flake","default:gold_flake","default:gold_flake"},
	},
})

minetest.register_craft({
	output="default:gold_flake",
	recipe={
		{"default:micro_gold_flake","default:micro_gold_flake","default:micro_gold_flake"},
		{"default:micro_gold_flake","default:micro_gold_flake","default:micro_gold_flake"},
		{"default:micro_gold_flake","default:micro_gold_flake","default:micro_gold_flake"},
	},
})


minetest.register_craft({
	output="default:stick 4",
	recipe={{"group:wood"}},
})
minetest.register_craft({
	output="default:torch 4",
	recipe={
		{"","default:coal_lump",""},
		{"","group:stick",""},
	},
})

--||||||||||||||||
-- ======================= Nodes
--||||||||||||||||

minetest.register_craft({
	type = "cooking",
	output="default:water_source",
	recipe="default:ice"
})
minetest.register_craft({
	type = "cooking",
	output="default:water_source",
	recipe="default:snowblock_thin"
})
minetest.register_craft({
	type = "cooking",
	output="default:water_source",
	recipe="default:snowblock"
})

minetest.register_craft({
	output="default:snowblock",
	recipe={
		{"default:snow","default:snow","default:snow"},
		{"default:snow","default:snow","default:snow"},
		{"default:snow","default:snow","default:snow"},
	},
})

minetest.register_craft({
	output="default:snow 9",
	recipe={
		{"default:snowblock"},
	},
})

minetest.register_craft({
	output="default:wool",
	recipe={
		{"plants:cotton","plants:cotton"},
		{"plants:cotton","plants:cotton"},
	},
})

minetest.register_craft({
	output="plants:cotton 4",
	recipe={
		{"default:wool"},
	},
})

minetest.register_craft({
	output="default:cobble",
	recipe={
		{"default:pebble_stone","default:pebble_stone","default:pebble_stone"},
		{"default:pebble_stone","default:pebble_stone","default:pebble_stone"},
		{"default:pebble_stone","default:pebble_stone","default:pebble_stone"},
	},
})
minetest.register_craft({
	output="default:desert_cobble",
	recipe={
		{"default:pebble_desert_stone","default:pebble_desert_stone","default:pebble_desert_stone"},
		{"default:pebble_desert_stone","default:pebble_desert_stone","default:pebble_desert_stone"},
		{"default:pebble_desert_stone","default:pebble_desert_stone","default:pebble_desert_stone"},
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


--||||||||||||||||
-- ======================= COOKING
--||||||||||||||||


minetest.register_craft({
	type = "cooking",
	output = "default:glass",
	recipe = "group:sand",
})

minetest.register_craft({
	output="default:glass_tabletop 4",
	recipe={
		{"default:glass","default:glass"},
	},
})

minetest.register_craft({
	type = "cooking",
	output = "default:stone",
	recipe = "default:cobble",
})

minetest.register_craft({
	type = "cooking",
	output = "default:desert_stone",
	recipe = "default:desert_cobble",
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