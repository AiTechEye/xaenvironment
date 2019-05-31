for i=1,20 do
default.register_plant({
	name="coral_" .. i,
	description = "Coral",
	tiles={"default_sand.png"},
	special_tiles = {{name  = "plants_coral.png^" .. default.dye_texturing(i*7,{opacity=150}).."^plants_coral_alpha.png^[makealpha:0,255,0"}, tileable_vertical = true},
	drawtype = "plantlike_rooted",
	groups={not_in_craftguide=1},
	visual_scale = i <7 and 1 or i< 12 and 1.5 or 2,
	floodable = false,
	walkable = true,
	decoration={
		noise_params={
			offset=0.6,
			scale=0.04,
			spread={x=17,y=17,z=17},
			seed=9*i,
		},
		place_on = {"default:sand","default:desert_sand"},
		place_offset_y = -1,
		flags = "force_placement",
		sidelen = 4,
		y_max = -5,
		y_min = -30,
		spawn_by = "default:salt_water_source",
		biomes ={
			"hot_ocean",
		}, 
	},
	dye_colors = {palette=i*7},
})
default.register_plant({
	name="coral2_" .. i,
	description = "Coral",
	tiles={"default_sand.png"},
	special_tiles = {{name  = "plants_coral2.png^" .. default.dye_texturing(i*7+4,{opacity=150}).."^plants_coral2_alpha.png^[makealpha:0,255,0"}, tileable_vertical = true},
	drawtype = "plantlike_rooted",
	groups={not_in_craftguide=1},
	visual_scale = i <11 and 1 or i< 16 and 1.5 or 2,
	floodable = false,
	walkable = true,
	decoration={
		noise_params={
			offset=0.6,
			scale=0.04,
			spread={x=17,y=17,z=17},
			seed=6*i,
		},
		place_on = {"default:sand","default:desert_sand"},
		place_offset_y = -1,
		flags = "force_placement",
		sidelen = 4,
		y_max = -5,
		y_min = -30,
		spawn_by = "default:salt_water_source",
		biomes ={
			"hot_ocean",
		}, 
	},
	dye_colors = {palette=i*7+4},
})
end