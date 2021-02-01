minetest.register_tool("player_style:bottle", {
	description = "Liquid storable bottle",
	liquids_pointable = true,
	groups = {treasure=1},
	inventory_image = "materials_plant_extracts_gas.png^[invert:b^materials_plant_extracts.png",
	on_use=function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		local max = 65535
		wear = wear ~= 0 and wear or max
		if pointed_thing.under and player_style.drinkable(pointed_thing.under,user) and wear > 1 then
			wear=math.floor(wear-(max/5))
		elseif wear < max then
			wear=math.floor(wear+(max/5))
			player_style.thirst(user,1)
		end
		if wear > max then
			wear = max
		elseif wear < 1 then
			wear = 1
		end
		itemstack:set_wear(wear)
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		if not minetest.is_protected(pointed_thing.above,user:get_player_name()) and default.defpos(pointed_thing.above,"buildable_to") then
			if wear == 65535 then
				minetest.add_node(pointed_thing.above,{name="materials:glass_bottle"})
				itemstack:take_item()
			elseif wear == 1 then
				minetest.add_node(pointed_thing.above,{name="player_style:glass_bottle_water"})
				itemstack:take_item()
			end
		end
		return itemstack
	end
})

minetest.register_craft({
	output="player_style:bottle 1 65535",
	recipe={{"materials:glass_bottle"}},
})

minetest.register_node("player_style:glass_bottle_water", {
	description = "Bottle with water",
	drop = "player_style:bottle 1 1",
	tiles={"materials_plant_extracts_gas.png^[invert:b^materials_plant_extracts.png"},
	inventory_image = "materials_plant_extracts_gas.png^[invert:b^materials_plant_extracts.png",
	drawtype = "plantlike",
	groups = {dig_immediate = 3,used_by_npc=1,not_in_craftguide=1,treasure=1},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
})

minetest.register_tool("player_style:matel_bottle", {
	description = "Liquid storable metal bottle",
	liquids_pointable = true,
	inventory_image = "materials_metal_bottle.png",
	groups = {treasure=2},
	on_use=function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		local max = 65535
		wear = wear ~= 0 and wear or max
		if pointed_thing.under and player_style.drinkable(pointed_thing.under,user) and wear > 1 then
			wear=math.floor(wear-(max/20))
		elseif wear < max then
			wear=math.floor(wear+(max/20))
			player_style.thirst(user,1)
		end
		if wear > max then
			wear = max
		elseif wear < 1 then
			wear = 1
		end
		itemstack:set_wear(wear)
		return itemstack
	end,
})

