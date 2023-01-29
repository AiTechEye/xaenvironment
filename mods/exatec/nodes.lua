minetest.register_craftitem("exatec:list", {
	description = "ExaTec list",
	inventory_image = "default_paper.png",
	groups = {flammable = 1},
	on_use=function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local gui = "size[8.5,12]label[0,0;List of supported items]bgcolor[#ddddddff]"
		local x = -0.2
		local y = 1
		for i,v in pairs(minetest.registered_items) do
			local g = v.groups or {}
			if not g.not_in_creative_inventory and (v.exatec or g and (g.exatec_tube or g.exatec_tube_connected or g.exatec_wire or g.exatec_wire_connected or exatec_data_wire or g.exatec_data_wire_connected)) then
				gui = gui .. "item_image_button["..x..","..y..";1,1;"..i..";"..i..";]"
				x = x + 0.7
				if x > 8 then
					x = -0.2
					y = y +0.8
				end
			end
		end
		minetest.after(0.2, function(name,gui)
			return minetest.show_formspec(name, "exaachievements",gui)
		end, name,gui)
	end
})

minetest.register_node("exatec:tube", {
	description = "Tube",
	tiles = {"exatec_glass.png"},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,store=500},
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected"},
	exatec={
		test_input=function(pos,stack,opos)
			return true
		end,
		on_input=function(pos,stack,opos)
			minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
		end
	}
})

minetest.register_node("exatec:wire_block", {
	description = "Wire block",
	tiles = {{name="default_ironblock.png^[colorize:#ff07"}},
	drop="exatec:wire_block",
	paramtype2="colorwallmounted",
	palette="default_palette.png",
	groups = {cracky = 2,exatec_wire=1,store=1000},
	sounds = default.node_sound_stone_defaults(),
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="exatec:wire_block",param2=112})
	end,
	on_timer = function (pos, elapsed)
		minetest.swap_node(pos,{name="exatec:wire_block",param2=112})
	end,
})

minetest.register_node("exatec:metal_block_tube", {
	description = "Metal block tube",
	tiles = {"default_ironblock.png^exatec_hole.png"},
	groups = {cracky=2,exatec_tube=1,store=1000},
	sounds = default.node_sound_metal_defaults(),
	exatec={
		test_input=function(pos,stack,opos)
			return true
		end,
		on_input=function(pos,stack,opos)
			minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
		end
	},
})

minetest.register_node("exatec:tube_detector", {
	description = "Detector tube",
	tiles = {"exatec_glass.png^[colorize:#ffff00cc"},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,exatec_wire=1,exatec_wire_connected=1,store=600},
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected","group:exatec_wire",},
	exatec={
		test_input=function(pos,stack,opos)
			return true
		end,
		on_input=function(pos,stack,opos)
			minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
		end,
		on_tube=function(pos,stack,opos,ob)
			exatec.send(pos)
		end,
	},
})

minetest.register_node("exatec:tube_gate", {
	description = "Gate tube",
	tiles = {"exatec_glass.png^[colorize:#00ff00cc"},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,exatec_wire_connected=1,store=600},
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected","group:exatec_wire"},
	on_construct=function(pos)
		minetest.get_meta(pos):set_string("infotext","Gate: closed")
	end,
	exatec={
		test_input=function(pos,stack,opos)
			return minetest.get_meta(pos):get_int("open") == 1
		end,
		on_input=function(pos,stack,opos)
			minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
		end,
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local open = m:get_int("open") == 1 and 0 or 1
			m:set_int("open",open)
			m:set_string("infotext","Storage: " .. (open == 1 and "open" or "closed"))
		end,
	},
})


minetest.register_node("exatec:tube_teleport", {
	description = "Teleport tube",
	tiles = {"exatec_glass.png^[colorize:#00e1ffcc"},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,exatec_wire_connected=1,store=600},
	paramtype2 = "facedir",
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected"},
	on_construct = function(pos)
		minetest.registered_nodes["exatec:tube_teleport"].on_teleporttube_set(pos)
	end,
	after_place_node = function(pos, placer)
		exatec.temp.teleport_tube = exatec.temp.teleport_tube or {}
		exatec.temp.teleport_tube[placer:get_player_name()] = pos
	end,
	on_teleporttube_set= function(pos,set_pos)
		local p = "No position set"
		local t = "Punch a input node,\ne.g tube, chest, or unit"
		minetest.forceload_block(pos)
		local m = minetest.get_meta(pos)
		if set_pos then
			p = minetest.pos_to_string(set_pos)
			t = ""
			m:set_string("pos",p)
		end
		m:set_string("formspec","size[4,1]label[0,-0.1;"..p.."]label[0,0.5;"..t.."]")
	end,
	exatec={
		test_input=function(pos,stack,opos)
			local p = minetest.string_to_pos(minetest.get_meta(pos):get_string("pos"))
			minetest.forceload_block(p or pos)
			return p and exatec.test_input(p,stack,p)
		end,
		on_input=function(pos,stack,opos)
			local p = minetest.string_to_pos(minetest.get_meta(pos):get_string("pos"))
			if not (p and exatec.test_input(p,stack,pos)) then
				p = pos
			end
			minetest.forceload_block(p)
			minetest.add_entity(p,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
		end,
		on_tube = function(pos,stack,opos,ob)
			local p = minetest.string_to_pos(minetest.get_meta(pos):get_string("pos"))
			if p and exatec.test_input(p,stack,pos) then
				minetest.forceload_block(p)
				ob:set_pos(p)
			end
		end,
	},
})

minetest.register_node("exatec:tube_dir", {
	description = "Direction tube",
	tiles = {
		"exatec_glass.png^[colorize:#ff00ffcc^default_crafting_arrowup.png",
		"exatec_glass.png^[colorize:#ff00ffcc",
		"exatec_glass.png^[colorize:#ff00ffcc",
		"exatec_glass.png^[colorize:#ff00ffcc",
		"exatec_glass.png^[colorize:#ff00ffcc",
		"exatec_glass.png^[colorize:#ff00ffcc",
	},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,exatec_wire_connected=1,store=600},
	paramtype2 = "facedir",
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected","group:exatec_wire"},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("on",1)
		m:set_string("infotext","Direction on")
	end,
	exatec={
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local on = m:get_int("on") == 1 and 0 or 1
			m:set_int("on",on)
			m:set_string("infotext","Direction: " .. (on == 1 and "On" or "Off"))
		end,
		test_input=function(pos,stack,opos)
			return true
		end,
		on_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local ob = minetest.add_entity(pos,"exatec:tubeitem")
			local en = ob:get_luaentity()
			en:new_item(stack,opos)
			en.storage.dir = d
			ob:set_velocity(d)
		end,
		on_tube = function(pos,stack,opos,ob)
			if minetest.get_meta(pos):get_int("on") == 1 then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				if exatec.test_input(apos(pos,d.x,d.y,d.z),stack,pos) then
					ob:get_luaentity().storage.dir = d
					ob:set_velocity(d)
					ob:set_pos(pos)
				end
			end
		end,
	},
})

minetest.register_node("exatec:recycling_dir_filter", {
	description = "Recycling filter direction tube",
	tiles = {
		"exatec_glass.png^[colorize:#007700cc^default_crafting_arrowup.png",
		"exatec_glass.png^[colorize:#007700cc",
		"exatec_glass.png^[colorize:#007700cc",
		"exatec_glass.png^[colorize:#007700cc",
		"exatec_glass.png^[colorize:#007700cc",
		"exatec_glass.png^[colorize:#007700cc",
	},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,store=600},
	paramtype2 = "facedir",
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected"},
	exatec={
		test_input=function(pos,stack,opos)
			return true
		end,
		on_input=function(pos,stack,opos)
			local inv = minetest.get_meta(pos):get_inventory()
			if stack:get_wear() == 0 and minetest.registered_nodes["default:recycling_mill"].on_metadata_inventory_put(pos, "input",1, stack, nil,stack) then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				local ob = minetest.add_entity(pos,"exatec:tubeitem")
				local en = ob:get_luaentity()
				en:new_item(stack,opos)
				en.storage.dir = d
				ob:set_velocity(d)
			else
				minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
			end
		end,
		on_tube = function(pos,stack,opos,ob)
			local inv = minetest.get_meta(pos):get_inventory()
			if stack:get_wear() == 0 and minetest.registered_nodes["default:recycling_mill"].on_metadata_inventory_put(pos, "input",1, stack, nil,stack) then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				if exatec.test_input(apos(pos,d.x,d.y,d.z),stack,pos) then
					ob:get_luaentity().storage.dir = d
					ob:set_velocity(d)
					ob:set_pos(pos)
				end
			end
		end
	}
})

minetest.register_node("exatec:fuel_dir_filter", {
	description = "Fuel filter direction tube",
	tiles = {
		"exatec_glass.png^[colorize:#555555cc^default_crafting_arrowup.png",
		"exatec_glass.png^[colorize:#555555cc",
		"exatec_glass.png^[colorize:#555555cc",
		"exatec_glass.png^[colorize:#555555cc",
		"exatec_glass.png^[colorize:#555555cc",
		"exatec_glass.png^[colorize:#555555cc",
	},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,store=600},
	paramtype2 = "facedir",
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected"},
	exatec={
		test_input=function(pos,stack,opos)
			return true
		end,
		on_input=function(pos,stack,opos)
			if default.get_fuel(stack) > 0 then
				local ob = minetest.add_entity(pos,"exatec:tubeitem")
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				local en = ob:get_luaentity()
				en:new_item(stack,opos)
				en.storage.dir = d
				ob:set_velocity(d)
			else
				minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
			end
		end,
		on_tube = function(pos,stack,opos,ob)
			if default.get_fuel(stack) > 0 then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				if exatec.test_input(apos(pos,d.x,d.y,d.z),stack,pos) then
					ob:get_luaentity().storage.dir = d
					ob:set_velocity(d)
					ob:set_pos(pos)
				end
			end
		end
	}
})

minetest.register_node("exatec:cookable_dir_filter", {
	description = "Cookable filter direction tube",
	tiles = {
		"exatec_glass.png^[colorize:#ff6600cc^default_crafting_arrowup.png",
		"exatec_glass.png^[colorize:#ff6600cc",
		"exatec_glass.png^[colorize:#ff6600cc",
		"exatec_glass.png^[colorize:#ff6600cc",
		"exatec_glass.png^[colorize:#ff6600cc",
		"exatec_glass.png^[colorize:#ff6600cc",
	},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,store=600},
	paramtype2 = "facedir",
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected"},
	exatec={
		test_input=function(pos,stack,opos)
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
			return result.item:get_name() ~= ""
		end,
		on_input=function(pos,stack,opos)
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
			if result.item:get_name() ~= "" then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				local ob = minetest.add_entity(pos,"exatec:tubeitem")
				local en = ob:get_luaentity()
				en:new_item(stack,opos)
				en.storage.dir = d
				ob:set_velocity(d)
			else
				minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
			end
		end,
		on_tube = function(pos,stack,opos,ob)
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
			if result.item:get_name() ~= "" then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				if exatec.test_input(apos(pos,d.x,d.y,d.z),stack,pos) then
					ob:get_luaentity().storage.dir = d
					ob:set_velocity(d)
					ob:set_pos(pos)
				end
			end
		end
	}
})

