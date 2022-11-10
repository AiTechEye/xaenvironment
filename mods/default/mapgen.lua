minetest.register_alias("mapgen_stone","default:stone")
minetest.register_alias("mapgen_water_source","default:salt_water_source")
minetest.register_alias("mapgen_river_water_source","default:water_source")
minetest.register_alias("mapgen_lava_source","default:lava_source")
minetest.register_alias("mapgen_mossycobble","default:mossycobble")
minetest.register_alias("mapgen_cobble","default:cobble")

minetest.register_tool("default:biocheck", {
	description = "Biocheck",
	inventory_image = "default_stick.png",
	groups={not_in_creative_inventory=1},
	on_use=function(itemstack, user, pointed_thing)
		local pos = user:get_pos()
		--local heat = math.floor(minetest.get_heat(pos)/10+0.5)*10
		--local humidity =math.floor(minetest.get_humidity(pos)/10+0.5)*10
		print(dump(minetest.registered_biomes[n]))
		local b = minetest.get_biome_data(pos)
		local n = minetest.get_biome_name(b.biome)
		minetest.chat_send_player(user:get_player_name(),n.." "..minetest.get_heat(pos) .." " ..minetest.get_humidity(pos))
	end
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:desert_quicksand",
	wherein= "default:desert_sand",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 5,
	y_min= -31000,
	y_max= 31000,
	noise_params = default.ore_noise_params()
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:bedrock",
	wherein= "default:stone",
	clust_scarcity = 10 * 10 * 10,
	clust_size = 5,
	y_min= -31000,
	y_max= 31000,
	noise_params = default.ore_noise_params()
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:cobble_porous",
	wherein= "default:stone",
	clust_scarcity = 10 * 10 * 10,
	clust_size = 5,
	y_min= -31000,
	y_max= 31000,
	noise_params = default.ore_noise_params()
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:gravel",
	wherein= "default:stone",
	clust_scarcity = 10 * 10 * 10,
	clust_size = 5,
	y_min= -31000,
	y_max= 31000,
	noise_params = default.ore_noise_params()
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:sand",
	wherein= "default:stone",
	clust_scarcity = 20 * 20 * 20,
	clust_size = 5,
	y_min= -31000,
	y_max= 31000,
	noise_params = default.ore_noise_params()
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:stone_hot",
	wherein= "default:stone",
	clust_scarcity = 10 * 10 * 10,
	clust_size = 5,
	y_min= -31000,
	y_max= -20,
	noise_params = default.ore_noise_params()
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:oil_source",
	wherein= "default:stone",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 5,
	y_min= -31000,
	y_max= -10,
	noise_params = default.ore_noise_params()
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:gas",
	wherein= "default:stone",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 5,
	y_min= -31000,
	y_max= -10,
	noise_params = default.ore_noise_params()
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:snowblock_thin",
	wherein= "default:snowblock",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 15,
	y_min= -10,
	y_max= 1,
	noise_params = default.ore_noise_params()
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:snowblock_thin",
	wherein= "default:ice",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 15,
	y_min= -10,
	y_max= 1,
	noise_params = default.ore_noise_params()
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "default:stone",
	sidelen = 16,
	noise_params = {
		offset = 0.01,
		scale = 0.02,
		spread = {x = 500, y = 500, z = 500},
		octaves = 3,
		persist = 0.6
	},
	y_min = -30000,
	y_max = 0,
	decoration = "default:cave_drops",
	flags = "all_ceilings",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "default:stone",
	sidelen = 16,
	noise_params = {
		offset = 0.01,
		scale = 0.02,
		spread = {x = 100, y = 100, z = 100},
		octaves = 3,
		persist = 0.6
	},
	y_min = -30000,
	y_max = 0,
	decoration = "default:stone_spike_drop",
	flags = "all_ceilings",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "default:stone",
	sidelen = 16,
	noise_params = {
		offset = 00.1,
		scale = 00.2,
		spread = {x = 100, y = 100, z = 100},
		octaves = 3,
		persist = 0.6
	},
	y_min = -30000,
	y_max = 0,
	decoration = "default:stone_spike",
	flags = "all_floors",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "default:stone",
	sidelen = 16,
	noise_params = {
		offset = 0.01,
		scale = 0.02,
		spread = {x = 500, y = 500, z = 500},
		octaves = 3,
		persist = 0.6
	},
	y_min = -30000,
	y_max = 0,
	decoration = "default:stone_with_red_moss",
	flags = "all_floors",
})
minetest.register_decoration({
	deco_type = "simple",
	place_on = "default:stone",
	sidelen = 16,
	noise_params = {
		offset = 0.01,
		scale = 0.02,
		spread = {x = 500, y = 500, z = 500},
		octaves = 3,
		persist = 0.6
	},
	y_min = -30000,
	y_max = -50,
	decoration = "default:stone_with_moss",
	flags = "all_floors",
})

