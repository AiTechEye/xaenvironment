multidimensions.register_dimension("candyland",{
	ground_ores = {["materials:marzipan_rose"] = 100,["materials:candy1"] = 100,["materials:candy2"] = 100,["materials:candy3"] = 100,["materials:candy4"] = 1000,["materials:candy5"] = 100,["materials:candy6"] = 100},
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
		{"materials:sponge_cake","materials:icecreamball",":materials:sponge_cake",},
		{"default:obsidian", "default:steel_ingot", "default:obsidian"},
	}
})