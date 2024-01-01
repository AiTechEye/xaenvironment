minetest.register_node("nitroglycerin:timed_bomb", {
	description = "Timed bomb",
	tiles = {"nitroglycerin_timed_bomb.png"},
	groups = {dig_immediate = 2,flammable = 5,treasure=2,exatec_wire_connected=1,store=500},
	sounds = default.node_sound_wood_defaults(),
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		minetest.after(0.01, function(pos)
			nitroglycerin.explode(pos,{radius=5,set="air"})
			for i, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
				ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=250}})
			end

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
	exatec={
		on_wire = function(pos)
			minetest.sound_play("nitroglycerin_activated", {pos=pos, gain = 1, max_hear_distance = 7})
			minetest.registered_nodes["nitroglycerin:timed_bomb"].on_blast(pos)
		end
	},
	on_burn = function(pos)
		minetest.registered_nodes["nitroglycerin:timed_bomb"].on_rightclick(pos)
	end,
	on_ignite = function(pos, igniter)
		minetest.registered_nodes["nitroglycerin:timed_bomb"].on_rightclick(pos)
	end,
})

minetest.register_node("nitroglycerin:timed_nuclear_bomb", {
	description = "Timed nuclear bomb",
	tiles = {"nitroglycerin_timed_bomb.png^[colorize:#aaff0055"},
	groups = {dig_immediate = 2,flammable = 5,treasure=2,exatec_wire_connected=1,store=4000},
	sounds = default.node_sound_wood_defaults(),
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		minetest.after(0.01, function()
			nitroglycerin.explode(pos,{radius=25,set="air",drops=0})
			for i, ob in pairs(minetest.get_objects_inside_radius(pos, 40)) do
				local pos2 = ob:get_pos()
				local impact = true
				if ob:is_player() then
					pos2 = apos(pos2,0,0.5)
				end
				for v in minetest.raycast(pos,pos2) do
					if v.type == "node" and default.defpos(v.under,"walkable") then
						impact = false
						break
					end
				end
				if impact then
					ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=2000}})
				end
			end
		end)
	end,
	on_timer=function(pos, elapsed)
		minetest.registered_nodes["nitroglycerin:timed_nuclear_bomb"].on_blast(pos)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		if meta:get_int("b")==1 then return end
		meta:set_int("b",1)
		minetest.get_node_timer(pos):start(5)
		minetest.sound_play("nitroglycerin_activated", {pos=pos, gain = 1, max_hear_distance = 7})
	end,

	exatec={
		on_wire = function(pos)
			minetest.sound_play("nitroglycerin_activated", {pos=pos, gain = 1, max_hear_distance = 7})
			minetest.registered_nodes["nitroglycerin:timed_nuclear_bomb"].on_blast(pos)
		end
	},
	on_burn = function(pos)
		minetest.registered_nodes["nitroglycerin:timed_nuclear_bomb"].on_rightclick(pos)
	end,
	on_ignite = function(pos, igniter)
		minetest.registered_nodes["nitroglycerin:timed_nuclear_bomb"].on_rightclick(pos)
	end,
})

minetest.register_craft({
	output = "nitroglycerin:timed_bomb 3",
	recipe = {
		{"default:iron_ingot","default:electric_lump","default:iron_ingot"},
		{"default:iron_ingot","default:uraniumactive_ingot","default:iron_ingot"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
	}
})

minetest.register_craft({
	output = "nitroglycerin:timed_nuclear_bomb",
	recipe = {
		{"default:uraniumactive_ingot","nitroglycerin:timed_bomb","default:uraniumactive_ingot"},
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

minetest.register_craftitem("nitroglycerin:c4", {
	description = "C4",
	inventory_image = "nitroglycerin_c4.png",
	groups={treasure=1,store=200},
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type == "object" then
			local ref = pointed_thing.ref
			minetest.after(5, function(ref)
				local pos = ref:get_pos()
				if pos then
					for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
						local en=ob:get_luaentity()
						ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=50}})
					end
					nitroglycerin.explode(pos,{radius=2,set="air"})
				end
			end,ref)
			itemstack:take_item()
			minetest.sound_play("nitroglycerin_activated", {pos=pointed_thing.ref:get_pos(), gain = 1, max_hear_distance = 7})
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "nitroglycerin:c4",
	recipe = {
		{"default:uranium_lump","default:iron_ingot"},
	}
})

minetest.register_craft({
	output = "nitroglycerin:timed_plutonium_bomb 3",
	recipe = {
		{"default:iron_ingot","default:electric_lump","default:iron_ingot"},
		{"default:iron_ingot","default:plutonium_ingot","default:iron_ingot"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
	}
})

minetest.register_node("nitroglycerin:timed_plutonium_bomb", {
	description = "Small timed plutonium bomb",
	tiles = {"nitroglycerin_timed_bomb.png^[colorize:#00d0ff55"},
	groups = {dig_immediate = 2,flammable = 5,treasure=2,exatec_wire_connected=1,store=500},
	sounds = default.node_sound_metal_defaults(),
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		minetest.after(0.01, function()
			for i, ob in pairs(minetest.get_objects_inside_radius(pos, 20)) do
				local p = ob:get_pos()
				if p and default.defpos(p,"buildable_to") and not minetest.is_protected(p,"") then
					minetest.set_node(p,{name="fire:plutonium_flame"})
				end
				local en = ob:get_luaentity()
				if en and en.name == "__builtin:item" then
					ob:remove()
				else
					ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=10}})
				end
			end
			nitroglycerin.explode(pos,{radius=7,set="fire:plutonium_flame",place={"fire:plutonium_flame","fire:plutonium_flame"}})
		end)
	end,
	on_timer=function(pos, elapsed)
		minetest.registered_nodes["nitroglycerin:timed_plutonium_bomb"].on_blast(pos)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		if meta:get_int("b")==1 then return end
		meta:set_int("b",1)
		minetest.get_node_timer(pos):start(5)
		minetest.sound_play("nitroglycerin_activated", {pos=pos, gain = 1, max_hear_distance = 7})
	end,
	exatec={
		on_wire = function(pos)
			minetest.sound_play("nitroglycerin_activated", {pos=pos, gain = 1, max_hear_distance = 7})
			minetest.registered_nodes["nitroglycerin:timed_plutonium_bomb"].on_blast(pos)
		end
	},
	on_burn = function(pos)
		minetest.registered_nodes["nitroglycerin:timed_plutonium_bomb"].on_rightclick(pos)
	end,
	on_ignite = function(pos, igniter)
		minetest.registered_nodes["nitroglycerin:timed_plutonium_bomb"].on_rightclick(pos)
	end,
})