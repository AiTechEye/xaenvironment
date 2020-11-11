examobs={
	global_timer=0,
	global_time=0,
	global_lifetime=0,
	hiding={},
	storage = minetest.get_mod_storage(),
--	interact_map = {},
	interact_map_timer = -60,
	active = {},
	active_spawn_mob_limit = tonumber(minetest.settings:get("xaenvironment_active_spawn_mob_limit")) or 100,
}

dofile(minetest.get_modpath("examobs") .. "/main.lua")
dofile(minetest.get_modpath("examobs") .. "/functions.lua")
dofile(minetest.get_modpath("examobs") .. "/mob_types.lua")
dofile(minetest.get_modpath("examobs") .. "/npc_stuff.lua")
dofile(minetest.get_modpath("examobs") .. "/mobs.lua")
dofile(minetest.get_modpath("examobs") .. "/items.lua")
dofile(minetest.get_modpath("examobs") .. "/sweet.lua")
dofile(minetest.get_modpath("examobs") .. "/snow.lua")


