minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.get_item_group(itemstack:get_name(),"not_regular_craft") > 0 then
		return ""
	end
	return itemstack
end)

default.workbench.result=function(pos,form,player)
	local inv = minetest.get_meta(pos):get_inventory()
	local craft = minetest.get_craft_result({method = "normal",width = 3, items = inv:get_list("craft")})
	if form=="output" and craft.item:get_name() ~= "" then
		for i,ite in ipairs(inv:get_list("craft")) do
			inv:set_stack("craft",i,ite:get_name() .." " .. ite:get_count()-1)
		end
		if #craft.replacements > 0 then
			for i,ite in pairs(craft.replacements) do
				if inv:room_for_item("craft",ite) then
					inv:add_item("craft",ite)
				elseif inv:room_for_item("stock",ite) then
					inv:add_item("stock",ite)
				else
					minetest.add_item({x=pos.x,y=pos.y+1,z=pos.z},ite)
				end
			end
		end

		if craft.item:get_name():find("_ingot") or craft.item:get_name():find("_lump") then
			minetest.sound_play("default_anvil", {pos=pos, gain = 4,max_hear_distance = 10})
		elseif minetest.get_item_group(craft.item:get_name(),"wood") then
			minetest.sound_play("default_saw", {pos=pos, gain = 4,max_hear_distance = 10})
		end
		exaachievements.customize(player,"Worker")
	end
	craft = minetest.get_craft_result({method = "normal",width = 3, items = inv:get_list("craft")})
	inv:set_stack("output",1,craft.item)
end

player_style.register_manual_page({
	name = "Workbench",
	itemstyle = "default:workbench",
	text = "The workbench contains a craft guide and a crafting grid that makes things less messy to craft.\nSome items like steel lumps can only be crafted in this way.",
	tags = {"default:workbench"},
})


player_style.register_manual_page({
	name = "Dye workbench",
	itemstyle = "default:dye_workbench",
	text = "Use this workbench to craft dye.\nAdd a bucket of water or water source, and colored items to mix the dye",
	tags = {"default:dye_workbench"},
})

player_style.register_manual_page({
	name = "Paper compressor",
	itemstyle = "default:paper_compressor",
	text = "Use the paper compressor to craft paper.\nAdd a bucket of water and pieces of wood",
	tags = {"default:paper_compressor"},
})

player_style.register_manual_page({
	name = "Recycling mill",
	itemstyle = "default:recycling_mill",
	text = "The recycling mill is used to recycling items / demount items so you get the items it is made of",
	tags = {"default:recycling_mill"},
})