minetest.register_ore({
	ore_type = "blob",
	ore= "default:mine_shaft",
	wherein= "default:stone",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 5,
	y_min= -31000,
	y_max= 0,
	noise_params = default.ore_noise_params()
})

--||||||||||||||||
-- ======================= biomes
--||||||||||||||||

minetest.register_biome({
	name = "ocean",
	node_top = "default:sand",
	depth_top = 5,
	depth_filler = 5,
	node_stone = "default:stone",
	node_water = "default:salt_water_source",
	node_river_water = "default:salt_water_source",
	y_min = -31000,
	y_max = 4,
	heat_point = 50,
	humidity_point = 50,
})

minetest.register_biome({
	name = "hot_ocean",
	node_top = "default:sand",
	depth_top = 5,
	depth_filler = 5,
	node_stone = "default:stone",
	node_water = "default:salt_water_source",
	--node_river_water = "default:salt_water_source",
	y_min = -31000,
	y_max = 0,
	heat_point = 90,
	humidity_point = 40,
})

minetest.register_biome({
	name = "deep_ocean",
	depth_top = 5,
	node_top = "default:sand",
	node_stone = "default:stone",
	node_water = "default:salt_water_source",
	node_river_water = "default:salt_water_source",
	y_min = -200,
	y_max = 4,
	heat_point = 51,
	humidity_point = 49
})

default.register_bio=function(def)
	default.registered_bios[def[1]] = {heat=def[2],humidity=def[3],grass=def.grass}
	table.insert(default.registered_bios_list,def[1])
	minetest.register_biome({
		name =		def[1],
		node_top =	def.grass,
		depth_top =	def.depth_top or		1,
		node_filler =	def.dirt or		"default:dirt",
		depth_filler = 	def.depth_filler or		5,
		node_stone = 	def.stone or		"default:stone",
		node_water_top = 	def.node_water_top,
		depth_water_top =	def.depth_water_top or	0 ,
		node_water =	def.node_water,
		node_river_water =def.node_river_water,
		y_min =		def.y_min or		def.beach and 3 or 1,
		y_max =		def.y_max or		31000,
		heat_point =				def[2],
		humidity_point =				def[3],

	--	max_pos={x=30000,z=30000},
	--	min_pos={x=-30000,z=-30000},

	})
	if def.beach then
		minetest.register_biome({
		name = def[1] .. "_beach",
		node_top = "default:sand",
		depth_top = 1,
		node_filler = "default:sand",
		depth_filler = 5,
		node_riverbed = "default:sand",
		depth_riverbed = 3,
		node_water_top = def.node_water_top,
		depth_water_top = def.depth_water_top or 0,
		y_min = 1,
		y_max = 3,
		heat_point = def[2],
		humidity_point = def[3],

	--	max_pos={x=30000,z=30000},
	--	min_pos={x=-30000,z=-30000},
		})
	end
end

default.register_bio({"semi_desert",			100,20,grass="default:desert_sand",dirt="default:desert_sand",stone="default:desert_stone",y_min=-50})
default.register_bio({"desert",				100,0,grass="default:desert_sand",dirt="default:desert_sand",stone="default:desert_stone",y_min=-50})

default.register_bio({"swamp",				80,100,grass="default:dirt_with_jungle_grass"})
default.register_bio({"jungle",				80,80,grass="default:dirt_with_jungle_grass",beach=true})
default.register_bio({"tropic",				80,50,grass="default:dirt_with_grass",beach=true})
default.register_bio({"savanna",			80,0,grass="default:dirt_with_dry_grass",beach=true})

default.register_bio({"deciduous",			60,20,grass="default:dirt_with_grass",beach=true})
default.register_bio({"deciduous_grassland",	60,80,grass="default:dirt_with_grass",beach=true})

default.register_bio({"coniferous",			40,20,grass="default:dirt_with_coniferous_grass",beach=true})
default.register_bio({"coniferous_foggy",		40,80,grass="default:dirt_with_coniferous_grass",beach=true})

