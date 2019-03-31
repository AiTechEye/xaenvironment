minetest.register_node("default:workbench", {
	description = "Workbench",
	tiles={"default_workbench_table.png","default_wood.png","default_wood.png^default_workbench.png"},
	groups = {wood=1,oddly_breakable_by_hand=3,choppy=3,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("craft", 9)
		inv:set_size("output", 1)
		inv:set_size("stock", 32)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", "Workbench")
		meta:set_string("formspec",
		"size[8,11]" ..
		"list[context;craft;4,0;3,3;]" ..
		"list[context;output;7,1;1,1;]" ..
		"list[context;stock;0,3;8,4;]" ..
		"list[current_player;main;0,7.3;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[current_name;stock]" .. 
		"listring[current_name;craft]".. 
		"listring[current_player;main]" ..
		"listring[current_name;output]" 
		)
	end,
	on_timer = function (pos, elapsed)
			local inv = minetest.get_meta(pos):get_inventory()
			inv:set_stack("output",1,default.workbench.get_craft_result(inv:get_list("craft")))
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname=="craft" then
			minetest.get_node_timer(pos):start(0.1)
		elseif listname=="output" then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		if name==meta:get_string("owner") or not minetest.is_protected(pos,name) then
			if listname == "output" then
				local inv = minetest.get_meta(pos):get_inventory()
				default.workbench.take_from_craftgreed(inv,"craft")
			end
			if listname == "craft" then
				minetest.get_node_timer(pos):start(0.1)
			end
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "output" then
			return 0
		end
		if from_list == "output" then
			local inv = minetest.get_meta(pos):get_inventory()
			default.workbench.take_from_craftgreed(inv,"craft")
		end
		if to_list == "craft" or from_list == "craft" then
			minetest.get_node_timer(pos):start(0.1)
		end
		return count
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("craft") and inv:is_empty("stock")
	end
})