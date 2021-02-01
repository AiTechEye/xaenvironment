minetest.register_on_mods_loaded(function()
	default.workbench.items_list = {}
	default.workbench.groups_list = {}
	for i,it in pairs(minetest.registered_items) do
		if not (it.groups and (it.groups.not_in_creative_inventory or it.groups.not_in_craftguide)) then
			table.insert(default.workbench.items_list,it.name)
		end
	end
	table.sort(default.workbench.items_list)
	for n,it1 in pairs(minetest.registered_items) do
		if it1.groups and not it1.groups.not_in_creative_inventory then
			for g,it2 in pairs(it1.groups) do
				default.workbench.groups_list["group:" .. g] = default.workbench.groups_list["group:" .. g] or {}
				table.insert(default.workbench.groups_list["group:" .. g],n)
			end
		end
	end
end)

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.get_item_group(itemstack:get_name(),"not_regular_craft") > 0 then
		return ""
	end
	return itemstack
end)

default.workbench.set_form=function(pos,add)
	local meta = minetest.get_meta(pos)
	local page = meta:get_int("page")

	local but_size = meta:get_string("but_size")
	local x_add = tonumber(meta:get_string("x_add"))
	local y_add = tonumber(meta:get_string("y_add"))

	local but_am = meta:get_int("but_am")
	local but_am_w = meta:get_int("but_am_w")

	local craftguide_items = ""
	add = add or ""
	local x=-0.2
	local y=0
	local search = meta:get_string("search")
	local itemlist = search ~= "" and minetest.deserialize(search) or default.workbench.items_list
	local craftr = add ~= ""


	for i=page,page+but_am,1 do
		local it = itemlist[i]
		if not it then
			break
		end
		craftguide_items = craftguide_items .. "item_image_button[" .. x .. "," .. y .. ";" .. but_size ..";".. it ..";guide_item#" .. it .. ";]"
		x = x + x_add
		if x >= x_add*but_am_w then
			x = -0.2
			y = y + y_add
		end
	end

	if meta:get_int("craftguide") == 1 then
		meta:set_string("formspec",
			"size[8,"..(craftr and 12 or 9).. "]" ..
			craftguide_items ..
			"list[current_player;main;0,"..(craftr and 8 or 5)..".4;8,4;]" ..
			"image_button[3.6,4.5;" .. but_size ..";default_crafting_arrowleft.png;guideback;]" ..
			"image_button[4.3,4.5;" .. but_size ..";default_crafting_arrowright.png;guidefront;]" ..
			"field[0,4.8;2.5,1;searchbox;;"..meta:get_string("search_text").."]"..
			"image_button[2,4.5;" .. but_size ..";player_style_search.png;search;]" ..
			"image_button[2.8,4.5;" .. but_size ..";synth_repeat.png;reset;]" ..
			"image_button[5.3,4.5;" .. but_size ..";default_craftgreed.png;add2c;]tooltip[add2c;Add to craft grid]" ..
			add
		)
	else
		meta:set_string("formspec",
		"size[8,11]" ..
		"list[context;craft;4,0;3,3;]" ..
		"list[context;output;7,1;1,1;]" ..
		"list[context;stock;4,3.2;4,4;]" ..
		"list[current_player;main;0,7.3;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[current_name;stock]" .. 
		"listring[current_name;craft]".. 
		"listring[current_player;main]" ..
		"listring[current_name;output]".. 
		"listring[current_player;main]" ..
		craftguide_items ..
		"image_button[3,3;0.7,0.7;default_crafting_arrowleft.png;guideback;]" ..
		"image_button[3.5,3;0.7,0.7;default_crafting_arrowright.png;guidefront;]" ..
		"field[0,3.5;2.5,0.5;searchbox;;"..meta:get_string("search_text").."]"..
		"image_button[2,3;0.7,0.7;player_style_search.png;search;]" ..
		"image_button[2.5,3;0.7,0.7;synth_repeat.png;reset;]" ..
		"image_button[3.5,3.5;0.7,0.7;default_craftgreed.png;add2c;]tooltip[add2c;Add to craft grid]" ..
		add
		)
	end
