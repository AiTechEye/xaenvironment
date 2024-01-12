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
			elseif pressed.amount then
				local c = tonumber(pressed.amount) or 1
				local c2 = c
				c = c >= 1 and c or 1
				c = c <= 99 and c or 99
				store.amount = c
				if c2 < 1 or c2 > 99 then
					store.too_high_amount = true
					store.amount = c2
					minetest.after(0.5, function()
						if minetest.get_player_by_name(name) then
							store.too_high_amount = nil
							store.amount = c
							player_style.store(player)
						end
					end)
					player_style.store(player)
					return
				end
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
						local c = math.ceil(player_style.store_items_cost[t]*0.1)
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
						local room = inv:room_for_item("main",t.." "..store.amount)
						if Getcoin(player) >= c*store.amount and room then
							if b ~= "confirm_" and c*store.amount >= 1000 then
								minetest.show_formspec(name, "store",
									"size[3,2]" 
									.."listcolors[#77777777;#777777aa;#000000ff]"
									.."label[0,0;Confirm purchase?\nCost: "..(c*store.amount).."\n("..c.."x"..store.amount..")]"
									.."button[0,1;1.5,1;confirm_"..t..";Buy]button[1.5,1;1.5,1;cancel;Cancel]"
								)
								return
							end
							inv:add_item("main",t.." "..store.amount)
							Coin(player,-c*store.amount)
							minetest.sound_play("default_lose_coins", {to_player=name, gain = 2})
							player_style.store(player)
							return
						elseif Getcoin(player) < c*store.amount and Getcoin(player) >= c then
							store.too_high_amount = true
							minetest.after(0.5, function()
								if minetest.get_player_by_name(name) then
									store.too_high_amount = nil
									player_style.store(player)
								end
							end)
							player_style.store(player)
							return
						elseif not room then
							store.no_room = true
							minetest.after(0.5, function()
								if minetest.get_player_by_name(name) then
									store.no_room = nil
									player_style.store(player)
								end
							end)
							player_style.store(player)
							return
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
	end
end

player_style.store=function(player)
	local name = player:get_player_name()
	local coins = Getcoin(name)
	local inv = minetest.get_inventory({type = "player",name = name})
	player_style.players[name].store = player_style.players[name].store or {index = 1, sell = false,amount=1}
	local store = player_style.players[name].store

	player_style.open_store()

	store.items = store.items or player_style.store_items

	local item_list = store.items
	local pages = math.ceil(#item_list / ITEMS_PER_PAGE)
	local page = math.ceil(store.index / ITEMS_PER_PAGE)
	local item_buttons = "style_type[item_image_button;bgcolor=#0F0F]"

	local screen_index = -1
	local _end = math.min(store.index + ITEMS_PER_PAGE - 1, #item_list)
	for i = store.index, _end do
		local item = item_list[i]

		local value = player_style.store_items_cost[item]
		value = store.sell and math.ceil(value*0.1) or value
		screen_index = screen_index + 1
		local x = 0.2 + screen_index % 8 * 2
		local y = 2 + math.floor(screen_index / 8) * 2
		local def = minetest.registered_items[item]
		local val = store.sell and "\nWorth: " .. minetest.colorize("#FFFF00", value) or "\nCost: " .. minetest.colorize("#FFFF00", value)

		if not store.sell and value <= coins or store.sell and inv:contains_item("main", item) then
			item_buttons = item_buttons
				.. "item_image_button[" .. x .. "," .. y .. ";2,2;" .. item .. ";itembut_" .. item ..";" .. value .. "]"
				.. "tooltip[itembut_" .. item .. ";" .. (def and def.description or item) .. val .. ";#555;#FFF]"
		else
			local tool_tip = store.sell and "\nNot in your inventory"
				or "\nYou can't afford this (need " .. minetest.colorize("#FFFF00", value - coins) .. " more coins)"
			
			item_buttons = item_buttons
				.. "item_image[" .. x .. "," .. y .. ";2,2;" .. item .. "]"
				.. "label[" .. x + 0.2 .. "," .. y + 1 .. ";" .. value .. "]"
				.. "tooltip[" .. x .. "," .. y .. ";2,2;" .. (def and def.description or item) .. val .. tool_tip .. ";#555;#FFF]"
		end
	end

	minetest.after(0.2, function()
		if not player:get_look_horizontal() then return end
		minetest.show_formspec(name, "store",
			"formspec_version[2]" -- MT 5.1+
			.. "size[16.4,12.2]"
			.. "bgcolor[#"..(store.no_room and "F00F" or "555F").."]"

			.. "button[0.2,0.5;5,1;sell;Switch to " .. (store.sell and "buying" or "selling") .. "]"

			.. "style_type[label;font_size=+5]"
			.. "label[7.5,0.5;" .. (store.sell and "Sell" or "Buy") .. "]"
			.. "style_type[label;font_size=]"

			.. "label[11.6,0.5;Coins: " .. minetest.colorize("#FFFF00", coins) .. "]"

			.. "tooltip[creinvleft;Back]"
			.. "image_button[6,1;0.8,0.8;default_crafting_arrowleft.png;creinvleft;]"

			.. "label[7,1.4;" .. page .. "/" .. pages .. "]"

			.. "tooltip[creinvright;Forward]"
			.. "image_button[8,1;0.8,0.8;default_crafting_arrowright.png;creinvright;]"

			.. (not store.sell and  "style[amount;textcolor=#"..(store.too_high_amount and "f00" or "fff").."]field[9,1;2,0.8;amount;Amount;" .. store.amount .. "]" or "")

			.. "field[11.6,1;3,0.8;searchbox;;" .. (store.search_text or "") .. "]"
			.. "field_close_on_enter[searchbox;false]"

			.. "tooltip[search;Search]"
			.. "image_button[14.6,1;0.8,0.8;player_style_search.png;search;]"

			.. "tooltip[reset;Reset search]"
			.. "image_button[15.4,1;0.8,0.8;synth_repeat.png;reset;]"

			.. item_buttons
		)
	end)
end

minetest.register_chatcommand("set_coins", {
	params = "<name> <coins amount>",
	description = "Set the player's coins to the number specified",
	privs = { debug = true },
	func = function(name, param)
		local name, count = string.match(param, "(%w+) (%d*)")
		local player
		if count then count = tonumber(count) end
		if count and name and minetest.get_player_by_name(name) then
			Coin(name, count, true)
			return true,"Set " .. name .. "'s coins to " .. count .. " coins."
		else
			return false,"Invalid parameters"
		end
	end
})