minetest.register_node("exatec:group_dir_filter", {
	description = "Group filter direction tube",
	tiles = {
		"exatec_glass.png^[colorize:#ff0000cc^default_crafting_arrowup.png",
		"exatec_glass.png^[colorize:#ff0000cc",
		"exatec_glass.png^[colorize:#ff0000cc",
		"exatec_glass.png^[colorize:#ff0000cc",
		"exatec_glass.png^[colorize:#ff0000cc",
		"exatec_glass.png^[colorize:#ff0000cc",
	},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,store=600},
	paramtype2 = "facedir",
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected"},
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("item", 1)
		minetest.registered_items["exatec:group_dir_filter"].setform(pos)
	end,
	setform = function(pos)
		local m = minetest.get_meta(pos)
		local stack = m:get_inventory():get_stack("item",1)
		local def = minetest.registered_items[stack:get_name()]
		local c = ""
		local g = ""
		if stack:get_name() ~= "" then
			for i,v in pairs(def.groups) do
				g = g .. c..i
				c = ","
			end
		end
		m:set_string("formspec",
			"size[8,5]"
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."dropdown[1,0;7,1;group;"..g..";"..m:get_int("index").."]"
			.."list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";item;0,0;1,1;]"
			.."list[current_player;main;0,1;8,4;]" 
		)
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_stack("item",1,nil)
		m:set_int("index",0)
		m:set_string("group","")
		minetest.registered_items["exatec:group_dir_filter"].setform(pos)
		return 0
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local def = minetest.registered_items[stack:get_name()]
			if def and def.groups then
				stack:set_count(1)
				minetest.get_meta(pos):get_inventory():set_stack("item",1,stack)
				minetest.registered_items["exatec:group_dir_filter"].setform(pos)
			end
		end
		return 0
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.group then
			local m = minetest.get_meta(pos)
			local def = minetest.registered_items[m:get_inventory():get_stack("item",1):get_name()]
			local x = 0
			m:set_string("group",pressed.group)
			for i,v in pairs(def.groups) do
				x = x + 1
				if i == pressed.group then
					m:set_int("index",x)
					minetest.registered_items["exatec:group_dir_filter"].setform(pos)
					return
				end
			end
		end
	end,
	exatec={
		test_input=function(pos,stack,opos)
			local m = minetest.get_meta(pos)
			return m:get_string("group") ~= "" and minetest.get_item_group(stack:get_name(),m:get_string("group")) > 0
		end,
		on_input=function(pos,stack,opos)
			local m = minetest.get_meta(pos)
			if m:get_string("group") ~= "" and minetest.get_item_group(stack:get_name(),m:get_string("group")) > 0 then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				local ob = minetest.add_entity(pos,"exatec:tubeitem")
				local en = ob:get_luaentity()
				en:new_item(stack,opos)
				en.storage.dir = d
				ob:set_velocity(d)
			else
				minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
			end
		end,
		on_tube = function(pos,stack,opos,ob)
			local m = minetest.get_meta(pos)
			if m:get_string("group") ~= "" and minetest.get_item_group(stack:get_name(),m:get_string("group")) > 0 then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				if exatec.test_input(apos(pos,d.x,d.y,d.z),stack,pos) then
					ob:get_luaentity().storage.dir = d
					ob:set_velocity(d)
					ob:set_pos(pos)
				end
			end
		end
	}
})

minetest.register_node("exatec:tube_filter", {
	description = "Filter tube",
	tiles = {
		"exatec_glass.png^[colorize:#000000",
		"exatec_glass.png^[colorize:#ffffff",
		"exatec_glass.png^[colorize:#ff0000",
		"exatec_glass.png^[colorize:#00ff00",
		"exatec_glass.png^[colorize:#0000ff",
		"exatec_glass.png^[colorize:#ffff00",
	},
	use_texture_alpha = "clip",
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,store=700},
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected","group:exatec_wire"},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		local b = ""
		if inv:get_size("input1") == 0 then
			inv:set_size("input1", 1)
			inv:set_size("input2", 1)
			inv:set_size("input3", 1)
			inv:set_size("input4", 1)
			inv:set_size("input5", 1)
			inv:set_size("input6", 1)
		else
			for i=1,6 do
			local d = m:get_string("input"..i)
			for i2,v in pairs(d.split(d,",")) do
				b=b.."item_image_button["..(i2-1)..","..(i-1)..";1,1;"..v..";input"..i..":"..v..";]"
			end
			end
		end
		local out = m:get_int("out")
		m:set_string("formspec",
			"size[13.2,10]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."label[12.5,-0.2;Out]"
			.."box[0,0;12,1;#ff0000]".."list[context;input1;11,0;1,1;]checkbox[12.5,0;out5;;"..(out==5 and "true" or "false").."]"
			.."box[0,1;12,1;#00ff00]".."list[context;input2;11,1;1,1;]checkbox[12.5,1;out4;;"..(out==4 and "true" or "false").."]"
			.."box[0,2;12,1;#0000ff]".."list[context;input3;11,2;1,1;]checkbox[12.5,2;out3;;"..(out==3 and "true" or "false").."]" 
			.."box[0,3;12,1;#ffff00]".."list[context;input4;11,3;1,1;]checkbox[12.5,3;out2;;"..(out==2 and "true" or "false").."]"
			.."box[0,4;12,1;#000000]".."list[context;input5;11,4;1,1;]checkbox[12.5,4;out1;;"..(out==1 and "true" or "false").."]"
			.."box[0,5;12,1;#ffffff]".."list[context;input6;11,5;1,1;]checkbox[12.5,5;out0;;"..(out==0 and "true" or "false").."]" 
			.."list[current_player;main;2,6.2;8,4;]" 
			..b
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local m = minetest.get_meta(pos)
			local d = m:get_string(listname)
			local s = d.split(d,",")
			local name = stack:get_name()
			if #s >=11 then
				return 0
			end
			for i,v in pairs(s) do
				if v == name then
					return 0
				end
			end
			m:set_string(listname,d..name..",")
			minetest.registered_nodes["exatec:tube_filter"].on_construct(pos)
		end
		return 0
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		local m = minetest.get_meta(pos)
		for i,v in pairs(pressed) do
			if i:sub(1,5) == "input" then
				local it = i:sub(8,-1)
				local na = i:sub(1,6)
				m:set_string(na,m:get_string(na):gsub(it..",",""))
				minetest.registered_nodes["exatec:tube_filter"].on_construct(pos)
				return
			elseif i:sub(1,3) == "out" then
				m:set_int("out",tonumber(i:sub(4,5)))
				minetest.registered_nodes["exatec:tube_filter"].on_construct(pos)
				return
			end
		end
	end,
	exatec={
		test_input=function(pos,stack,opos)
			return true
		end,
		on_input=function(pos,stack,opos)
			minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
		end,
		on_tube=function(pos,stack,opos,ob)
			local m = minetest.get_meta(pos)
			local n = stack:get_name()
			local e
			for i,v in pairs(exatec.tube_rules) do
				local d = m:get_string("input"..i)
				if d:find(n) then
					ob:set_velocity(v)
					ob:get_luaentity().storage.dir = v
					ob:set_pos(pos)
					return
				end
			end

			local out =  m:get_int("out")
			for i=0,5 do
				if i == out then
					local I = math.abs(6-i)
					local v = exatec.tube_rules[I]
					ob:set_velocity(v)
					ob:get_luaentity().storage.dir = v
					ob:set_pos(pos)
					return
				end
			end
		end,
	},
})

minetest.register_node("exatec:wire", {
	description = "Wire",
	tiles = {{name="default_cloud.png"}},
	wield_image="exatec_wire.png",
	inventory_image="exatec_wire.png",
	drop="exatec:wire",
	drawtype="nodebox",
	use_texture_alpha = "opaque",
	paramtype = "light",
	paramtype2="colorwallmounted",
	palette="default_palette.png",
	sunlight_propagates=true,
	walkable=false,
	node_box = {
		type = "connected",
		connect_back={-0.05,-0.5,0, 0.05,-0.45,0.5},
		connect_front={-0.05,-0.5,-0.5, 0.05,-0.45,0},
		connect_left={-0.5,-0.5,-0.05, 0.05,-0.45,0.05},
		connect_right={0,-0.5,-0.05, 0.5,-0.45,0.05},
		connect_top = {-0.05, -0.5, -0.05, 0.05, 0.5, 0.05},
		fixed = {-0.05, -0.5, -0.05, 0.05, -0.45, 0.05},
	},
	selection_box={type="fixed",fixed={-0.5,0.4,-0.5,0.5,0.5,0.5}},
	connects_to={"group:exatec_wire","group:exatec_wire_connected"},
	groups = {dig_immediate = 3,exatec_wire=1,store=100},
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="exatec:wire",param2=112})
	end,
	on_timer = function (pos, elapsed)
		minetest.swap_node(pos,{name="exatec:wire",param2=112})
	end,
})

minetest.register_node("exatec:datawire", {
	description = "Data wire",
	tiles = {{name="default_cloud.png"}},
	wield_image="exatec_wire.png^[colorize:#fff",
	inventory_image="exatec_wire.png^[colorize:#fff",
	drop="exatec:datawire",
	drawtype="nodebox",
	paramtype = "light",
	use_texture_alpha = "opaque",
	paramtype2="colorwallmounted",
	palette="default_palette.png",
	sunlight_propagates=true,
	walkable=false,
	node_box = {
		type = "connected",
		connect_back={-0.05,-0.5,0, 0.05,-0.45,0.5},
		connect_front={-0.05,-0.5,-0.5, 0.05,-0.45,0},
		connect_left={-0.5,-0.5,-0.05, 0.05,-0.45,0.05},
		connect_right={0,-0.5,-0.05, 0.5,-0.45,0.05},
		connect_top = {-0.05, -0.5, -0.05, 0.05, 0.5, 0.05},
		fixed = {-0.05, -0.5, -0.05, 0.05, -0.45, 0.05},
	},
	selection_box={type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	connects_to={"group:exatec_data_wire","group:exatec_data_wire_connected"},
	groups = {dig_immediate = 3,exatec_data_wire=1,store=100},
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="exatec:datawire",param2=134})
	end,
	on_timer = function(pos, elapsed)
		minetest.swap_node(pos,{name="exatec:datawire",param2=134})
	end,
})

minetest.register_node("exatec:button", {
	description = "Button",
	tiles={"default_wood.png",},
	drawtype = "nodebox",
	node_box = {type = "fixed",fixed={-0.2, -0.5, -0.2, 0.2, -0.3, 0.2}},
	paramtype = "light",
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	sounds = default.node_sound_wood_defaults(),
	groups = {chappy=3,dig_immediate = 2,exatec_wire_connected=1,store=200},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		exatec.send(pos)
	end,
})