end

local on_receive_fields=function(pos, formname, pressed, sender)
		local meta = minetest.get_meta(pos)
		if pressed.guidefront then
			local page = meta:get_int("page")
			local search = meta:get_string("search")
			local itemlist = search ~= "" and minetest.deserialize(search) or default.workbench.items_list
			if page + 40 < #itemlist then
				meta:set_int("page",page + meta:get_int("but_am")+1)
				default.workbench.set_form(pos)
			end
			return
		elseif pressed.guideback then
			local page = meta:get_int("page")
			if page - 40 >= 0 then
				meta:set_int("page",page - meta:get_int("but_am")-1)
				default.workbench.set_form(pos)
			end
			return
		elseif pressed.reset then
			meta:set_string("search","")
			meta:set_string("search_text","")
			meta:set_int("page",1)
			default.workbench.set_form(pos)
			return
		elseif pressed.search then
			local its = {}
			local s = pressed.searchbox:lower()
			for i,it in pairs(default.workbench.items_list) do
				if it:find(s) or (minetest.registered_items[it].description or ""):lower():find(s) then
					table.insert(its,it)
				end
			end
			meta:set_string("search",minetest.serialize(its))
			meta:set_string("search_text",s)
			meta:set_int("page",1)
			default.workbench.set_form(pos)
			return
		elseif pressed.add2c then
			local craft_item = meta:get_string("craft_item")
			local craft
			if craft_item ~= "" then
				craft = minetest.get_craft_recipe(craft_item)
				if not (craft.items and craft.type == "normal") then
					return
				end
			else
				return
			end

			local take_from
			local add_to
			local inv

			if meta:get_int("craftguide") == 1 then
				inv = sender:get_inventory()
				take_from = "main"
				add_to = "craft"
			elseif meta:get_int("workbench") == 1 then
				inv = meta:get_inventory()
				take_from = "stock"
				add_to = "craft"
			else
				return
			end

			for i,v in pairs(craft.items) do
				local n =  inv:get_stack(add_to,i):get_name()
				local c =  inv:get_stack(add_to,i):get_count()
				local max = n ~= "" and minetest.registered_items[n] and minetest.registered_items[n].stack_max or 99
				if v:sub(1,6) == "group:" then
					for i2,v2 in pairs(inv:get_list(take_from)) do
						if minetest.get_item_group(v2:get_name(),v:sub(7,-1)) > 0 and (n == "" or v2:get_name() == n and c < max) then
							inv:set_stack(add_to,i,v2:get_name() .. " "..(c+1))
							inv:remove_item(take_from,v2:get_name() .. " 1")
							break
						end
					end
				elseif inv:contains_item(take_from,v) and (n == "" or n == v and c < max) then
					inv:set_stack(add_to,i,v .. " "..(c+1))
					inv:remove_item(take_from,v .. " 1")
				end
			end
		end

		local but_size = meta:get_string("but_size")
		local x_add = tonumber(meta:get_string("x_add"))
		local y_add = tonumber(meta:get_string("y_add"))
		local x_start = tonumber(meta:get_string("x_start"))
		local y_start_crafring = tonumber(meta:get_string("y_start_crafring"))
		local y_start_cooking = tonumber(meta:get_string("y_start_cooking"))
		local y_label = tonumber(meta:get_string("y_label"))

		local but_am_w = meta:get_int("but_am_w")

		for i,it in pairs(pressed) do
			if string.sub(i,1,11) == "guide_item#" or string.sub(i,1,18) == "guide_alternative#" then
				local item
				local itlist = ""
				local craft
				if string.sub(i,1,18) == "guide_alternative#" then
					item = string.sub(i,19,-3)
					local c = minetest.get_all_craft_recipes(item)
					if c and #c > 1 then
						for i,v in pairs(c) do
							itlist = itlist .. "item_image_button[" .. (1.5+i) .. ",5.7;" .. but_size ..";".. v.output ..";guide_alternative#" ..v.output .."="..i..";]"
						end
						craft = c[tonumber(string.sub(i,-1,-1))]
					else
						item = string.sub(i,12,-1)
						craft = minetest.get_craft_recipe(item)
					end
				else
					item = string.sub(i,12,-1)
					craft = minetest.get_craft_recipe(item)
					meta:set_string("craft_item",item)

				end

				local x = x_start
				local y = y_start_crafring+0.5
				
				if craft.items and craft.type == "normal" then
					local craftgl = 9
					for i1=1, craftgl,1 do
						local it2s = (i1 and craft.items[i1] or "")
						local label = ""
						local kind = "item"
						local but = it2s

						if it2s=="" or minetest.registered_items[it2s] then
						elseif string.sub(it2s,1,6) == "group:" and default.workbench.groups_list[it2s] then
							but = it2s
							it2s = default.workbench.groups_list[it2s][1] or "default:unknown"
							label = "G"
							kind = "group"
						else
							it2s = "default:unknown"
							kind = ""
						end
						itlist = itlist .. "item_image_button[" .. x .. "," .. y .. ";" .. but_size ..";".. it2s ..";guide_" .. kind .."#" .. but ..";" .. label .."]"
						x = x + x_add
						if x >= x_add*2 then
							x = x_start
							y = y + y_add
						end
					end
					itlist = itlist .. (minetest.get_item_group(item,"not_regular_craft") > 0 and "item_image_button[" .. (x_start+x_add*4) .. "," .. (y_start_crafring+y_add) .. ";" .. but_size ..";default:workbench;guide_item#default:workbench;]" or "")
				elseif craft.type and craft.type == "cooking" and craft.items then
					craft.item = craft.items[1]

					local kind = "item"
					local label = ""
					local itkind = craft.item
					if string.sub(craft.item,1,6) == "group:" and default.workbench.groups_list[craft.item] then
						craft.item = default.workbench.groups_list[craft.item][1] or "default:unknown"
						label = "G"
						kind = "group"
					end

					itlist = ""
					.. "item_image_button[" .. x .. "," .. y .. ";" .. but_size ..";".. craft.item ..";guide_" .. kind .."#" .. itkind ..";" .. label .. "]"
					.. "label[" .. (x+0.3) .. "," .. (y-0.4) .. ";Cooking]"
					.. "item_image_button[" .. (x+x_add) .. "," .. y .. ";" .. but_size ..";default:furnace;guide_item#default:furnace;]"
					..  "item_image_button[" .. (x+x_add*2) .. "," .. y .. ";" .. but_size ..";".. craft.output ..";guide_item#" .. craft.output ..";]"
				end

				local c = minetest.get_all_craft_recipes(item)
				if c and #c > 1 then
					for i,v in pairs(c) do
						if i > 5 then
							break
						end
						local na = v.output
						local s =  string.find(na," ")
						if s then
							na = string.sub(na,1,s-1)
						end
						itlist = itlist .. "item_image_button[" .. (1.5+i) .. ",6.5;" .. but_size ..";".. na ..";guide_alternative#" ..na .."="..i..";]"
					end
				end

				default.workbench.set_form(pos,itlist)
				return
			elseif string.sub(i,1,12) == "guide_group#" then
				local groupname = string.sub(i,13,-1)
				local group = default.workbench.groups_list[groupname] or {}
				local x = x_start
				local y = y_start_cooking
				local itlist = "label[-0.2," .. (y_label+0.1) .. ";" .. groupname .."]"
				local bs = tonumber(but_size.split(but_size,",")[1])
				for _,nam in pairs(group) do
					itlist = itlist .. "item_image_button[" .. x .. "," .. y .. ";" .. but_size ..";".. nam ..";guide_item#" ..nam ..";]"
					x = x + x_add
					if x >= bs*(but_am_w-2)  then
						x = x_start
						y = y + y_add
					end
				end
				default.workbench.set_form(pos,itlist)
				return
			end
		end
