multidimensions={
	start_y=4000,
	max_distance=50, --(50 is 800)
	max_distance_chatt=800,
	limited_chat=true,
	limeted_nametag=true,
	remake_home=true,
	remake_bed=true,
	user={},
	player_pos={},
	earth = {
		above=31000,
		under=-31000,
	},
	craftable_teleporters=true,
	registered_dimensions={},
	first_dimensions_appear_at = 2000,
	calculating_dimensions_from_min_y = 0,
	map={
		offset=0,
		scale=1,
		spread={x=100,y=18,z=100},
		seeddiff=24,
		octaves=5,
		persist=0.7,
		lacunarity=1,
		flags="absvalue",
	},
}

dofile(minetest.get_modpath("multidimensions") .. "/api.lua")
dofile(minetest.get_modpath("multidimensions") .. "/dimensions.lua")
dofile(minetest.get_modpath("multidimensions") .. "/tools.lua")