local ITEMS_PER_PAGE = 8 * 5

player_style.register_button({
	name="Store",
	image="player_style_coin.png",
	type="image",
	info="Store",
	action=function(player)
		if player:get_meta():get_int("store_disabled") == 1 then
			minetest.chat_send_player(player:get_player_name(),"The store is disallowed in this case")
		else
			player_style.store(player)
		end
	end
})

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "store" then
		local name = player:get_player_name()
		local store = player_style.players[name].store
		if store then
			if pressed.quit then
				player_style.players[name].store.clean = nil
				return
			elseif pressed.creinvright and store.index + ITEMS_PER_PAGE < #store.items then
				store.index = store.index + ITEMS_PER_PAGE
				player_style.store(player)
				return
			elseif pressed.creinvleft and store.index > 1 then
				store.index = store.index - ITEMS_PER_PAGE
				player_style.store(player)
				return
			elseif pressed.reset then
				store.index = 1
				store.search_text = nil
				store.items = player_style.store_items
				player_style.store(player)
				return
			elseif pressed.sell then
				store.sell = store.sell == false
				player_style.store(player)
				return
			elseif pressed.search or pressed.key_enter_field == "searchbox" then
				local its = {}
				local s = pressed.searchbox:lower()
				for i,it in pairs(player_style.store_items) do
					if it:find(s) or (minetest.registered_items[it].description or ""):lower():find(s) then
						table.insert(its,it)
					end
				end
				store.index = 1
				store.search_text = s
				store.items = its
				player_style.store(player)
				return
			end
			if pressed.cancel then
				player_style.store(player)
			elseif store.sell then
				for i,v in pairs(pressed) do
					local b = i:sub(1,8)
					if b == "itembut_" or b == "confirm_" then
						local t = i:sub(9,-1)
						local m = player:get_meta()
						local inv = player:get_inventory()
						local s = i:sub(9,-1)
						local c = math.floor(player_style.store_items_cost[t]*0.1)
						if inv:contains_item("main",s) then

							if b ~= "confirm_" and c >= 1000 then
								minetest.after(0.2, function()
									if not minetest.get_player_by_name(name) then return end
									minetest.show_formspec(name, "store",
										"size[3,2]" 
										.."listcolors[#77777777;#777777aa;#000000ff]"
										.."label[0,0;Sell item?\n(Worth: "..c..")]"
										.."button[0,1;1.5,1;confirm_"..t..";Sell]button[1.5,1;1.5,1;cancel;Cancel]"
									)
								end)
								return
							end

							inv:remove_item("main",ItemStack(s.." 1"))
							Coin(player,c)
							player_style.store(player)
							minetest.sound_play("default_coins", {to_player=name, gain = 2})
							break
						end
					end
				end
			else
				for i,v in pairs(pressed) do
					local b = i:sub(1,8)
					if b == "itembut_" or b == "confirm_" then
						local t = i:sub(9,-1)
						local inv = player:get_inventory()
						local c = player_style.store_items_cost[t]
						if Getcoin(player) >= c and inv:room_for_item("main",t) then

							if b ~= "confirm_" and player_style.store_items_cost[t] >= 1000 then
								minetest.after(0.2, function()
									if not minetest.get_player_by_name(name) then return end
									minetest.show_formspec(name, "store",
										"size[3,2]" 
										.."listcolors[#77777777;#777777aa;#000000ff]"
										.."label[0,0;Confirm purchase?\n(Cost: "..c..")]"
										.."button[0,1;1.5,1;confirm_"..t..";Buy]button[1.5,1;1.5,1;cancel;Cancel]"
									)
								end)
								return
							end
							inv:add_item("main",t.." 1")
							Coin(player,-c)
							player_style.store(player)
							break
						end
					end
				end
			end
		end
	end
end)