minetest.register_node("exatec:autosender", {
	description = "Auto sender",
	tiles={
		"default_ironblock.png^materials_gear_metal.png",
		"default_ironblock.png^materials_gear_metal.png",
		"default_ironblock.png^materials_gear_metal.png^exatec_wirecon.png"
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_wire_connected=1,store=200},
	exatec={
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local t = minetest.get_node_timer(pos)
		local m = minetest.get_meta(pos)
		if t:is_started() then
			t:stop()
			m:set_string("infotext","OFF")
		else
			t:start(1)
			m:set_string("infotext","ON")
		end
	end,
	on_timer = function (pos, elapsed)
		exatec.send(pos)
		return true
	end
})

minetest.register_node("exatec:autocrafter", {
	description = "Autocrafter",
	tiles={"default_ironblock.png^default_craftgreed.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1,store=200},
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		local item = m:get_string("item")
		if m:get_string("item") == "" then
			local inv = m:get_inventory()
			inv:set_size("input", 16)
			inv:set_size("output", 16)
			inv:set_size("craft", 9)
		end
		m:set_string("formspec",
			"size[8,11]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."list[context;craft;2,0;3,3;]" 
			.."box[6,1;1,1;#666666]"
			..(item ~="" and "item_image[6,1;1,1;"..item.."]" or "")
			.."list[context;input;-0.2,3;4,4;]" 
			.."list[context;output;4.2,3;4,4;]" 
			.."label[0,2.5;Input]" 
			.."label[7,2.5;Output]" 
			.."list[current_player;main;0,7.1;8,4;]" 
			.."listring[current_player;main]" 
			.."listring[current_name;input]" 
			.."listring[current_name;output]" 
			.."listring[current_player;main]"

			.."listring[current_player;craft]"
			.."listring[current_player;main]"
		)
	end,
	exatec={
		input_list="input",
		output_list="output",
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local inv = m:get_inventory()
			if m:get_string("item") ~= "" then
				local craft = minetest.get_craft_recipe(m:get_string("item"))
				if not (craft.items and craft.type == "normal") or not inv:room_for_item("output",ItemStack(m:get_string("item").." " .. m:get_string("count"))) then
					return
				end
				local list = {}
				for i,v in pairs(craft.items) do
					list[v] = (list[v] and list[v]+1) or 1
				end
				for i,v in pairs(list) do
					if i:sub(1,6) == "group:" then
						local it = 0
						local n = i:sub(7,-1)
						for i2,v2 in pairs(inv:get_list("input")) do
							if minetest.get_item_group(v2:get_name(),n) > 0 then
								it = it + v2:get_count()
								if it >= v then
									break
								end
							end
						end
						if it < v then
							return
						end
					elseif not inv:contains_item("input",ItemStack(i .." " .. v)) then
						return
					end
				end
				for i,v in pairs(list) do
					if i:sub(1,6) == "group:" then
						for i2,v2 in pairs(inv:get_list("input")) do
							if minetest.get_item_group(v2:get_name(),i:sub(7,-1)) > 0 then
								inv:remove_item("input",v2:get_name() .. " " .. v)
								break
							end
						end
					else
						inv:remove_item("input",ItemStack(i .." " .. v))
					end
				end
				inv:add_item("output",ItemStack(m:get_string("item").." " .. m:get_string("count")))
				return true
			end
		end,
	},
	set_craft_item=function(pos)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		local craft = minetest.get_craft_result({method = "normal",width = 3, items = inv:get_list("craft")})
		m:set_string("item",craft.item:get_name())
		m:set_int("count",craft.item:get_count())
		minetest.registered_nodes["exatec:autocrafter"].on_construct(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "craft" then
			minetest.registered_nodes["exatec:autocrafter"].set_craft_item(pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "craft" or from_list == "craft" then
			minetest.registered_nodes["exatec:autocrafter"].set_craft_item(pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "craft" then
			minetest.registered_nodes["exatec:autocrafter"].set_craft_item(pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("input") and inv:is_empty("output") and inv:is_empty("craft")
	end,
})

minetest.register_node("exatec:extraction", {
	description = "Extraction",
	tiles={
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png^default_crafting_arrowright.png^exatec_wirecon.png",
		"default_ironblock.png^default_crafting_arrowleft.png^exatec_wirecon.png",
		"default_ironblock.png^exatec_hole.png^exatec_wirecon.png",
		"default_ironblock.png^exatec_hole.png^exatec_wirecon.png",
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_tube=1,exatec_wire_connected=1,store=200},
	after_place_node=function(pos, placer, itemstack, pointed_thing)
		if placer:is_player() and minetest.check_player_privs(placer:get_player_name(), {creative=true}) then
			local m = minetest.get_meta(pos)
			m:set_string("formspec",
				"size[4.5,2]"
				.."listcolors[#77777777;#777777aa;#000000ff]"
				..'label[0,-0.2;Logical problems:\nStacks can disappear\nin "Full" mode in some cases]'
				.."button[0,1;2,1;stack;"..(m:get_int("stack") == 0 and "Single" or "Full").."]"
				.."button_exit[2,1;2,1;hide;Hide]"
			)
		end
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
			local m = minetest.get_meta(pos)
		if pressed.stack then
			m:set_int("stack",m:get_int("stack") == 0 and 1 or 0)
			minetest.registered_nodes["exatec:extraction"].after_place_node(pos, sender)
		elseif pressed.hide then
			m:set_string("formspec","")
		end
	end,
	exatec={
		on_wire = function(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local b = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
			local b1 = exatec.def(b)
			if b1.output_list then

				local st = minetest.get_meta(pos):get_int("stack")
				local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
				local f1 = exatec.def(f)
				
				for i,v in pairs(minetest.get_meta(b):get_inventory():get_list(b1.output_list)) do
					if v:get_name() ~= "" then
						local stack = ItemStack(v:get_name() .." ".. (st == 0 and 1 or v:get_count()))
						if exatec.test_input(f,stack,pos,pos) and exatec.test_output(b,stack,pos,pos) then
							exatec.input(f,stack,pos,pos)
							exatec.output(b,stack,pos,pos)
							minetest.sound_play("default_pump_out", {pos=pos, gain = 2, max_hear_distance = 10})
							return true
						end
					end
				end
				minetest.sound_play("default_pump_in", {pos=pos, gain = 2, max_hear_distance = 10})
			end
		end,
		test_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			return exatec.test_input(f,stack,pos,pos)
		end,
		on_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			if exatec.test_input(f,stack,pos) then
				exatec.input(f,stack,pos)
			end
		end,
	},
})

minetest.register_node("exatec:dump", {
	description = "Dump",
	tiles={
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png^default_crafting_arrowright.png^exatec_wirecon.png",
		"default_ironblock.png^default_crafting_arrowleft.png^exatec_wirecon.png",
		"default_ironblock.png^exatec_hole.png^default_chest_top.png^exatec_wirecon.png",
		"default_ironblock.png^exatec_hole.png^default_chest_top.png^exatec_wirecon.png",
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_tube=1,exatec_wire_connected=1,store=200},
	exatec={
		on_wire = function(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local b = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
			local b1 = exatec.def(b)
			if b1.output_list then
				local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
				for i,v in pairs(minetest.get_meta(b):get_inventory():get_list(b1.output_list)) do
					if v:get_name() ~= "" then
						local stack = ItemStack(v:get_name() .." " .. 1)
						if exatec.test_output(b,stack,pos) then
							exatec.output(b,stack,pos)
							minetest.add_item(f,stack)
							minetest.sound_play("default_pump", {pos=pos, gain = 1, max_hear_distance = 10})
							return true
						end
					end
				end
			end
		end,
		test_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			return not exatec.getnodedefpos(f).walkable
		end,
		on_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			if not exatec.getnodedefpos(f).walkable then
				minetest.add_item(f,stack)
			end
		end,
	},
})

minetest.register_node("exatec:counter", {
	description = "Counter",
	tiles = {	"default_ironblock.png^materials_gear_metal.png",
		"default_ironblock.png^materials_gear_metal.png",
		"default_ironblock.png^materials_gear_metal.png^exatec_wirecon.png"
	},
	groups = {chappy=3,dig_immediate = 2,exatec_wire_connected=1,store=150},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("times",1)
		m:set_string("infotext","Counter: 0 count: 0")
		m:set_string("formspec","size[4,0.5]field[0,0;3,1;text;;]button_exit[3,-0.3;1,1;go;Go]")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.go then
			local m = minetest.get_meta(pos)
			local n = tonumber(pressed.text)
			local t = 10000000
			if n then
				n = n < t and n or t
				n = n > 0 and n or 0
				m:set_string("formspec","size[4,0.5]field[0,0;3,1;text;;"..n.."]button_exit[3,-0.3;1,1;go;Go]")
				m:set_int("times",n)
				m:set_string("infotext","Counter: "..n.." count: "..m:get_int("count"))
			end
		end
	end,
	exatec={
		on_wire = function(pos)
			local meta = minetest.get_meta(pos)
			local c = meta:get_int("count")+1
			local times = meta:get_int("times")
			if c >= times then
				minetest.after(0, function(pos)
					exatec.send(pos,true)
				end,pos)
				c = 0
			end
			meta:set_int("count",c)
			meta:set_string("infotext","Counter: "..times.." count: "..c)
		end
	}
})
minetest.register_node("exatec:delayer", {
	description = "Delayer (Click to change time)",
	tiles = {
		"default_ironblock.png^clock.png^default_chest_top.png",
		"default_ironblock.png",
		"default_ironblock.png^exatec_wire.png"},
	groups = {dig_immediate = 2,exatec_wire_connected=1,store=150},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name()) == false then
			local meta = minetest.get_meta(pos)
			local time = meta:get_int("time") + 1
			time = time < 601 and time or 1
			meta:set_int("time",time)
			meta:set_string("infotext","Delayer (" .. time ..")")
		end
	end,
	on_punch = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name()) == false then
			local meta = minetest.get_meta(pos)
			local time = meta:get_int("time") + 10
			time = time < 601 and time or 1
			meta:set_int("time",time)
			meta:set_string("infotext","Delayer (" .. time ..")")
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("time",1)
		meta:set_string("infotext","Delayer (1)")
	end,
	on_timer = function (pos, elapsed)
		minetest.get_meta(pos):set_int("case",0)
		exatec.send(pos,true)
	end,
	exatec={
		on_wire = function(pos)
			local meta = minetest.get_meta(pos)
			if meta:get_int("case") == 0 then
				meta:set_int("case",1)
				minetest.get_node_timer(pos):start(meta:get_int("time"))
			end
		end
	}
})

minetest.register_node("exatec:toggleable_storage", {
	description = "Toggleable storage",
	tiles={
		"default_wood.png^default_chest_top.png^exatec_hole.png",
		"default_wood.png^default_chest_top.png^exatec_hole.png",
		"default_wood.png^default_chest_top.png^exatec_hole.png^exatec_wirecon.png"
	},
	groups = {choppy=3,flammable=2,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1,store=200},
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 32)
		m:set_string("infotext","Storage: closed")
		m:set_string("formspec",
			"size[8,8]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
			"list[current_player;main;0,4.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
	end,
	exatec={
		input_list="main",
		output_list="main",
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local open = m:get_int("open") == 1 and 0 or 1
			m:set_int("open",open)
			m:set_string("infotext","Storage: " .. (open == 1 and "open" or "closed"))
		end,
		test_input=function(pos,stack,opos)
			return minetest.get_meta(pos):get_int("open") == 1
		end,
		test_output=function(pos,stack,opos)
			return minetest.get_meta(pos):get_int("open") == 1
		end,
	},
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
})

minetest.register_node("exatec:wire_gate", {
	description = "Wire gate",
	tiles={
		"default_ironblock.png^default_crafting_arrowup.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
	},
	groups = {dig_immediate = 2,exatec_wire_connected=1,store=100},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	exatec={
		on_wire = function(pos,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			if not exatec.samepos(vector.subtract(opos,pos),d) then
				exatec.send({x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z},true,true)
			end
		end,
	}
})

minetest.register_node("exatec:wire_dir_gate", {
	description = "Wire direction gate",
	tiles={
		"default_ironblock.png^exatec_wire.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
	},
	groups = {dig_immediate = 2,exatec_wire_connected=1,store=100},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	exatec={
		on_wire = function(pos,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local b  = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			if exatec.samepos(vector.subtract(opos,pos),d) then
				return
			elseif exatec.samepos(opos,f) then
				exatec.send(b,true,true)
			elseif exatec.samepos(opos,b) then
				exatec.send(f,true,true)
			end
		end,
	}
})

minetest.register_node("exatec:wire_gate_toggleable", {
	description = "Toggleable wire gate",
	tiles={
		"default_ironblock.png^default_crafting_arrowup.png^exatec_wire.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
	},
	groups = {dig_immediate = 2,exatec_wire_connected=1,store=120},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local m = minetest.get_meta(pos)
			local i = m:get_int("toggleable") == 1 and 0 or 1
			local a = m:get_int("auto")
			m:set_int("toggleable",i)
			m:set_int("on",1)
			m:set_string("infotext","On, "..(i == 0 and "not " or "") .. "toggleable, auto: "..(a == 1 and "On" or "Off"))
		end
	end,
	on_punch = function(pos, node, player, itemstack, pointed_thing)
		local m = minetest.get_meta(pos)
		local a = m:get_int("auto") == 1 and 0 or 1
		local i = m:get_int("toggleable")
		m:set_int("auto",a)
		m:set_int("on",1)
		m:set_string("infotext","On, "..(i == 0 and "not " or "") .. "toggleable, auto: "..(a == 1 and "On" or "Off"))
	end,
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("toggleable",1)
		m:set_int("on",1)
		m:set_string("infotext","On, toggleable, auto closing: Off")
	end,
	exatec={
		on_wire = function(pos,opos)
			local m = minetest.get_meta(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			local b = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
			local toggleable = m:get_int("toggleable")
			local a = m:get_int("auto") == 1
			local on = m:get_int("on")
			if on == 1 and a and exatec.samepos(opos,b) then
				exatec.send(f,true,true)
				m:set_int("on",0)
				m:set_string("infotext","Off, toggleable, auto: " .. (a and "On" or "Off"))
			elseif toggleable == 1 and not exatec.samepos(opos,f) and not exatec.samepos(opos,b) then
				on = on == 1 and 0 or 1
				m:set_int("on",on)
				m:set_string("infotext",(on == 1 and "On" or "Off") .. ", toggleable, auto: " .. (a and "On" or "Off"))
			elseif on == 1 and exatec.samepos(opos,b) then
				exatec.send(f,true,true)
			end
		end,
	}
})

minetest.register_node("exatec:object_detector", {
	description = "Object detector",
	tiles = {
		"default_steelblock.png^exatec_glass.png^default_chest_top.png",
		"default_steelblock.png^exatec_glass.png^default_chest_top.png",
		"default_steelblock.png^exatec_glass.png^default_chest_top.png^(default_crafting_arrowleft.png^default_crafting_arrowright.png^[colorize:#00ff00)"
	},
	groups = {dig_immediate = 2,exatec_wire=1,exatec_data_wire_connected=1,store=300},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("formspec","size[1,1]button_exit[0,0;1,1;go;Setup]")
		minetest.get_node_timer(pos):start(2)
	end,
	on_timer = function (pos, elapsed)
		local obs = {}
		local sen
		local m = minetest.get_meta(pos)
		local o = m:get_int("only")
		local n = m:get_string("object")
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, m:get_int("radius"))) do
			local en = ob:get_luaentity()
			local name = en and en.name or ob:is_player() and ob:get_player_name()
			if not (en and (en.exatec_item or en.name == "__builtin:item")) and (n == "" or (o == 0 and name == n) or (o == 1 and name ~= n)) then
				if not sen then
					sen = true
					exatec.send(pos,true)
				end
				table.insert(obs,ob)
			end
		end
		if sen then
			exatec.data_send(pos,m:get_string("to_channel"),m:get_string("channel"),{objects=obs})
		end
		return true
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.go or pressed.auto or pressed.only and minetest.is_protected(pos, sender:get_player_name())==false then
			local m = minetest.get_meta(pos)
			local n = tonumber(pressed.radius) or m:get_int("radius")
			n = n <= 20 and n or 20
			n = n >= 1 and n or 1
			m:set_int("radius",n)

			local only = m:get_int("only")
			if pressed.only then
				only = only == 0 and 1 or 0
				m:set_int("only",only)
			end

			local to_channel = pressed.to_channel or m:get_string("to_channel")
			local channel = pressed.channel or m:get_string("channel")

			m:set_string("to_channel",to_channel)
			m:set_string("channel",channel)

			local object = pressed.object or m:get_string("object")
			if pressed.auto then
				for _, ob in pairs(minetest.get_objects_inside_radius(pos, n)) do
					local en = ob:get_luaentity()
					if en and en.name ~= "__builtin:item" then
						object = en.name
					elseif ob:is_player() then
						object = ob:get_player_name()
					end
				end
			end
			m:set_string("object",object)
			local err = (minetest.player_exists(object) or minetest.registered_entities[object]) and "" or "box[-0.3,0.8;2.8,0.7;#ff0000]"
			err = object == "" and "" or err

			m:set_string("formspec","size[6,2.2]"
			..err
			.."field[0,0;3,1;radius;;"..n.."]"
			.."field[0,1;3,1;object;;"..object.."]"
			.."button_exit[3,-0.3;1,1;go;Save]"
			.."button_exit[2.5,0.7;2,1;auto;Autodetect]"
			.."button_exit[4.3,0.7;2,1;only;"..(only == 0 and "Only" or "Except").."]"
			.."field[0,2;3,1;channel;;"..channel.."]"
			.."field[3,2;3,1;to_channel;;"..to_channel.."]"
			.."tooltip[channel;Channel]"
			.."tooltip[to_channel;To channel]"
			.."tooltip[object;Object/player name]"
			.."tooltip[radius;Radius]"
			)
		end
	end,
})

minetest.register_node("exatec:vacuum", {
	description = "Vacuum",
	tiles={
		"default_stone.png^exatec_hole_big.png^materials_fanblade_metal.png",
		"default_stone.png",
		"default_stone.png^exatec_hole.png^exatec_wirecon.png"
	},
	groups = {cracky=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1,store=300},
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 32)
		m:set_string("infotext","Radius (1)")
		m:set_int("radius",1)
		m:set_string("formspec",
			"size[8,8]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
			"list[current_player;main;0,4.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
	end,
	on_punch = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local m = minetest.get_meta(pos)
			local radius=m:get_int("radius")
			radius = radius < 10 and radius or 0
			m:set_int("radius",radius+1)
			m:set_string("infotext","Radius (" .. (radius+1) ..")")
		end
	end,
	exatec={
		input_list="main",
		output_list="main",
		on_wire = function(pos)
			local inv = minetest.get_meta(pos):get_inventory()
			for _, ob in pairs(minetest.get_objects_inside_radius(pos,minetest.get_meta(pos):get_int("radius"))) do
				local en = ob:get_luaentity()
				if en and en.name == "__builtin:item" then
					if inv:room_for_item("main",en.itemstring) then
						exatec.input(pos,ItemStack(en.itemstring),pos)
						ob:remove()
					else
						return
					end
				end
			end
		end,
	},
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
})

minetest.register_node("exatec:node_breaker", {
	description = "Node breaker",
	tiles={
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png^exatec_wirecon.png",
		"default_ironblock.png^exatec_wirecon.png",
		"default_ironblock.png^exatec_hole_big.png^materials_sawblade.png^exatec_wirecon.png",
		"default_ironblock.png^exatec_hole.png^exatec_wirecon.png",
	},
	groups = {cracky=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1,store=400},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name())
		meta:set_int("range",1)
		meta:set_string("infotext","Range (1)")
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name()) == false then
			local meta = minetest.get_meta(pos)
			local range=meta:get_int("range")
			range = range < 10 and range or 0
			meta:set_int("range",range+1)
			meta:set_string("infotext","Range (" .. (range+1) ..")")
		end
	end,
	exatec={
		on_wire = function(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local b = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
			for i=1,minetest.get_meta(pos):get_int("range") do
				local f = {x=pos.x+(d.x*i),y=pos.y+(d.y*i),z=pos.z+(d.z*i)}
				local n = minetest.get_node(f).name
				local def = minetest.registered_nodes[n] or {}
				local fowner = minetest.get_meta(f):get_string("owner")
				local owner = minetest.get_meta(pos):get_string("owner")

				if n ~= "air" and def.drop ~= "" and minetest.get_item_group(n,"unbreakable") == 0 and not (def.can_dig and def.can_dig(f, {get_player_name=function() return owner end}) ==  false) and fowner == "" and not minetest.is_protected(f, owner) then
					local stack = ItemStack(n)
					if exatec.test_input(b,stack,pos) then
						exatec.input(b,stack,pos)
					else
						minetest.add_item(b,stack)
					end
					minetest.remove_node(f)
					default.update_nodes(f)
				end
				local inv = minetest.get_meta(pos):get_inventory()
				for _, ob in pairs(minetest.get_objects_inside_radius(f,1)) do
					local en = ob:get_luaentity()
					if en and en.name == "__builtin:item" then
						local s = ItemStack(en.itemstring)
						if exatec.test_input(b,s,pos) then
							exatec.input(b,s,pos)
						else
							minetest.add_item(b,s)
						end
						ob:remove()
					else
						default.punch(ob,ob,5)
					end
				end
			end
		end,
	},
})

minetest.register_node("exatec:placer", {
	description = "Placer",
	tiles = {
		"default_ironblock.png^default_crafting_arrowup.png",
		"default_ironblock.png",
		"default_ironblock.png^exatec_hole.png",
		"default_ironblock.png^exatec_hole.png",
		"default_ironblock.png^exatec_hole_big.png",
		"default_ironblock.png^exatec_hole.png"
	},
	groups = {chappy=3,dig_immediate = 2,exatec_tube_connected=1,store=250},
	paramtype2 = "facedir",
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local range=meta:get_int("range")
			range = range < 10 and range or 0
			meta:set_int("range",range+1)
			meta:set_string("infotext","Range (" .. (range+1) ..")")
		end
	end,
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_string("owner",placer:get_player_name())
		local meta = minetest.get_meta(pos)
		meta:set_int("range",1)
		meta:set_string("infotext","Range (1)")
	end,
	exatec={
		test_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local owner = minetest.get_meta(pos):get_string("owner")
			local r = minetest.get_meta(pos):get_int("range")
			if not minetest.registered_nodes[stack:get_name()] then
				return false
			end
			for i=1,minetest.get_meta(pos):get_int("range") do
				local f = {x=pos.x+(d.x*i),y=pos.y+(d.y*i),z=pos.z+(d.z*i)}
				local n = minetest.get_node(f).name
				local def = minetest.registered_nodes[n] or {}
				if not def.buildable_to or minetest.is_protected(f, owner) then
					r = r -1
					if r <= 0 then
						return false
					end
				end
			end
			return true
		end,
		on_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local owner = minetest.get_meta(pos):get_string("owner")
			local sdef = minetest.registered_nodes[stack:get_name()]
			if not sdef then
				return
			end
			for i=1,minetest.get_meta(pos):get_int("range") do
				local f = {x=pos.x+(d.x*i),y=pos.y+(d.y*i),z=pos.z+(d.z*i)}
				local n = minetest.get_node(f).name
				local def = minetest.registered_nodes[n] or {}
				if def.buildable_to and not minetest.is_protected(f, owner) then
					minetest.add_node(f,{name=stack:get_name()})
					if sdef.sounds and sdef.sounds.place and sdef.sounds.place.name then
						minetest.sound_play(sdef.sounds.place.name,{pos=f,max_hear_distance=10,gain=sdef.sounds.place.gain or 1})
					end
					return
				end
			end
		end
	},
})

minetest.register_node("exatec:light_detector", {
	description = "Light detector",
	tiles = {
		"default_steelblock.png^[colorize:#0000ffaa^exatec_glass.png^default_chest_top.png",
		"default_steelblock.png^[colorize:#0000ffaa",
		"default_steelblock.png^[colorize:#0000ffaa"
	},
	groups = {dig_immediate = 2,exatec_data_wire_connected=1,exatec_wire_connected=1,store=250},
	sounds = default.node_sound_glass_defaults(),
	drawtype="nodebox",
	paramtype="light",
	sunlight_propagates=true,
	use_texture_alpha = "opaque",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local level=meta:get_int("level") + 1
			level = level < 16 and level or 0
			meta:set_int("level",level)
			local t = {"=","<",">","<=",">="}
			local typ = meta:get_int("type")
			typ = typ > 0 and typ or 1
			meta:set_string("infotext","Level " ..t[meta:get_int("type")].." ".. meta:get_int("level"))
		end
	end,
	on_punch = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local typ=meta:get_int("type") + 1
			typ = typ < 6 and typ or 1
			meta:set_int("type",typ)
			local t = {"=","<",">","<=",">="}
			meta:set_string("infotext","Level " ..t[typ].." ".. meta:get_int("level"))
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext","Level = 0")
		meta:set_int("type",1)
		minetest.get_node_timer(pos):start(2)
	end,
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		local level = m:get_int("level")
		local t = m:get_int("type")
		local l = minetest.get_node_light(pos) or 0
		if (t == 1 and l == level) or (t == 2 and l < level) or (t == 3 and l > level) or (t == 4 and l <= level) or (t == 5 and l >= level) then
			exatec.send(pos)
			exatec.data_send(pos,m:get_string("to_channel"),m:get_string("channel"),{light=l})
		end
		return true
	end,
})

minetest.register_node("exatec:destroyer", {
	description = "Destroyer",
	tiles = {"default_lava.png^default_glass.png^default_chest_top.png"},
	sounds = default.node_sound_glass_defaults(),
	groups = {chappy=3,dig_immediate = 2,exatec_tube_connected=1,store=400},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 32)
		m:set_string("formspec",
			"size[8,8]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
			"list[current_player;main;0,4.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
	end,
	on_metadata_inventory_put=function(pos)
		local t = minetest.get_node_timer(pos)
		if not t:is_started() then
			t:start(0.1)
		end
	end,
	exatec={
		input_list="main",
		output_list="main",
		on_input=function(pos,stack,opos)
			minetest.get_node_timer(pos)
			local t = minetest.get_node_timer(pos)
			if not t:is_started() then
				t:start(0.1)
			end
		end,
	},
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		if inv:is_empty("main") then
			return
		end
		for i,v in pairs(inv:get_list("main")) do
			local n = v:get_name()
			if n ~= "" then
				if minetest.get_item_group(n,"flammable") > 0 then
					inv:set_stack("main",i,nil)
					return true
				else
					inv:set_stack("main",i,ItemStack(n.. " " .. (v:get_count()-1)))
					return true
				end
			end
		end
	end
})

minetest.register_node("exatec:node_detector", {
	description = "Node detector",
	tiles={
		"default_steelblock.png",
		"default_steelblock.png",
		"default_steelblock.png^exatec_wirecon.png",
		"default_steelblock.png^exatec_wirecon.png",
		"default_steelblock.png^(exatec_hole.png^[colorize:#ff0000)^exatec_wirecon.png",
		"default_steelblock.png^exatec_wirecon.png",
	},
	groups = {cracky=3,oddly_breakable_by_hand=3,exatec_wire_connected=1,store=300},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("range",1)
		local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		local n = minetest.get_node({x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}).name
		m:set_string("node",n)
		m:set_string("formspec","size[4.2,1.1]field[0,0;3,1;range;;1]field[0,1;3,1;node;;"..n.."]button_exit[3,-0.3;1,1;go;Go]button_exit[2.5,0.7;2,1;auto;Autodetect]")
		minetest.get_node_timer(pos):start(2)
	end,
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		local node = m:get_string("node")
		local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		for i=1,m:get_int("range") do
			if minetest.get_node({x=pos.x+(d.x*i),y=pos.y+(d.y*i),z=pos.z+(d.z*i)}).name == node then
				exatec.send(pos,true)
				return true
			end
		end
		return true
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.go or pressed.auto then
			local m = minetest.get_meta(pos)
			local n = tonumber(pressed.range) or m:get_int("range")
			n = n < 20 and n or 20
			n = n > 1 and n or 1
			m:set_int("range",n)
			local node = pressed.node or m:get_string("node")
			if pressed.auto then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				for i=1,n do
					node = minetest.get_node({x=pos.x+(d.x*i),y=pos.y+(d.y*i),z=pos.z+(d.z*i)}).name
				end
			end
			m:set_string("node",node)
			local err = minetest.registered_nodes[node] and "" or "box[-0.3,0.8;2.8,0.7;#ff0000]"
			m:set_string("formspec","size[4.2,1.1]"..err.."field[0,0;3,1;range;;"..n.."]field[0,1;3,1;node;;"..node.."]button_exit[3,-0.3;1,1;go;Go]button_exit[2.5,0.7;2,1;auto;Autodetect]")
		end
	end,
})

minetest.register_node("exatec:bow", {
	description = "Autobow",
	tiles = {"default_ironblock.png"},
	inventory_image="default_ironblock.png^default_bow_loaded.png^[makealpha:0,255,0",
	wield_image = "default_ironblock.png^default_bow_loaded.png^[makealpha:0,255,0",
	groups = {dig_immediate = 2,exatec_tube_connected=1,exatec_wire_connected=1,exatec_data_wire_connected=1,store=300},
	sounds = default.node_sound_glass_defaults(),
	drawtype="nodebox",
	paramtype="light",
	sunlight_propagates=true,
	node_box = {type="fixed",fixed={-0.2,-0.2,-0.2,0.2,-0.4,0.2}},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		minetest.add_entity({x=pos.x,y=pos.y+0.3,z=pos.z},"exatec:bow")
		meta:get_inventory():set_size("main", 1)
		meta:set_string("formspec","size[1,1]button_exit[0,0;1,1;go;Setup]")
		minetest.get_node_timer(pos):start(1)
	end,
	on_destruct = function(pos)
		for _, ob in pairs(minetest.get_objects_inside_radius(pos,1)) do
			local en = ob:get_luaentity()
			if en and en.exatec_bow then
				ob:remove()
			end
		end
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.go and minetest.is_protected(pos, sender:get_player_name())==false then
			local m = minetest.get_meta(pos)
			local channel = pressed.channel or m:get_string("channel")
			m:set_string("channel",channel)
			m:set_string("formspec","size[8,5]listcolors[#77777777;#777777aa;#000000ff]"
			.."field[0,0;3,1;channel;;"..channel.."]"
			.."button_exit[2.5,-0.3;1,1;go;Save]"
			.."tooltip[channel;Channel]"
			.."item_image[3.5,0;1,1;default:arrow_iron]"
			.."list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;3.5,0;1,1;]"
			.."list[current_player;main;0,1.2;8,4;]"
			.."listring[current_player;main]"
			.."listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
			)
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		return minetest.is_protected(pos, player:get_player_name()) and 0 or stack:get_count()
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return not minetest.is_protected(pos, player:get_player_name()) and minetest.get_item_group(stack:get_name(), "arrow") > 0 and stack:get_count() or 0
	end,
	exatec={
		on_data_wire=function(pos,data)
			if data.objects then
				local bow
				for _, ob in pairs(minetest.get_objects_inside_radius(pos,1)) do
					local en = ob:get_luaentity()
					if en and en.exatec_bow then
						bow = en
						break
					end
				end
				if not bow then
					bow = minetest.add_entity({x=pos.x,y=pos.y+0.3,z=pos.z},"exatec:bow")
					bow = bow:get_luaentity()
				end
				for _, ob in pairs(data.objects) do
					local en = ob:get_luaentity()
					if bow and not (en and en.exatec_item) and examobs.visiable(ob,pos) then
						bow:lookat(ob:get_pos())
						local meta = minetest.get_meta(pos)
						local inv = meta:get_inventory()
						local s = inv:get_stack("main",1)
						if s:get_count() > 0 then
							bow:shoot(s)
							s:take_item()
							inv:set_stack("main",1,s)
						end
						return
					end
				end
			end
		end,
		on_wire = function(pos)
			local bow
			for _, ob in pairs(minetest.get_objects_inside_radius(pos,1)) do
				local en = ob:get_luaentity()
				if en and en.exatec_bow then
					bow = en
					break
				end
			end
			if not bow then
				bow = minetest.add_entity({x=pos.x,y=pos.y+0.3,z=pos.z},"exatec:bow")
				bow = bow:get_luaentity()
			end

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local s = inv:get_stack("main",1)
			if bow and s:get_count() > 0 then
				bow:shoot(s)
				s:take_item()
				inv:set_stack("main",1,s)
			end
		end,
		input_list="main",
		output_list="main",
		test_input=function(pos,stack,opos)
			return minetest.get_item_group(stack:get_name(),"arrow") > 0 and minetest.get_meta(pos):get_inventory():room_for_item("main",stack)
		end,
	},
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
})

minetest.register_node("exatec:pcb", {
	description = "PCB",
	tiles = {"exatec_pcb.png"},
	groups = {dig_immediate = 2,exatec_tube_connected=1,exatec_wire_connected=1,exatec_data_wire_connected=1,store=150},
	sounds = default.node_sound_wood_defaults(),
	drawtype="nodebox",
	paramtype="light",
	sunlight_propagates=true,
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("formspec","size[1,1]button_exit[0,0;1,1;save;Setup]")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if (pressed.save or pressed.run or pressed.list) and minetest.is_protected(pos, sender:get_player_name())==false then
			local m = minetest.get_meta(pos)
			local memory = 0
			local user = sender:get_player_name()
			local channel = pressed.channel or m:get_string("channel")
			local func_info
			m:set_string("channel",channel)
			m:set_string("owner",sender:get_player_name())
			local text,err,limit = pressed.text or m:get_string("text")
			m:set_string("text",text)
			m:set_string("channel",channel)
			m:set_string("user",user)
			minetest.registered_nodes["exatec:pcb"].timeout(pos)
			if pressed.run and m:get_int("timeout") == 0 then
				local mb = memory_mb()
				err,limit =exatec.run_code(text,{type={run=true},pos=pos,channel=channel,user=user})
				memory = math.floor((memory_mb()-mb)*1000)/1000
			end

			err = err  or (m:get_int("timeout") == 1 and (m:get_int("timeout_count").."/100 runs/s")) or ""
			if err == "" then
				m:set_int("error",0)
			end

			local list = "textlist[10,-0.3;2.1,11.5;list;"
			local c = ""
			local listn = 0
			local listin = ""
			local preslist = pressed.list and tonumber(pressed.list:sub(5,-1)) or -1

			local funcs = exatec.create_env()
			for i,v in pairs(funcs) do
				if type(v) == "table" then
					for i2,v2 in pairs(v) do
						if type(v2) == "function" then
							list = list..c..i.."."..i2
							c=","
							listn = listn + 1
							if listn == preslist then
								func_info = funcs[i][i2.."_text"]
								listin = i.."."..i2.."()"
							end
						end
					end
				elseif type(v) == "function" then
					list = list..c..i
					c=","
					listn = listn + 1
					if listn == preslist then
						func_info = funcs[i.."_text"]
						listin = i.."()"
					end
				end
			end

			list = list.."]"

			text = minetest.formspec_escape(text)

			m:set_string("formspec","size[12,11]"
			.."field[2,0;3,1;channel;;"..channel.."]"
			.."button[-0.2,-0.2;1,1;save;Save]"
			.."button[0.7,-0.2;1,1;run;Run]"
			.."textarea[0,1;10.5,12;text;;"..text.."]"
			..list
			.."field[2,1;3,0.1;listin;;"..listin.."]"
			.."label[0,0.5;"..err.."]"
			.."tooltip[channel;Channel]"
			.."label[4.5,-0.2;"..memory.."MB]"
			.."label[6.5,-0.2;"..(limit or 0).."/10000 Events]"
			.."label[6.5,0.2;Incoming variable: event]"
			.."label[6.5,0.6;storage variable: storage]"

			.."image_button[-0.2,0.5;0.7,0.7;default_unknown.png"..(func_info and "^[invert:r" or "")..";info;]"
			.."tooltip[info;"..(func_info or "storage variable: storage\nincomming event variable: event\nevent.pos: incoming position")
			.."]")
		end
	end,
	exatec={
		on_data_wire=function(pos,data)
			local m = minetest.get_meta(pos)
			minetest.registered_nodes["exatec:pcb"].timeout(pos)
			if m:get_int("error") == 1 or m:get_int("timeout") == 1 then
				return
			end
			local text = m:get_string("text")
			local user = m:get_string("user")
			local channel = m:get_string("channel")
			local err,limit = exatec.run_code(text,{type={on_data_wire=true},data=data,pos=pos,channel=channel,user=user})
			if err and err ~= "" then
				m:set_int("error",1)
				m:set_string("formspec","size[12,1]button[-0.2,-0.2;1,1;save;Clear]label[0,1;"..err.."]")
			end
		end,
		on_wire = function(pos,opos)
			local m = minetest.get_meta(pos)
			minetest.registered_nodes["exatec:pcb"].timeout(pos)
			if m:get_int("error") == 1 or m:get_int("timeout") == 1 then
				return
			end
			local text = m:get_string("text")
			local user = m:get_string("user")
			local channel = m:get_string("channel")
			local err,limit = exatec.run_code(text,{type={on_wire=true},pos=pos,opos=opos,channel=channel,user=user})
			if err and err ~= "" then
				m:set_int("error",1)
				m:set_string("formspec","size[12,1]button[-0.2,-0.2;1,1;save;Clear]label[0,1;"..err.."]")
			end
		end,
	},
	timeout=function(pos)
		local m = minetest.get_meta(pos)
		local t = m:get_int("timeout_count")+1
		m:set_int("timeout_count",t)
		local d = default.date("s",m:get_int("date"))
		if t >= 100 and d < 10 then
			m:set_int("timeout",1)
		elseif t == 1 then
			m:set_int("date",default.date("get"))
		elseif d >= 1 then
			m:set_int("timeout",0)
			m:set_int("timeout_count",0)
		end
	end,
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		minetest.registered_nodes["exatec:pcb"].timeout(pos)
		if m:get_int("error") == 1 or m:get_int("timeout") == 1 then
			return
		end
		local text = m:get_string("text")
		local user = m:get_string("user")
		local channel = m:get_string("channel")
		local err,limit = exatec.run_code(text,{type={time=true},pos=pos,channel=channel,user=user})
		if err and err ~= "" then
			m:set_int("error",1)
			m:set_string("formspec","size[12,1]button[-0.2,-0.2;1,1;save;Clear]label[0,1;"..err.."]")
		end
		return minetest.get_meta(pos):get_int("interval") == 1
	end,
})

minetest.register_node("exatec:cmd", {
	description = "CMD",
	tiles={"exatec_cmd.png",},
	groups = {cracky=1,exatec_wire_connected=1,exatec_data_wire_connected=1,store=300},
	sounds = default.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("formspec","size[1,1]button_exit[0,0;1,1;save;Setup]")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.save then
			local m = minetest.get_meta(pos)
			if m:get_string("user") ~= sender:get_player_name() then
				return
			end
			local text = pressed.text or m:get_string("text")
			local channel = pressed.channel or m:get_string("channel")
			m:set_string("channel",channel)
			m:set_string("text",pressed.text)
			m:set_string("formspec","size[12,11]"
			.."field[2,0;3,1;channel;;"..channel.."]"
			.."button[-0.2,-0.2;1,1;save;Save]"
			.."button[0.7,-0.2;1,1;run;Run]"
			.."textarea[0,1;12.5,12;text;;"..text.."]"
			.."label[5,0;send commands by {cmd='text'}]"
			)
		elseif pressed.run then
			if minetest.get_meta(pos):get_string("user") == sender:get_player_name() then
				minetest.registered_nodes["exatec:cmd"].exatec.on_wire(pos,pos)
			end
		end
	end,
	after_place_node = function(pos, placer)
		minetest.get_meta(pos):set_string("user",placer:get_player_name())
	end,
	exatec={
		on_data_wire=function(pos,data)
			if not data.cmd or type(data.cmd) ~= "string" then return end
			local m = minetest.get_meta(pos)
			local user = m:get_string("user")
			if user == "" then
				minetest.remove_node(pos)
				return
			end
			local aa = data.cmd.split(data.cmd," ")
			if not (aa and aa[2]) then
				aa = {data.cmd,""}
			end
			local c = minetest.registered_chatcommands[aa[1]]
			if c then
				if minetest.check_player_privs(user, c.privs) then
					c.func(user,aa[2])
				elseif c.privs then
					minetest.chat_send_player(user,minetest.pos_to_string(pos).." You aren't allowed to do that")
					minetest.remove_node(pos)
					return
				end
			else
				minetest.chat_send_player(user,minetest.pos_to_string(pos).." command "..(aa[1] or data.cmd).." doesn't exist")
				return
			end
		end,
		on_wire = function(pos,opos)
			local m = minetest.get_meta(pos)
			local text = m:get_string("text")
			local user = m:get_string("user")
			if user == "" then
				minetest.remove_node(pos)
				return
			end
			for i,a in pairs(text.split(text,"\n")) do
				local aa = a.split(a," ")
				if not (aa and aa[2]) then
					aa = {a,""}
				else
					aa[2] = a:sub(aa[1]:len()+1,-1)
				end

				local c = minetest.registered_chatcommands[aa[1]]
				if c then
					if minetest.check_player_privs(user, c.privs) then
						c.func(user,aa[2])
					else
						minetest.chat_send_player(user,minetest.pos_to_string(pos).." You aren't allowed to do that")
						minetest.remove_node(pos)
						return
					end
				else
					minetest.chat_send_player(user,minetest.pos_to_string(pos).." command "..(aa[1] or a).." doesn't exist")
					return
				end
			end
		end
	}
})

minetest.register_node("exatec:weather_detector", {
	description = "Weather detector",
	tiles={
		"default_steelblock.png^[colorize:#0000ff99^default_glass.png",
		"default_steelblock.png^[colorize:#0000ff99^default_glass.png",
		"default_steelblock.png^[colorize:#0000ff99^default_glass.png^exatec_wirecon.png",
	},
	groups = {cracky=3,oddly_breakable_by_hand=3,exatec_data_wire_connected=1,exatec_wire_connected=1,store=300},
	sounds = default.node_sound_glass_defaults(),
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("formspec","size[1,1]button_exit[0,0;1,1;save;Setup]")
	end,
	on_timer = function (pos, elapsed,g)
		local m = minetest.get_meta(pos)
		local ma = m:get_int("margin")
		local l = m:get_int("level")
		local iswaether
		for i, w in pairs(weather.currweather) do
			iswaether = true
			local d = vector.distance(pos,w.pos) <= w.size
			if g and d then
				return w.strength
			elseif not g and d and w.strength >= l-ma and w.strength <= l+ma then
				exatec.send(pos)
				exatec.data_send(pos,m:get_string("to_channel"),m:get_string("channel"),{weather_strength=w.strength})
				return true
			end
		end
		if not g and not iswaether and l == 0 then
			exatec.send(pos)
			exatec.data_send(pos,m:get_string("to_channel"),m:get_string("channel"),{weather_strength=0})
		end
		return g and 0 or true
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.save or pressed.auto then
			local m = minetest.get_meta(pos)
			local level = tonumber(pressed.level) or m:get_int("level")
			level = level < 100 and level or 100
			level = level >= 0 and level or 0

			local channel = pressed.channel or m:get_string("channel")
			local to_channel = pressed.to_channel or m:get_string("to_channel")
			local margin =  tonumber(pressed.margin) or m:get_int("margin")

			m:set_string("channel",channel)
			m:set_string("to_channel",to_channel)

			margin = margin < 100 and margin or 100
			margin = margin >= 0 and margin or 0
			m:set_int("margin",margin)

			if pressed.auto then
				level = minetest.registered_nodes["exatec:weather_detector"].on_timer(pos,0,true)
			end
			m:set_int("level",level)

			m:set_string("formspec","size[5,2]"
			.."field[0,0;3,1;level;;"..level.."]"
			.."field[0,0.7;3,1;margin;;"..margin.."]"
			.."field[0,1.4;3,1;channel;;"..channel.."]"
			.."field[0,2.1;3,1;to_channel;;"..to_channel.."]"
			.."button_exit[4.3,-0.3;1,1;save;Save]"
			.."button_exit[2.5,-0.3;2,1;auto;Autodetect]"

			.."tooltip[level;Strength]"
			.."tooltip[channel;Channel]"
			.."tooltip[to_channel;Sand to channel]"
			.."tooltip[margin;Margin]"
			)
			minetest.get_node_timer(pos):start(2)
		end
	end,
})

minetest.register_node("exatec:industrial_miner", {
	description = "Industrial miner",
	tiles={
		"default_steelblock.png^materials_fanblade_metal.png",
		"default_steelblock.png^exatec_hole.png",
		"materials_metal_beam.png^materials_pallet_box.png"
	},
	groups = {cracky=3,oddly_breakable_by_hand=3,exatec_wire_connected=1,store=15000},
	sounds = default.node_sound_glass_defaults(),
	after_place_node = function(pos, placer)
		minetest.get_meta(pos):set_string("owner",placer:get_player_name())
	end,
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 32)
		m:set_int("pos",pos.y-1)
		m:set_string("infotext","Industrial miner: "..(pos.y-1))
		m:set_string("formspec",
			"size[8,8]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
			"list[current_player;main;0,4.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
	end,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
	exatec={
		input_list="main",
		output_list="main",
		on_wire = function(pos,opos)
			local m = minetest.get_meta(pos)
			local y = m:get_int("pos")
			if y <= -30000 then
				m:set_string("infotext","Industrial miner: -30000 [max]")
				return
			end
			local p = {x=pos.x,y=y,z=pos.z}
			local no = minetest.get_node(p).name
			if no == "ignore" then
				minetest.emerge_area({x=p.x,y=p.y,z=p.z},{x=p.x,y=p.y-2,z=p.z})
				minetest.forceload_block({x=p.x,y=p.y,z=p.z})
				no = minetest.get_node(p).name
			end
			local n = minetest.get_node_drops(no)[1]
			local def = minetest.registered_nodes[n] or {}
			local owner = minetest.get_meta(pos):get_string("owner")
			if minetest.get_item_group(no,"unbreakable") == 0 and minetest.get_item_group(n,"unbreakable") == 0 and not (def.can_dig and def.can_dig(p, {get_player_name=function() return owner end}) ==  false) and not minetest.is_protected(p, owner) then
				local stack = ItemStack(n)
				local inv = m:get_inventory()

				if n ~= "air" and def.drop ~= "" and not inv:room_for_item("main",stack) then
					return
				elseif not n or n == "air" then
					minetest.sound_play("default_pump_in", {pos=pos, gain = 2, max_hear_distance = 10})
				elseif def.drop ~= "" then
					inv:add_item("main",stack)
					minetest.sound_play("default_pump_out", {pos=pos, gain = 2, max_hear_distance = 10})
				end
				m:set_int("pos",y-1)
				m:set_string("infotext","Industrial miner: "..(y-1))
				minetest.set_node(p,{name="exatec:vacuumtransport"})
				minetest.get_meta(p):set_string("base",minetest.pos_to_string(pos))
			end
		end
	},
	after_destruct=function(pos)
		local d = {x=pos.x,y=pos.y-1,z=pos.z}
		if exatec.get_node(d) == "exatec:vacuumtransport" then
			minetest.remove_node(d)
		end
	end,
	on_blast = function(pos)
		minetest.get_meta(pos):set_string("pos","") 
		local d = {x=pos.x,y=pos.y-1,z=pos.z}
		if exatec.get_node(d) == "exatec:vacuumtransport" then
			minetest.remove_node(d)
		end
	end
})

minetest.register_node("exatec:vacuumtransport", {
	groups = {not_in_creative_inventory=1},
	tiles={"default_ironblock.png"},
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
		node_box = {
		type = "fixed",
		fixed = { 
			{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
		}
	},
	after_destruct=function(pos)
		local u = {x=pos.x,y=pos.y+1,z=pos.z}
		if exatec.get_node(u) == "exatec:vacuumtransport" then
			local p = minetest.string_to_pos(minetest.get_meta(pos):get_string("base"))
			if p == nil then
				return
			elseif minetest.get_meta(p):get_string("pos") == "" then
				minetest.remove_node(u)
			end
		end
	end,
	on_blast = function(pos)
		local u = {x=pos.x,y=pos.y+1,z=pos.z}
		if exatec.get_node(u) == "exatec:vacuumtransport" then
			local p = minetest.string_to_pos(minetest.get_meta(pos):get_string("base"))
			if p == nil then
				return
			elseif minetest.get_meta(p):get_string("pos") == "" then
				minetest.remove_node(u)
			end
		end
	end,
	on_destruct=function(pos,oldnode)
		local d = {x=pos.x,y=pos.y-1,z=pos.z}
		if exatec.get_node(d) == "exatec:vacuumtransport" then
			local p = minetest.string_to_pos(minetest.get_meta(pos):get_string("base"))
			if p == nil then
				return
			end
			if minetest.get_meta(p):get_int("pos") == 0 then
				minetest.remove_node(d)
			end
		end
	end,
	on_punch = function(pos, node, player, itemstack, pointed_thing)
		local p = minetest.string_to_pos(minetest.get_meta(pos):get_string("base"))
		if p == nil or minetest.get_meta(p):get_string("pos") == "" then
			minetest.remove_node(pos)
		end
	end,
})

minetest.register_node("exatec:node_constructor", {
	description = "Node constructor",
	tiles = {"exatec_pcb.png^[invert:bg"},
	groups = {dig_immediate = 2,exatec_tube_connected=1,exatec_data_wire_connected=1,store=500},
	sounds = default.node_sound_wood_defaults(),
	drawtype="nodebox",
	paramtype="light",
	sunlight_propagates=true,
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("formspec","size[1,1]button_exit[0,0;1,1;save;Setup]")
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		inv:set_size("main", 48)
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.save and minetest.is_protected(pos, sender:get_player_name())==false then
			local m = minetest.get_meta(pos)
			local channel = pressed.channel or m:get_string("channel")
			m:set_string("channel",channel)
			m:set_string("formspec",
				"size[8,11]" 
				.."listcolors[#77777777;#777777aa;#000000ff]"
				.."item_image[0,1;1,1;default:flint]"
				.."item_image[1,1;1,1;default:copper_ingot]"
				.."item_image[2,1;1,1;default:bronze_ingot]"
				.."item_image[3,1;1,1;default:iron_ingot]"
				.."item_image[4,1;1,1;default:steel_ingot]"
				.."item_image[5,1;1,1;default:cloud]"
				.."item_image[6,1;1,1;default:diamond]"

				.."label[4,0;"..(m:get_string("connection") ~= "" and ("Connected ".. m:get_string("connection")) or "Not connected").."]" 
				.."label[0,0.5;Storage/Fuel]" 
				.."label[4,0.5;Power ("..m:get_int("power")..")]" 
				.."field[0.3,0;3,1;channel;;"..channel.."]"
				.."button_exit[3,-0.3;1,1;save;Save]"
				.."tooltip[channel;Channel (send {connect=true} to connect)]"
				.."list[context;main;0,1;8,6;]" 
				.."list[current_player;main;0,7.3;8,4;]" 
				.."listring[current_player;main]" 
				.."listring[current_name;main]" 
			)
		end
	end,
	exatec={
		input_list="main",
		output_list="main",
		on_data_wire=function(pos,data)
			local m = minetest.get_meta(pos)
			if exatec.is_pos(data.from_pos) and minetest.get_node(data.from_pos).name == "exatec:pcb" and data.connect then
				m:set_string("connection",minetest.pos_to_string(data.from_pos))
				minetest.get_meta(data.from_pos):set_string("connected_constructor",minetest.pos_to_string(pos))
				minetest.get_meta(pos):set_string("formspec","size[4,1]button_exit[0,0;4,1;save;Connection successful!]")
			end
		end,
	},
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
})

minetest.register_node("exatec:trader", {
	description = "Trader",
	tiles={
		"default_goldblock.png^player_style_coin.png^exatec_hole.png",
		"default_goldblock.png^player_style_coin.png",
		"default_goldblock.png^player_style_coin.png^exatec_wirecon.png"
	},
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1,store=200,used_by_npc=1},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		minetest.get_meta(pos):set_string("owner",placer:get_player_name())
	end,
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 1)
		m:get_inventory():set_size("output", 1)
		m:set_int("tocoins",1)
		minetest.registered_nodes["exatec:trader"].setform(pos)
	end,
	setform = function(pos)
		local m = minetest.get_meta(pos)
		local coins = m:get_int("tocoins") == 0 and 1 or 0
		m:set_int("tocoins",coins)

		m:set_string("formspec",
			"size[8,5]"
			.."listcolors[#77777777;#777777aa;#000000ff]"
			 .."list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;3,0;8,4;]"

			..(coins == 1 and "item_image[4,0;1,1;player_style:coin]"
			.."list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";output;4,0;8,4;]" or "")

			 .."list[current_player;main;0,1.2;8,4;]"
			 .."listring[current_player;main]"
			 .."listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
			.."listring[current_player;main]"
			.."tooltip[showstore;Open store]"
			.."image_button[0,0;1,1;player_style_coin.png;showstore;]"
			.."button[1,0;2,1;coin;"..(coins == 1 and "Get coins" or "Earn").."]"
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return listname == "main" and minetest.registered_nodes["exatec:trader"].can_trade(pos,stack) and stack:get_count() or 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local m = minetest.get_meta(pos)
		local t = math.ceil(player_style.store_items_cost[stack:get_name()]*0.1) * stack:get_count()
		local o = m:get_string("owner")

		if stack:get_name() == "player_style:coin" then
			t = stack:get_count()
		end

		if m:get_int("tocoins") == 1 then
			local ss = m:get_inventory():add_item("output",ItemStack("player_style:coin "..t))
			m:get_inventory():set_stack("main",1,nil)
			if ss:get_count() == 0 then
				minetest.sound_play("default_coins", {pos=pos, gain = 2, max_hear_distance = 10})
				return
			end
		end
		if o ~= "" then
			Coin(o,t)
			m:set_string("infotext",Getcoin(o))
			m:get_inventory():set_stack("main",1,nil)
			minetest.sound_play("default_coins", {pos=pos, gain = 2, max_hear_distance = 10})
			return
		end
		local at = m:get_int("coins")+t
		m:set_int("coins",at)
		m:set_string("infotext","Contains: "..at.." (break to get)")
		m:get_inventory():set_stack("main",1,nil)
		minetest.sound_play("default_coins", {pos=pos, gain = 2, max_hear_distance = 10})
	end,
	on_destruct=function(pos)
		local m = minetest.get_meta(pos)
		if m:get_int("coins") > 0 then
			minetest.add_item(pos,ItemStack("player_style:coin "..m:get_int("coins")))
		end
		if m:get_inventory():is_empty("output") == false then
			minetest.add_item(pos,m:get_inventory():get_stack("output",1))
		end
	end,
	can_trade=function(pos,item)
		player_style.open_store()
		local it = item:get_name()
		local i = player_style.store_items_cost[it]
		return (i ~= nil or it == "player_style:coin")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.showstore then
			player_style.store(sender)
		elseif pressed.coin then
			minetest.registered_nodes["exatec:trader"].setform(pos)
		end
	end,
	exatec={
		input_list="main",
		output_list="output",
		test_input=function(pos,stack,opos)
			return minetest.registered_nodes["exatec:trader"].can_trade(pos,stack)
		end,
	}
})

minetest.register_node("exatec:object_magnet", {
	description = "Object magnet",
	tiles = {
		"default_silverblock.png^default_craftgreed.png^default_chest_top.png"
	},
	groups = {dig_immediate = 2,exatec_wire_connected=1,store=300},
	sounds = default.node_sound_stone_defaults(),
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		local st = m:get_int("st") -1
		m:set_int("st",st)
		for _, ob in pairs(minetest.get_objects_inside_radius(pos,minetest.get_meta(pos):get_int("radius"))) do
			local en = ob:get_luaentity()
			if en and (en.name == "__builtin:item" or en.examob) then
				local p = ob:get_pos()
				ob:set_velocity({x=(pos.x-p.x)*5,y=(pos.y-p.y)*5,z=(pos.z-p.z)*5})
			end
		end
		return st > 0
	end,
	on_construct=function(pos)
		minetest.get_meta(pos):set_string("infotext","Radius (1)")
	end,
	on_punch = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local m = minetest.get_meta(pos)
			local radius = m:get_int("radius")
			radius = radius < 20 and radius or 0
			m:set_int("radius",radius+1)
			m:set_string("infotext","Radius (" .. (radius+1) ..")")
		end
	end,
	exatec={
		on_wire = function(pos)
			local m = minetest.get_meta(pos):set_int("st",10)
			minetest.get_node_timer(pos):start(0.1)
		end,
	}
})

minetest.register_node("exatec:codelock", {
	description = "Codelock panel (sends signals 2 blocks away)",
	tiles = {"default_steelblock.png","exatec_codelock.png"},
	groups = {snappy = 3,exatec_wire_connected=1,store=300},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local meta=minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name())
	end,
	on_construct=function(pos)
		minetest.get_meta(pos):set_string("code",math.random(0,99)..math.random(0,99)..math.random(0,99))

		minetest.registered_nodes["exatec:codelock"].update_panel(pos)
	end,
	update_panel=function(pos,show)
		local meta=minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local user = meta:get_string("user")
		local current = meta:get_string("current")
		meta:set_string("formspec",
			"size[3,5]"
			.."tooltip[current;Enter code]"
			.."button[0,1;1,1;b1;1]"
			.."button[1,1;1,1;b2;2]"
			.."button[2,1;1,1;b3;3]"
			.."button[0,2;1,1;b4;4]"
			.."button[1,2;1,1;b5;5]"
			.."button[2,2;1,1;b6;6]"
			.."button[0,3;1,1;b7;7]"
			.."button[1,3;1,1;b8;8]"
			.."button[2,3;1,1;b9;9]"
			.."button[1,4;1,1;b0;0]"

			.."button_exit[2,4;1,1;ok;OK]"
			..(show and "button_exit[0,4;1,1;save;Set]tooltip[save;Change code]" or "")
			.."field[0.3,0;3,1;current;;" .. current .."]"
		)
	end,
	on_receive_fields=function(pos, form, pressed, sender)
		local meta = minetest.get_meta(pos)
		if pressed.save and sender:get_player_name() == meta:get_string("owner") then
			if not tonumber(pressed.current) then
				minetest.chat_send_player(sender:get_player_name(), "Not a valid code")
				return
			end
			meta:set_string("code",pressed.current)
			minetest.chat_send_player(sender:get_player_name(), "Code set!")
			meta:set_string("current","")
			minetest.registered_nodes["exatec:codelock"].update_panel(pos)
		elseif pressed.ok then
			meta:set_string("current","")
			minetest.registered_nodes["exatec:codelock"].update_panel(pos)
			if pressed.current == meta:get_string("code") or sender:get_player_name() == meta:get_string("owner") then
				local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
				exatec.send({x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z})
			end
			return
		end
		local n
		for i = 0,9 do
			if pressed["b"..i] then
				n = i
				break
			end
		end
		if n then
			meta:set_string("current",meta:get_string("current")..n)
			minetest.registered_nodes["exatec:codelock"].update_panel(pos,sender:get_player_name() == meta:get_string("owner"))
		end
	end,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.4375, 0.375, 0.1875, 0.0625, 0.5},
		}
	}
})

minetest.register_node("exatec:paypass", {
	description = "Pay pass (pay to activate)",
	tiles = {"default_steelblock.png","exatec_codelock.png"},
	groups = {snappy = 3,exatec_wire_connected=1,store=300},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local m=minetest.get_meta(pos)
		m:set_string("owner",placer:get_player_name())
	end,
	on_construct=function(pos)
		minetest.registered_nodes["exatec:paypass"].update_panel(pos)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.registered_nodes["exatec:paypass"].update_panel(pos,player)
	end,
	update_panel=function(pos,user,customer)
		local m = minetest.get_meta(pos)
		local owner = m:get_string("owner")
		local name = user and user:get_player_name() or ""
		local form = "size[3,2]"

		if not customer and (name == owner or minetest.check_player_privs(name, {protection_bypass=true})) then
			form = form
			.."field[0,0;1,1;cost;;" .. m:get_int("cost") .."]tooltip[cost;Cost]"
			.."field[1,0;1,1;delay;;" .. m:get_int("delay") .."]tooltip[delay;Repeats after timeout 0 == no repeat]"
			.."button[2,-0.3;1,1;set;Set]"
			.."button[0,1;3,1;customer;Customer view]"
		elseif user then
			form = form
			.."label[0,0;"..minetest.colorize("#FFFF00",Getcoin(user)).."]"
			.."button_exit[0,1;3,1;pay;Pay "..m:get_int("cost").."]"
		end	
		m:set_string("formspec",form)
	end,
	on_receive_fields=function(pos, form, pressed, sender)
		local m = minetest.get_meta(pos)
		if pressed.set then
			pressed.cost = tonumber(pressed.cost)
			pressed.cost = pressed.cost < 0 and 0 or pressed.cost > 100000 and 100000 or pressed.cost
			m:set_int("cost",pressed.cost)
			pressed.delay = tonumber(pressed.delay)
			pressed.delay = pressed.delay < 0 and 0 or pressed.delay > 60 and 60 or pressed.delay
			m:set_int("delay",pressed.delay)
			minetest.registered_nodes["exatec:paypass"].update_panel(pos,sender)
		elseif pressed.pay and m:get_int("open") == 0 then
			local c = m:get_int("cost")
			m:set_int("open",1)
			Coin(sender,-c)
			Coin(m:get_string("owner"),c)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			exatec.send({x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z})
			if m:get_int("delay") > 0 then
				minetest.get_node_timer(pos):start(m:get_int("delay"))
			end
		elseif pressed.customer then
			minetest.registered_nodes["exatec:paypass"].update_panel(pos,sender,true)
		end
	end,
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		exatec.send({x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z})
		m:set_int("open",0)
	end,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.4375, 0.375, 0.1875, 0.0625, 0.5},
		}
	}
})

