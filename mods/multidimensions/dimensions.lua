local ores={
	["default:stone_with_coal"]=200,
	["default:stone_with_iron"]=400,
	["default:stone_with_copper"]=500,
	["default:stone_with_gold"]=2000,
--	["default:stone_with_mese"]=10000,
	["default:stone_with_diamond"]=20000,
--	["default:mese"]=40000,
	["default:gravel"]={chance=3000,chunk=2,}
}

local plants = {
	["flowers:mushroom_brown"] = 1000,
	["flowers:mushroom_red"] = 1000,
	["flowers:mushroom_brown"] = 1000,
	["flowers:rose"] = 1000,
	["flowers:tulip"] = 1000,
	["flowers:dandelion_yellow"] = 1000,
	["flowers:geranium"] = 1000,
	["flowers:viola"] = 1000,
	["flowers:dandelion_white"] = 1000,
	["default:junglegrass"] = 2000,
	["default:papyrus"] = 2000,
	["default:grass_3"] = 10,

	["multidimensions:tree"] = 1000,
	["multidimensions:aspen_tree"] = 1000,
	["multidimensions:pine_tree"] = 1000,
}

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

multidimensions.register_dimension("spacelands",{
	--ground_ores = table.copy(plants),
	--stone_ores = table.copy(ores),
	ground_limit=550,
	stone = "default:space_stone",
	dirt = "default:space_dust",
	grass = "default:space_dust",
	gravity = 0.3,
	node={
		description="Spacelands",
		tiles = {"materials_spaceyfloor.png"},
	},
	map={
		spread={x=30,y=30,z=30},
		octaves=3,
		persist=0.2,
		lacunarity=2,
		flags="eased",
	},
	terrain_density=0.2,
	enable_water=false,
	self={
		blocking="multidimensions:blocking",
		killing = "multidimensions:killing",
	},
	on_generate=function(self,data,id,area,x,y,z)
		if y <= self.dirt_start-70 then
			data[id] = self.killing
		elseif y <= self.dirt_start-100 then
			data[id] = self.blocking
		elseif y <= self.dirt_start+5 then
			data[id] = self.air
		else
			return
		end
		return data
	end,
	--craft = {
		--{"default:obsidian", "default:steel_ingot", "default:obsidian"},
		--{"examobs:sponge_cake","examobs:icecreamball","examobs:sponge_cake",},
		--{"default:obsidian", "default:steel_ingot", "default:obsidian"},
	--}
})

--multidimensions.register_dimension("earthlike2",{
--	ground_ores = table.copy(plants),
--	stone_ores = table.copy(ores),
--	sand_ores={["default:clay"]={chunk=2,chance=5000}},
--	node={description="Alternative earth 2"},
--	map={spread={x=20,y=18,z=20}},
--	ground_limit=550,
--	gravity=0.5,
--	craft = {
--		{"default:obsidianbrick", "default:steel_ingot", "default:obsidianbrick"},
--		{"default:aspen_wood","default:mese","default:aspen_wood",},
--		{"default:obsidianbrick", "default:steel_ingot", "default:obsidianbrick"},
--	}
--})

--minetest.register_lbm({
--	name = "multidimensions:lbm",
--	run_at_every_load = true,
--	nodenames = {"group:multidimensions_tree"},
--	action = function(pos, node)
--		minetest.set_node(pos, {name = "air"})
--		local tree=""
--		if node.name=="multidimensions:tree" then
--			tree=minetest.get_modpath("default") .. "/schematics/apple_tree.mts"
--		elseif node.name=="multidimensions:pine_tree" then
--			tree=minetest.get_modpath("default") .. "/schematics/pine_tree.mts"
--		elseif node.name=="multidimensions:pine_treesnow" then
--			tree=minetest.get_modpath("default") .. "/schematics/snowy_pine_tree_from_sapling.mts"
--		elseif node.name=="multidimensions:jungle_tree" then
--			tree=minetest.get_modpath("default") .. "/schematics/jungle_tree.mts"
--		elseif node.name=="multidimensions:aspen_tree" then
--			tree=minetest.get_modpath("default") .. "/schematics/aspen_tree.mts"
--		elseif node.name=="multidimensions:acacia_tree" then
--			tree=minetest.get_modpath("default") .. "/schematics/acacia_tree.mts"
--		end
--		minetest.place_schematic({x=pos.x,y=pos.y,z=pos.z}, tree, "random", {}, true)
--	end,
--})