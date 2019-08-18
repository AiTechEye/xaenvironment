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
			local g = v.groups 
			if v.exatec or g and (g.exatec_tube or g.exatec_tube_connected or g.exatec_wire or g.exatec_wire_connected) then
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
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1},
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
	},
})

minetest.register_node("exatec:tube_detector", {
	description = "Detector tube",
	tiles = {"exatec_glass.png^[colorize:#ffff00cc"},
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,exatec_wire=1,exatec_wire_connected=1},
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
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,exatec_wire_connected=1},
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
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,exatec_wire_connected=1},
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
				ob:get_luaentity().storage.dir = d
				ob:set_velocity(d)
				ob:set_pos(pos)
			end
		end,
	},
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
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1},
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
		m:set_string("formspec",
			"size[12,10]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."box[0,0;12,1;#ff0000]".."list[context;input1;11,0;1,1;]" 
			.."box[0,1;12,1;#00ff00]".."list[context;input2;11,1;1,1;]" 
			.."box[0,2;12,1;#0000ff]".."list[context;input3;11,2;1,1;]" 
			.."box[0,3;12,1;#ffff00]".."list[context;input4;11,3;1,1;]"
			.."box[0,4;12,1;#000000]".."list[context;input5;11,4;1,1;]"
			.."box[0,5;12,1;#ffffff]".."list[context;input6;11,5;1,1;]" 
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
			if #s >=10 then
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
		for i,v in pairs(pressed) do
			if i:sub(1,5) == "input" then
				local it = i:sub(8,-1)
				local na = i:sub(1,6)
				local m = minetest.get_meta(pos)
				m:set_string(na,m:get_string(na):gsub(it..",",""))
				minetest.registered_nodes["exatec:tube_filter"].on_construct(pos)
				return
			end
		end
	end,
	exatec={
		test_input=function(pos,stack,opos)
			local m = minetest.get_meta(pos)
			local n = stack:get_name()
			local e = false
			for i=1,6 do
				local d = m:get_string("input"..i)
				if d == "" then
					e = true
				elseif d:find(n) then
					return true
				end
			end
			return e
		end,
		on_tube=function(pos,stack,opos,ob)
			local m = minetest.get_meta(pos)
			local n = stack:get_name()
			local e
			for i,v in pairs(exatec.tube_rules) do
				local d = m:get_string("input"..i)
				if d == "" then
					e = v
				elseif d:find(n) then
					ob:set_velocity(v)
					ob:get_luaentity().storage.dir = v
					ob:set_pos(pos)
					return
				end
			end
			if not e then
				local en = ob:get_luaentity()
				local dir = en.storage.dir
				en.storage.dir = {x=dir.x*-1,y=dir.y*-1,z=dir.z*-1,}
				ob:set_velocity(en.storage.dir)
				return
			end
			ob:set_velocity(e)
			ob:get_luaentity().storage.dir = e
			ob:set_pos(pos)
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
	selection_box={type="fixed",fixed={-0.5,-0.5,-0.5,0.5,0.5,-0.4}},
	connects_to={"group:exatec_wire","group:exatec_wire_connected"},
	groups = {dig_immediate = 3,exatec_wire=1},
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="exatec:wire",param2=98})
	end,
	on_timer = function (pos, elapsed)
		minetest.swap_node(pos,{name="exatec:wire",param2=98})
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
	groups = {chappy=3,dig_immediate = 2,exatec_wire_connected=1},
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
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_wire_connected=1},
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
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1},
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
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_tube=1,exatec_wire_connected=1},
	exatec={
		on_wire = function(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local b = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
			local b1 = exatec.def(b)
			if b1.output_list then
				local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
				local f1 = exatec.def(f)
				for i,v in pairs(minetest.get_meta(b):get_inventory():get_list(b1.output_list)) do
					if v:get_name() ~= "" then
						local stack = ItemStack(v:get_name() .." " .. 1)
						if exatec.test_input(f,stack,pos) and exatec.test_output(b,stack,pos) then
							exatec.input(f,stack,pos)
							exatec.output(b,stack,pos)
							return true
						end
					end
				end
			end
		end,
		test_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			return exatec.test_input(f,stack,pos)
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
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_tube=1,exatec_wire_connected=1},
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
	groups = {chappy=3,dig_immediate = 2,exatec_wire_connected=1},
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
				exatec.send(pos,true)
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
	groups = {dig_immediate = 2,exatec_wire_connected=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local time=meta:get_int("time")
			time = time < 10 and time or 0
			meta:set_int("time",time+1)
			meta:set_string("infotext","Delayer (" .. (time+1) ..")")
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
	groups = {choppy=3,flammable=2,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1},
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
	groups = {dig_immediate = 2,exatec_wire_connected=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	exatec={
		on_wire = function(pos,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			exatec.send({x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z},true)
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
	groups = {dig_immediate = 2,exatec_wire_connected=1},
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
			if exatec.samepos(opos,f) then
				exatec.send(b,true)
			elseif exatec.samepos(opos,b) then
				exatec.send(f,true)
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
	groups = {dig_immediate = 2,exatec_wire_connected=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("on",1)
		m:set_string("infotext","On")
	end,
	exatec={
		on_wire = function(pos,opos)
			local m = minetest.get_meta(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			local b = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
			if not exatec.samepos(opos,f) and not exatec.samepos(opos,b) then
				local on = m:get_int("on") == 1 and 0 or 1
				m:set_int("on",on)
				m:set_string("infotext",on == 1 and "On" or "Off")
			elseif m:get_int("on") == 1 then
				exatec.send(f,true)
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
	groups = {dig_immediate = 2,exatec_wire=1},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local radius=meta:get_int("radius")
			radius = radius < 10 and radius or 0
			meta:set_int("radius",radius+1)
			meta:set_string("infotext","Radius (" .. (radius+1) ..")")
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("radius",1)
		meta:set_string("infotext","Radius (1)")
		minetest.get_node_timer(pos):start(2)
	end,
	on_timer = function (pos, elapsed)
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, minetest.get_meta(pos):get_int("radius"))) do
			exatec.send(pos,true)
			break	
		end
		return true
	end,
})

minetest.register_node("exatec:vacuum", {
	description = "Vacuum",
	tiles={
		"default_stone.png^exatec_hole_big.png^materials_fanblade_metal.png",
		"default_stone.png",
		"default_stone.png^exatec_hole.png^exatec_wirecon.png"
	},
	groups = {cracky=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1},
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
	groups = {cracky=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype2 = "facedir",
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_string("owner",placer:get_player_name())
		local meta = minetest.get_meta(pos)
		meta:set_int("range",1)
		meta:set_string("infotext","Range (1)")
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
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
				local owner = minetest.get_meta(f):get_string("owner")
				if n ~= "air" and def.drop ~= "" and minetest.get_item_group(n,"unbreakable") == 0 and not (def.can_dig and def.can_dig(f, {get_player_name=function() return owner end}) ==  false) and not minetest.is_protected(f, owner) then
					local stack = ItemStack(n)
					if exatec.test_input(b,stack,pos) then
						exatec.input(b,stack,pos)
					else
						minetest.add_item(b,stack)
					end
					minetest.remove_node(f)
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
	groups = {chappy=3,dig_immediate = 2,exatec_tube_connected=1},
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
	description = "Light detector (Click to change level)",
	tiles = {"default_steelblock.png^[colorize:#0000ffaa^exatec_glass.png^default_chest_top.png"},
	groups = {dig_immediate = 2,exatec_wire_connected=1},
	sounds = default.node_sound_glass_defaults(),
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local level=meta:get_int("level") + 1
			level = level < 14 and level or 0
			meta:set_int("level",level)
			meta:set_string("infotext","Level (" .. (level) ..")")
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext","Level (0)")
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function (pos, elapsed)
		if (minetest.get_node_light(pos) or 0) == minetest.get_meta(pos):get_int("level") then
			exatec.send(pos)
		end
		return true
	end,
})

minetest.register_node("exatec:destroyer", {
	description = "Destroyer",
	tiles = {"default_lava.png^default_glass.png^default_chest_top.png"},
	sounds = default.node_sound_glass_defaults(),
	groups = {chappy=3,dig_immediate = 2,exatec_tube_connected=1,igniter=1},
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
	on_metadata_inventory_put=function(pos)
		minetest.get_node_timer(pos)
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
	groups = {cracky=3,oddly_breakable_by_hand=3,exatec_wire_connected=1},
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