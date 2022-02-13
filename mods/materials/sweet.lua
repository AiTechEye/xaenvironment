minetest.register_node("materials:sugar", {
	description = "Sugar",
	groups = {crumbly=3,soil=1,candy_ground=1},
	tiles = {"materials_sugar.png"},
	sounds=default.node_sound_snow_defaults(),
})

minetest.register_node("materials:sugar_with_glaze", {
	description = "Sugar with glaze",
	groups = {crumbly=3,spreading_dirt_type=1,candy_ground=1},
	tiles = {"materials_glaze.png","materials_sugar.png","materials_sugar.png^materials_glaze_side.png"},
	sounds=default.node_sound_clay_defaults(),
})

minetest.register_node("materials:sponge_cake", {
	description = "Sponge cake",
	groups = {cracky=3,candy_underground=1},
	tiles = {"materials_spongecake.png"},
	sounds=default.node_sound_snow_defaults(),
})

minetest.register_node("materials:marzipan_rose", {
	description = "Marzipan rose",
	groups = {snappy=3},
	tiles = {"materials_marzipan_rose.png"},
	drawtype="plantlike",
	walkable=false,
	paramtype="light",
	sunlight_propagates=true,
	buildable_to=true,
	sounds=default.node_sound_leaves_defaults(),
	on_use=minetest.item_eat(1)
})

local candycolor={"ff75ec","ff0000","00ff00","0000ff","00ffff","ffff00"}
for i=1,6,1 do
minetest.register_node("materials:candy" .. i, {
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
end

minetest.register_node("materials:gel", {
	description = "Gel",
	drawtype = "liquid",
	tiles = {"default_water.png^[colorize:#00ff1155"},
	use_texture_alpha = "clip",
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = false,
	drowning = 1,
	liquidtype = "source",
	liquid_range = 2,
	liquid_alternative_flowing = "materials:gel_flowing",
	liquid_alternative_source = "materials:gel",
	liquid_viscosity = 15,
	post_effect_color = {a=160,r=0,g=150,b=100},
	groups = {liquid = 4,crumbly = 1, sand = 1,lava=1},
})

minetest.register_node("materials:gel_flowing", {
	description = "Gel flowing",
	drawtype = "flowingliquid",
	use_texture_alpha = "clip",
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
	liquid_alternative_flowing = "materials:gel_flowing",
	liquid_alternative_source = "materials:gel",
	liquid_viscosity = 1,
	liquid_range = 2,
	post_effect_color = {a=160,r=0,g=150,b=100},
	groups = {liquid = 4, not_in_creative_inventory = 1,lava=1},
})

minetest.register_node("materials:gel2", {
	description = "Gel 2",
	drawtype = "liquid",
	use_texture_alpha = "clip",
	tiles = {"default_stone.png^[colorize:#00ff0055"},
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = false,
	drowning = 1,
	liquidtype = "source",
	liquid_range = 2,
	liquid_alternative_flowing = "materials:gel_flowing2",
	liquid_alternative_source = "materials:gel2",
	liquid_viscosity = 15,
	post_effect_color = {a=60,r=0,g=150,b=0},
	groups = {liquid = 4,crumbly = 1, sand = 1,lava=1},
})

minetest.register_node("materials:gel_flowing2", {
	description = "Gel flowing",
	drawtype = "flowingliquid",
	use_texture_alpha = "clip",
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
	liquid_alternative_flowing = "materials:gel_flowing2",
	liquid_alternative_source = "materials:gel2",
	liquid_viscosity = 1,
	liquid_range = 2,
	post_effect_color = {a=60,r=0,g=150,b=0},
	groups = {liquid = 4, not_in_creative_inventory = 1,lava=1},
})