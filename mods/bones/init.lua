bones={
	enabled=minetest.settings:get_bool("xaenvironment_itemlosing") ==  true
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
		return minetest.get_meta(pos):get_inventory():is_empty("main")
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
		for i,v in pairs(inv:get_list("main")) do
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
	end
})
minetest.register_craftitem("bones:bone", {
	description = "Bone",
	inventory_image = "bones_bone.png",
	wield_scale={x=2,y=2,z=2},
})

minetest.register_on_dieplayer(function(player)
	if bones.enabled then
		local name = player:get_player_name()

		if minetest.check_player_privs(name, {bones=true}) then
			return
		end

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

			inv:set_size("main", 41)
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
		else
			for i,v in pairs(pinv:get_list("craft")) do
				minetest.add_item(pos,v)
			end
			for i,v in pairs(pinv:get_list("main")) do
				minetest.add_item(pos,v)
			end
		end

		for i,v in pairs(pinv:get_list("craft")) do
			pinv:remove_item("craft",v)
		end
		for i,v in pairs(pinv:get_list("main")) do
			pinv:remove_item("main",v)
		end
	end
end)