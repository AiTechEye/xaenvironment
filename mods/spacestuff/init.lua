spacestuff={
	rules = {{x=1,y=0,z=0},{x=-1,y=0,z=0},{x=0,y=0,z=1},{x=0,y=0,z=-1},{x=0,y=1,z=0},{x=0,y=-1,z=0}},
	users = {}
}

minetest.register_craft({
	output = "spacestuff:door_1",
	recipe = {
		{"","default:titanium_ingot","default:titanium_ingot"},
		{"","default:titanium_ingot", "default:titanium_ingot"},
		{"","default:titanium_ingot", "default:titanium_ingot"},
	}
})

minetest.register_craft({
	output = "spacestuff:door_1_safe",
	recipe = {
		{"spacestuff:door_1","default:titaniumblock"},
	}
})

minetest.register_craft({
	output = "spacestuff:air_compressor",
	recipe = {
		{"materials:plastic_sheet","materials:fanblade_metal","materials:plastic_sheet"},
		{"materials:plastic_sheet","air_balloons:gastank_empty","materials:plastic_sheet"},
		{"default:titanium_ingot","materials:gear_metal", "default:titanium_ingot"},
	}
})

minetest.register_craft({
	output = "spacestuff:airgen",
	recipe = {
		{"spacestuff:airgen","spacestuff:air_gassbotte"},
	}
})

minetest.register_craft({
	output = "spacestuff:airgen",
	recipe = {
		{"default:titanium_ingot","spacestuff:air_gassbotte","default:titanium_ingot"},
		{"default:titanium_ingot","materials:plastic_sheet", "default:titanium_ingot"},
	}
})

minetest.register_craft({
	output = "spacestuff:air_gassbotte 2",
	recipe = {
		{"default:titanium_ingot","default:tankstorage","default:titanium_ingot"},
	}
})

minetest.register_craft({
	output = "spacestuff:spacesuit",
	recipe = {
		{"materials:plastic_sheet","spacestuff:air_gassbotte","materials:plastic_sheet"},
		{"materials:plastic_sheet","default:glass_tabletop","materials:plastic_sheet"},
		{"default:titanium_ingot","default:tin_ingot","default:titanium_ingot"},
	}
})

minetest.register_on_leaveplayer(function(player)
	spacestuff.users[player:get_player_name()]=nil
end)

minetest.register_tool("spacestuff:spacesuit", {
	description = "Spacesuit (place on 'Air compressor' to refill)",
	inventory_image = "spacestuff_spacesuit.png",
	on_use=function(itemstack, user, pointed_thing)
		spacestuff.wieldsuit(user,true)
	end,
	on_place=function(itemstack, user, pointed_thing)
		if pointed_thing.under then
			local pos = pointed_thing.under
			if minetest.get_node(pos).name == "spacestuff:air_compressor" then
				for i,v in pairs(spacestuff.rules) do
					local p = {x=pos.x+v.x,y=pos.y+v.y,z=pos.z+v.z}
					if minetest.get_node(p).name == "air" then
						itemstack:set_wear(0)
						minetest.sound_play("spacestuff_pff", {pos=pos, gain = 1, max_hear_distance = 8})
						return itemstack
					end
				end
			end
		end
	end
})

minetest.register_tool("spacestuff:backpack", {
	description = "Backpack",
	inventory_image = "spacestuff_backpack.png",
	wield_scale={x=2,y=2,z=3},
	groups={not_in_creative_inventory=1},
})

