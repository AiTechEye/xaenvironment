minetest.register_on_mods_loaded(function()
	default.workbench.items_list = {}
	default.workbench.groups_list = {}
	for i,it in pairs(minetest.registered_items) do
		if not (it.groups and it.groups.not_in_creative_inventory) then
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


default.workbench.set_form=function(pos,add)
	local meta = minetest.get_meta(pos)
	local page = meta:get_int("page")
	local craftguide_items = ""
	add = add or ""
	local x=-0.2
	local y=0
	for i=page,page+39,1 do
		local it = default.workbench.items_list[i]
		if not it then
			break
		end
		craftguide_items = craftguide_items .. "item_image_button[" .. x .. "," .. y .. ";0.7,0.7;".. it ..";guide_item#" .. it .. ";]"
		x = x + 0.5
		if x >= 3.8 then
			x = -0.2
			y = y + 0.6
		end
	end

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
		"listring[current_name;output]" ..
		"listring[current_player;main]" ..

		craftguide_items ..

		"image_button[-0.2,3;0.7,0.7;default_crafting_arrowleft.png;guideback;]" ..
		"image_button[0.3,3;0.7,0.7;default_crafting_arrowright.png;guidefront;]" ..

		add
	)
end

minetest.register_node("default:workbench", {
	description = "Workbench",
	tiles={"default_workbench_table.png","default_wood.png","default_wood.png^default_workbench.png"},
	groups = {wood=1,oddly_breakable_by_hand=3,choppy=3,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_receive_fields=function(pos, formname, pressed, sender)
		local meta = minetest.get_meta(pos)
		if pressed.guidefront then
			local page = meta:get_int("page")
			if page + 40 < #default.workbench.items_list then
				meta:set_int("page",page + 40)
				default.workbench.set_form(pos)
			end
			return
		elseif pressed.guideback then
			local page = meta:get_int("page")
			if page - 40 >= 0 then
				meta:set_int("page",page - 40)
				default.workbench.set_form(pos)
			end
			return
		elseif pressed.reset then
			default.workbench.set_form(pos)
			return
		end

		for i,it in pairs(pressed) do
			if  string.sub(i,1,11) == "guide_item#" then
				local item = string.sub(i,12,-1)

				local craft = default.workbench.get_craft_recipe(item)
				local x = -0.2
				local y = 4
				local itlist = ""

				if craft.items and (craft.type == "normal" or craft.type == "workbench") then
					local craftgl = 9 -- #craft.items
					--if craftgl < 9 then
					--	 craftgl = 9
					--end
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
						itlist = itlist .. "item_image_button[" .. x .. "," .. y .. ";0.7,0.7;".. it2s ..";guide_" .. kind .."#" .. but ..";" .. label .."]"
						x = x + 0.5
						if x >= 1.2 then
							x = -0.2
							y = y + 0.6
						end
					end
					itlist = itlist .. (craft.type == "workbench" and "item_image_button[1.7,4.6;0.7,0.7;default:workbench;guide_item#default:workbench;]" or "")
				elseif craft.type and craft.type == "cooking" and craft.item then
					local kind = "item"
					local label = ""
					local itkind = craft.item
					if string.sub(craft.item,1,6) == "group:" and default.workbench.groups_list[craft.item] then
						craft.item = default.workbench.groups_list[craft.item][1] or "default:unknown"
						label = "G"
						kind = "group"
					end

					itlist = ""
					.. "item_image_button[" .. x .. "," .. y .. ";0.7,0.7;".. craft.item ..";guide_" .. kind .."#" .. itkind ..";" .. label .. "]"
					.. "label[" .. (x+0.3) .. "," .. (y-0.4) .. ";Cooking]"
					.. "item_image_button[" .. (x+0.5) .. "," .. y .. ";0.7,0.7;default:furnace;guide_item#default:furnace;]"
					..  "item_image_button[" .. (x+1) .. "," .. y .. ";0.7,0.7;".. craft.output ..";guide_item#" .. craft.output ..";]"
				end

				default.workbench.set_form(pos,itlist)
				return
			elseif string.sub(i,1,12) == "guide_group#" then
				local groupname = string.sub(i,13,-1)
				local group = default.workbench.groups_list[groupname] or {}
				local x = -0.2
				local y = 4.5
				local itlist = "label[-0.2,4;" .. groupname .."]"
				for _,nam in pairs(group) do
					itlist = itlist .. "item_image_button[" .. x .. "," .. y .. ";0.7,0.7;".. nam ..";guide_item#" ..nam ..";]"
					x = x + 0.5
					if x >= 3.8 then
						x = -0.2
						y = y + 0.6
					end
				end
				default.workbench.set_form(pos,itlist)
				return
			end
		end
	end,
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("craft", 9)
		inv:set_size("output", 1)
		inv:set_size("stock", 16)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", "Workbench")
		meta:set_int("page", 1)
		default.workbench.set_form(pos)
	end,
	on_timer = function (pos, elapsed)
			local inv = minetest.get_meta(pos):get_inventory()
			inv:set_stack("output",1,default.workbench.get_craft_result(inv:get_list("craft")))
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname=="craft" then
			minetest.get_node_timer(pos):start(0.1)
		elseif listname=="output" then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		if name==meta:get_string("owner") or not minetest.is_protected(pos,name) then
			if listname == "output" then
				local inv = minetest.get_meta(pos):get_inventory()
				default.workbench.take_from_craftgreed(inv,"craft")
			end
			if listname == "craft" then
				minetest.get_node_timer(pos):start(0.1)
			end
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "output" then
			return 0
		end
		if from_list == "output" then
			local inv = minetest.get_meta(pos):get_inventory()
			default.workbench.take_from_craftgreed(inv,"craft")
		end
		if to_list == "craft" or from_list == "craft" then
			minetest.get_node_timer(pos):start(0.1)
		end
		return count
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("craft") and inv:is_empty("stock")
	end
})