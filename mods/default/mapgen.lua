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

default.register_bios=function(bios)
	for name,def in pairs(bios) do
	table.insert(default.registered_bios,name)

	minetest.register_biome({
		name =		name,
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
		heat_point =				def[1],
		humidity_point =				def[2],
	})
	if def.beach then
		minetest.register_biome({
		name = name .. "_beach",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 5,
		node_riverbed = "default:sand",
		depth_riverbed = 3,
		y_min = 1,
		y_max = 3,
		heat_point = def[1],
		humidity_point = def[2],
		})
	end
	end
end

--desert_rocky
default.register_bios({
		semi_desert=		{100,20,grass="default:desert_sand",dirt="default:desert_sand"},
		desert=			{100,0,grass="default:desert_sand",dirt="default:desert_sand"},

		swamp=			{80,100,grass="default:dirt_with_jungle_grass"},
		jungle=			{80,80,grass="default:dirt_with_jungle_grass",beach=true},
		tropic=			{80,50,grass="default:dirt_with_grass",beach=true},
		savaana=			{80,20,grass="default:dirt_with_dry_grass",beach=true},

		deciduous=		{60,20,grass="default:dirt_with_grass",beach=true},
		deciduous_grassland=	{60,80,grass="default:dirt_with_grass",beach=true},
		coniferous=		{40,20,grass="default:dirt_with_coniferous_grass",beach=true},
		coniferous_foggy=		{40,80,grass="default:dirt_with_coniferous_grass",beach=true},
		cold_coniferous=		{20,20,grass="default:dirt_with_snow",beach=true},
		cold_grassland=		{20,80,grass="default:dirt_with_snow",beach=true},

		tundra_green=		{0,80,grass="default:dirt_with_red_permafrost_grass",dirt="default:permafrost_dirt",y_min=20,y_max=40,beach=true},
		snowy=			{10,50,grass="default:dirt_with_snow",depth_filler=0},
		tundra_red=		{0,20,grass="default:dirt_with_red_permafrost_grass",dirt="default:permafrost_dirt",y_min=20,y_max=40,beach=true},
		arctic=			{0,50,grass="default:snow",stone="default:ice",dirt="default:ice"},
})

minetest.register_tool("default:a", {
	description = "a",
	inventory_image = "default_stick.png",
	on_use=function(itemstack, user, pointed_thing)
		local p = user:get_pos()

minetest.chat_send_all(minetest.get_heat(p) .." " .. minetest.get_humidity(p))


		--print(minetest.get_perlin({offset=50,scale=50,spread={x=1000,y=1000,z=1000},seed=5349,octaves=3,persist=0.5,lacunarity=2,flags="default"}):get2d({x=p.x,y=p.z}))
	end
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