pchest={}

minetest.register_craft({
	output = "hook:pchest",
	recipe = {
		{"default:stick","default:stick","default:stick"},
		{"default:stick","default:chest", "default:diamondblock"},
		{"default:stick","default:stick","default:stick"},
	}
})

pchest.setpchest=function(pos,user)
	local meta = minetest.get_meta(pos)
	meta:set_string("owner", user:get_player_name())
	meta:set_int("state", 0)
	meta:get_inventory():set_size("main", 32)
	meta:get_inventory():set_size("trans", 1)
	meta:set_string("formspec",
	"size[8,8]" ..
	"list[context;main;0,0;8,4;]" ..
	"list[context;trans;0,0;0,0;]" ..
	"list[current_player;main;0,4.3;8,4;]" ..
	"listring[current_player;main]" ..
	"listring[current_name;main]")
	meta:set_string("infotext", "PChest by: " .. user:get_player_name())
end

minetest.register_tool("hook:pchest", {
	description = "Portable locked chest",
	inventory_image = "hook_extras_chest3.png",
	on_place = function(itemstack, user, pointed_thing)
		if minetest.is_protected(pointed_thing.above,user:get_player_name()) or hook.slingshot_def(pointed_thing.above,"walkable") then
			return itemstack
		end
		local p=minetest.dir_to_facedir(user:get_look_dir())
		local item=itemstack:to_table()
		minetest.set_node(pointed_thing.above, {name = "hook:pchest_node",param1="",param2=p})
		pchest.setpchest(pointed_thing.above,user)
			
		minetest.sound_play("default_place_node_hard", {pos=pointed_thing.above, gain = 1.0, max_hear_distance = 5})

		if not (item.meta or item.metadata) then
			itemstack:take_item()
			return itemstack
		end
		if item.meta.items then
			local its = minetest.deserialize(item.meta.items or "") or {}
			local items = {}
			for i,it in pairs(its) do
				table.insert(items,ItemStack(it))
			end

			minetest.get_meta(pointed_thing.above):get_inventory():set_list("main",items)
		elseif item.metadata ~= "" then
			local meta=minetest.deserialize(item["metadata"])
			local s=meta.stuff
			local its=meta.stuff.split(meta.stuff,",",",")
			local nmeta=minetest.get_meta(pointed_thing.above)
			for i,it in pairs(its) do
				if its~="" then
					nmeta:get_inventory():set_stack("main",i, ItemStack(it))
				end
			end
		end
		itemstack:take_item()
		return itemstack
	end
})

minetest.register_node("hook:pchest_node", {
	description = "Portable locked chest",
	tiles = {"hook_extras_chest2.png","hook_extras_chest2.png","hook_extras_chest1.png","hook_extras_chest1.png","hook_extras_chest1.png","hook_extras_chest3.png"},
	groups = {dig_immediate = 2, not_in_creative_inventory=1,tubedevice = 1, tubedevice_receiver = 1},
	drop="hook:pchest",
	paramtype2 = "facedir",
	tube = {insert_object = function(pos, node, stack, direction)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local added = inv:add_item("main", stack)
		return added
	end,
	can_insert = function(pos, node, stack, direction)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:room_for_item("main", stack)
	end,
	input_inventory = "main",
	connect_sides = {left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1}},
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local m = minetest.get_meta(pos)
		local owner = m:get_string("owner")
		local inv = m:get_inventory()
		local name = player:get_player_name()
		if owner == name or owner == "" then
			if stack:get_name() == "hook:pchest" then
				minetest.chat_send_player(name, "Not allowed to put in it")
				return 0
			elseif not inv:room_for_item("main",stack) then
				minetest.chat_send_player(name, "Full")
				return 0
			end
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local owner = minetest.get_meta(pos):get_string("owner")
		if owner==player:get_player_name() or owner=="" then
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local owner = minetest.get_meta(pos):get_string("owner")
		if owner==player:get_player_name() or owner=="" then
			return count
		end
		return 0
	end,
	can_dig = function(pos, player)
		local m = minetest.get_meta(pos)
		return m:get_string("owner") == "" and m:get_inventory():is_empty("main")
	end,
	on_punch = function(pos, node, player, pointed_thing)
		local meta=minetest.get_meta(pos)
		local name = player:get_player_name()
		local pinv = player:get_inventory()
		if minetest.is_protected(pos,name) or meta:get_string("owner") ~= name or not pinv:room_for_item("main",ItemStack("hook:pchest")) then
			return false
		end
		local inv=meta:get_inventory()
		local items = {}
		for i,v in pairs(inv:get_list("main")) do
			table.insert(items,v:to_table())
		end
		local item = ItemStack("hook:pchest"):to_table()
		item.meta={items=minetest.serialize(items)}
		pinv:add_item("main", ItemStack(item))
		minetest.set_node(pos, {name = "air"})
		minetest.sound_play("default_dig_dig_immediate", {pos=pos, gain = 1.0, max_hear_distance = 5,})
	end
})