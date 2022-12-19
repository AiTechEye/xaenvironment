minetest.register_craft({
	type = "toolrepair",
	additional_wear = -0.4
})

--||||||||||||||||
-- ======================= Tools
--||||||||||||||||

minetest.register_craft({
	output="default:knuckles",
	recipe={
		{"default:steel_ingot","default:steel_ingot",""},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"","default:steel_ingot","default:steel_ingot"},
	},
})

minetest.register_craft({
	output="default:telescopic",
	recipe={
		{"default:copper_ingot","default:glass_tabletop","default:copper_ingot"},
		{"default:copper_ingot","","default:copper_ingot"},
		{"default:copper_ingot","default:glass_tabletop","default:copper_ingot"},
	},
})

minetest.register_craft({
	output="default:quantum_pick",
	recipe={
		{"default:quantumblock","default:quantumblock","default:quantumblock"},
		{"","group:stick",""},
		{"","group:stick",""},
	},
})

minetest.register_craft({
	output="default:quantumblock 3",
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
	output="default:sign 3",
	recipe={
		{"group:wood","group:wood","group:wood"},
		{"group:wood","group:wood","group:wood"},
		{"","group:stick",""},
	},
})

minetest.register_craft({
	output="default:pellets_mill",
	recipe={
		{"default:steel_ingot","materials:tube_metal","default:steel_ingot"},
		{"default:iron_ingot","default:copper_ingot","materials:fanblade_metal"},
		{"default:iron_ingot","materials:sawblade","default:iron_ingot"},
	},
})

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
	output="default:ladder_metal 14",
	recipe={
		{"default:iron_ingot","","default:iron_ingot"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
		{"default:iron_ingot","","default:iron_ingot"},
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
	output="default:furnace_industrial",
	recipe={
		{"default:steel_ingot","default:wire","default:steel_ingot"},
		{"default:steel_ingot","materials:gear_metal","default:steel_ingot"},
		{"default:steel_ingot","default:glass_tabletop","default:steel_ingot"},
	}
})

minetest.register_craft({
	output="default:steam_powered_generator",
	recipe={
		{"default:steel_ingot","default:bucket_with_water_source","materials:diode"},
		{"default:steel_ingot","default:wire","materials:fanblade_metal"},
		{"default:steel_ingot","materials:gear_metal","materials:tube_metal"},
	}
})

minetest.register_craft({
	output="default:wire 9",
	recipe={
		{"group:metalstick","group:metalstick","group:metalstick"},
		{"materials:diode","default:copper_ingot","default:tin_ingot"},
		{"group:metalstick","group:metalstick","group:metalstick"},
	}
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
	output="default:stick",
	recipe={
		{"group:leaves"},
	},
})

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
	output="default:ironstick 4",
	recipe={{"default:iron_ingot"}},
})

minetest.register_craft({
	output="default:torch 4",
	recipe={
		{"","default:coal_lump",""},
		{"","group:stick",""},
	},
})

minetest.register_craft({
	output="default:clay_brick",
	recipe={{"default:clay_lump"}},
})

minetest.register_craft({
	type = "cooking",
	output="default:brick",
	recipe="default:clay_brick"
})

--||||||||||||||||
-- ======================= Nodes
--||||||||||||||||

minetest.register_craft({
	output="default:brickblock",
	recipe={
		{"default:brick","default:brick",""},
		{"default:brick","default:brick",""},
	},
})

minetest.register_craft({
	output="default:stone_spike 4",
	recipe={
		{"","group:stone",""},
		{"group:stone","group:stone","group:stone"},
	},
})

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
	output="default:carpet 12",
	recipe={
		{"materials:piece_of_cloth","materials:piece_of_cloth"},
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

minetest.register_craft({
	output="default:desert_sand 3",
	recipe={
		{"default:desert_sandstone","default:desert_sandstone","default:desert_sandstone"},
	},
})

minetest.register_craft({
	output="default:desert_sandstone 3",
	recipe={
		{"default:desert_sand","default:desert_sand","default:desert_sand",},
		{"default:desert_sand","default:desert_sand","default:desert_sand",},
		{"default:desert_sand","default:desert_sand","default:desert_sand",},
	},
})

minetest.register_craft({
	output="default:glass_tabletop 4",
	recipe={
		{"default:glass","default:glass"},
	},
})
minetest.register_craft({
	output="default:glass_corner 3",
	recipe={
		{"default:glass","default:glass",""},
		{"","default:glass",""},
	},
})


minetest.register_craft({
	output="default:glass_frosted 2",
	recipe={
		{"default:glass","default:glass","default:shell"},
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
	output = "default:obsidian_glass 9",
	recipe = "default:obsidian",
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