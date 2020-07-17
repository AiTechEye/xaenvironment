player_style.register_button({
	name="Store",
	image="player_style_coin.png",
	type="image",
	info="Store",
	action=function(player)
		player_style.store(player)
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
			elseif pressed.search then
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
			if store.sell then
				for i,v in pairs(pressed) do
					if i:sub(1,8) == "itembut_" then
						local t = i:sub(9,-1)
						local m = player:get_meta()
						local inv = player:get_inventory()
						local s = i:sub(9,-1)
						if inv:contains_item("main",s) then
							inv:remove_item("main",ItemStack(s.." 1"))
							m:set_int("coins",m:get_int("coins")+math.floor(player_style.store_items_cost[t]*0.01))
							player_style.store(player)
						end
					end
				end
			else
				for i,v in pairs(pressed) do
					if i:sub(1,8) == "itembut_" then
						local t = i:sub(9,-1)
						local m = player:get_meta()
						local inv = player:get_inventory()
						if m:get_int("coins") >= player_style.store_items_cost[t] and inv:room_for_item("main",t) then
							inv:add_item("main",t.." 1")
							m:set_int("coins",m:get_int("coins")-player_style.store_items_cost[t])
							player_style.store(player)
						end
					end
				end
			end
		end
	end
end)

player_style.store=function(player)
	local name = player:get_player_name()
	player_style.players[name].store = player_style.players[name].store or {size=63,index=1,sell=false}
	local store = player_style.players[name].store

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
				local ss = player_style.store_items_cost[it]*0.01
				if ss >= 1 then
					s = math.floor(ss)
				end
			else
				s = player_style.store_items_cost[it]
			end

			if s then
				itembutts = itembutts.."item_image_button["..x..","..y..";1,1;"..it..";itembut_"..it..";\n"..s.."]"
				x = x + 0.8
				if x >= 6 then
					y = y + 0.8
					x = 0
				end
			end
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

			
			.."label[0,-0.35;"..minetest.colorize("#FFFF00",player:get_meta():get_int("coins")).."]"

			.."label[7.6,9.9;"..page.."/"..pages.."]"
			.."field[4,7.3;3,1;searchbox;;"..(store.search and store.search.text or "").."]"
			.."image_button[3.2,7.1;0.8,0.8;;search;]"
			..itembutts
		)
	end,name,page,pages,store,itembutts)
end