minetest.register_craft({
	output="player_style:matel_bottle",
	recipe={
		{"","default:iron_ingot",""},
		{"default:iron_ingot","","default:iron_ingot"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
	},
})

minetest.register_node("player_style:edgehook", {
	drawtype = "airlike",
	drop = "",
	liquid_viscosity = 3,
	pointable= false,
	liquidtype = "source",
	liquid_alternative_flowing="player_style:edgehook",
	liquid_alternative_source="player_style:edgehook",
	liquid_renewable = false,
	liquid_range = 0,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {not_in_creative_inventory=1,climbalespace=1},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.1)
	end,
	on_timer = function (pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do
			if ob:is_player() then
				local key=ob:get_player_control()
				if key.jump and key.down then
					local d = ob:get_look_dir()
					ob:add_player_velocity({x=d.x*7,y=2,z=d.z*7})
					break
				else
					return true
				end
			end
		end
		minetest.remove_node(pos)
		default.update_nodes(pos)
	end
})

minetest.register_node("player_style:edgehook2", {
	drawtype = "airlike",
	drop = "",
	liquid_viscosity = 3,
	pointable= false,
	liquidtype = "source",
	drowning = 1,
	liquid_alternative_flowing="player_style:edgehook2",
	liquid_alternative_source="player_style:edgehook2",
	liquid_renewable = false,
	liquid_range = 0,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {not_in_creative_inventory=1,climbalespace=1},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.1)
	end,
	on_timer = function (pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do
			if ob:is_player() then
				local key=ob:get_player_control()
				if key.jump and key.down then
					local d = ob:get_look_dir()
					ob:add_player_velocity({x=d.x*7,y=2,z=d.z*7})
					break
				else
					return true
				end
			end
		end
		minetest.remove_node(pos)
		default.update_nodes(pos)
	end
})

minetest.register_tool("player_style:backpack", {
	description = "Backpack",
	inventory_image = "player_style_backpack.png",
	wield_scale={x=2,y=2,z=3},
	groups={treasure=1,backpack=2,flammable=1,store=500},
})
minetest.register_craft({
	output="player_style:backpack",
	recipe={
		{"materials:string","examobs:pelt","materials:string"},
		{"examobs:pelt","materials:piece_of_cloth","examobs:pelt"},
		{"examobs:pelt","examobs:pelt","examobs:pelt"},
	},
})

minetest.register_craftitem("player_style:coin", {
	description = "Coin",
	stack_max = 10000,
	inventory_image = "player_style_coin.png",
	groups = {treasure=1,coin=1,store=1},
	on_use=function(itemstack, user, pointed_thing)
		Coin(user,itemstack:get_count())
		itemstack:clear()
		return itemstack
	end
})



minetest.register_on_cheat(function(ob,cheat)
	if cheat.type == "interacted_too_far" then
		local np = minetest.find_node_near(ob:get_pos(),5,"player_style:top_hat_upside_down")
		if np then
			return ob
		end
	end
end)



minetest.register_craft({
	output="player_style:top_hat",
	recipe={
		{"","materials:piece_of_cloth",""},
		{"","exatec:tube_teleport",""},
		{"materials:piece_of_cloth","materials:piece_of_cloth","materials:piece_of_cloth"},
	},
})

minetest.register_node("player_style:top_hat", {
	description = "Top hat (use on blocks/chests ... teleports items/players/objects)",
	stack_max = 1,
	tiles = {"default_coalblock.png^[colorize:#000000aa"},
	use_texture_alpha = true,
	groups = {dig_immediate = 3,flammable=3,hat=1,fall_damage_add_percent=-100,store=1000},
	hat_properties={pos={x=0, y=7, z=0}, rotation={x=0,y=90,z=0},size={x=0.5,y=0.5,z=0.5}},
	after_place_node=function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local meta2 = itemstack:get_meta()
		meta:set_string("inputlist",meta2:get_string("inputlist"))
		local pos1 = meta2:get_string("pos1")
		local pos2 = meta2:get_string("pos2")
		meta:set_string("pos1",pos1)
		meta:set_string("pos2",pos2)
		meta:set_int("size",meta2:get_int("size"))
		meta:set_string("description",meta2:get_string("description"))
		if pos2 ~= "" then
			minetest.swap_node(pos,{name="player_style:top_hat_upside_down"})
			minetest.get_node_timer(pos):start(0.2)
			if pos1 ~= "" then
				meta:get_inventory():set_size("main", meta:get_int("size"))
				local npos = minetest.string_to_pos(pos1)
				minetest.forceload_block(npos)
				local nmeta = minetest.get_meta(npos)
				meta:get_inventory():set_list("main",nmeta:get_inventory():get_list(meta:get_string("inputlist")))

				meta:set_string("formspec",
					"size[8,8]" ..
					"listcolors[#77777777;#777777aa;#000000ff]" ..
					"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
					"list[current_player;main;0,4.2;8,4;]" ..
					"listring[current_player;main]" ..
					"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
				)
			end
		end
	end,
	on_use=function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if pointed_thing.type ~= "node" or minetest.is_protected(pointed_thing.above,name) or minetest.is_protected(pointed_thing.under,name) then
			return itemstack
		end
		local meta = itemstack:get_meta()
		
		meta:set_string("pos2",minetest.pos_to_string(pointed_thing.above))
		if exatec.test_input(pointed_thing.under,ItemStack("default:unknown"),pointed_thing.under,pointed_thing.under) then
			local inputlist = exatec.def(pointed_thing.under).input_list or ""
			local inv = minetest.get_meta(pointed_thing.under):get_inventory()
			local size = inv and inv:get_size(inputlist) or 0
			if size > 0 and size <= 32 and inputlist ~= "" then
				meta:set_string("pos1",minetest.pos_to_string(pointed_thing.under))
				meta:set_string("inputlist",inputlist)
				meta:set_int("size",size)
				local r = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
				local d = r and r.description and ("("..r.description..") ") or ""
				meta:set_string("description","Top hat "..d.. minetest.pos_to_string(pointed_thing.under).." "..minetest.pos_to_string(pointed_thing.above))
			end
		else
			meta:set_string("pos1","")
			meta:set_string("description","Top hat ".. minetest.pos_to_string(pointed_thing.above))
		end
		return itemstack
	end,
	drawtype="nodebox",
	node_box ={
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375},
			{-0.22, -0.4375, -0.22, 0.22, 0.0625, 0.22}
		}
	}
})