default.register_bio({"cold_coniferous",		20,20,grass="default:dirt_with_snow",beach=true,node_water_top="default:ice_clear",depth_water_top=1})
default.register_bio({"cold_grassland",		20,80,grass="default:dirt_with_snow",beach=true,node_water_top="default:ice_clear",depth_water_top=1})

default.register_bio({"tundra_green",		0,80,grass="default:dirt_with_permafrost_grass",dirt="default:permafrost_dirt",y_min=20,y_max=40,beach=true,node_water_top="default:ice_clear",depth_water_top=4})
default.register_bio({"snowy",				10,50,grass="default:dirt_with_snow",depth_filler=0,node_water_top="default:ice_clear",depth_water_top=4})
default.register_bio({"tundra_red",			0,20,grass="default:dirt_with_red_permafrost_grass",dirt="default:permafrost_dirt",y_min=20,y_max=40,beach=true,node_water_top="default:ice_clear",depth_water_top=4})
default.register_bio({"arctic",				0,50,grass="default:snow",stone="default:ice",dirt="default:ice",node_water_top="default:ice_clear",depth_water_top=20})


--||||||||||||||||
-- =======================Decorations
--||||||||||||||||

minetest.register_on_generated(function(minp, maxp, seed)

	if minp.y> -30000 and maxp.y< 50 then
-- ground cracks

		local height = 0
		local lenth = maxp.x-minp.x+1
		local cindx = 1

		if not default.crack_perlin_map then
			default.crack_perlin_map = minetest.get_perlin_map(default.crack_map,{x=lenth,y=lenth,z=lenth})

			default.crack_dirt = {}
			for i,v in pairs(minetest.registered_nodes) do
				if v.groups and (v.groups.spreading_dirt_type or v.groups.sand or v.groups.snowy) then
					default.crack_dirt[minetest.get_content_id(i)] = i
				end
			end
		end

		local map = default.crack_perlin_map:get_3d_map_flat(minp)
		local air = minetest.get_content_id("air")
		local water= minetest.get_content_id("default:salt_water_source")
		local floor = minp.y < 0 and maxp.y > 0 and minetest.get_content_id("default:sand") or maxp.y < 0 and minetest.get_content_id("default:stone_spike") or air
		local vm,min,max = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
		local data = vm:get_data()

		for z=minp.z,maxp.z do
		local id=area:index(minp.x,height,z)
		for x=minp.x,maxp.x do
			local d = math.abs(map[cindx])
			if d < 0.07 then
				local d2 = minp.y < 0 and math.ceil(d*100) or 0
				for i=maxp.y,minp.y+d2,-1 do
					local y = id+(i*area.ystride)
					local n = data[y]
					if n ~= water then
						data[y] = air
						if maxp.y > height and default.crack_dirt[n] then
							floor = n
						end
					end
				end
				if data[id+(minp.y+d2-1)*area.ystride] ~= air then
					data[id+(minp.y+d2)*area.ystride] = floor
				end
			end
			cindx=cindx+1
			id=id+1
		end
		end
		vm:set_data(data)
		vm:write_to_map()
	end

	if minp.y> -50 and maxp.y< 50 then
--waterland
		local depth = 10
		local height = -50
		local heat = minetest.get_heat(minp)

		local lenth = maxp.x-minp.x+1
		local cindx = 1


		default.waterland_perlin_map = default.waterland_perlin_map or minetest.get_perlin_map(default.water_land_map,{x=lenth,y=lenth,z=lenth})

		local map = default.waterland_perlin_map:get_3d_map_flat(minp)

		local water= minetest.get_content_id("default:salt_water_source")
		local sand = minetest.get_content_id("default:sand")
		local dsand = minetest.get_content_id("default:desert_sand")
		local stone = minetest.get_content_id("default:stone")
		local dstone = minetest.get_content_id("default:desert_stone")

		local sandtype = sand
		local treasure
		local gened
		local vm,min,max = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
		local data = vm:get_data()

		for z=minp.z,maxp.z do
		for y=minp.y,maxp.y do
			local id=area:index(minp.x,y,z)
		for x=minp.x,maxp.x do
			if y > -20 and y < -6 and (data[id] == sand or data[id] == dsand) then
				height = y
				sandtype = data[id]
			end
			local den = math.abs(map[cindx]) - math.abs(height-y)/(depth*2) or 0
			if (data[id] == water or data[id] == sand or data[id] == dsand) and y >= height-depth and y <= -6 and den > 0.7 then
				data[id] = stone
				data[id+area.ystride] = sandtype
				gened = true
				if sandtype == sand and den < 0.8 then
					if heat > 85 and math.random(1,40) == 1 then
						data[id+area.ystride] = minetest.get_content_id("plants:coral"..math.random(1,2).."_"..math.random(1,20))
					elseif math.random(1,10) == 1 then
						data[id+area.ystride] = minetest.get_content_id("plants:kelp"..math.random(1,4))
					elseif math.random(1,10) == 1 then
						data[id+area.ystride] = minetest.get_content_id("plants:seaweed"..math.random(1,3))
					end
				elseif sandtype == dsand then
					data[id] = dstone
				end
			elseif not treasure and gened and den > 0.6 and y <= 7 and data[id] == water and data[id-area.ystride] == sandtype and data[id+area.ystride] == water and math.random(1,15) == 1 then
				local pos = area:position(id)
				treasure = true
				minetest.after(0,function(pos)
					default.treasure({pos=pos})
				end,pos)
			end
			cindx=cindx+1
			id=id+1
		end
		end
		end
		vm:set_data(data)
		vm:write_to_map()
	end


	if minp.y< 0 and maxp.y> 0 then
-- deep ocean

		local depth = math.random(80,150)
		local height = 0
		local lenth = maxp.x-minp.x+1
		local cindx = 1
		local heat = minetest.get_heat(minp)

		if not default.deepocean_perlin_map then
			default.deepocean_perlin_map =  minetest.get_perlin_map(default.deepocean_map,{x=lenth,y=lenth,z=lenth})
			default.deepocean_water = minetest.get_content_id("default:salt_water_source")
			default.deepocean_sand = minetest.get_content_id("default:sand")
			default.deepocean_dsand = minetest.get_content_id("default:desert_sand")
			default.deepocean_atlantis = minetest.get_content_id("villages:atlantis_spawner")
			default.deepocean_plants = {}
			default.deepocean_corals = {}
			for i=1,20 do
				table.insert(default.deepocean_corals,minetest.get_content_id("plants:coral1_"..i))
				table.insert(default.deepocean_corals,minetest.get_content_id("plants:coral2_"..i))
				if i <= 4 then
					if minetest.registered_nodes["plants:kelp"..i] then
						table.insert(default.deepocean_plants,minetest.get_content_id("plants:kelp"..i))
					end
					if minetest.registered_nodes["plants:seaweed"..i] then
						table.insert(default.deepocean_plants,minetest.get_content_id("plants:seaweed"..i))
					end
				end
			end
		end

		local water = default.deepocean_water
		local sand = default.deepocean_sand
		local dsand = default.deepocean_dsand
		local plants = default.deepocean_plants
		local corals = default.deepocean_corals
		local atlantis = default.deepocean_atlantis
		local plants_len = #plants
		local under_water

		local map =  default.deepocean_perlin_map:get_3d_map_flat(minp)
		local vm,min,max = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
		local data = vm:get_data()

		for z=minp.z,maxp.z do
		for y=maxp.y,minp.y,-1 do
			local id=area:index(minp.x,y,z)
		for x=minp.x,maxp.x do
			local den = math.abs(map[cindx]) - math.abs(height-y)/(depth*2) or 0
			under_water = data[area:index(x,1,z)] == water
			if under_water and  y <= height and den > 0.7 and y >= height-depth then
				data[id] = water
				local ystr = id-area.ystride
				if data[ystr] ~= water then
					data[ystr] = sand
					if math.random(1,20) == 1 then
						data[ystr] = plants[math.random(1,plants_len)]
					elseif math.random(1,1000) == 1 then
						data[ystr] = atlantis
					end
					if heat > 85 then
						data[ystr] = dsand
						if math.random(1,80) == 1 then
							data[ystr] = corals[math.random(1,20)]
						end
					end
				end
			end
			cindx=cindx+1
			id=id+1
		end
		end
		end

		vm:set_data(data)
		vm:set_lighting({day=0,night=0})
		vm:calc_lighting()
		vm:write_to_map()
	end

	if minp.y> 200 and maxp.y< 300 then
--cloudland
		local depth = 18
		local height = 250

		local lenth = maxp.x-minp.x+1
		local cindx = 1

		default.cloudland_perlin_map = default.cloudland_perlin_map or minetest.get_perlin_map(default.cloud_land_map,{x=lenth,y=lenth,z=lenth})

		local map = default.cloudland_perlin_map:get_3d_map_flat(minp)

		local air = minetest.get_content_id("air")
		local cloud = minetest.get_content_id("default:cloud")
		local vm,min,max = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
		local data = vm:get_data()
		for z=minp.z,maxp.z do
		for y=minp.y,maxp.y do
			local id=area:index(minp.x,y,z)
		for x=minp.x,maxp.x do
			local den = math.abs(map[cindx]) - math.abs(height-y)/(depth*2) or 0
			if data[id] == air and y >= height-depth and y <= height+depth and den > 0.7 then
				data[id] = cloud
			end
			cindx=cindx+1
			id=id+1
		end
		end	
		end
		vm:set_data(data)
		vm:write_to_map()
	end

	if (minp.y <= -default.mapgen_limit+1000 or maxp.y <= -default.mapgen_limit+1000 ) or ((minp.x >= default.mapgen_limit-1000 or minp.x <= -default.mapgen_limit+1000 or minp.z >= default.mapgen_limit-1000 or minp.z <= -default.mapgen_limit+1000) and (maxp.x >= default.mapgen_limit-1000 or maxp.x <= -default.mapgen_limit+1000 or maxp.z >= default.mapgen_limit-1000 or maxp.z <= -default.mapgen_limit+1000)) then
--world edge

		local air = minetest.get_content_id("default:end_of_world_air")
		local airblocking = minetest.get_content_id("default:end_of_world_air2")
		local sand = minetest.get_content_id("default:end_of_world_sand")
		local stone = minetest.get_content_id("default:end_of_world_stone")
		local water = minetest.get_content_id("default:end_of_world_water")
		local waterblocking = minetest.get_content_id("default:end_of_world_water2")
		local lava = minetest.get_content_id("default:end_of_world_lava")
		local lavablocking = minetest.get_content_id("default:end_of_world_lava2")
		local vox = minetest.get_voxel_manip()
		local min, max = vox:read_from_map(minp, maxp)
		local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
		local data = vox:get_data()
		for x=min.x,max.x do
		for y=min.y,max.y do
		for z=min.z,max.z do
			if y == -20 then
				data[area:index(x,y,z)] = sand
			elseif y < -default.mapgen_limit+2920 and y > -default.mapgen_limit+1000 then
				data[area:index(x,y,z)] = air
			elseif y < -20 and y > -default.mapgen_limit+1000 then
				data[area:index(x,y,z)] = stone
			elseif y > -20 and (x >= default.mapgen_limit-500 or x <= -default.mapgen_limit+500 or z >= default.mapgen_limit-500 or z <= -default.mapgen_limit+500) then
				if y > -20 and y <= 1 then
					data[area:index(x,y,z)] = waterblocking
				elseif y > 1 then
					data[area:index(x,y,z)] = airblocking
				end
			elseif y > -20 and y <= 1 then
				data[area:index(x,y,z)] = water
			elseif y <= -default.mapgen_limit+500 then
				data[area:index(x,y,z)] = lavablocking
			elseif y <= -default.mapgen_limit+1000 then
				data[area:index(x,y,z)] = lava
			else
				data[area:index(x,y,z)] = air
			end
		end
		end
		end
		vox:set_data(data)
		vox:write_to_map()
	end
end)

