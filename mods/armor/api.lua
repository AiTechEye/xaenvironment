armor={
	types={chestplate=1,helmet=2,gloves=3,boots=4,leggings=5,shield=6},
	user={},
	registered_items={},
	gloves_properties={
		type = "none",
		wield_scale={x=1,y=1,z=2},
		groups={not_in_creative_inventory=1},
		range = not default.creative and 4 or 15,
		tool_capabilities = not default.creative and {
			full_punch_interval = 1,
			max_drop_level = 0,
			groupcaps={
				crumbly = {times={[2]=3, [3]=0.7}, uses=0, maxlevel=1},
				snappy = {times={[2]=2,[3]=0.7}, uses=0, maxlevel=1},
				oddly_breakable_by_hand = {times={[1]=5,[2]=4,[3]=3}, uses=0},
				dig_immediate={times={[1]=2,[2]=1,[3]=0}, uses=0}
			},
			damage_groups = {fleshy=1},
		} or {
			full_punch_interval = 0.1,
			max_drop_level = 0,
			groupcaps = {
				fleshy={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
				choppy={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
				bendy={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
				cracky={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
				crumbly={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
				snappy={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
				dig_immediate={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
			},
			damage_groups={fleshy=10},
		}
	}
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
	local skin = minetest.formspec_escape(player:get_properties().textures[1] or "character.png")
	minetest.after(0.2, function(name,skin)
		return minetest.show_formspec(name, "armor",
		"size[8,6]" ..
		"listcolors[#77777777;#777777aa;#000000ff]"..
		"list[detached:armor;main;2,0.5;6,1;]" ..
		"list[current_player;main;0,2.3;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[detached:armor;main]" ..
		"item_image[2,0.5;1,1;armor:iron_chestplate]" ..
		"item_image[3,0.5;1,1;armor:iron_helmet]" ..
		"item_image[4,0.5;1,1;armor:iron_gloves]" ..
		"item_image[5,0.5;1,1;armor:iron_boots]" ..
		"item_image[6,0.5;1,1;armor:iron_leggings]" .. 
		"item_image[7,0.5;1,1;armor:iron_shield]" ..
		"label[2,-0.2;Level: "..(armor.user[name].armorlevel or 0).."]" ..
		"model[-0.5,-0.2;3,3;character_preview;character.b3d;"..skin..";0,180;false;true;1,31]"
		)
	end, name,skin)
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
		if item and wear > 0 and item.name ~= "" then
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
		local texture = ""
		local c = ""
		for i,v in ipairs(inv) do
			if v:get_name() ~= "" and i < 6 then
				texture = texture .. c .."("..armor.registered_items[v:get_name()]..")"
				c = "^"
			elseif i == 6 then
				data.shield = data.shield or {}
				if data.shield.item ~= v:get_name() then
					local ob
					data.shield.item = v:get_name()
					if data.shield.object and data.shield.object:get_luaentity() then
						data.shield.object:remove()
					end
					data.shield.object = nil

					if data.shield.hud then
						player:hud_remove(data.shield.hud)
						data.shield.hud = nil
					end

					if v:get_name() ~= "" then
						ob = minetest.add_entity(player:get_pos(),"default:wielditem")
						data.shield.object = ob
						ob:set_attach(player, "larm2",{x=0, y=0, z=2}, {x=170, y=0,z=-20},true)
						ob:set_properties({textures={v:get_name()},visual_size = {x=0.4,y=0.4}})
					end
				end
			end
			if i == 3 then
				local def = default.def(v:get_name())
				player:get_inventory():set_size("hand",1)
				player:get_inventory():set_stack("hand",1,ItemStack(def.armor_hand))
			end
		end
		player_style.remove_player_skin(player,data.texture,2)
		player_style.add_player_skin(player,texture,2)
		data.texture = texture
	end
end

armor.register_item=function(name,def)
	if type(def.type) ~= "string" then
		error('Armor: declare a specific "type" : chestplate, helmet, gloves, boots, leggings, shield')
	elseif not armor.types[def.type] then
		error("Armor: invaild type ("..def.type..") : chestplate, helmet, gloves, boots, leggings, shield")
	elseif not def.image then
		error("Armor: declare a image")
	end

	def.groups = def.groups or {}
	def.groups.level=def.level or 1
	def.groups.armor=armor.types[def.type]
	def.item_image = def.item_image or def.image.."^armor_alpha_"..def.type.."_item.png^[makealpha:0,255,0"
	def.armor_image = def.type == "shield" and def.item_image or (def.armor_image or def.image.."^armor_alpha_"..def.type..".png^[makealpha:0,255,0")
	local mod = minetest.get_current_modname() ..":"

	armor.registered_items[mod..name.."_"..def.type] = def.armor_image
	minetest.register_tool(mod..name.."_"..def.type, {
		description = def.description or name.upper(string.sub(name,1,1)) .. string.sub(name,2,string.len(name)).." "..def.type .." (level "..(def.level or 1)..")",
		inventory_image = def.item_image,
		groups = def.groups,
		armor_type = name,
		armor_hand = def.type == "gloves" and mod..name.."_hand" or nil,
	})

	if def.type == "gloves" then
		local hand = table.copy(armor.gloves_properties)
		hand.tool_capabilities.damage_groups.fleshy = def.hand_damage or 1
		hand.wield_image = def.hand_image or def.image.."^armor_alpha_hand.png^[makealpha:0,255,0"
		hand.on_secondary_use = def.on_secondary_use
		minetest.register_item(mod..name.."_hand", hand)
	end

	if def.item then
		local recipe = {
			chestplate={{def.item,"",def.item},{def.item,def.item,def.item},{def.item,def.item,def.item}},
			helmet={{def.item,def.item,def.item},{def.item,"",def.item}},
			leggings={{def.item,def.item,def.item},{def.item,"",def.item},{def.item,"",def.item}},
			boots={{def.item,"",def.item},{def.item,"",def.item}},
			gloves={{def.item,"",def.item}},
			shield={{def.item,def.item,def.item},{def.item,def.item,def.item},{"",def.item,""}},
		}
		minetest.register_craft({output=mod..name.."_"..def.type,recipe=recipe[def.type]})
	end
end

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
	if player and hp_change < 0 and not (modifer.type == "node_damage" and minetest.get_item_group(modifer.node,"igniter") > 0) then
		hp_change = special.use_ability(player,"immortal",hp_change)
		if hp_change < 0 then
			armor.update(player,hp_change*-1)
		end
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
			player_style.inventory(player)
		end,
		on_take = function(inv, listname, index, stack, player)
			armor.update(player)
			armor.show(player)
			player_style.inventory(player)
		end,
	})
	armor.user[name].inv:set_size("main", 6)
	local list = {}
	for i,v in pairs(minetest.deserialize(player:get_meta():get_string("armor") or "") or {}) do
		local g = minetest.get_item_group(v.name,"armor")
		if g > 0 then
			list[g] = ItemStack(v)
		end
	end
	armor.user[name].inv:set_list("main", list)
	armor.user[name].texture = ""
	minetest.after(0, function(player)
		armor.update(player)
	end,player)
end)

armor.register_group=function(name,texture,item,level)
	for i,v in pairs(armor.types) do
		local def = {
			type=i,
			image=texture,
			level=level,
			item=item,
			groups={treasure=3},
		}
		if v == 3 then
			def.level = math.floor(level/3)
			def.hand_damage = math.floor(level/4)
		end
		armor.register_item(name,def)
	end
end