end

default.workbench.result=function(pos,form)
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
	end
	craft = minetest.get_craft_result({method = "normal",width = 3, items = inv:get_list("craft")})
	inv:set_stack("output",1,craft.item)
end

minetest.register_node("default:workbench", {
	description = "Workbench",
	tiles={"default_workbench_table.png","default_wood.png","default_wood.png^default_workbench.png"},
	groups = {wood=1,oddly_breakable_by_hand=3,choppy=3,flammable=2,used_by_npc=1,exatec_tube_connected=1},
	sounds = default.node_sound_wood_defaults(),
	on_receive_fields=on_receive_fields,
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_string("owner", placer:get_player_name())
	end,
	on_construct=function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("craft", 9)
		inv:set_size("output", 1)
		inv:set_size("stock", 16)
		meta:set_string("infotext", "Workbench")
		meta:set_int("workbench", 1)
		meta:set_int("page", 1)
		meta:set_string("but_size", "0.7,0.7")
		meta:set_string("x_start", "-0.2")
		meta:set_string("x_add", "0.5")
		meta:set_string("y_add", "0.6")
		meta:set_string("y_start_crafring", "4")
		meta:set_string("y_start_cooking", "4.5")
		meta:set_string("y_label", 4)
		meta:set_int("but_am", 39)
		meta:set_int("but_am_w", 7)
		default.workbench.set_form(pos)
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
			default.workbench.result(pos,from_list)
		end
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname=="craft" or listname=="output" then
			default.workbench.result(pos,listname)
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
		return (inv:is_empty("craft") and inv:is_empty("stock")) and (name == owner or owner == "")
	end,
	exatec={
		input_list="stock",
		output_list="stock",
	},
})

