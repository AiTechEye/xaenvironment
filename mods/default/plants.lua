default.register_tree=function(def)

	if type(def.name) ~= "string" then
		error("name (string) required!")
	elseif type(def.sapling_place_schematic) ~= "function" then
		error("sapling_place_schematic (function) required!")
	elseif type(def.schematic) ~= "string" then
		error("schematic (string) required!")
	end

	local mod = minetest.get_current_modname() ..":"
	local name = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local schematic = def.sapling_place_schematic
	local fruit_name

	if def.fruit then
		fruit_name = def.fruit.name or mod .. def.name
	end

-- tree

	def.tree = def.tree or					{}
	def.tree.description = def.tree.description or			name .. " tree"
	def.tree.tiles = def.tree.tiles or				{"default_tree_top.png","default_tree_top.png","default_tree.png"}
	def.tree.paramtype2 = def.tree.paramtype2 or			"facedir"
	def.tree.on_place = def.tree.on_place or 			minetest.rotate_node
	def.tree.groups = def.tree.groups or				 {tree=1,choppy=2,flammable=1}
	def.tree.sounds = def.tree.sounds or 				default.node_sound_wood_defaults()
	def.tree.on_construct = def.tree.on_construct or 			function(pos, placer)
									minetest.get_meta(pos):set_int("placed",1)
								end
	minetest.register_node(mod .. def.name .. "_tree", def.tree)

-- wood

	def.wood = def.wood or					{}
	def.wood.description = def.wood.description or			name .. " wood"
	def.wood.tiles = def.wood.tiles or				{"default_wood.png"}
	def.wood.groups = def.wood.groups or				{wood=1,choppy=3,flammable=2}
	def.wood.sounds = def.wood.sounds or 				default.node_sound_wood_defaults()
	minetest.register_node(mod .. def.name .. "_wood", def.wood)
	minetest.register_craft({
		output=mod .. def.name .. "_wood 4",
		recipe={{mod .. def.name .. "_tree"}},
	})

-- leaves

	def.leaves = def.leaves or					{}
	def.leaves.description = def.leaves.description or			name .. " leaves"
	def.leaves.tiles = def.leaves.tiles or				{"default_leaves.png"}
	def.leaves.paramtype = def.leaves.paramtype or			"light"
	def.leaves.drawtype = def.leaves.drawtype or			"allfaces_optional"
	def.leaves.sunlight_propagetes = def.leaves.sunlight_propagetes or	true
	def.leaves.groups = def.leaves.groups or			{leaves=1,snappy=3,leafdecay=3,flammable=2}
	def.leaves.sounds = def.leaves.sounds or 			default.node_sound_leaves_defaults()
	def.leaves.drop = def.leaves.drop or 				{max_items = 1,items = {{items = {mod .. def.name .. "_sapling"}, rarity = 25},{items = {"default:stick"}, rarity = 10},{items = {mod .. def.name .. "_leaves"}}}}
	minetest.register_node(mod .. def.name .. "_leaves", def.leaves)

