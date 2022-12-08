player_style.craftguide = {
	items = {},
	groups = {},
	width=8,
	height=4
}

minetest.register_on_mods_loaded(function()
	for i,def in pairs(minetest.registered_items) do
		local g = def.groups
		if not g or not (g.not_in_creative_inventory or g.not_in_craftguide) then
			table.insert(player_style.craftguide.items,def.name)
		end
		if g and not g.not_in_creative_inventory then
			for g2,v in pairs(g) do
				player_style.craftguide.groups["group:" .. g2] = player_style.craftguide.groups["group:" .. g2] or {}
				table.insert(player_style.craftguide.groups["group:" .. g2],def.name)
			end
		end
	end
	table.sort(player_style.craftguide.items)
end)

player_style.craftguide.show=function(player,pos)
	local name = player:get_player_name()
	player_style.players[name].craftguide = player_style.players[name].craftguide or {page=1,index=1}

	local user = player_style.players[name].craftguide

	if pos then
		user.pos = pos
		local meta = minetest.get_meta(pos):to_table()
		user.search = nil
		user.search_text = nil
		for i,v in pairs(meta.fields) do
			user[i] = tonumber(v) or v
		end
		if meta.fields.search_text then
			player_style.craftguide.search(player,meta.fields.search_text)
		end
	elseif user.pos then
		local meta = minetest.get_meta(user.pos)
		for i,v in pairs(user) do
			if type(v) == "string" and i ~= "search" then
				meta:set_string(i,v)
			elseif type(v) == "number" then
				meta:set_int(i,v)
			end
		end
	end

	local x=0
	local y=0
	local craftable,craft_status,missing = player_style.craftguide.autocraft(player,true)
	local list = user.search or player_style.craftguide.items
	local items = ""
	local size = player_style.craftguide.width * player_style.craftguide.height
	local pages = math.ceil(#list/size)

	for i=user.index,user.index+size-1 do
		local item = list[i]
		if not item then
			break
		end
		items = items .. "item_image_button[" .. x .. "," .. y .. ";1,1;" .. item .. ";guide_item#" .. item .. ";]"
		x = x + 1
		if x >= player_style.craftguide.width then
			x = 0
			y = y + 1
		end
	end

	if user.craft_item and missing then
		x = 0
		y = 5.5
		for i,v in ipairs(missing) do
			if v == "." then
				items = items .. "box[" .. (x-0.025) .. "," .. (y-0.04) .. ";0.85,0.95;#f00f]"
			end
			x = x + 1
			if x >= 3 then
				x = 0
				y = y  + 1
			end
		end
	end

	if user.craft_item then
		items = items .. "image[3,6.5;1,1;default_crafting_arrowright.png]"
		if craftable then
			items = items .. "item_image_button[4,6.5;1,1;"..user.craft_item..";craft;]tooltip[craft;Craft it]"
		else
			items = items .. "box[4,6.5;0.8,0.9;#333f]item_image[4,6.5;1,1;"..user.craft_item.."]box[4,6.5;0.8,0.9;#555c]tooltip[4,6.5;1,1;"..(craft_status or "").."]"
		end
	end

	return minetest.show_formspec(name, "player_style.craftguide",
		"size[8,"..(user.info and 8.5 or 5).."]"
		.. "listcolors[#77777777;#777777aa;#000000ff]"
		.. items

		.. "image_button[1,4.25;1,1;default_crafting_arrowleft.png"..(user.page == 1 and "^[colorize:#5555;No" or ";").."guideback;]"

		.. "label[2,4.4;" .. user.page .. "/" .. pages .."]"

		.. "image_button[3,4.25;1,1;default_crafting_arrowright.png"..(user.page == pages and "^[colorize:#5555;No" or ";").."guidefront;]"
		.. "image_button[4,4.25;1,1;synth_repeat.png;reset;]"
		.. "image_button[5,4.25;1,1;player_style_search.png;search;]"
		.. "field[6,4.5;2.5,1;searchbox;;"..(user.search_text or "").."]"
		.. "field_close_on_enter[searchbox;false]"
		.. (user.info or "")
		)
end

player_style.craftguide.autocraft=function(player,test)

	local name = player:get_player_name()
	local user = player_style.players[name].craftguide
	local inv
	local meta = user.pos and minetest.get_meta(user.pos)
	if meta and meta:get_inventory():get_list("main") then
		inv = meta:get_inventory()
	else
		inv = player:get_inventory()
	end

	local craft_item = user.craft_item
	local craft = minetest.get_craft_recipe(craft_item or "")
	local take_from = "main"
	local add_to = "craft"

	local visual_craft_grid = {}
	local visual_inv = table.copy(inv:get_list(take_from))

	if not (craft.items and craft.type == "normal") then
		return false,"Unable"
	end

	for i,v in pairs(craft.items) do
		if v:sub(1,6) == "group:" then
			local g = v:sub(7,-1)
			for i2,v2 in pairs(visual_inv) do
				if minetest.get_item_group(v2:get_name(),g) > 0 then
					visual_craft_grid[i] = v2:get_name() .. " 1"
					visual_inv[i2]:take_item(1)
					break
				end
			end
		elseif inv:contains_item(take_from,v) then
			for i2,v2 in pairs(visual_inv) do
				if v == v2:get_name() then
					visual_inv[i2]:take_item(1)
					visual_craft_grid[i] = v .. " 1"
					break
				end
			end
		end
	end

	local item = minetest.get_craft_result({method = "normal",width = 3, items = visual_craft_grid}).item

	if item:get_name() == craft_item then
		if not inv:room_for_item("main",craft_item) then
			return false,"No room in the inventory"
		elseif not test then
			inv:add_item(take_from,item)
			for i,v in pairs(visual_craft_grid) do
				inv:remove_item(take_from,v)
			end
		end
		return true,""
	else
		for i=1,9 do
			local v = craft.items[i]
			if not v or v == "" then
				visual_craft_grid[i] = ""
			elseif (v or v ~= "") and not visual_craft_grid[i] then
				visual_craft_grid[i] = "."
			end
		end
		return false,"Not all necessary items are in the inventory",visual_craft_grid
	end
end

player_style.craftguide.search=function(player,text)
	local s = text:lower()
	local items = {}
	local name = player:get_player_name()
	local user = player_style.players[name].craftguide
	for i,it in pairs(player_style.craftguide.items) do
		if it:find(s) or (default.def(it).description or ""):lower():find(s) then
			table.insert(items,it)
		end
	end
	user.search = items
	user.search_text = s
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "player_style.craftguide" then
		local name = player:get_player_name()
		local user = player_style.players[name].craftguide

		if pressed.quit then
			user.pos = nil
		elseif pressed.guidefront then
			local list = user.search or player_style.craftguide.items
			local size = player_style.craftguide.width*player_style.craftguide.height

			if user.index+size < #list then
				user.index = user.index + size
				user.page = user.page + 1
				player_style.craftguide.show(player)
			end
			return
		elseif pressed.guideback then
			if user.page > 1 then
				user.index = user.index - player_style.craftguide.width*player_style.craftguide.height
				user.page = user.page -1
				player_style.craftguide.show(player)
			end
			return
		elseif pressed.reset then
			user.search = nil
			user.search_text = nil
			user.page = 1
			user.index = 1
			user.info = nil
			user.craft_item = nil
			player_style.craftguide.show(player)
			return
		elseif pressed.search or pressed.key_enter_field == "searchbox" then
			player_style.craftguide.search(player,pressed.searchbox)
			user.page = 1
			user.index = 1
			player_style.craftguide.show(player)
			return
		elseif pressed.craft then
			player_style.craftguide.autocraft(player)

			if user.craft_item then
				local i = "guide_item#"..user.craft_item
				pressed[i] = i
			else
				return
			end
		end

		local list = player_style.craftguide.items
		local groups = player_style.craftguide.groups
		local size = player_style.craftguide.width*player_style.craftguide.height

		for i,it in pairs(pressed) do
--normal & alternatives
			if string.sub(i,1,11) == "guide_item#" or string.sub(i,1,18) == "guide_alternative#" then
				local item
				local itlist = ""
				local craft
				if string.sub(i,1,18) == "guide_alternative#" then
					user.craft_item = nil
					item = string.sub(i,19,-3)
					local c = minetest.get_all_craft_recipes(item)
					if c and #c > 1 then
						for i,v in pairs(c) do
							itlist = itlist .. "item_image_button[" .. (3+i) .. ",6.5;1,1;".. v.output ..";guide_alternative#" ..v.output .."="..i..";]"
						end
						craft = c[tonumber(string.sub(i,-1,-1))]
					else
						item = string.sub(i,12,-1)
						craft = minetest.get_craft_recipe(item)

					end
				else
					item = string.sub(i,12,-1)
					craft = minetest.get_craft_recipe(item)
					user.craft_item = item
				end

				local x = 0
				local y = 5.5

				if craft.items and craft.type == "normal" then
--normal

					for i1=1, 9 do
						local it2s = (i1 and craft.items[i1] or "")
						local label = ""
						local kind = "item"
						local but = it2s

						if it2s=="" or minetest.registered_items[it2s] then
						elseif string.sub(it2s,1,6) == "group:" and groups[it2s] then
							but = it2s
							it2s = groups[it2s][1] or "default:unknown"
							label = "G"
							kind = "group"
						else
							it2s = "default:unknown"
							kind = ""
						end
						itlist = itlist .. "item_image_button[" .. x .. "," .. y .. ";1,1;".. it2s ..";guide_" .. kind .."#" .. but ..";" .. label .."]"
						x = x + 1
						if x >= 3 then
							x = 0
							y = y + 1
						end
					end
					itlist = itlist .. (minetest.get_item_group(item,"not_regular_craft") > 0 and "item_image_button[3,6.5;1,1;default:workbench;guide_item#default:workbench;]" or "")


				elseif craft.type and craft.type == "cooking" and craft.items then
--cooking
					craft.item = craft.items[1]
					user.craft_item = nil

					local kind = "item"
					local label = ""
					local itkind = craft.item
					if string.sub(craft.item,1,6) == "group:" and groups[craft.item] then
						craft.item = groups[craft.item][1] or "default:unknown"
						label = "G"
						kind = "group"
					end

					itlist = ""
					.. "item_image_button[" .. x .. "," .. y .. ";1,1;".. craft.item ..";guide_" .. kind .."#" .. itkind ..";" .. label .. "]"
					.. "label[" .. (x+0.3) .. "," .. (y-0.4) .. ";Cooking]"
					.. "item_image_button[" .. (x+1) .. "," .. y .. ";1,1;default:furnace;guide_item#default:furnace;]"
					.. "item_image_button[" .. (x+2) .. "," .. y .. ";1,1;".. craft.output ..";guide_item#" .. craft.output ..";]"
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
						itlist = itlist .. "item_image_button[" .. (3+i) .. ",5.5;1,1;".. na ..";guide_alternative#" ..na .."="..i..";]"
					end
				end
				user.info = itlist
				player_style.craftguide.show(player)
				return

			elseif string.sub(i,1,12) == "guide_group#" then
--groups
				user.craft_item = nil
				local group = groups[i:sub(13,-1)] or {}
				local items = {}
				for _,g in pairs(group) do
					table.insert(items,g)
				end
				user.search = items
				user.search_text = i:sub(19,-1)
				user.page = 1
				user.index = 1
				player_style.craftguide.show(player)
				return
			end
		end
	end
end)
