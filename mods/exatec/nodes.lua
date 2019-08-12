minetest.register_node("exatec:tube", {
	description = "Tube",
	tiles = {"exatec_glass.png"},
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {dig_immediate = 3,exatec_tube=1},
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube"},
	--on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	--	node.param2=node.param2+1
	--	print(node.param2)
	--	minetest.swap_node(pos,node)
	--end,
	after_place_node = function(pos, placer)
		--minetest.set_node(pos,{name="was:wire",param2=135})
	end,
})

minetest.register_node("exatec:tube_distribution", {
	description = "Tube distribution",
	tiles = {"exatec_glass.png"},
	paramtype = "light",
	drawtype = "glasslike",
	sunlight_propagates=true,
	groups = {dig_immediate = 3,exatec_tube=2},
	exatec={
		test_input=function(pos,stack)
			return true
		end,
		input=function(pos,stack)
			for i,d in pairs(exatec.tube_rules) do
				local t = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
				if minetest.get_item_group(minetest.get_node(t).name,"exatec_tube") == 1 then
					local e = minetest.add_entity(t,"exatec:tubeitem")
					e:get_luaentity():new_item(stack,d)
					return
				end
			end
			minetest.add_item(pos,stack)
		end
	},
})

minetest.register_node("exatec:autocrafter", {
	description = "Autocrafter",
	tiles={"default_ironblock.png^default_craftgreed.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube=1},
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
				if i:sub(1,6) == "group:" then
					local it = 0
					local n = i:sub(7,-1)
					for i2,v2 in pairs(inv:get_list("input")) do
						if minetest.get_item_group(v2:get_name(),n) > 0 then
							it = it + v2:get_count()
							if it >= v then
								break
							end
						end
					end
					if it < v then
						return
					end
				elseif not inv:contains_item("input",ItemStack(i .." " .. v)) then
					return
				end
			end
			for i,v in pairs(list) do
				if i:sub(1,6) == "group:" then
					for i2,v2 in pairs(inv:get_list("input")) do
						if minetest.get_item_group(v2:get_name(),i:sub(7,-1)) > 0 then
							inv:remove_item("input",v2:get_name() .. " " .. v)
							break
						end
					end
				else
					inv:remove_item("input",ItemStack(i .." " .. v))
				end
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
	exatec={
		input_list="input",
		output_list="output",
	},
})

minetest.register_node("exatec:extraction", {
	description = "Extraction",
	tiles={
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png^default_crafting_arrowright.png",
		"default_ironblock.png^default_crafting_arrowleft.png",
		"default_ironblock.png",
		"default_ironblock.png",
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function (pos, elapsed)
		local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		local b = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
		local b1 = exatec.def(b)
		if b1.output_list then
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			local f1 = exatec.def(f)
			for i,v in pairs(minetest.get_meta(b):get_inventory():get_list(b1.output_list)) do
				if v:get_name() ~= "" then
					local stack = ItemStack(v:get_name() .." " .. 1)
					if exatec.test_input(f,stack) and exatec.test_output(b,stack) then
						exatec.input(f,stack)
						exatec.output(b,stack)
						return true
					end
				end
			end
		end
		return true
	end,
	groups = {choppy=3,oddly_breakable_by_hand=3},
	exatec={
		on_input=function(pos,stack)
		end,
		on_output=function(pos,stack)
		end,
	},
})