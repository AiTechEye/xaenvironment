player_style.register_button=function(def)
	local b = (def.type and (def.type .. "_button") or "button")
	.. (def.exit and "_exit" or "")
	.. "["..player_style.buttons.num..",7.2;1,1;"
	.. (((def.type == "image" or def.type == "item_image") and def.image and (def.image .. ";")) or "")
	.. def.name ..";"
	.. (def.label or "") .."]"
	..(def.info and ("tooltip["..def.name..";"..def.info.."]") or "")
	player_style.buttons.text = player_style.buttons.text .. b
	player_style.buttons.num = player_style.buttons.num + 1
	player_style.buttons.action[def.name]=def.action
end

player_style.inventory=function(player)
	local name = player:get_player_name()
	if not (player_style.creative or minetest.check_player_privs(name, {creative=true})) then
		player:set_inventory_formspec(
			"size[8,8]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."list[current_player;main;0,3;8,4;]"
			.."list[current_player;craft;4,0;3,3;]"
			.."list[current_player;craftpreview;7,1;1,1;]"
			.."listring[current_player;main]"
			.."listring[current_player;craft]"
			..player_style.buttons.text
		)
	else
		if not player_style.inventory_items then
			player_style.inventory_items={}
			for i,it in pairs(minetest.registered_items) do
				if not (it.groups and it.groups.not_in_creative_inventory) then
					table.insert(player_style.inventory_items,it.name)
				end
			end
			table.sort(player_style.inventory_items)

			minetest.create_detached_inventory("deleteslot", {
				on_put = function(inv, listname, index, stack, player)
					inv:set_stack("main",1,"")
				end
			}):set_size("main", 1)

		end

		player_style.players[name].inv = player_style.players[name].inv or {index=1,size=27}


		local itembutts = ""
		local invp=player_style.players[name].inv
		local x=8
		local y=0
		for i=invp.index,invp.index+invp.size do
			local it = player_style.inventory_items[i]
			if it then
				itembutts = itembutts.."item_image_button["..x..","..y..";1,1;"..it..";itembut_"..it..";]"
				x = x + 1
				if x >= 12 then
					y = y + 1
					x = 8
				end
			end
		end
		player:set_inventory_formspec(
			"size[12,8]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."list[current_player;main;0,3;8,4;]"
			.."list[current_player;craft;4,0;3,3;]"
			.."list[current_player;craftpreview;7,1;1,1;]"
			.."listring[current_player;main]"
			.."listring[current_player;craft]"
			..player_style.buttons.text
			.."image_button[8,7;1,1;default_crafting_arrowleft.png;creinvleft;]"
			.."image_button[9,7;1,1;default_crafting_arrowright.png;creinvright;]"
			.."image_button[10,7;1,1;synth_repeat.png;reset;]"
			.."image_button[11,7;1,1;default_bucket.png;clean;]"
			.."tooltip[creinvleft;Back]"
			.."tooltip[creinvright;Forward]"
			.."tooltip[reset;Reset]"
			.."tooltip[clean;Clean your inventory]"
			.."image[7,2;1,1;default_bucket.png]list[detached:deleteslot;main;7,2;1,1;]"
			..itembutts
		)



	end
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "" then

		for i,v in pairs(pressed) do
			if player_style.buttons.action[i] then
				player_style.buttons.action[i](player)
				return
			end
		end

		local name = player:get_player_name()
		local invp = player_style.players[name].inv
		if invp then
			if pressed.quit then
				player_style.players[name].inv.clean = nil
				return
			elseif pressed.creinvright and invp.index+invp.size < #player_style.inventory_items then
				invp.index = invp.index + invp.size
				player_style.inventory(player)
				return
			elseif pressed.creinvleft and invp.index > 1 then
				invp.index = invp.index - invp.size
				player_style.inventory(player)
				return
			elseif pressed.reset then
				invp.index = 1
				player_style.inventory(player)
				return
			elseif pressed.clean then
				if not invp.clean then
					minetest.chat_send_player(name,"Press again to clean you inventory")
					invp.clean = true
				else
					local inv = player:get_inventory()
					for i,v in pairs(inv:get_list("main")) do
						inv:set_stack("main",i,"")
					end
					player_style.players[name].inv.clean = nil
				end
			end
			for i,v in pairs(pressed) do
				if i:sub(1,8) == "itembut_" then
					local t = i:sub(9,-1)
					player:get_inventory():add_item("main",t.." "..minetest.registered_items[t].stack_max)
					return
				end
			end
		end
	end
end)