spacestuff.wieldsuit=function(user,s)
	if not user then
		return
	end

	local name = user:get_player_name()
	local u = spacestuff.users[name]

	if u == nil and s == nil then
		return
	elseif (u and s) or user:get_hp() <= 0 then
		player_style.remove_player_skin(user,"spacestuff_spacesuit3.png",3)
		u.user:hud_remove(u.hud)
		if spacestuff.users[name].backpack then
			spacestuff.users[name].backpack:remove()
		end
		spacestuff.users[name] = nil
		return
	elseif s then
		local i = user:get_wield_index()
		local stack = user:get_inventory():get_stack("main",i)
		if stack:get_wear() >= 65500 then
			local inv = user:get_inventory()
			if inv:contains_item("main","spacestuff:air_gassbotte") then
				stack:set_wear(0)
				inv:remove_item("main",ItemStack("spacestuff:air_gassbotte"))
				user:get_inventory():set_stack("main",i,stack)
				minetest.sound_play("spacestuff_pff", {pos=pos, gain = 1, max_hear_distance = 8})
				user:get_inventory():add_item("main","spacestuff:air_gassbotte_empty")
			else
				minetest.chat_send_player(name,"Have 'Air gassbottes' in your inventory to reload")
				return
			end
		end

		local backpack
		if player_style.players[name].inv.backpack_object then
			backpack = minetest.add_entity(user:get_pos(),"default:wielditem")
			backpack:set_attach(user, "body2",{x=2, y=0, z=0}, {x=180,y=90,z=0})
			backpack:set_properties({textures={"spacestuff:backpack"},visual_size = {x=0.151,y=0.151,z=0.301}})
		end

		spacestuff.users[name] = {
			air=100,
			user=user,
			index=i,
			backpack = backpack,
			hud=user:hud_add({
				hud_elem_type = "image",
				text ="spacestuff_scene.png",
				name = "spacestuff_sky",
				scale = {x=-100, y=-100},
				position = {x=0, y=0},
				alignment = {x=1, y=1},
			})
		}

		player_style.add_player_skin(user,"spacestuff_spacesuit3.png",3)
		u = spacestuff.users[name]
	end

	local stack = user:get_inventory():get_stack("main",u.index)

	if stack:get_name() ~= "spacestuff:spacesuit" then
		spacestuff.wieldsuit(user,true)
		return
	end

	if stack:get_wear() >= 65500 then
		local inv = user:get_inventory()
		if inv:contains_item("main","spacestuff:air_gassbotte") then
			inv:remove_item("main",ItemStack("spacestuff:air_gassbotte"))
			stack:set_wear(0)
			local pos = user:get_pos()
			minetest.sound_play("spacestuff_pff", {pos=pos, gain = 1, max_hear_distance = 8}) 
			user:get_inventory():add_item("main","spacestuff:air_gassbotte_empty")

			if minetest.get_node(pos).name == "default:vacuum" then
				exaachievements.customize(user,"Space guy")
			end

		else
			minetest.chat_send_player(name,"Have 'Air gassbottes' in your inventory to reload")
			spacestuff.wieldsuit(user,true)
			return
		end
	end

	stack:add_wear(65535/100)
	user:get_inventory():set_stack("main",u.index,stack)
	user:set_breath(10)
	minetest.after(2, function(user)
		spacestuff.wieldsuit(user)
	end,user)
end

minetest.register_node("spacestuff:door_1", {
	description = "Door",
	drop="spacestuff:door_1",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
		}
	},
	tiles = {"default_ironblock.png","default_ironblock.png","default_ironblock.png","spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:12,0=spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:-12,0=spacestuff_warntape.png"},
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local p={x=pos.x,y=pos.y+1,z=pos.z}
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			return false
		else
			minetest.set_node(p, {name = "spacestuff:door_2",param2=minetest.get_node(pos).param2})
		end
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(apos(pos,0,1), {name="spacestuff:door_open_2", param2=minetest.get_node(pos).param2})
		minetest.swap_node(pos, {name="spacestuff:door_open_1", param2=minetest.get_node(pos).param2})
		minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
		minetest.get_node_timer(pos):start(2)
	end,
	after_dig_node = function (pos, name, digger)
		local p = apos(pos,0,1)
		if minetest.get_node(p).name == "spacestuff:door_2" then
			minetest.remove_node(p)
		end
	end
})

minetest.register_node("spacestuff:door_2", {
	description = "Door 2-1",
	drawtype = "nodebox",
	drop="spacestuff:door_1",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
		}
	},
	tiles = {"default_ironblock.png","default_ironblock.png","default_ironblock.png","spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:12,0=spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:-12,0=spacestuff_warntape.png"},
	groups = {cracky = 1, level = 2, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(apos(pos,0,-1), {name="spacestuff:door_open_1", param2=minetest.get_node(pos).param2})
		minetest.swap_node(pos, {name="spacestuff:door_open_2", param2=minetest.get_node(pos).param2})
		minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
		minetest.get_node_timer(pos):start(2)
	end,
	after_dig_node = function (pos, name, digger)
		local p = apos(pos,0,-1)
		if minetest.get_node(p).name == "spacestuff:door_1" then
			minetest.remove_node(p)
		end
	end
})

