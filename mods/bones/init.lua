bones={
	enabled=minetest.settings:get_bool("xaenvironment_itemlosing") ==  true,
	corpses={},
	functions_add={},
	functions_drop={},
	functions_remove={},
}
minetest.register_privilege("bones", {
	description = "Don't droping bones",
	give_to_singleplayer = false,
})

minetest.register_node("bones:boneblock", {
	description = "Bone block",
	tiles={"bones_bone1.png","bones_bone3.png","bones_bone3.png","bones_bone3.png","bones_bone2.png","bones_bone3.png"},
	groups = {dig_immediate = 3,flammable=3},
	paramtype2="facedir",
	can_dig = function(pos, player)
		local owner = minetest.get_meta(pos):get_string("owner")
		return minetest.get_meta(pos):get_inventory():is_empty("main") and (owner == "" or owner == player:get_player_name())
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local m = minetest.get_meta(pos)
		if m:get_inventory():is_empty("main") then
			m:set_string("formspec","")
		end

	end,
	on_punch=function(pos, node, player,pointed_thing)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		local pinv = player:get_inventory()
		local main = inv:get_list("main")
		local owner = m:get_string("owner")
		if not main or owner ~= "" and owner ~= player:get_player_name() then
			return
		end
		for i,v in pairs(main) do
			if pinv:room_for_item("main",v) then
				pinv:add_item("main",v)
				inv:remove_item("main",v)
			elseif pinv:room_for_item("craft",v) then
				pinv:add_item("craft",v)
				inv:remove_item("main",v)
			else
				return
			end
		end
		if inv:is_empty("main") then
			m:set_string("formspec","")

		end
	end,
	on_timer=function(pos, elapsed)
		local m = minetest.get_meta(pos)
		if default.date("s",m:get_int("date")) >= 24 then
			m:set_string("infotext",m:get_string("owner").."'s old remains")
			m:set_string("owner","")
			return false
		end
		return true
	end,
})
minetest.register_craftitem("bones:bone", {
	description = "Bone",
	inventory_image = "bones_bone.png",
	wield_scale={x=2,y=2,z=2},
})

minetest.register_on_leaveplayer(function(player)
	bones.corpses[player:get_player_name()] = nil
end)

minetest.register_on_respawnplayer(function(player)
	bones.corpses[player:get_player_name()] = nil
end)

minetest.register_on_dieplayer(function(player)
	if bones.enabled then
		local name = player:get_player_name()

		if bones.corpses[name] or minetest.check_player_privs(name, {bones=true}) then
			return
		end
		bones.corpses[name] = true
		local pos = player:get_pos()
		local bpos
		if not minetest.is_protected(pos,name) then
			if default.defpos(pos,"buildable_to") then
				bpos = pos
			elseif minetest.find_node_near(pos,2,"air") then
				bpos = minetest.find_node_near(pos,2,"air")
			elseif minetest.get_item_group(pos,"dirt") > 0
			or minetest.get_item_group(pos,"stone") > 0
			or minetest.get_item_group(pos,"sand") > 0
			or minetest.get_item_group(pos,"snowy") > 0
			or minetest.get_node(pos).name == "default:ice" then
				bpos = pos
			end
		end
		local pinv = player:get_inventory()
		if bpos then
			minetest.set_node(bpos,{name="bones:boneblock"})
			local m = minetest.get_meta(bpos)
			local inv = m:get_inventory()

			inv:set_size("main", 45)
			m:set_string("formspec",
				"size[9,9]" ..
				"listcolors[#77777777;#777777aa;#000000ff]"..
				"list[context;main;0,0;9,5;]" ..
				"list[current_player;main;0.5,5.3;8,4;]" ..
				"listring[current_player;main]" ..
				"listring[current_name;main]"
			)
			for i,v in pairs(pinv:get_list("craft")) do
				inv:add_item("main",v)
			end
			for i,v in pairs(pinv:get_list("main")) do
				inv:add_item("main",v)
			end
			for i,v in pairs(bones.functions_add) do
				v(player,inv)
			end


			m:set_int("date",default.date("get"))

			m:set_string("owner",name)
			m:set_string("infotext",name.."'s remains")
			minetest.get_node_timer(bpos):start(10)
		else
			for i,v in pairs(pinv:get_list("craft")) do
				minetest.add_item(pos,v)
			end
			for i,v in pairs(pinv:get_list("main")) do
				minetest.add_item(pos,v)
			end
			for i,v in pairs(bones.functions_drop) do
				v(player,pos)
			end
		end

		for i,v in pairs(pinv:get_list("craft")) do
			pinv:remove_item("craft",v)
		end
		for i,v in pairs(pinv:get_list("main")) do
			pinv:remove_item("main",v)
		end
		for i,v in pairs(bones.functions_remove) do
			v(player)
		end
	end
end)