armor={
	types={chestplate=1,helmet=2,gloves=3,boots=4,leggings=5},
	user={},
	registered_items={}
}

player_style.register_button({
	name="armor",
	image="armor:iron_chestplate",
	type="item_image",
	info="Armor",
	action=function(user)
		armor.show(user)
	end
})


armor.show=function(player)
	local name = player:get_player_name()
	minetest.after(0.2, function(name)
		return minetest.show_formspec(name, "armor",
		"size[8,5]" ..
		"listcolors[#77777777;#777777aa;#000000ff]"..
		"list[detached:armor;main;1.5,0;5,1;]" ..
		"list[current_player;main;0,1.3;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[detached:armor;main]" ..
		"item_image[1.5,0;1,1;armor:iron_chestplate]" ..
		"item_image[2.5,0;1,1;armor:iron_helmet]" ..
		"item_image[3.5,0;1,1;armor:iron_gloves]" ..
		"item_image[4.5,0;1,1;armor:iron_boots]" ..
		"item_image[5.5,0;1,1;armor:iron_leggings]" .. 
		"label[0,-0.1;Level: "..(armor.user[name].armorlevel or 0).."]"
		)
	end, name)

end

armor.update=function(player,wear)
	local name = player:get_player_name()
	local data = armor.user[name]
	local inv = data.inv:get_list("main")
	local d = {}
	local arml = 0
	wear = wear or 0
	for i,v in pairs(inv) do
		local item = v:to_table()
		if wear > 0 and item.name ~= "" then
			item.wear = item.wear + (math.floor(wear*10/minetest.get_item_group(item.name,"level"))*10)
			if item.wear >= 65000 then
				item.name = ""
			end
			data.inv:set_stack("main",i,item)
		end
		arml = arml + (item and minetest.get_item_group(item.name,"level") or 0)
		table.insert(d,item)
	end

	player:get_meta():set_string("armor",minetest.serialize(d))
	data.playerlevel = data.playerlevel or player:get_armor_groups().fleshy
	armor.user[name].armorlevel = arml


	if player:get_armor_groups().fleshy ~= armor.user[name].playerlevel-arml then
		player:set_armor_groups({fleshy=data.playerlevel-arml})
		if not data.skin then
			data.skin = player:get_properties().textures[1]
		end
		local texture =data.skin
		for i,v in pairs(inv) do
			if v:get_name() ~= "" then
				texture = texture .. "^("..armor.registered_items[v:get_name()]..")"
			end
		end
		player:set_properties({textures={texture}})
	end
end

armor.register_item=function(name,def)
	if type(def.type) ~= "string" then
		error('Armor: declare a specific "type" : chestplate, helmet, gloves, boots, leggings, overall')
	elseif not armor.types[def.type] then
		error("Armor: invaild type ("..def.type..") : chestplate, helmet, gloves, boots, leggings, overall")
	elseif not def.image then
		error("Armor: declare a image")
	end
	local mod = minetest.get_current_modname() ..":"
	armor.registered_items[mod..name.."_"..def.type] =""..def.image.."^armor_alpha_"..def.type..".png^[makealpha:0,255,0"
	minetest.register_tool(mod..name.."_"..def.type, {
		description = def.description or name.upper(string.sub(name,1,1)) .. string.sub(name,2,string.len(name)).." "..def.type .." (level "..(def.level or 1)..")",
		inventory_image = def.image.."^armor_alpha_"..def.type.."_item.png^[makealpha:0,255,0",
		groups = {level=def.level or 1,armor=armor.types[def.type],weaknes=math.abs(math.floor(65000/(def.resistance or 100)))},
	})
	if def.item then
		local recipe = {
			chestplate={{def.item,"",def.item},{def.item,def.item,def.item},{def.item,def.item,def.item}},
			helmet={{def.item,def.item,def.item},{def.item,"",def.item}},
			leggings={{def.item,def.item,def.item},{def.item,"",def.item},{def.item,"",def.item}},
			boots={{def.item,"",def.item},{def.item,"",def.item}},
			gloves={{def.item,"",def.item}},
			overall={{def.item,def.item,def.item},{def.item,def.item,def.item},{def.item,"",def.item}},

		}
		minetest.register_craft({output=mod..name.."_"..def.type,recipe=recipe[def.type]})
	end
end

dofile(minetest.get_modpath("armor") .. "/items.lua")

table.insert(bones.functions_add,function(player,inv)
	local name = player:get_player_name()
	local ainv = armor.user[name].inv:get_list("main")
	for i,v in pairs(ainv) do
		inv:add_item("main",v)
	end
end)

table.insert(bones.functions_drop,function(player,pos)
	local name = player:get_player_name()
	local ainv = armor.user[name].inv:get_list("main")
	for i,v in pairs(ainv) do
		minetest.add_item(pos,v)
	end
end)

table.insert(bones.functions_remove,function(player)
	local ainv=armor.user[player:get_player_name()].inv
	for i,v in pairs(ainv:get_list("main")) do
		ainv:remove_item("main",v)
	end
	armor.update(player)
end)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	armor.update(player,tool_capabilities.damage_groups.fleshy or 1)
end)

minetest.register_on_player_hpchange(function(player,hp_change,modifer)
	if player and hp_change < 0 and (modifer.type == "node_damage" or modifer.type == "fall") then
		armor.update(player,hp_change*-1)
	end
	return hp_change
end,true)

minetest.register_on_leaveplayer(function(player)
	armor.user[player:get_player_name()] = nil
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	armor.user[name]={}
	armor.user[name].inv=minetest.create_detached_inventory("armor", {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
		allow_put = function(inv, listname, index, stack, player)
			return minetest.get_item_group(stack:get_name(),"armor") == index and stack:get_count() or 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
		on_put = function(inv, listname, index, stack, player)
			armor.update(player)
			armor.show(player)
		end,
		on_take = function(inv, listname, index, stack, player)
			armor.update(player)
			armor.show(player)
		end,
	})
	armor.user[name].inv:set_size("main", 5)
	local list = {}
	for i,v in pairs(minetest.deserialize(player:get_meta():get_string("armor") or "") or {}) do
		local g = minetest.get_item_group(v.name,"armor")
		if g > 0 then
			list[g] = ItemStack(v)
		end
	end
	armor.user[name].inv:set_list("main", list)
	armor.update(player)
end)