minetest.register_node("spacestuff:door_open_1", {
	description = "Door (open) 2-o-1",
	drop="spacestuff:door_1",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{0.495, -0.5, -0.124, 1.41, 0.5, 0.125},
		}
	},
	tiles = {"default_ironblock.png","default_ironblock.png","default_ironblock.png","spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:12,0=spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:-12,0=spacestuff_warntape.png"},
	groups = {cracky = 1, level = 2, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
		minetest.swap_node(apos(pos,0,1), {name="spacestuff:door_2", param2=minetest.get_node(pos).param2})
		minetest.swap_node(pos, {name="spacestuff:door_1", param2=minetest.get_node(pos).param2})
	end,
	on_timer=function(pos, elapsed)
		if minetest.get_node(pos).name=="spacestuff:door_open_1" then
			--local p={x=pos.x,y=pos.y+1,z=pos.z}
			minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
			minetest.swap_node(apos(pos,0,1), {name="spacestuff:door_2", param2=minetest.get_node(pos).param2})
			minetest.swap_node(pos, {name="spacestuff:door_1", param2=minetest.get_node(pos).param2})
		end
	end,
	after_dig_node = function (pos, name, digger)
		local p = apos(pos,0,1)
		if minetest.get_node(p).name == "spacestuff:door_open_2" then
			minetest.remove_node(p)
		end
	end
})

minetest.register_node("spacestuff:door_open_2", {
	description = "Door (open) 2-o-1",
	drawtype = "nodebox",
	drop="spacestuff:door_1",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{0.495, -0.5, -0.124, 1.41, 0.5, 0.125},
		}
	},
	tiles = {"default_ironblock.png","default_ironblock.png","default_ironblock.png","spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:12,0=spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:-12,0=spacestuff_warntape.png"},
	groups = {cracky = 1, level = 2, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
		minetest.swap_node(apos(pos,0,-1), {name="spacestuff:door_1", param2=minetest.get_node(pos).param2})
		minetest.swap_node(pos, {name="spacestuff:door_2", param2=minetest.get_node(pos).param2})
	end,
	on_timer = function (pos, elapsed)
		if minetest.get_node(pos).name=="spacestuff:door_open_2" then
			minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
			minetest.swap_node(apos(pos,0,-1), {name="spacestuff:door_1", param2=minetest.get_node(pos).param2})
			minetest.swap_node(pos, {name="spacestuff:door_2", param2=minetest.get_node(pos).param2})
		end
	end,
	after_dig_node = function (pos, name, digger)
		local p = apos(pos,0,-1)
		if minetest.get_node(p).name == "spacestuff:door_open_1" then
			minetest.remove_node(p)
		end
	end
})

minetest.register_node("spacestuff:airgen", {
	description = "Air Generater 100%",
	tiles = {"default_workbench_table.png^default_frame.png","spacestuff_gen.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local a
		local m = minetest.get_meta(pos)
		local pr = m:get_int("air")-10
		if pr <= -10 then
			return
		end

		for i,v in pairs(spacestuff.rules) do
			local p = {x=pos.x+v.x,y=pos.y+v.y,z=pos.z+v.z}
			local n = minetest.get_node(p).name
			local def = default.def(n)
			if def and n ~= "air" and n ~= "spacestuff:air" and (def.buildable_to and def.damage_per_second == 0 and def.pointable == false) then
				minetest.add_node(p,{name="spacestuff:air"})
				minetest.get_node_timer(p):start(0.1)
				a = true
			end
		end
		if a then
			m:set_int("air",pr)
			minetest.get_meta(pos):set_string("infotext", "Air Generater " .. pr .."% (place on 'Air compressor' to refill)")
		end
	end,
	on_place=function(itemstack, user, pointed_thing)
		if pointed_thing.above then
			local m=minetest.get_meta(pointed_thing.above)
			local item1 = itemstack
			local item2 = item1:to_table()
			minetest.add_node(pointed_thing.above,{name="spacestuff:airgen"})
			if item2.meta and item2.meta.air then
				local pos = pointed_thing.above
				if minetest.get_node(apos(pos,0,-1)).name == "spacestuff:air_compressor" then
					for i,v in pairs(spacestuff.rules) do
						local p = {x=pos.x+v.x,y=pos.y+v.y,z=pos.z+v.z}
						if minetest.get_node(p).name == "air" then
							m:set_int("air",100)
							m:set_string("infotext", "Air Generater 100%")
							minetest.sound_play("spacestuff_pff", {pos=pos, gain = 1, max_hear_distance = 8})
							itemstack:take_item()
							return itemstack
						end
					end
				end
				m:set_int("air",item2.meta.air)
				m:set_string("infotext", "Air Generater " .. item2.meta.air .."%")
			else
				m:set_int("air",100)
				m:set_string("infotext", "Air Generater 100%")
			end
		end
		itemstack:take_item()
		return itemstack
	end,
	on_punch=function(pos, node, player, pointed_thing)
		local m=minetest.get_meta(pos)
		local a = m:get_int("air")
		local item1 = ItemStack("spacestuff:airgen")
		if a == 100 then
			player:get_inventory():add_item("main",item1)
			minetest.remove_node(pos)
			return
		end
		local item2 = item1:to_table()
		item2.meta = {air = m:get_int("air"), description="Air Generator "..a.."%"}
		player:get_inventory():add_item("main",item2)
		minetest.remove_node(pos)
		for i,v in pairs(spacestuff.rules) do
			local p = {x=pos.x+v.x,y=pos.y+v.y,z=pos.z+v.z}
			if minetest.get_item_group(minetest.get_node(p).name,"on_update") > 0 then
				local def=default.def(minetest.get_node(p).name)
				if def.on_update then
					def.on_update(p)
					return
				end
			end
		end
	end,
})

minetest.register_node("spacestuff:air", {
	description = "Air",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drawtype = "glasslike",
	post_effect_color = {a = 180, r = 120, g = 120, b = 120},
	use_texture_alpha = "blend",
	tiles = {"default_cloud.png^[colorize:#E0E0E099"},
	groups = {not_in_creative_inventory=0},
	paramtype = "light",
	sunlight_propagates =true,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.1)
	end,
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		local r = m:get_int("range") + 1
		if r < 30 then
			m:set_int("range",r)
			for i,v in pairs(spacestuff.rules) do
				local p = {x=pos.x+v.x,y=pos.y+v.y,z=pos.z+v.z}
				local n = minetest.get_node(p).name
				local def = default.def(n)
				if def and n ~= "air" and n ~= "spacestuff:air" and (def.buildable_to and def.damage_per_second == 0 and def.pointable == false) then
					minetest.add_node(p, {name = "spacestuff:air"})
					minetest.get_meta(p):set_int("range",r)
				end
			end
			minetest.add_node(pos, {name = "air"})
		else
			minetest.add_node(pos, {name = "air"})
			for i,v in pairs(spacestuff.rules) do
				local p = {x=pos.x+v.x,y=pos.y+v.y,z=pos.z+v.z}
				if minetest.get_item_group(minetest.get_node(p).name,"on_update") > 0 then
					local def=default.def(minetest.get_node(p).name)
					if def.on_update then
						def.on_update(p)
						return
					end
				end
			end
		end
	end
})

