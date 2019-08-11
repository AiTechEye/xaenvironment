minetest.register_node("exatec:autocrafter", {
	description = "Autocrafter",
	tiles={"default_ironblock.png^default_craftgreed.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		local item = m:get_string("item")
		if m:get_string("item") == "" then
			local inv = m:get_inventory()
			inv:set_size("input", 16)
			inv:set_size("output", 16)
			inv:set_size("craft", 9)
		end
		m:set_string("formspec",
			"size[8,11]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."list[context;craft;2,0;3,3;]" 
			.."box[6,1;1,1;#666666]"
			..(item ~="" and "item_image[6,1;1,1;"..item.."]" or "")
			.."list[context;input;-0.2,3;4,4;]" 
			.."list[context;output;4.2,3;4,4;]" 
			.."label[0,2.5;Input]" 
			.."label[7,2.5;Output]" 
			.."list[current_player;main;0,7.1;8,4;]" 
			.."listring[current_player;main]" 
			.."listring[current_name;input]" 
			.."listring[current_name;output]" 
			.."listring[current_player;main]"

			.."listring[current_player;craft]"
			.."listring[current_player;main]"
		)
	end,
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		if m:get_string("item") ~= "" then
			local craft = minetest.get_craft_recipe(m:get_string("item"))
			if not (craft.items and craft.type == "normal") or not inv:room_for_item("output",ItemStack(m:get_string("item").." " .. m:get_string("count"))) then
				return
			end
			local list = {}
			for i,v in pairs(craft.items) do
				list[v] = (list[v] and list[v]+1) or 1
			end
			for i,v in pairs(list) do
				if not inv:contains_item("input",ItemStack(i .." " .. v)) then
					return
				end
			end
			for i,v in pairs(list) do
				inv:remove_item("input",ItemStack(i .." " .. v))
			end
			inv:add_item("output",ItemStack(m:get_string("item").." " .. m:get_string("count")))
			return true
		end
	end,
	set_craft_item=function(pos)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		local craft = minetest.get_craft_result({method = "normal",width = 3, items = inv:get_list("craft")})
		m:set_string("item",craft.item:get_name())
		m:set_int("count",craft.item:get_count())
		minetest.registered_nodes["exatec:autocrafter"].on_construct(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "craft" then
			minetest.registered_nodes["exatec:autocrafter"].set_craft_item(pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "craft" or from_list == "craft" then
			minetest.registered_nodes["exatec:autocrafter"].set_craft_item(pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "craft" then
			minetest.registered_nodes["exatec:autocrafter"].set_craft_item(pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("input") and inv:is_empty("output") and inv:is_empty("craft")
	end,
})