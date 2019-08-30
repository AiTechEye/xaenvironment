minetest.register_biome({
	name="candyland",
	node_top="examobs:sugar_with_glaze",
	depth_top=1,
	node_filler="examobs:sugar",
	depth_filler=5,
	node_stone="examobs:sponge_cake",
	node_water="examobs:gel2",
	node_river_water="examobs:gel",
	y_min=-50,
	y_max=31000,
	heat_point=60,
	humidity_point=67,
})

minetest.register_node("examobs:sugar", {
	description = "Sugar",
	groups = {crumbly=3,soil=1,candy_ground=1},
	tiles = {"examobs_sugar.png"},
	sounds=default.node_sound_dirt_defaults({footstep={name="default_snow_footstep"},dug={name="default_snow_footstep"},dig={name="default_snow_footstep"}}),
})

minetest.register_node("examobs:sugar_with_glaze", {
	description = "Sugar with glaze",
	groups = {crumbly=3,spreading_dirt_type=1,candy_ground=1},
	tiles = {"examobs_glaze.png","examobs_sugar.png","examobs_sugar.png^examobs_glaze_side.png"},
	sounds=default.node_sound_dirt_defaults({footstep={name="default_snow_footstep"},dug={name="default_snow_footstep"},dig={name="default_snow_footstep"}}),
})

minetest.register_node("examobs:sponge_cake", {
	description = "Sponge cake",
	groups = {cracky=3,candy_underground=1},
	tiles = {"examobs_spongecake.png"},
	sounds=default.node_sound_wood_defaults(),
})
minetest.register_node("examobs:marzipan_rose", {
	description = "Marzipan rose",
	groups = {snappy=3},
	tiles = {"examobs_marzipan_rose.png"},
	drawtype="plantlike",
	walkable=false,
	paramtype="light",
	sunlight_propagates=true,
	buildable_to=true,
	sounds=default.node_sound_leaves_defaults(),
	on_use=minetest.item_eat(1)
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"examobs:sugar_with_glaze"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.01,
		spread = {x = 40, y = 40, z = 40},
		seed = 329,
		octaves = 4,
		persist = 0.5
	},
	y_min = -10,
	y_max = 32000,
	decoration = "examobs:marzipan_rose",
})

local candycolor={"ff75ec","ff0000","00ff00","0000ff","00ffff","ffff00"}
for i=1,6,1 do
minetest.register_node("examobs:candy" .. i, {
	description = "Candy",
	groups = {snappy=3,flora=1},
	tiles = {"default_stone.png^[colorize:#" .. candycolor[i] .."55"},
	drawtype="nodebox",
	walkable=false,
	buildable_to=true,
	paramtype="light",
	sunlight_propagates=true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.4375, 0.25, -0.4, 0.4375},
			{0.25, -0.5, -0.375, 0.375, -0.4, 0.375},
			{0.375, -0.5, -0.3125, 0.4375, -0.4, 0.3125},
			{-0.4375, -0.5, -0.3125, -0.375, -0.4, 0.3125},
			{-0.375, -0.5, -0.375, -0.25, -0.4, 0.375},
		}
	},
	on_use=minetest.item_eat(1),
	sounds=default.node_sound_leaves_defaults(),
})
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"examobs:sugar_with_glaze"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.01,
			spread = {x = 20, y = 20, z = 20},
			seed = 329,
			octaves = 4,
			persist = 0.5
		},
	y_min = -10,
	y_max = 32000,
	decoration = "examobs:candy" .. i,
})
end

minetest.register_node("examobs:gel", {
	description = "Gel",
	drawtype = "liquid",
	tiles = {"default_water.png^[colorize:#00ff1155"},
	alpha=200,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = false,
	drowning = 1,
	liquidtype = "source",
	liquid_range = 2,
	liquid_alternative_flowing = "examobs:gel_flowing",
	liquid_alternative_source = "examobs:gel",
	liquid_viscosity = 15,
	post_effect_color = {a=160,r=0,g=150,b=100},
	groups = {liquid = 4,crumbly = 1, sand = 1},
})

minetest.register_node("examobs:gel_flowing", {
	description = "Gel flowing",
	drawtype = "flowingliquid",
	tiles = {"default_water.png^[colorize:#00ff1155"},
	special_tiles = {
		{
			name = "default_water.png^[colorize:#00ff1155",
			backface_culling = false,
		},
		{
			name = "default_water.png^[colorize:#00ff1155",
			backface_culling = true,
		},
	},
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "examobs:gel_flowing",
	liquid_alternative_source = "examobs:gel",
	liquid_viscosity = 1,
	liquid_range = 2,
	post_effect_color = {a=160,r=0,g=150,b=100},
	groups = {liquid = 4, not_in_creative_inventory = 1},
})

minetest.register_node("examobs:gel2", {
	description = "Gel 2",
	drawtype = "liquid",
	tiles = {"default_stone.png^[colorize:#00ff0055"},
	alpha=200,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = false,
	drowning = 1,
	liquidtype = "source",
	liquid_range = 2,
	liquid_alternative_flowing = "examobs:gel_flowing2",
	liquid_alternative_source = "examobs:gel2",
	liquid_viscosity = 15,
	post_effect_color = {a=60,r=0,g=150,b=0},
	groups = {liquid = 4,crumbly = 1, sand = 1},
})

minetest.register_node("examobs:gel_flowing2", {
	description = "Gel flowing",
	drawtype = "flowingliquid",
	tiles = {"default_stone.png^[colorize:#00ff0055"},
	special_tiles = {
		{
			name = "default_stone.png^[colorize:#00ff0055",
			backface_culling = false,
		},
		{
			name = "default_stone.png^[colorize:#00ff0055",
			backface_culling = true,
		},
	},
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "examobs:gel_flowing2",
	liquid_alternative_source = "examobs:gel2",
	liquid_viscosity = 1,
	liquid_range = 2,
	post_effect_color = {a=60,r=0,g=150,b=0},
	groups = {liquid = 4, not_in_creative_inventory = 1},
})