minetest.register_node("spacestuff:air_gassbotte_empty", {
	description = "Air gassbotte (empty) place on 'Air compressor' to refill",
	tiles = {"default_steelblock.png"},
	drawtype = "nodebox",
	groups = {dig_immediate=3},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	node_box = {type="fixed",fixed={-0.1,-0.5,-0.1,0.1,0.3,0.1}},
	on_construct=function(pos)
		if minetest.get_node(apos(pos,0,-1)).name == "spacestuff:air_compressor" then
			for i,v in pairs(spacestuff.rules) do
				local p = {x=pos.x+v.x,y=pos.y+v.y,z=pos.z+v.z}
				if minetest.get_node(p).name == "air" then
					minetest.set_node(pos,{name="spacestuff:air_gassbotte"})
					minetest.sound_play("spacestuff_pff", {pos=pos, gain = 1, max_hear_distance = 8})
					return
				end
			end
		end
	end,
})

minetest.register_node("spacestuff:air_gassbotte", {
	description = "Air gassbotte",
	tiles = {"default_steelblock.png"},
	drawtype = "nodebox",
	groups = {dig_immediate=3},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	node_box = {type="fixed",fixed={-0.1,-0.5,-0.1,0.1,0.3,0.1}},
})

minetest.register_node("spacestuff:air_compressor", {
	description = "Air compressor",
	tiles = {"default_ironblock.png^[colorize:#f00a^exatec_hole.png^default_chest_top.png","default_ironblock.png^[colorize:#f00a^materials_fanblade_metal.png^exatec_glass.png^default_chest_top.png"},
	groups = {cracky=3},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("spacestuff:door_1_safe", {
	description = "Safe door (only safe in protected areas)",
	drop="spacestuff:door_1_safe",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
		}
	},
	tiles = {"default_ironblock.png","default_ironblock.png","default_ironblock.png","spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:12,0=spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:-12,0=spacestuff_warntape.png"},
	groups = {exatec_wire_connected=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local p={x=pos.x,y=pos.y+1,z=pos.z}
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			return false
		else
			minetest.set_node(p, {name = "spacestuff:door_2_safe",param2=minetest.get_node(pos).param2})
		end
	end,
	on_punch=function(pos, node, player, pointed_thing)
		if not minetest.is_protected(pos, player:get_player_name()) then
			minetest.add_item(pos,"spacestuff:door_1_safe")
			minetest.remove_node(pos)
		end
	end,
	exatec={
		on_wire = function(pos)
			minetest.swap_node(apos(pos,0,1), {name="spacestuff:door_open_2_safe", param2=minetest.get_node(pos).param2})
			minetest.swap_node(pos, {name="spacestuff:door_open_1_safe", param2=minetest.get_node(pos).param2})
			minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
			minetest.get_node_timer(pos):start(2)
		end
	},
	after_destruct = function (pos, onode)
		local p = apos(pos,0,1)
		if minetest.get_node(p).name == "spacestuff:door_2_safe" then
			minetest.remove_node(p)
		end
	end
})

minetest.register_node("spacestuff:door_2_safe", {
	description = "Door 2-1",
	drawtype = "nodebox",
	drop="spacestuff:door_1_safe",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
		}
	},
	tiles = {"default_ironblock.png","default_ironblock.png","default_ironblock.png","spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:12,0=spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:-12,0=spacestuff_warntape.png"},
	groups = {exatec_wire_connected=1, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	exatec={
		on_wire = function(pos)
			minetest.swap_node(apos(pos,0,-1), {name="spacestuff:door_open_1_safe", param2=minetest.get_node(pos).param2})
			minetest.swap_node(pos, {name="spacestuff:door_open_2_safe", param2=minetest.get_node(pos).param2})
			minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
			minetest.get_node_timer(pos):start(2)
		end
	},
	after_destruct = function (pos, onode)
		local p = apos(pos,0,-1)
		if minetest.get_node(p).name == "spacestuff:door_1_safe" then
			minetest.remove_node(p)
		end
	end
})