player_style.open_store=function()
	if not player_style.store_items then
		player_style.store_items_cost={}
		player_style.store_items={}
		for i,it in pairs(minetest.registered_items) do
			if it.groups and it.groups.store then
				table.insert(player_style.store_items,it.name)
				player_style.store_items_cost[it.name] = it.groups.store
			end
		end
		table.sort(player_style.store_items)
		minetest.chat_send_all(dump(#player_style.store_items))
	end
end

player_style.store=function(player)
	local name = player:get_player_name()
	local balance = Getcoin(name)
	local inv = minetest.get_inventory({ type = "player", name = name})
	player_style.players[name].store = player_style.players[name].store or { index = 1, sell = false }
	local store = player_style.players[name].store

	player_style.open_store()

	store.items = store.items or player_style.store_items

	local item_list = store.items
	local pages = math.ceil(#item_list / ITEMS_PER_PAGE)
	local page = math.ceil(store.index / ITEMS_PER_PAGE)
	local item_buttons = ""

	local screen_index = -1
	local _end = math.min(store.index + ITEMS_PER_PAGE - 1, #item_list)
	for i = store.index, _end do
		local item = item_list[i]

		local value = player_style.store_items_cost[item]
		if store.sell then
			value = value * 0.1
			if value >= 1 then
				value = math.floor(value)
			end
		end
		screen_index = screen_index + 1
		local x = 0.2 + screen_index % 8 * 1.2
		local y = 2 + math.floor(screen_index / 8) * 1.2
		local def = minetest.registered_items[item]
		if
			not store.sell and value <= balance or
			store.sell and inv:contains_item("main", item)
		then
			item_buttons = item_buttons
				.. "item_image_button[" .. x .. "," .. y .. ";1.2,1.2;" .. item .. ";itembut_" .. item ..";" .. value .. "]"
				.. "tooltip[itembut_" .. item .. ";" .. (def and def.description or item) .. "]"
		else
			item_buttons = item_buttons
				.. "item_image[" .. x .. "," .. y .. ";1.2,1.2;" .. item .. "]"
				.. "label[" .. x .. "," .. y + 0.6 .. ";" .. value .. "]"
				.. "tooltip[" .. x .. "," .. y .. ";1.2,1.2;" .. (def and def.description or item) .. "]"
		end
	end

	minetest.after(0.2, function()
		if not player:get_look_horizontal() then return end
		minetest.show_formspec(name, "store",
			"formspec_version[2]" -- MT 5.1+
			.. "size[10,10.5]"
			.. "listcolors[#77777777;#777777aa;#000000ff]"

			.. "style_type[label;font_size=+5]"
			.. "label[1,0.6;" .. (store.sell and "Sell" or "Buy") .. "]"
			.. "style_type[label;font_size=]"

			.. "label[1,1.5;Balance: " .. minetest.colorize("#FFFF00", balance) .. " coins]"

			.. "button[6,0.3;3.6,0.75;sell;Switch to " .. (store.sell and "buying" or "selling") .. "]"

			.. item_buttons

			.. "tooltip[creinvleft;Back]"
			.. "image_button[0.4,8.5;0.8,0.8;default_crafting_arrowleft.png;creinvleft;]"

			.. "label[1.7,8.9;" .. page .. "/" .. pages .. "]"

			.. "tooltip[creinvright;Forward]"
			.. "image_button[3,8.5;0.8,0.8;default_crafting_arrowright.png;creinvright;]"

			.. "field[5.2,8.5;3,0.8;searchbox;;" .. (store.search_text or "") .. "]"
			.. "field_close_on_enter[searchbox;false]"

			.. "tooltip[search;Search]"
			.. "image_button[8,8.5;0.8,0.8;player_style_search.png;search;]"

			.. "tooltip[reset;Reset search]"
			.. "image_button[8.8,8.5;0.8,0.8;synth_repeat.png;reset;]"
		)
	end)
end

minetest.register_chatcommand("set_coins", {
	params = "<name> <coins amount>",
	description = "Set the player's coin balance to the number specified",
	privs = { debug = true },
	func = function(name, param)
		local name, count = string.match(param, "(%w+) (%d*)")
		local player
		if count then count = tonumber(count) end
		if count and name and minetest.get_player_by_name(name) then
			Coin(name, count, true)
			minetest.chat_send_all("Set " .. name .. "'s balance to " .. count .. " coins.")
		else
			minetest.chat_send_all("Invalid parameters")
		end
	end
})