minetest.register_node("default:craftguide", {
	description = "Craftguide",
	tiles={"default_craftgreed.png^default_unknown.png"},
	use_texture_alpha = true,
	wield_image="default_craftgreed.png^default_unknown.png",
	inventory_image="default_craftgreed.png^default_unknown.png",
	groups = {dig_immediate=3,flammable=2,used_by_npc=2},
	sounds = default.node_sound_wood_defaults(),
	on_receive_fields=on_receive_fields,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.49,0.5}},
	paramtype2="wallmounted",
	paramtype = "light",
	sunlight_propagates = true,
	on_construct=function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("page", 1)
		meta:set_string("but_size", "1,1")
		meta:set_string("x_start", -0.2)
		meta:set_string("x_add", "0.8")
		meta:set_string("y_add", "0.9")
		meta:set_string("y_start_crafring", "5")
		meta:set_string("y_start_cooking", "5.5")
		meta:set_string("y_label", "5")
		meta:set_int("craftguide", 1)
		meta:set_int("but_am", 49)
		meta:set_int("but_am_w", 9)
		default.workbench.set_form(pos)
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
	groups = {cracky=3,flammable=2,used_by_npc=1,exatec_tube_connected=1,store=1000},
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
		if listname == "input" and inv:is_empty("output") and inv:is_empty("input") and stack:get_wear() == 0 then
			local i = stack:get_name()
			if m:get_int(i) == 1 or minetest.registered_nodes["default:recycling_mill"].on_metadata_inventory_put(pos, listname, index, stack, player,stack) then
				m:set_int(i,1)
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
					if a.item and a.item:get_name()== input_item then
						return
					end

					if a.item:get_name() == "default:flitblock" then
						return
					elseif v:sub(1,6) == "group:" then
						local g = v:sub(7,-1)
						for i2,v2 in pairs(minetest.registered_items) do
							if v2.groups and (v2.groups[g] or 0) > 0 then
								craft.items[i]=i2
								break
							end

						end
					end

				end
				for i,v in pairs(craft.items) do
					if not minetest.registered_items[v] then
						craft.items[i] = ""
					end
				end

				if test then
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
			return inv:is_empty("input") and inv:is_empty("output") and minetest.registered_nodes["default:recycling_mill"].allow_metadata_inventory_put(pos, "input", 1, stack,stack) == 1
		end,
	},
})