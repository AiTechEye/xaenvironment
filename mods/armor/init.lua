if 1 then return end

not ready yet

armor={
	types={chestplate=1,helmet=2,gloves=3,boots=4,leggings=5,overall=6},
	user={},
	registered_items={}
}

player_style.register_button({
	name="armor",
	image="armor:iron_chestplate",
	type="item_image",
	info="Armor",
	action=function(user)
		local name = user:get_player_name()
		minetest.after(0.2, function(name)
		return minetest.show_formspec(name, "armor",
			"size[8,6]" ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"list[detached:armor;main;2.5,0;3,2;]" ..
			"list[current_player;main;0,2.3;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[detached:armor;main]"
			)
		end, name)
	end
})

armor.update=function(player,wear)
	local name = player:get_player_name()
	local data = armor.user[name]
	local inv = data.inv:get_list("main")
	local d = {}
	local arml = 0
	wear = wear or 0
	for i,v in pairs(inv) do
		v:add_wear(wear*minetest.get_item_group(v:get_name(),"weaknes"))
		arml = arml + minetest.get_item_group(v:get_name(),"level")
		table.insert(d,v:to_table())
	end
	player:get_meta():set_string("armor",minetest.serialize(d))

	data.playerlevel = data.playerlevel or player:get_armor_groups().fleshy

	if player:get_armor_groups() ~= armor.user[name].playerlevel+arml then
		player:set_armor_groups({fleshy=data.playerlevel+arml})
		if not data.skin then
			data.skin = player:get_properties().textures[1]
		end
		local texture = data.skin
		local t
		for i,v in pairs(inv) do
			
			if v:get_name() ~= "" then
				t = true
				texture = texture .. "^"..armor.registered_items[v:get_name()]
			end
		end
		if t then
			player:set_properties({textures={texture}})
		end
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
	local texture = "([combine:64x32:"

	for i=0,64,16 do
		texture =  texture ..":0,"..i.."="..def.image ..":16,"..i.."="..def.image
	end

	armor.registered_items[mod..name.."_"..def.type] = texture .. "^armor_alpha_"..def.type..".png^[makealpha:0,255,0)"

	minetest.register_tool(mod..name.."_"..def.type, {
		description=def.description or name.upper(string.sub(name,1,1)) .. string.sub(name,2,string.len(name)).." "..def.type,
		inventory_image=def.image.."^armor_alpha_"..def.type.."_item.png^[makealpha:0,255,0",
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
	if player then
		armor.update(player,hp_change)
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
			return count
		end,
		allow_put = function(inv, listname, index, stack, player)
			return minetest.get_item_group(stack:get_name(),"armor") > 0 and stack:get_count() or 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
		on_put = function(inv, listname, index, stack, player)
			armor.update(player)
		end,
		on_take = function(inv, listname, index, stack, player)
			armor.update(player)
		end,
	})
	armor.user[name].inv:set_size("main", 6)
	local list = {}
	for i,v in pairs(minetest.deserialize(player:get_meta():get_string("armor") or "") or {}) do
		table.insert(list,ItemStack(v))
	end
	armor.user[name].inv:set_list("main", list)
	armor.update(player)
end)