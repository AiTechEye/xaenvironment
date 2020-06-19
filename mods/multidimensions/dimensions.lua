--local ores={
--	["default:stone_with_coal"]=200,
--	["default:stone_with_iron"]=400,
--	["default:stone_with_copper"]=500,
--	["default:stone_with_gold"]=2000,
--	["default:stone_with_mese"]=10000,
--	["default:stone_with_diamond"]=20000,
--	["default:mese"]=40000,
--	["default:gravel"]={chance=3000,chunk=2,}
--}

--minetest.register_node("multidimensions:tree", {drawtype="airlike",groups = {multidimensions_tree=1,not_in_creative_inventory=1},})
--minetest.register_node("multidimensions:pine_tree", {drawtype="airlike",groups = {multidimensions_tree=1,not_in_creative_inventory=1},})
--minetest.register_node("multidimensions:pine_treesnow", {drawtype="airlike",groups = {multidimensions_tree=1,not_in_creative_inventory=1},})
--minetest.register_node("multidimensions:jungle_tree", {drawtype="airlike",groups = {multidimensions_tree=1,not_in_creative_inventory=1},})
--minetest.register_node("multidimensions:aspen_tree", {drawtype="airlike",groups = {multidimensions_tree=1,not_in_creative_inventory=1},})
--minetest.register_node("multidimensions:acacia_tree", {drawtype="airlike",groups = {multidimensions_tree=1,not_in_creative_inventory=1},})

multidimensions.register_dimension("candyland",{
	ground_ores = {["examobs:marzipan_rose"] = 100,["examobs:candy1"] = 100,["examobs:candy2"] = 100,["examobs:candy3"] = 100,["examobs:candy4"] = 1000,["examobs:candy5"] = 100,["examobs:candy6"] = 100},

	--stone_ores = table.copy(ores),
	--sand_ores={["default:clay"]={chunk=2,chance=5000}},
	--grass_ores={
	--	["default:dirt_with_snow"]={chance=1,max_heat=20},
	--},
	water_ores={["examobs:gel"]={chance=500,max_heat=20},},

	stone = "examobs:sponge_cake",
	dirt = "examobs:sugar",
	grass = "examobs:sugar_with_glaze",
	water = "examobs:gel2",
	sand = "examobs:sugar",
	node={
		description="Candyland",
		tiles = {"examobs_glaze.png^examobs_lollipop.png"},
	},
	craft = {
		{"default:obsidian", "default:steel_ingot", "default:obsidian"},
		{"default:cloud","default:uranium_lump","default:cloud",},
		{"default:obsidian", "default:steel_ingot", "default:obsidian"},
	}
})

multidimensions.register_dimension("moon",{
--	ground_ores = table.copy(plants),
	stone_ores = {["default:titanium_ore"]={chunk=1,chance=5000}},
--	sand_ores={["default:clay"]={chunk=2,chance=5000}},
	air = "default:vacuum",
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

	--craft = {
		--{"default:obsidian", "default:steel_ingot", "default:obsidian"},
		--{"examobs:sponge_cake","examobs:icecreamball","examobs:sponge_cake",},
		--{"default:obsidian", "default:steel_ingot", "default:obsidian"},
	--}

})