minetest.register_node("exatec:transsignal", {
	description = "Transsignal (sends signals 2 blocks away)",
	tiles = {
		"exatec_pcb.png^default_crafting_arrowup.png",
		"exatec_pcb.png^default_crafting_arrowup.png",
		"exatec_pcb.png^exatec_codelock.png",

	},
	groups = {snappy = 3,exatec_wire_connected=1,store=300},
	sounds = default.node_sound_wood_defaults(),
	exatec={
		on_wire = function(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			exatec.send({x=pos.x+d.x*2,y=pos.y+d.y*2,z=pos.z+d.z*2},true,true)
		end,
	},
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
})

minetest.register_node("exatec:burner", {
	description = "Burner",
	tiles = {"default_lava.png^default_craftgreed.png^default_chest_top.png","default_ironblock.png","default_ironblock.png","default_ironblock.png","default_ironblock.png","default_ironblock.png"},
	sounds = default.node_sound_metal_defaults(),
	groups = {cracky = 2,exatec_wire_connected=1,store=400},
	exatec={
		on_wire = function(pos)
			local t = minetest.get_node_timer(pos)
			if t:is_started() then
				t:stop()
				local up = apos(pos,0,1)
				if minetest.get_item_group(minetest.get_node(up).name,"fire") > 0 then
					minetest.remove_node(up)
				end
			else
				t:start(0.5)
			end
		end,
	},
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_string("owner",placer:get_player_name())
	end,
	on_timer = function (pos, elapsed)
		local owner = minetest.get_meta(pos):get_string("owner")
		local up = apos(pos,0,1)
		if default.defpos(up,"buildable_to") and not minetest.is_protected(up, owner) then
			minetest.set_node(up,{name="fire:basic_flame"})
		end
		return true
	end
})

minetest.register_node("exatec:radioactivity_meter", {
	description = "Radioactivity meter",
	tiles = {
		"default_ironblock.png^default_radioactivity.png^default_chest_top.png",
		"default_ironblock.png",
		"default_ironblock.png^exatec_wire.png"},
	groups = {dig_immediate = 2,exatec_wire_connected=1,store=150},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("typen",1)
		m:set_int("once", 1)
		m:set_string("formspec","size[2,1]button_exit[0,0;2,1;save;Setup]")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if minetest.is_protected(pos, sender:get_player_name()) == false then
			local m = minetest.get_meta(pos)
			local t = pressed.type == "rad >" and 1 or pressed.type == "rad <" and 2 or pressed.type == "rad =" and 3 or m:get_int("typen")
			local r = pressed.rad or m:get_int("rad")
			local o = pressed.once == "once" and 1 or pressed.once == "constant" and 2 or m:get_int("once")
			local op = {">","<","="}

			m:set_int("once", o)
			m:set_int("rad", tonumber(r))
			m:set_int("typen", t)
			m:set_string("type", op[t])

			m:set_string("formspec",
				"size[5,0.7]"
				.."bgcolor[#ffd800]"
				.."dropdown[-0.3,0;1.5,1;type;rad >,rad <,rad =;"..t.."]"
				.."field[1.45,0.25;1.5,1;rad;;"..r.."]"
				.."dropdown[2.5,0;1.5,1;once;once,constant;"..o.."]"
				.."button_exit[3.9,-0.05;1.4,1;update;Update]"
				.."tooltip[once;Send signal once or constant]"
				.."tooltip[rad;Radioactivity range]"
			)
			minetest.get_node_timer(pos):start(1)
		end
	end,
	on_timer = function(pos, elapsed)
		local m = minetest.get_meta(pos)
		local typn = m:get_int("typen")
		local range = m:get_int("rad")
		local rad = math.floor(default.get_radioactivity(pos))
		local k = {rad > range,rad < range,rad == range,}
		m:set_string("infotext","Radioactivity meter (" .. rad .. " " .. m:get_string("type") .." " .. range ..")")
		if k[typn] == true then
			if m:get_int("once") == 2 or m:get_int("sent") == 0 then
				m:set_int("sent", 1)
				exatec.send(pos)
			end
		else
			m:set_int("sent", 0)
		end
		return true
	end
})