minetest.register_node("spacestuff:door_open_1_safe", {
	description = "Door (open) 2-o-1",
	drop="spacestuff:door_1_safe",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{0.495, -0.5, -0.124, 1.41, 0.5, 0.125},
		}
	},
	tiles = {"default_ironblock.png","default_ironblock.png","default_ironblock.png","spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:12,0=spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:-12,0=spacestuff_warntape.png"},
	groups = {exatec_wire_connected=1, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	exatec={
		on_wire = function(pos)
			minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
			minetest.swap_node(apos(pos,0,1), {name="spacestuff:door_2_safe", param2=minetest.get_node(pos).param2})
			minetest.swap_node(pos, {name="spacestuff:door_1_safe", param2=minetest.get_node(pos).param2})

		end,
	},
	on_timer=function(pos, elapsed)
		if minetest.get_node(pos).name=="spacestuff:door_open_1_safe" then
			--local p={x=pos.x,y=pos.y+1,z=pos.z}
			minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
			minetest.swap_node(apos(pos,0,1), {name="spacestuff:door_2_safe", param2=minetest.get_node(pos).param2})
			minetest.swap_node(pos, {name="spacestuff:door_1_safe", param2=minetest.get_node(pos).param2})
		end
	end,
	after_destruct = function (pos, onode)
		local p = apos(pos,0,1)
		if minetest.get_node(p).name == "spacestuff:door_open_2_safe" then
			minetest.remove_node(p)
		end
	end
})

minetest.register_node("spacestuff:door_open_2_safe", {
	description = "Door (open) 2-o-1",
	drawtype = "nodebox",
	drop="spacestuff:door_1_safe",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{0.495, -0.5, -0.124, 1.41, 0.5, 0.125},
		}
	},
	tiles = {"default_ironblock.png","default_ironblock.png","default_ironblock.png","spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:12,0=spacestuff_warntape.png","[combine:16x16:0,0=default_ironblock.png:-12,0=spacestuff_warntape.png"},
	groups = {exatec_wire_connected=1, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	exatec={
		on_wire = function(pos)
			minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
			minetest.swap_node(apos(pos,0,-1), {name="spacestuff:door_1_safe", param2=minetest.get_node(pos).param2})
			minetest.swap_node(pos, {name="spacestuff:door_2_safe", param2=minetest.get_node(pos).param2})
		end
	},
	on_timer = function (pos, elapsed)
		if minetest.get_node(pos).name=="spacestuff:door_open_2_safe" then
			minetest.sound_play("spacestuff_door", {pos=pos, gain = 1, max_hear_distance = 5})
			minetest.swap_node(apos(pos,0,-1), {name="spacestuff:door_1_safe", param2=minetest.get_node(pos).param2})
			minetest.swap_node(pos, {name="spacestuff:door_2_safe", param2=minetest.get_node(pos).param2})
		end
	end,
	after_destruct = function (pos, onode)
		local p = apos(pos,0,-1)
		if minetest.get_node(p).name == "spacestuff:door_open_1_safe" then
			minetest.remove_node(p)
		end
	end
})