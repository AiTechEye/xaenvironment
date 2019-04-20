minetest.register_alias("mapgen_stone","default:stone")
minetest.register_alias("mapgen_water_source","default:salt_water_source")
minetest.register_alias("mapgen_river_water_source","default:water_source")
minetest.register_alias("mapgen_lava_source","default:lava_source")

minetest.register_alias("mapgen_mossycobble","default:mossycobble")
minetest.register_alias("mapgen_cobble","default:cobble")



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

default.register_bio=function(def)
	default.registered_bios[def[1]] = {heat=def[2],humidity=def[3],grass=def.grass}
	table.insert(default.registered_bios_list,def[1])
	minetest.register_biome({
		name =		def[1],
		node_top =	def.grass,
		depth_top =	def.depth_top or		1,
		node_filler =	def.dirt or		"default:dirt",
		depth_filler = 	def.depth_filler or		5,
		node_stone = 	def.stone or		"default:stone",
		node_water_top = 	def.node_water_top,
		depth_water_top =	def.depth_water_top or	0 ,
		node_water =	def.node_water,
		node_river_water =def.node_river_water,
		y_min =		def.y_min or		def.beach and 3 or 1,
		y_max =		def.y_max or		31000,
		heat_point =				def[2],
		humidity_point =				def[3],
	})
	if def.beach then
		minetest.register_biome({
		name = def[1] .. "_beach",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 5,
		node_riverbed = "default:sand",
		depth_riverbed = 3,
		y_min = 1,
		y_max = 3,
		heat_point = def[2],
		humidity_point = def[3],
		})
	end
end

minetest.register_tool("default:biocheck", {
	description = "Biocheck",
	inventory_image = "default_stick.png",
	groups={not_in_creative_inventory = 1},
	on_use=function(itemstack, user, pointed_thing)

		local pos = user:get_pos()
		--local heat = math.floor(minetest.get_heat(pos)/10+0.5)*10
		--local humidity =math.floor(minetest.get_humidity(pos)/10+0.5)*10

		minetest.chat_send_player(user:get_player_name(),minetest.get_heat(pos) .." " ..minetest.get_humidity(pos))
	end
})

--desert_rocky

default.register_bio({"semi_desert",		100,20,grass="default:desert_sand",dirt="default:desert_sand"})
default.register_bio({"desert",		100,0,grass="default:desert_sand",dirt="default:desert_sand"})

default.register_bio({"swamp",		80,100,grass="default:dirt_with_jungle_grass"})
default.register_bio({"jungle",		80,80,grass="default:dirt_with_jungle_grass",beach=true})
default.register_bio({"tropic",		80,50,grass="default:dirt_with_grass",beach=true})
default.register_bio({"savanna",		80,0,grass="default:dirt_with_dry_grass",beach=true})

default.register_bio({"deciduous",		60,20,grass="default:dirt_with_grass",beach=true})
default.register_bio({"deciduous_grassland",	60,80,grass="default:dirt_with_grass",beach=true})

default.register_bio({"coniferous",		40,20,grass="default:dirt_with_coniferous_grass",beach=true})
default.register_bio({"coniferous_foggy",	40,80,grass="default:dirt_with_coniferous_grass",beach=true})

default.register_bio({"cold_coniferous",	20,20,grass="default:dirt_with_snow",beach=true})
default.register_bio({"cold_grassland",		20,80,grass="default:dirt_with_snow",beach=true})

default.register_bio({"tundra_green",		0,80,grass="default:dirt_with_red_permafrost_grass",dirt="default:permafrost_dirt",y_min=20,y_max=40,beach=true})
default.register_bio({"snowy",		10,50,grass="default:dirt_with_snow",depth_filler=0})
default.register_bio({"tundra_red",		0,20,grass="default:dirt_with_red_permafrost_grass",dirt="default:permafrost_dirt",y_min=20,y_max=40,beach=true})
default.register_bio({"arctic",			0,50,grass="default:snow",stone="default:ice",dirt="default:ice"})


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