minetest.register_node("default:workbench", {
	description = "Workbench",
	tiles={"default_workbench_table.png","default_wood.png","default_wood.png^default_workbench.png"},
	groups = {oddly_breakable_by_hand=3,choppy=3,flammable=2,used_by_npc=1,exatec_tube_connected=1,on_load=1},
	sounds = default.node_sound_wood_defaults(),
	on_load=function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_string("x_add") ~= "" then
			local inv = meta:to_table()
			local a = inv
			minetest.after(0.1,function()
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				inv:set_list("output",a.inventory.output)
				inv:set_list("main",a.inventory.stock)
				inv:set_list("craft",a.inventory.craft)
			end)
			local n = minetest.get_node(pos)
			minetest.set_node(pos,n)
		end
	end,
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_string("owner", placer:get_player_name())
	end,
	on_receive_fields=function(pos, formname, pressed, player)
		if pressed.craftguide then
			player_style.craftguide.show(player,pos)
		end
	end,
	on_construct=function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("craft", 9)
		inv:set_size("output", 1)
		inv:set_size("main", 32)
		meta:set_string("infotext", "Workbench")
		meta:set_string("formspec",
		"size[8,11]"
		.. "listcolors[#77777777;#777777aa;#000000ff]"
		.. "list[context;craft;3,0;3,3;]"
		.. "list[context;output;6,1;1,1;]"
		.. "list[context;main;0,3.2;8,4;]"
		.. "list[current_player;main;0,7.3;8,4;]"
		.. "listring[current_player;main]"
		.. "listring[current_name;main]"
		.. "listring[current_name;craft]"
		.. "listring[current_player;main]"
		.. "listring[current_name;output]"
		.. "listring[current_player;main]"
		.. "image_button[1,1;1,1;default_craftgreed.png^default_unknown.png;craftguide;]"
		.. "tooltip[craftguide;Craftguide]"
		)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname=="craft" then
			local inv = minetest.get_meta(pos):get_inventory()
			local item = minetest.get_craft_result({method = "normal",width = 3, items = inv:get_list("craft")}).item
			inv:set_stack("output",1,item:get_name() .. " " .. item:get_count())
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list=="craft" or from_list=="craft" or from_list=="output" then
			default.workbench.result(pos,from_list, player)
		end
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname=="craft" or listname=="output" then
			default.workbench.result(pos,listname, player)
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local owner = minetest.get_meta(pos):get_string("owner")
		local name = player:get_player_name()
		if listname=="output" or (name ~= owner and owner ~= "") or ( name ~= owner and not minetest.check_player_privs(name, {protection_bypass=true})) then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local owner = minetest.get_meta(pos):get_string("owner")
		local name = player:get_player_name()
		if name ~= owner and owner ~= "" and not minetest.check_player_privs(name, {protection_bypass=true}) then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local owner = minetest.get_meta(pos):get_string("owner")
		local name = player:get_player_name()
		if to_list == "output" or (name ~= owner and owner ~= "" and not minetest.check_player_privs(name, {protection_bypass=true})) then
			return 0
		end
		return count
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local owner = minetest.get_meta(pos):get_string("owner")
		local name = player:get_player_name()
		return (inv:is_empty("craft") and inv:is_empty("main")) and (name == owner or owner == "")
	end,
	exatec={
		input_list="main",
		output_list="main",
	},
})

minetest.register_node("default:craftguide", {
	description = "Craftguide",
	tiles={"default_craftgreed.png^default_unknown.png"},
	wield_image="default_craftgreed.png^default_unknown.png",
	inventory_image="default_craftgreed.png^default_unknown.png",
	groups = {dig_immediate=3,flammable=2,used_by_npc=2},
	sounds = default.node_sound_wood_defaults(),
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.49,0.5}},
	paramtype2="wallmounted",
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		if meta:get_string("x_add") ~= "" then
			minetest.after(0.1,function()
				player_style.craftguide.show(player,pos)
			end)
			local n = minetest.get_node(pos)
			minetest.set_node(pos,n)
			return
		end
		player_style.craftguide.show(player,pos)
	end,
	after_place_node = function(pos, placer, itemstack)
		minetest.rotate_node(itemstack,placer,{under=pos,above=pos})
	end,
})

