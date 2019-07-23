if 1 then return end

-- this is just a test, its not really working yet


armor={
	bones=minetest.settings:get_bool("xaenvironment_itemlosing") ==  true,
	types={chestplate=1,gloves=2,boots=3,leggings=4,overall=5},
	user={},
	playerlevel=100,
}

player_style.register_button({
	name="armor",
	image="armor:chestplate",
	type="item_image",
	info="Armor",
	action=function(user)
		local name = user:get_player_name()
		minetest.after(0.2, function(name)
		return minetest.show_formspec(name, "exaachievements",
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
	local inv = armor.user[name]:get_list("main")
	local d = {}
	local arml = 0
	wear = wear or 0
	for i,v in pairs(inv) do
		v:add_wear(wear*minetest.get_item_group(v:get_name(),"weaknes"))
		arml = arml + minetest.get_item_group(v:get_name(),"level")
		table.insert(d,v:to_table())
	end
	player:get_meta():set_string("armor",minetest.serialize(d))

	if player:get_armor_groups() ~= armor.playerlevel+arml then
		player:set_armor_groups({flashy=armor.playerlevel+arml})
	end
end

armor.register_item=function(name,def)
	if type(def.type) ~= "string" then
		error('Armor: declare a specific "type" : chestplate, gloves, boots, leggings, overall')
	elseif not armor.types[def.type] then
		error("Armor: invaild type ("..def.type..") : chestplate, gloves, boots, leggings, overall")
	elseif not def.image then
		error("Armor: declare a image")
	end
	local mod = minetest.get_current_modname() ..":"

	minetest.register_tool(mod..name, {
		description=def.description or string.gsub(name,"_"," "),
		wield_image="[combine:16x16:0,0:"..def.image.."^armor_alpha_chestplate.png^[makealpha:0,255,0",
		groups = {level=def.level or 1,armor=armor.types[def.type],weaknes=math.abs(math.floor(65000/(def.resistance or 100)))},
	})

	if def.item and def.type == "chestplate" then
		minetest.register_craft({
			output=mod..name,
			recipe={
				{def.item,"",def.item},
				{def.item,def.item,def.item},
				{def.item,def.item,def.item},
			}
		})
	end
end

dofile(minetest.get_modpath("armor") .. "/items.lua")

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	armor.update(player,tool_capabilities.damage_groups.fleshy or 1)
end)
--[[
minetest.register_on_player_hpchange(function(player,hp_change,modifer)
	if player then
		armor.update(player,hp_change)
	end
	return hp_change
end,true)
--]]
minetest.register_on_joinplayer(function(user)
	local name = user:get_player_name()
	armor.user[name]=minetest.create_detached_inventory("armor", {
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
	})
	armor.user[name]:set_size("main", 6)
	local list = {}
	for i,v in pairs(minetest.deserialize(user:get_meta():get_string("armor") or "") or {}) do
		table.insert(list,ItemStack(v))
	end
	armor.user[name]:set_list("main", list)
end)

table.insert(bones.functions_add,function(player,inv)
	local name = player:get_player_name()
	local ainv = armor.user[name]:get_list("main")
	for i,v in pairs(ainv) do
		inv:add_item("main",v)
	end
end)

table.insert(bones.functions_drop,function(player,pos)
	local name = player:get_player_name()
	local ainv = armor.user[name]:get_list("main")
	for i,v in pairs(ainv) do
		minetest.add_item(pos,v)
	end
end)

table.insert(bones.functions_remove,function(player)
	local ainv=armor.user[player:get_player_name()]
	for i,v in pairs(ainv:get_list("main")) do
		ainv:remove_item("main",v)
	end
	armor.update(player)
end)