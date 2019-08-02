default={
	workbench={
		registered_crafts={}
	},
	player_attached = player_style.player_attached,
	player_set_animation = player_style.set_animation,
	on_player_death = {},
	registered_bios={},
	registered_bios_list={},
	bucket={},
	creative = minetest.settings:get_bool("creative_mode") == true,
	mapgen_limit = tonumber(minetest.settings:get("mapgen_limit")),
	cloud_land_map={
		offset=0,
		scale=1,
		spread={x=350,y=18,z=350},
		seeddiff=24,
		octaves=3,
		persist=0.6,
		lacunarity=2,
		flags="eased",
	},
	water_land_map={
		offset=0,
		scale=1,
		spread={x=35,y=18,z=35},
		seeddiff=24,
		octaves=3,
		persist=0.6,
		lacunarity=2,
		flags="eased",
	},
}

dofile(minetest.get_modpath("default") .. "/functions.lua")
dofile(minetest.get_modpath("default") .. "/furnishings.lua")
dofile(minetest.get_modpath("default") .. "/plants.lua")
dofile(minetest.get_modpath("default") .. "/bows.lua")

dofile(minetest.get_modpath("default") .. "/nodes.lua")
dofile(minetest.get_modpath("default") .. "/mapgen.lua")

dofile(minetest.get_modpath("default") .. "/furnace.lua")
dofile(minetest.get_modpath("default") .. "/crafting.lua")
dofile(minetest.get_modpath("default") .. "/items.lua")
dofile(minetest.get_modpath("default") .. "/craft.lua")
dofile(minetest.get_modpath("default") .. "/entities.lua")
dofile(minetest.get_modpath("default") .. "/block_modifiers.lua")