minetest.register_node("default:paper_compressor", {
	description = "Paper compressor",
	tiles={"default_wood.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,flammable=2,used_by_npc=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.3125, 0.5},
			{-0.3125, 0.0625, 0.3125, 0.3125, 0.5, 0.5},
			{-0.3125, 0.0625, -0.5, 0.3125, 0.5, -0.3125},
			{-0.5, 0.0625, -0.5, -0.3125, 0.5, 0.5},
			{0.3125, 0.0625, -0.5, 0.5, 0.5, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
	},
	on_construct=function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("input_water", 1)
		inv:set_size("output", 1)
		meta:set_string("formspec",
			"size[8,5]" ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"item_image[2,0;1,1;materials:piece_of_wood]" ..
			"item_image[3,0;1,1;default:bucket_with_water_source]" ..
			"list[context;input;2,0;1,1;]" ..
			"list[current_player;main;0,1.3;8,4;]" ..
			"list[context;input_water;3,0;1,1;]" ..
			"list[context;output;5,0;1,1;]" ..
			"listring[current_player;main]" ..
			"listring[current_name;input_water]"
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname=="input" and stack:get_name() == "materials:piece_of_wood" or listname=="input_water" and minetest.get_item_group(stack:get_name(),"bucket_water") > 0 then
			local inv = minetest.get_meta(pos):get_inventory()
			local p = inv:get_stack("input",1):get_count()
			local b = minetest.get_item_group(stack:get_name(),"bucket_water")
			if ((listname == "input" and p + stack:get_count() >= 4) or p >= 4) and (minetest.get_item_group(inv:get_stack("input_water",1):get_name(),"bucket_water") > 0 or b > 0) then
				inv:set_stack("output",1,"default:paper")
			end
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		if name==meta:get_string("owner") or not minetest.is_protected(pos,name) then
			local inv = minetest.get_meta(pos):get_inventory()
			if listname == "output" then
				local w = inv:get_stack("input",1)
				w:take_item(4)
				inv:set_stack("input",1,w)
				inv:set_stack("input_water",1,"default:bucket")
			elseif (listname == "input" and inv:get_stack("input",1):get_count()-stack:get_count() < 4) or listname == "input_water" then
				inv:set_stack("output",1,nil)
			end
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "output" or to_list ~= from_list then
			return 0
		end
		return count
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("input") and inv:is_empty("input_water")
	end
})

minetest.register_node("default:dye_workbench", {
	description = "Dye workbench",
	tiles={"default_birch_wood.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,flammable=2,used_by_npc=1},
	sounds = default.node_sound_wood_defaults(),
	palette="default_palette.png",
	paramtype2="color",
	on_punch = function(pos, node, player, pointed_thing)
		local meta = minetest.get_meta(pos)
		if meta:get_int("colortest") == 1 then
			local p = meta:get_int("color")
			local n = 1
			if p+1 > 255 then
				n = 0
				p = 0
			elseif player:get_wielded_item():get_name() == "default:dye_workbench" then
				n = 7
			end
			meta:set_int("color",p+n)
			node.param2 = p+n
			minetest.swap_node(pos,node)
			minetest.chat_send_player(player:get_player_name(),node.param2)
		end
	end,
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_int("colortest",minetest.check_player_privs(placer:get_player_name(), {server=true}) and 1 or 0)
	end,
	on_construct=function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("input_water", 1)
		inv:set_size("output", 1)
		meta:set_string("formspec",
			"size[8,5]" ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"item_image[2,0;1,1;plants:daisybush1]" ..
			"item_image[3,0;1,1;default:water_source]" ..
			"item_image[3,0;1,1;default:bucket_with_water_source]" ..
			"list[context;input;2,0;1,1;]" ..
			"list[current_player;main;0,1.3;8,4;]" ..
			"list[context;input_water;3,0;1,1;]" ..
			"list[context;output;5,0;1,1;]" ..
			"listring[current_player;main]" ..
			"listring[current_name;input_water]"
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname=="input" and default.def(stack:get_name()).dye_colors or listname=="input_water" and (minetest.get_item_group(stack:get_name(),"bucket_water") > 0 or minetest.get_item_group(stack:get_name(),"water") > 0) then
			local inv = minetest.get_meta(pos):get_inventory()
			local p = inv:get_stack("input",1)
			local b = inv:get_stack("input_water",1)
			if (listname == "input" or p:get_count() > 0) and (minetest.get_item_group(b:get_name(),"bucket_water") > 0 or minetest.get_item_group(stack:get_name(),"bucket_water") > 0 or minetest.get_item_group(stack:get_name(),"water") > 0) then
				local color = default.def(stack:get_name()).dye_colors or default.def(p:get_name()).dye_colors
				if color then
					local item = ItemStack("default:dye"):to_table()
					item.meta ={
						palette_index = color.palette or 1,
						hex=color.hex or "777777",
						name=color.name or "dye",
						description= (color.name and color.name.upper(string.sub(color.name,1,1)) .. string.sub(color.name,2,string.len(color.name))) or ""
					}
					item.count = 4
					inv:set_stack("output",1,item)
					minetest.swap_node(pos,{name="default:dye_workbench",param2=color.palette})
				end
			end
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		if name==meta:get_string("owner") or not minetest.is_protected(pos,name) then
			local inv = minetest.get_meta(pos):get_inventory()
			if listname == "output" then
				local w = inv:get_stack("input",1)
				local iw = inv:get_stack("input_water",1)
				if minetest.get_item_group(iw:get_name(),"bucket_water") > 0 then
					inv:set_stack("input_water",1,"default:bucket")
					inv:set_stack("input",1,w)
				else
					iw:take_item()
					inv:set_stack("input_water",1,iw)
					if iw:get_count() > 0 and w:get_count()-4 > 0 then
						minetest.after(0,function(pos, iw, player)
							minetest.registered_nodes["default:dye_workbench"].allow_metadata_inventory_put(pos, "input_water", 1, iw, player)
						end,pos, iw, playe)
					end
				end
				w:take_item()
				inv:set_stack("input",1,w)
			elseif (listname == "input" and inv:get_stack("input",1):get_count()-stack:get_count() < 1) or listname == "input_water" then
				inv:set_stack("output",1,nil)
			end
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "output" or to_list ~= from_list then
			return 0
		end
		return count
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("input") and inv:is_empty("input_water")
	end,
	drop="default:dye_workbench 1",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.125, -0.5, 0.5, 0.1875, 0.5},
			{0.125, 0.1875, 0.4375, 0.5, 0.5, 0.5},
			{0.125, 0.1875, 0.125, 0.5, 0.5, 0.1875},
			{0.125, 0.1875, 0.1875, 0.1875, 0.5, 0.4375},
			{0.4375, 0.1875, 0.1875, 0.5, 0.5, 0.4375},
			{-0.5, -0.5, -0.5, -0.4375, 0.125, -0.4375},
			{0.4375, -0.5, -0.5, 0.5, 0.125, -0.4375},
			{0.4375, -0.5, 0.4375, 0.5, 0.125, 0.5},
			{-0.5, -0.5, 0.4375, -0.4375, 0.125, 0.5},
			{-0.4375, 0.1875, -0.4375, 0, 0.25, 0},
		}
	}
})

local recycling_mill_items = {}

minetest.register_node("default:recycling_mill", {
	description = "Recycling mill",
	tiles={"default_ironblock.png^synth_repeat.png"},
	groups = {cracky=3,used_by_npc=1,exatec_tube_connected=1,store=10000},
	sounds = default.node_sound_stone_defaults(),
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_int("colortest",minetest.check_player_privs(placer:get_player_name(), {server=true}) and 1 or 0)
	end,
	on_construct=function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 9)
		meta:set_string("formspec",
			"size[8,7]" ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"list[context;input;2,1;1,1;]" ..
			"list[context;output;4,0;3,3;]" ..
			"list[current_player;main;0,3.5;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[current_name;input]" ..
			"listring[current_name;output]" ..
			"listring[current_player;main]"
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		if listname == "input" and inv:is_empty("output") and inv:is_empty("input") then
			if minetest.registered_nodes["default:recycling_mill"].on_metadata_inventory_put(pos, listname, index, stack, player,stack) then
				return 1
			end
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "output" or to_list ~= from_list then
			return 0
		end
		return count
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local inv = minetest.get_meta(pos):get_inventory()
		if listname == "output" then
			inv:set_list("input",{})
		elseif listname == "input" then
			inv:set_list("output",{})
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player,test)
		local inv = minetest.get_meta(pos):get_inventory()
		local input_item = test and test:get_name() or inv:get_stack("input",1):get_name()

		if inv:is_empty("output") then
			local craft = minetest.get_craft_recipe(input_item)
			if craft.items and craft.type == "normal" and ItemStack(craft.output):get_count() == 1 then
				local same_items = false

				for i,v in pairs(craft.items) do
					if v == input_item then
						if same_items == false then
							same_items = true
						else
							return
						end
					end
				end

				for i,v in pairs(craft.items) do
					local a,b = minetest.get_craft_result({method = "normal",width = 3, items = {v}})
					if a.item:get_name() == input_item or minetest.get_item_group(v,"not_recycle_return") > 0 then
						return
					elseif v:sub(1,6) == "group:" then
						local g = v:sub(7,-1)
						for i2,v2 in pairs(minetest.registered_items) do
							if v2.groups and (v2.groups[g] or 0) > 0 and not v2.groups.not_recycle_return then
								craft.items[i]=i2
								break
							end

						end
					end
				end

				local w = stack:get_wear()
				for i,v in pairs(craft.items) do
					if v == input_item or not minetest.registered_items[v] or w > 0 and math.random(1,math.ceil(w*0.00005)) > 1 then
						craft.items[i] = ""
					end
				end

				if #craft.items == 0 then
					return false
				elseif test then
					return true
				else
					inv:set_list("output",craft.items)
				end
			end
		end
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("input") and inv:is_empty("output")
	end,
	exatec={
		input_max=1,
		input_list="input",
		output_list="output",
		test_input=function(pos,stack)
			local inv = minetest.get_meta(pos):get_inventory()
			return stack:get_count() == 1 and inv:is_empty("input") and inv:is_empty("output") and minetest.registered_nodes["default:recycling_mill"].allow_metadata_inventory_put(pos, "input", 1, stack,stack) == 1
		end,
	},
})

