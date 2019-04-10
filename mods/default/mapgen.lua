minetest.register_alias("mapgen_stone","default:stone")
minetest.register_alias("mapgen_water_source","default:salt_water_source")
minetest.register_alias("mapgen_river_water_source","default:water_source")
minetest.register_alias("mapgen_lava_source","default:lava_source")

--minetest.set_mapgen_setting("mgv7_lava_depth",-50)



minetest.register_ore({
	ore_type = "blob",
	ore= "default:gravel",
	wherein= "default:stone",
	clust_scarcity = 20 * 20 * 20,
	clust_size = 5,
	y_min= -31000,
	y_max= 31000,
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:sand",
	wherein= "default:stone",
	clust_scarcity = 20 * 20 * 20,
	clust_size = 5,
	y_min= -31000,
	y_max= 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore= "default:apple",
	wherein= "default:leaves",
	clust_scarcity = 8 * 8 * 8,
	clust_num_ores = 2,
	clust_size = 3,
	y_min= 0,
	y_max= 200,
})

--||||||||||||||||
-- ======================= biomes
--||||||||||||||||

minetest.register_biome({
	name = "ocean",
	node_top = "default:sand",
	depth_top = 5,
	depth_filler = 5,
	node_stone = "default:stone",
	node_water = "default:salt_water_source",
	node_river_water = "default:salt_water_source",
	y_min = -31000,
	y_max = 0,
	heat_point = 50,
	humidity_point = 50,
})

minetest.register_biome({
	name = "beach",
	node_top = "default:sand",
	depth_top = 1,
	node_filler = "default:sand",
	depth_filler = 5,
	--node_stone = "default:stone",
	--node_water = "default:water_source",
	--node_river_water = "default:water_source",
	node_riverbed = "default:sand",
	depth_riverbed = 3,
	y_min = 1,
	y_max = 3,
	heat_point = 50,
	humidity_point = 50,
})

minetest.register_biome({
	name = "grassland",
	node_top = "default:dirt_with_grass",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 5,
	--node_stone = "default:stone",
	--node_water = "default:water_source",
	--node_river_water = "default:water_source",
	node_riverbed = "default:sand",
	depth_riverbed = 3,
	y_min = 1,
	y_max = 31000,
	heat_point = 50,
	humidity_point = 50,
})

--||||||||||||||||
-- =======================Decorations
--||||||||||||||||

--[[
minetest.register_biome({
	name = "underground",
	node_top = "default:dirt_with_grass",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 5,
	node_stone = "default:stone",
	node_water_top = "",
	depth_water_top =0 ,
	node_water = "",
	node_river_water = "",
	y_min = -31000,
	y_max = 0,
	heat_point = 50,
	humidity_point = 50,
})
--]]