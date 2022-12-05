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
			elseif pressed.creinvright and store.index+store.size < (store.search and #store.search.items or #player_style.store_items) then
				store.index = store.index + store.size+1
				player_style.store(player)
				return
			elseif pressed.creinvleft and store.index > 1 then
				store.index = store.index - store.size-1
				player_style.store(player)
				return
			elseif pressed.reset then
				store.index = 1
				store.search = nil
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
				store.search={
					text = s,
					items = its
				}
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
								minetest.after(0.2, function(name,t)
									return minetest.show_formspec(name, "store",
									"size[3,2]" 
									.."listcolors[#77777777;#777777aa;#000000ff]"
									.."label[0,0;Sell item?\n(Worth: "..c..")]"
									.."button[0,1;1.5,1;confirm_"..t..";Sell]button[1.5,1;1.5,1;cancel;Cancel]"
									)end,name,t)
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
								minetest.after(0.2, function(name,t)
									return minetest.show_formspec(name, "store",
									"size[3,2]" 
									.."listcolors[#77777777;#777777aa;#000000ff]"
									.."label[0,0;Confirm purchase?\n(Cost: "..c..")]"
									.."button[0,1;1.5,1;confirm_"..t..";Buy]button[1.5,1;1.5,1;cancel;Cancel]"
									)end,name,t)
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
	end
end

player_style.store=function(player)
	local name = player:get_player_name()
	player_style.players[name].store = player_style.players[name].store or {size=63,index=1,sell=false}
	local store = player_style.players[name].store

	player_style.open_store()
		
	store.search = store.search and store.search.text ~= "" and store.search or nil

	local itemlist = store.search and store.search.items or player_style.store_items
	local pages = math.floor(#itemlist/player_style.players[name].store.size)
	local page = math.floor(player_style.players[name].store.index/player_style.players[name].store.size)
	local itembutts = ""
	local x=0
	local y=0

	for i=store.index,store.index+store.size do
		local it = itemlist[i]
		if it then
			local s
			if store.sell then
				local ss = player_style.store_items_cost[it]*0.1
				if ss >= 1 then
					s = math.floor(ss)
				end
			else
				s = player_style.store_items_cost[it]
			end

			if s then
				local def = minetest.registered_items[it]
				itembutts = itembutts.."item_image_button["..x..","..y..";1,1;"..it..";itembut_"..it..";]tooltip[itembut_"..it..";"..(def and def.description or it).."\n"..(store.sell and "Worth " or "Cost ")..s.."]"
				x = x + 0.8
				if x >= 6 then
					y = y + 0.8
					x = 0
				end
			end
		else
			break
		end
	end

	minetest.after(0.2, function(name,page,pages,store,itembutts)
		return minetest.show_formspec(name, "store",
			"size[6.7,8]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"

			.."tooltip[creinvleft;Back]"
			.."tooltip[creinvright;Forward]"
			.."tooltip[reset;Reset]"
			.."tooltip[search;Search]"
			.."tooltip[sell;"..(store.sell and "Buy" or "Sell").."]"

			.."image_button[0,7;1,1;default_crafting_arrowleft.png;creinvleft;]"
			.."image_button[0.8,7;1,1;default_crafting_arrowright.png;creinvright;]"
			.."image_button[1.6,7;1,1;synth_repeat.png;reset;]"
			.."image_button[2.4,7;1,1;player_style_coin.png;sell;]"

			
			.."label[0,-0.35;"..minetest.colorize("#FFFF00",Getcoin(player)).."]"

			.."label[7.6,9.9;"..page.."/"..pages.."]"
			.."field[4,7.3;3,1;searchbox;;"..(store.search and store.search.text or "").."]"
			.."field_close_on_enter[searchbox;false]"
			.."image_button[3.2,7.1;0.8,0.8;player_style_search.png;search;]"
			..itembutts
		)
	end,name,page,pages,store,itembutts)
end