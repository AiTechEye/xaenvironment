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

minetest.register_craft({
	output = "nitroglycerin:timed_bomb 3",
	recipe = {
		{"nitroglycerin:c4","nitroglycerin:c4","nitroglycerin:c4"},
		{"nitroglycerin:c4","nitroglycerin:c4","nitroglycerin:c4"},
		{"nitroglycerin:c4","nitroglycerin:c4","nitroglycerin:c4"},
	}
})

minetest.register_craftitem("nitroglycerin:c4", {
	description = "C4",
	inventory_image = "nitroglycerin_c4.png"
})

if examobs then
examobs.register_mob({
	name = "gass_man",
	type = "npc",
	team = "gass",
	textures = {"nitroglycerin_gassman.png"},
	aggressivity = 2,
	walk_speed = 1,
	dmg = 0,
	run_speed = 4,
	animation = "default",
	spawn_chance = 1000,
	extimer = 20,
	inv = {["nitroglycerin:c4"]=1},
	step=function(self)
		if self.fight and examobs.distance(self.object,self.fight) < 3 then
			examobs.showtext(self,self.extimer,"ffff00")
			self.extimer = self.extimer - 1
			if self.extimer and self.extimer < 0 then
				self.extimer = nil
				local pos = self:pos()
				self.object:remove()
				nitroglycerin.explode(pos,{radius=4,set="air"})
			end
		end
	end
})
end