-- sapling

	def.sapling = def.sapling or					{}
	def.sapling.description = def.sapling.description or		name .. "tree sapling"
	def.sapling.tiles = def.sapling.tiles or				{"default_treesapling.png"}
	def.sapling.inventory_image = def.sapling.inventory_image or	def.sapling.tiles[1]
	def.sapling.paramtype = def.sapling.paramtype or			"light"
	def.sapling.drawtype = def.sapling.drawtype or			"plantlike"
	def.sapling.sunlight_propagetes = def.sapling.sunlight_propagetes or	true
	def.sapling.groups = def.sapling.groups or			{sapling=1,dig_immediate=3,snappy=3,flammable=3}
	def.sapling.sounds = def.sapling.sounds or 			default.node_sound_leaves_defaults()
	def.sapling.attached_node = def.sapling.attached_node or		1
	def.sapling.walkable = def.sapling.walkable or			false
	def.sapling.after_place_node = def.sapling.after_place_node or function(pos, placer)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"soil") > 0 then
			local meta = minetest.get_meta(pos)
			meta:set_int("date",default.date("get"))
			meta:set_int("growtime",math.random(10,60))
			minetest.get_node_timer(pos):start(10)
		end
	end
	def.sapling.on_timer = def.sapling.on_timer or function (pos, elapsed)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"soil") and (minetest.get_node_light(pos,0.5) or 0) >= 13 then
			local meta = minetest.get_meta(pos)
			if default.date("m",meta:get_int("date")) >= meta:get_int("growtime") then
				local applm = math.random(5,20)
				minetest.remove_node(pos)
				schematic(pos)
				if fruit_name then
					for z=-3,3 do
					for x=-3,3 do
					for y=4,10 do
						local pos2 = {x=pos.x+x,y=pos.y+y,z=pos.z+z}
						if math.random(1,applm) == 1 and minetest.get_node(pos2).name == mod .. def.name .. "_leaves" then
							local meta = minetest.get_meta(pos2)
							minetest.set_node(pos2,{name="default:fruit_spawner"})
							meta:set_string("fruit",fruit_name)
							meta:set_int("date",default.date("get"))
							meta:set_int("growtime",math.random(1,30))
							minetest.get_node_timer(pos2):start(10)
						end
					end
					end
					end
				end
			end
			return true
		end
	end
	minetest.register_node(mod .. def.name .. "_sapling", def.sapling)

	if def.fruit then
		minetest.register_ore({
			ore_type = "scatter",
			ore = fruit_name,
			wherein= mod .. def.name .. "_leaves",
			clust_scarcity = 4 * 4 * 4,
			clust_num_ores = 2,
			clust_size = 3,
			y_min= 0,
			y_max= 200,
		})

		local fts = 0
		for _,i in pairs(def.fruit) do
			fts = fts + 1
			if fts > 1 then
				break
			end
		end

		if fts > 1 then
			default.register_eatable("node",fruit_name,(def.fruit.hp or 1),(def.fruit.gaps or 4),{
				description = def.fruit.description or 			fruit_name,
				inventory_image = def.fruit.inventory_image or 		"default_apple.png",
				tiles = def.fruit.tiles or				{"default_apple.png"},
				groups = def.fruit.groups or				{dig_immediate=3,leafdecay=3,snappy=3,flammable=3,attached_node=1},
				sounds = def.fruit.sounds or				default.node_sound_leaves_defaults(),
				drawtype = def.fruit.drawtype or			"plantlike",
				paramtype = def.fruit.paramtype or			"light",
				sunlight_propagetes = def.fruit.sunlight_propagetes or	true,
				walkable =def.fruit.walkable or				false,
				visual_scale = def.fruit.visual_scale or			0.5,
				selection_box = def.fruit.selection_box or		{type = "fixed",fixed={-0.1, -0.5, -0.1, 0.1, -0.1, 0.1}},
				after_place_node = def.fruit.after_place_node or		function(pos, placer)
											minetest.set_node(pos,{name=fruit_name,param2=1})
										end,
				after_dig_node = def.fruit.after_dig_node or		function(pos, oldnode, oldmetadata, digger)
											if oldnode.param2 == 0 then
												local meta = minetest.get_meta(pos)
												minetest.set_node(pos,{name="default:fruit_spawner"})
												meta:set_int("date",default.date("get"))
												meta:set_string("fruit",fruit_name)
												meta:set_int("growtime",math.random(1,30))
												minetest.get_node_timer(pos):start(10)
											end
										end,
			})
		end
	end

	def.mapgen = def.mapgen or {}
	minetest.register_decoration({
		deco_type = def.mapgen.deco_type or		"schematic",
		place_on = def.mapgen.place_on or		{"default:dirt_with_grass"},
		sidelen = def.mapgen.sidelen or			16,
		noise_params = def.mapgen.noise_params or	{
								offset = 0.006,
								scale = 0.002,
								spread = {x = 250, y = 250, z = 250},
								seed = 2,
								octaves = 3,
								persist = 0.66
							},
		biomes = def.mapgen.biomes or		{"grassland"},
		y_min = def.mapgen.y_min or		1,
		y_max = def.mapgen.y_max or		31000,
		schematic = def.schematic			,
		flags = def.mapgen.flags or			"place_center_x, place_center_z",
	})
end

minetest.register_node("default:fruit_spawner", {
	groups = {not_in_creative_inventory=1},
	drop = "",
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	sunlight_propagetes = true,
	walkable = false,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		if default.date("m",meta:get_int("date")) > meta:get_int("growtime") then
			if minetest.find_node_near(pos,1,"group:leaves") then
				minetest.set_node(pos,{name=meta:get_string("fruit"),param2=0})
			else
				minetest.remove_node(pos)
			end
		end
		return true
	end
})