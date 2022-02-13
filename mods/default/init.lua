default={
	XaEnvironment = true,
	workbench={
		registered_crafts={}
	},
	pickup_object={},
	player_attached = player_style.player_attached,
	player_set_animation = player_style.set_animation,
	on_player_death = {},
	registered_bios={},
	registered_bios_list={},
	bucket={},
	registered_item_drops={},
	hand_on_secondary_use={},
	creative = minetest.settings:get_bool("creative_mode") == true,
	mapgen_limit = tonumber(minetest.settings:get("mapgen_limit")),
	ore_noise_params = function(def)
		def = def or {}
		return {
			offset = def.offset or 0,
			scale = def.scale or 1,
			spread = def.spread or {x=100,y=100,z=100},
			seed = def.seed or math.random(1,1000000),
			octaves = def.octaves or 3,
			persist = def.persist or 0.6
		}
	end,
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
	crack_map={
		offset=0,
		scale=1,
		spread={x=500,y=100,z=500},
		seeddiff=15,
		octaves=5,
		persist=1.6,
		lacunarity=1,
		flags="eased",
	},
	deepocean_map={
		offset=0,
		scale=1,
		spread={x=200,y=200,z=200},
		seeddiff=25,
		octaves=3,
		persist=0.6,
		lacunarity=1,
		flags="eased"
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