minetest.register_node("default:pellets_mill", {
	description = "Pellets mill",
	tiles={"default_steelblock.png^fire_basic_flame.png^synth_repeat.png"},
	groups = {cracky=3,used_by_npc=1,exatec_tube_connected=1,store=6000,on_load=1},
	sounds = default.node_sound_stone_defaults(),
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_int("colortest",minetest.check_player_privs(placer:get_player_name(), {server=true}) and 1 or 0)
	end,
	on_load = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if meta:get_inventory():get_size("input") ~= 9 then
			local a = inv:get_stack("input",1)
			local b = inv:get_stack("output1",1)
			local c = inv:get_stack("output2",1)
			minetest.registered_nodes["default:pellets_mill"].on_construct(pos)
			inv:set_stack("input",1,a)
			inv:set_stack("output1",1,b)
			inv:set_stack("output2",1,c)
		end
	end,
	on_construct=function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 9)
		inv:set_size("output1", 1)
		inv:set_size("output2", 1)
		meta:set_string("formspec",
			"size[8,6.5]" ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"image[0.2,0.2;3,3;fire_basic_flame.png]" ..
			"list[context;input;0,0;3,3;]" ..

			"list[context;output1;4,1;3,3;]" ..
			"list[context;output2;6,1;3,3;]" ..

			"list[current_player;main;0,3;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[current_name;input]" ..
			"listring[current_name;output2]" ..
			"listring[current_player;main]"
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		if listname == "input" and minetest.get_item_group(stack:get_name(),"flammable") > 0 and stack:get_name() ~= "materials:pelletsblock" then
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.get_node_timer(pos):start(0.01)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player,test)
		minetest.get_node_timer(pos):start(0.01)
	end,
	on_timer = function(pos, elapsed)
		local timer = false
		local meta = minetest.get_meta(pos)
		local skip = meta:get_int("skip") == 1
		local inv = minetest.get_meta(pos):get_inventory()
		local stack1

		for i=1,16 do
			stack1 = inv:get_stack("input",i)
			if stack1:get_count() > 0 then
				break
			end
		end

		local craft = minetest.get_craft_recipe(stack1:get_name())

		if not skip and stack1:get_count() > 0 and craft.items and craft.type == "normal" and ItemStack(craft.output):get_count() == 1 then
			local same_items = false
			for i,v in pairs(craft.items) do
				if v == stack1:get_name() then
					if same_items == false then
						same_items = true
					else
						return
					end
				end
			end

			for i,v in pairs(craft.items) do
				local a,b = minetest.get_craft_result({method = "normal",width = 3, items = {v}})
				if a.item:get_name() == stack1:get_name() or minetest.get_item_group(v,"not_recycle_return") > 0 then
					meta:set_int("skip",1)
					return true
				elseif v:sub(1,6) == "group:" then
					local g = v:sub(7,-1)
					for i2,v2 in pairs(minetest.registered_items) do
						if v2.groups and (v2.groups[g] or 0) > 0 and not v2.groups.not_recycle_return then
							craft.items[i]=i2
							break
						end
					end
				end
			end

			local w = stack1:get_wear()
			for i,v in pairs(craft.items) do
				if v == stack1:get_name() or not minetest.registered_items[v] or w > 0 and math.random(1,math.ceil(w*0.00005)) > 1 then
					craft.items[i] = ""
				end
			end

			if #craft.items == 0 then
				return false
			else
				for i,v in pairs(craft.items) do
					if inv:room_for_item("input",v) then
						inv:add_item("input",v)
					else
						return false
					end
				end
				inv:remove_item("input",stack1:get_name())
			end
			return true
		elseif skip then
			meta:set_int("skip",0)
		end

		local c = minetest.get_item_group(stack1:get_name(),"wood") > 0 and 4 or minetest.get_item_group(stack1:get_name(),"tree") > 0 and 12 or minetest.get_item_group(stack1:get_name(),"flammable")

		if c == 0 and stack1:get_name() ~= "" then
			local ob = minetest.add_entity(vector.offset(pos,0,1,0),"exatec:tubeitem")
			local en = ob:get_luaentity()
			en:new_item(stack1,pos)
			en.storage.dir = vector.new(0,1,0)
			ob:set_velocity(en.storage.dir)
			inv:remove_item("input",stack1)
			return true
		end

		local pellets = ItemStack("materials:pellets "..c)
		local pelletsblock = ItemStack("materials:pelletsblock")

		if inv:is_empty("input") and inv:is_empty("output1") then	
			return false
		elseif stack1:get_count() >= 10 and inv:room_for_item("output1",ItemStack("materials:pellets "..(c*stack1:get_count()))) then
			inv:add_item("output1",ItemStack("materials:pellets "..(c*stack1:get_count())))
			inv:remove_item("input",stack1)
			timer = true
		elseif stack1:get_count() >= 10 and inv:room_for_item("output1",ItemStack("materials:pellets "..(c*10))) then
			inv:add_item("output1",ItemStack("materials:pellets "..(c*10)))
			inv:remove_item("input",stack1:get_name() .. " 10")
			timer = true
		elseif stack1:get_count() >= 1 and inv:room_for_item("output1",pellets) then
			inv:add_item("output1",pellets)
			inv:remove_item("input",stack1:get_name() .. " 1")
			timer = true
		end

		for i = 0,10 do
			local stack2= inv:get_stack("output1",1)
			if stack2:get_count() >= 9 and inv:room_for_item("output2",pelletsblock) then
				inv:add_item("output2",pelletsblock)
				inv:set_stack("output1",1,ItemStack(stack2:get_name() .. " "..stack2:get_count()-9))
				timer = true
			else
				break
			end
		end
		return timer 
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("input") and inv:is_empty("output1") and inv:is_empty("output2")
	end,
	exatec={
		input_list="input",
		output_list="output2",
		test_input=function(pos,stack)
			return minetest.get_item_group(stack:get_name(),"flammable") > 0 and stack:get_name() ~= "materials:pelletsblock" and minetest.get_meta(pos):get_inventory():room_for_item("input",stack) and stack:get_count() or false
		end,
	}
})