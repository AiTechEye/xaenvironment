examobs={
	registered_num = 0,
	global_timer=0,
	global_time=0,
	global_lifetime=0,
	hiding={},
	storage = minetest.get_mod_storage(),
	paths={},
--	interact_map = {},
	interact_map_timer = -60,
	terminal_users={},
	active = {
		num=0,
		ref={},
		types={},
		spawn_mob_limit=tonumber(minetest.settings:get("xaenvironment_active_spawn_mob_limit")) or 100,
		spawn_same_mob_limit=tonumber(minetest.settings:get("xaenvironment_active_spawn_same_mob_limit")) or 20,
	},
}

dofile(minetest.get_modpath("examobs") .. "/main.lua")
dofile(minetest.get_modpath("examobs") .. "/functions.lua")
dofile(minetest.get_modpath("examobs") .. "/mob_types.lua")
dofile(minetest.get_modpath("examobs") .. "/npc_stuff.lua")
dofile(minetest.get_modpath("examobs") .. "/mobs.lua")
dofile(minetest.get_modpath("examobs") .. "/items.lua")
dofile(minetest.get_modpath("examobs") .. "/snow.lua")
dofile(minetest.get_modpath("examobs") .. "/blackhole.lua")