minetest.register_node("default:rock_spawner", {
	tiles={"default_stone.png"},
	groups={on_load=1,not_in_creative_inventory=1},
	on_construct = function(pos)
		minetest.remove_node(pos)
	end,
	on_load = function(pos)
		minetest.remove_node(pos)

		local stone = minetest.get_content_id("default:stone")
		local grass
		local rndstuff = {minetest.get_content_id("air")}
		local rndstone = {stone}
		local rndstone2 = {}
		rndstone2["default:stone"] = true

		local s = math.random(5,15)*0.1
		local r = math.random(2,10)
		local ry = math.random(2,10)
		local pos1 = vector.subtract(pos, r)
		local pos2 = vector.add(pos, r)
		local vox = minetest.get_voxel_manip()
		local min, max = vox:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
		local data = vox:get_data()

		for y = -ry, ry do
		for z = -r, r do
		for x = -r, r do
			if r/vector.length(vector.new(x,y,z)) > s then
				local v = area:index(pos.x+x,pos.y+y,pos.z+z)
				local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
				local n = minetest.get_node(p).name
				if not grass then
					if minetest.get_item_group(n,"spreading_dirt_type") > 0 then
						grass = minetest.get_content_id(n)
					end
				else
					local def = minetest.registered_nodes[n]
					local g = def.groups or {}

					if not (g.dirt or g.choppy or g.leaves) and n ~= "default:stone" and n ~= "air" then
						table.insert(rndstuff,minetest.get_content_id(n))
					end
					data[v+area.ystride] = grass
					data[v+area.ystride+area.ystride] = rndstuff[math.random(1,#rndstuff)]
				end
				if not rndstone2[n] and minetest.get_item_group(n,"stone") > 0 then
					table.insert(rndstone,minetest.get_content_id(n))
					rndstone2[n] = true
				end
				data[v] = rndstone[math.random(1,#rndstone)]
			end
		end
		end
		end
		vox:set_data(data)
		vox:write_to_map()
		vox:update_map()
		vox:update_liquids()
	end
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"group:spreading_dirt_type"},
	sidelen = 16,
	noise_params = {
		offset = 0.003,
		scale = 0.005,
		spread = {x = 200, y = 200, z = 200},
		octaves = 3,
		persist = 0.6
	},
	y_min = -20,
	y_max = 100,
	decoration = "default:rock_spawner",
})

minetest.register_node("default:end_of_world_sand", {
	tiles={"default_sand.png"},
	drop = "",
	drowning = 1,
	groups={not_in_creative_inventory = 1},
})
minetest.register_node("default:end_of_world_stone", {
	tiles={"default_stone.png"},
	drop = "",
	drowning = 1,
	groups={not_in_creative_inventory = 1},
})
minetest.register_node("default:end_of_world_air", {
	drawtype = "airlike",
	walkable = false,
	pointable = false,
	diggable = false,
	drowning = 1,
	drop = "",
	paramtype = "light",
	sunlight_propagates = true,
	floodable = false,
	groups={not_in_creative_inventory = 1},
})
minetest.register_node("default:end_of_world_air2", {
	drawtype = "airlike",
	pointable = false,
	diggable = false,
	drowning = 1,
	drop = "",
	paramtype = "light",
	sunlight_propagates = true,
	floodable = false,
	groups={not_in_creative_inventory = 1},
})

minetest.register_node("default:end_of_world_water", {
	tiles={
		{
			name = "default_salt_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_salt_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	drop = "",
	drowning = 1,
	drawtype = "liquid",
	liquidtype = "source",
	liquid_alternative_flowing = "default:salt_water_flowing",
	liquid_alternative_source = "default:end_of_world_water",
	liquid_viscosity = 1,
	liquid_renewable = false,
	post_effect_color = {a = 100, r = 0, g = 90, b = 133},
	sounds = default.node_sound_water_defaults(),
	groups={not_in_creative_inventory = 1},
})

minetest.register_node("default:end_of_world_water2", {
	tiles={
		{
			name = "default_salt_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_salt_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	paramtype = "light",
	pointable = false,
	drop = "",
	drowning = 1,
	liquid_range = 0,
	drawtype = "liquid",
	liquidtype = "source",
	liquid_alternative_flowing = "default:end_of_world_water2",
	liquid_alternative_source = "default:end_of_world_water2",
	groups={not_in_creative_inventory = 1},
})

minetest.register_node("default:end_of_world_lava", {
	description = "Lava source",
	tiles={
		{
			name = "default_lava_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		},
		{
			name = "default_lava_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		}
	},
	drawtype = "liquid",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	light_source=13,
	drop = "",
	liquid_range = 0,
	drowning = 1,
	damage_per_second = 1000,
	liquidtype = "source",
	liquid_alternative_flowing = "default:end_of_world_lava",
	liquid_alternative_source = "default:end_of_world_lava",
	liquid_viscosity = 20,
	liquid_renewable = false,
	post_effect_color = {a = 240, r = 255, g = 55, b = 0},
	groups={not_in_creative_inventory = 1,igniter=1000},
})
minetest.register_node("default:end_of_world_lava2", {
	description = "Lava source",
	tiles={
		{
			name = "default_lava_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		},
		{
			name = "default_lava_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		}
	},
	drawtype = "liquid",
	paramtype = "light",
	pointable = false,
	diggable = false,
	light_source=13,
	drop = "",
	drowning = 1,
	liquid_range = 0,
	damage_per_second = 1000,
	liquidtype = "source",
	liquid_alternative_flowing = "default:end_of_world_lava2",
	liquid_alternative_source = "default:end_of_world_lava2",
	liquid_viscosity = 20,
	liquid_renewable = false,
	post_effect_color = {a = 240, r = 255, g = 55, b = 0},
	groups={not_in_creative_inventory = 1,igniter=1000},
})