minetest.register_node("player_style:top_hat_upside_down", {
	description = "Top hat",
	stack_max = 1,
	tiles = {"default_coalblock.png^[colorize:#000000aa"},
	use_texture_alpha = true,
	groups = {dig_immediate = 3,flammable=3,not_in_creative_inventory=1,fall_damage_add_percent=-100},
	drawtype="nodebox",
	node_box ={
		type = "fixed",
		fixed = {
			{-0.375, 0, -0.375, 0.375, -0.0375, 0.375},
			{-0.22, -0.0375, -0.22, 0.22, -0.5, 0.22}
		}
	},
	on_timer = function(pos, elapsed)
		local pos2
		local meta = minetest.get_meta(pos)
		for i, ob in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
			if not default.is_decoration(ob,true) then
				pos2 = pos2 or minetest.string_to_pos(meta:get_string("pos2"))
				if ob:is_player() then
					minetest.sound_play("default_pipe", {to_player=ob:get_player_name(), gain = 2, max_hear_distance = 10})
				end
				minetest.sound_play("default_pipe", {pos=pos, gain = 2, max_hear_distance = 10})
				ob:set_pos(pos2)
			end
		end
		minetest.registered_nodes["player_style:top_hat_upside_down"].on_rightclick(pos)
		return true
	end,
	on_rightclick = function(pos, _, player)
		local meta = minetest.get_meta(pos)
		local npos = minetest.string_to_pos(meta:get_string("pos1"))
		if not npos then
			return
		end
		minetest.forceload_block(npos)
		local nmeta = minetest.get_meta(npos)
		meta:get_inventory():set_list("main",nmeta:get_inventory():get_list(meta:get_string("inputlist")))

		meta:set_string("formspec",
			"size[8,8]" ..
			"listcolors[#77777777;#777777aa;#000000ff]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
			"list[current_player;main;0,4.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
		--local name = player:get_player_name()
		--minetest.show_formspec(name, "default.tophat",
		--	"size[8,8]" ..
		--	"listcolors[#77777777;#777777aa;#000000ff]" ..
		--	"list[nodemeta:" .. npos.x .. "," .. npos.y .. "," .. npos.z  .. ";main;0,0;8,4;]" ..
		--	"list[current_player;main;0,4.2;8,4;]" ..
		--	"listring[current_player;main]" ..
		--	"listring[nodemeta:" .. npos.x .. "," .. npos.y .. "," .. npos.z  .. ";main]"
		--)
	end,
	on_item_stand_on=function(pos,object)
		local meta = minetest.get_meta(pos)
		local pos1 = minetest.string_to_pos(meta:get_string("pos1"))
		local pos2 = minetest.string_to_pos(meta:get_string("pos2"))
		local item = ItemStack(object:get_luaentity().itemstring)
		minetest.sound_play("default_pipe", {pos=pos, gain = 2, max_hear_distance = 10})
		if pos1 and exatec.test_input(pos1,item,pos1,pos1) then
			exatec.input(pos1,item,pos1,pos1)
			object:remove()
		elseif pos2 then
			object:set_pos(pos2)
		end
	end,
	on_punch=function(pos, node, puncher,pounted_thing)
		if minetest.is_protected(pos,puncher:get_player_name()) then
			return itemstack
		end
		local meta2 = minetest.get_meta(pos)
		local itemstack = ItemStack("player_style:top_hat")
		local meta = itemstack:get_meta()

		meta:set_string("inputlist",meta2:get_string("inputlist"))
		meta:set_string("pos1",meta2:get_string("pos1"))
		meta:set_int("size",meta2:get_int("size"))
		meta:set_string("pos2",meta2:get_string("pos2"))
		meta:set_string("description",meta2:get_string("description"))
		puncher:get_inventory():add_item("main",itemstack)
		minetest.remove_node(pos)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local npos = minetest.string_to_pos(meta:get_string("pos1"))
		local nmeta = minetest.get_meta(npos)
		nmeta:get_inventory():set_list(meta:get_string("inputlist"),meta:get_inventory():get_list("main"))
		local def = minetest.registered_nodes[minetest.get_node(npos).name]
		if def and def.on_metadata_inventory_put then
			def.on_metadata_inventory_put(npos, listname, index, stack, player)
			minetest.registered_nodes["player_style:top_hat_upside_down"].on_rightclick(pos, nil, player)
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		local npos = minetest.string_to_pos(meta:get_string("pos1"))
		local nmeta = minetest.get_meta(npos)
		nmeta:get_inventory():set_list(meta:get_string("inputlist"),meta:get_inventory():get_list("main"))
		local def = minetest.registered_nodes[minetest.get_node(npos).name]
		if def and def.on_metadata_inventory_move then
			def.on_metadata_inventory_move(npos, from_list, from_index, to_list, to_index, count, player)
			minetest.registered_nodes["player_style:top_hat_upside_down"].on_rightclick(pos, nil, player)
		end
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local npos = minetest.string_to_pos(meta:get_string("pos1"))
		local nmeta = minetest.get_meta(npos)
		nmeta:get_inventory():set_list(meta:get_string("inputlist"),meta:get_inventory():get_list("main"))
		local def = minetest.registered_nodes[minetest.get_node(npos).name]
		if def and def.on_metadata_inventory_take then
			def.on_metadata_inventory_take(npos, listname, index, stack, player)
			minetest.registered_nodes["player_style:top_hat_upside_down"].on_rightclick(pos, nil, player)
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local npos = minetest.string_to_pos(meta:get_string("pos1"))
		local inputlist = meta:get_string("inputlist")
		local def = minetest.registered_nodes[minetest.get_node(npos).name]
		if def and def.allow_metadata_inventory_put then
			return def.allow_metadata_inventory_put(npos, inputlist, index, stack, player)
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local npos = minetest.string_to_pos(meta:get_string("pos1"))
		local inputlist = meta:get_string("inputlist")
		local def = minetest.registered_nodes[minetest.get_node(npos).name]
		if def and def.allow_metadata_inventory_take then
			return def.allow_metadata_inventory_take(npos, listname, index, stack, player)
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		local npos = minetest.string_to_pos(meta:get_string("pos1"))
		local inputlist = meta:get_string("inputlist")
		local def = minetest.registered_nodes[minetest.get_node(npos).name]
		if def and def.allow_metadata_inventory_move then
			return def.allow_metadata_inventory_move(npos, from_list, from_index, to_list, to_index, count, player)
		else
			return count
		end
	end,
})