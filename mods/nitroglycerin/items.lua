minetest.register_node("nitroglycerin:timed_bomb", {
	description = "Timed bomb",
	tiles = {"nitroglycerin_timed_bomb.png"},
	groups = {dig_immediate = 2,mesecon = 2,flammable = 5},
	sounds = default.node_sound_wood_defaults(),
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		minetest.after(0.1, function(pos)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
			local en=ob:get_luaentity()
			ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=250}})
		end
		nitroglycerin.explode(pos,{radius=5,set="air"})
		end,pos)
	end,
	on_timer=function(pos, elapsed)
		minetest.registered_nodes["nitroglycerin:timed_bomb"].on_blast(pos)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		if meta:get_int("b")==1 then return end
		meta:set_int("b",1)
		minetest.get_node_timer(pos):start(5)
		minetest.sound_play("nitroglycerin_activated", {pos=pos, gain = 1, max_hear_distance = 7})
	end,
	mesecons = {effector =
		{action_on=function(pos)
			minetest.registered_nodes["nitroglycerin:timed_bomb"].on_rightclick(pos)
		end
		}
	},
	on_burn = function(pos)
		minetest.registered_nodes["nitroglycerin:timed_bomb"].on_rightclick(pos)
	end,
	on_ignite = function(pos, igniter)
		minetest.registered_nodes["nitroglycerin:timed_bomb"].on_rightclick(pos)
	end,
})

minetest.register_craft({
	output = "nitroglycerin:timed_bomb 3",
	recipe = {
		{"default:steel_ingot","default:electric_lump","default:steel_ingot"},
		{"default:steel_ingot","default:uraniumactive_ingot","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	}
})

minetest.override_item("default:coalblock",{
	on_burn=function(pos)
		minetest.remove_node(pos)
		nitroglycerin.explode(pos,{radius=2,set="air"})
	end,
	on_ignite=function(pos)
		minetest.remove_node(pos)
		nitroglycerin.explode(pos,{radius=2,set="air"})
	end
})

minetest.override_item("default:oil_source",{
	on_burn=function(pos)
		minetest.remove_node(pos)
		nitroglycerin.explode(pos,{radius=4,set="air"})
	end,
	on_ignite=function(pos)
		minetest.remove_node(pos)
		nitroglycerin.explode(pos,{radius=4,set="air"})
	end
})
minetest.override_item("default:oil_flowing",{
	on_burn=function(pos)
		minetest.remove_node(pos)
		nitroglycerin.explode(pos,{radius=4,set="air"})
	end,
	on_ignite=function(pos)
		minetest.remove_node(pos)
		nitroglycerin.explode(pos,{radius=4,set="air"})
	end
})