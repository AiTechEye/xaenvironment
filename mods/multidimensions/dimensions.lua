multidimensions.register_dimension("maps",{
	custom_y = true,
	dim_y = 26000,
	dim_height = 5000,
	dirt_start = 21000,
	bedrock_depth = 50,
	dirt_depth = 0,
	ground_limit = 0,
	enable_water = false,
	flatland = true,
	stone = "air",
	dirt = "default:bedrock",
	grass = "default:bedrock",
	sand = "air",
	teleporter = false,
})

multidimensions.register_dimension("candyland",{
	ground_ores = {["materials:marzipan_rose"] = 100,["materials:candy1"] = 100,["materials:candy2"] = 100,["materials:candy3"] = 100,["materials:candy4"] = 1000,["materials:candy5"] = 100,["materials:candy6"] = 100,["plants:candytree_spawner"] = 1000},
	water_ores={["materials:gel"]={chance=500,max_heat=20},},
	stone = "materials:sponge_cake",
	dirt = "materials:sugar",
	grass = "materials:sugar_with_glaze",
	water = "materials:gel2",
	sand = "materials:sugar",
	sky = {base_color={r=255, g=140, b=255},type="plain"},
	sun = {scale=0.1,visible=true},
	moon = {scale=3,visible=true},
	node={
		description="Candyland",
		tiles = {"materials_glaze.png^examobs_lollipop.png"},
	},
	craft = {
		{"default:obsidian", "default:steel_ingot", "default:obsidian"},
		{"default:cloud","default:uranium_lump","default:cloud",},
		{"default:obsidian", "default:steel_ingot", "default:obsidian"},
	}
})

multidimensions.register_dimension("moon",{
	stone_ores = {
		["default:space_titanium_ore"]={chunk=1,chance=5000},
		["default:emerald"]={chunk=1,chance=5000},
		["default:space_gold_ore"]={chunk=1,chance=4000},
		["default:space_iron_ore"]={chunk=1,chance=4500},
	},
	air = "default:vacuum",
	sky = {base_color={r=0, g=0, b=0},type="skybox",textures={"spacestuff_sky.png","spacestuff_sky.png","spacestuff_sky.png","spacestuff_sky.png","spacestuff_sky.png","spacestuff_sky.png"}},
	sun = {scale=5,visible=true},
	moon = {scale=2,visible=true,texture="spacestuff_earth.png"},
	node={
		description="Moon",
		tiles = {"materials_spaceyfloor.png"},
	},
	stone = "default:space_stone",
	dirt = "default:space_dust",
	grass = "default:space_dust",
	gravity = 0.3,
	enable_water=false,

	ground_limit=690,
	terrain_density=-2.5,
	map={
		spread={x=190,y=500,z=190},
		octaves=3,
		persist=3.2,
		lacunarity=2,
		flags="eased",
	},
	craft = {
		{"default:obsidian", "default:steel_ingot", "default:obsidian"},
		{"materials:sponge_cake","examobs:icecreamball","materials:sponge_cake",},
		{"default:obsidian", "default:steel_ingot", "default:obsidian"},
	}
})

multidimensions.register_dimension("macro",{
	ground_ores = {["plants:macro_grass"] = 100,["plants:macro_flower"] = 1000,["plants:macro_mushroom"] = 10000,["plants:macro_trees"] = 100000},
	water_ores={["plants:macro_lilypad"]={chance=500}},
	stone_ores = {
		["default:zirconia_ore"]={chance=4000},
		["default:ruby_ore"]={chance=4200},
		["default:opal_ore"]={chance=4300},
		["default:taaffeite_ore"]={chance=4400},
		["default:jadeite_ore"]={chance=4500},
		["default:peridot_ore"]={chance=4600},
		["default:amethyst_ore"]={chance=4700},
	},
	stone = "default:bedrock",
	dirt = "default:dirt",
	grass = "default:dirt",
	water = "default:water_source",
	sand = "default:sand",
	sky = {base_color={r=55, g=200, b=55},type="plain"},
	sun = {scale=10,visible=true},
	moon = {scale=10,visible=true},
	node={
		description="Macro land",
		tiles = {"plants_oak_tree.png^[colorize:#00ff0055"},
	},
	craft = {
		{"default:emerald", "default:goldblock", "default:emerald"},
		{"default:titaniumblock","default:uraniumactiveblock","default:titaniumblock",},
		{"default:emerald", "default:goldblock", "exatec:pcb"},
	}
})

multidimensions.register_dimension("slime",{
	--ground_ores = {["plants:candytree_spawner"] = 100},
	--water_ores={["materials:gel"]={chance=500,max_heat=20},},
	stone = "materials:slime_source",
	dirt = "materials:slime_source",
	grass = "materials:slime",
	water = "materials:slime_source",
	sand = "materials:slime_source",
	sky = {base_color={r=0, g=255, b=0},type="plain"},
	sun = {scale=2,visible=true,texture="default_amberblock.png^[colorize:#0f0a"},
	moon = {scale=2,visible=true,texture="default_lava.png^[colorize:#0f0a"},
	node={
		description="Slime world",
		tiles = {"default_water.png^[colorize:#0f0c"},
		use_texture_alpha = "blend",
	},
	craft = {
		{"materials:gel2", "materials:gel2", "plants:macro_tree"},
		{"materials:gel2","materials:gel2","plants:macro_tree",},
		{"materials:gel2", "materials:gel2", "plants:macro_tree"},
	},
	gravity = 0.5,
	ground_limit=505,
	terrain_density=1,
	map={
		spread={x=190,y=500,z=190},
		octaves=2,
		persist=0.2,
		lacunarity=2,
		flags="eased",
	},
})