multidimensions.register_dimension=function(name,def,self)

	local y = multidimensions.first_dimensions_appear_at
	for i,v in pairs(multidimensions.registered_dimensions) do
		if v.dim_y >= multidimensions.calculating_dimensions_from_min_y then
			y = y + v.dim_height
		end
	end

	def = def or				{}
	def.self = def.self or			{}

	def.dim_y = def.dim_y or			y
	def.dim_height = def.dim_height or		1000

	def.bedrock_depth = 50
	def.dirt_start = def.dim_y +			(def.dirt_start or 501)
	def.dirt_depth =				(def.dirt_depth or 3)
	def.ground_limit = def.dim_y +		(def.ground_limit or 530)
	def.water_depth = def.water_depth or		8
	def.enable_water = def.enable_water == nil
	def.terrain_density = def.terrain_density or	0.4
	def.flatland = def.flatland		
	def.gravity = def.gravity or			1
	--def.sky = def.sky
	--def.sun = def.sun
	--def.moon = def.moon

	def.map = def.map or {}
	def.map.offset = def.map.offset or 0
	def.map.scale = def.map.scale or 1
	def.map.spread = def.map.spread or {x=100,y=18,z=100}
	def.map.seeddiff = def.map.seeddiff or 24
	def.map.octaves = def.map.octaves or 5
	def.map.persist = def.map.persist or 0.7
	def.map.lacunarity = def.map.lacunarity or 1
	def.map.flags = def.map.flags or "absvalue"

	def.self.stone = def.stone or "default:stone"
	def.self.dirt = def.dirt or "default:dirt"
	def.self.grass = def.grass or "default:dirt_with_grass"
	def.self.air = def.air or "air"
	def.self.water = def.water or "default:water_source"
	def.self.sand = def.sand or "default:sand"
	def.self.bedrock = def.bedrock or "multidimensions:bedrock"

	def.self.dim_start = def.dim_y
	def.self.dim_end = def.dim_y+def.dim_height
	def.self.dim_height = def.dim_height
	def.self.ground_limit = def.ground_limit
	def.self.dirt_start = def.dirt_start
	--def.stone_ores {}
	--def.dirt_ores {}
	--def.grass_ores {}
	--def.ground_ores {}
	--def.air_ores {}
	--def.water_ores {}
	--def.sand_ores {}
	--on_generate=function(data,id,cdata,area,x,y,z)


	for i,v in pairs(table.copy(def.self)) do
		def.self[i] = minetest.registered_items[v] and minetest.get_content_id(v) or def.self[i]
	end

	for i1,v1 in pairs(table.copy(def)) do
		if  i1:sub(-5,-1)== "_ores" then
			for i2,v2 in pairs(v1) do
				local n = minetest.get_content_id(i2)
				def[i1][n] = {}
				local t = type(v2)
				if t == "number" then
					def[i1][n] = {chance=v2}
				elseif t ~="table" then
					error("Multidimensions: ("..name..") ore "..i2.." defines as number (chance) or table, is: ".. t)
				else
					def[i1][n] = v2
					local ndef = def[i1][n]
					ndef.chance = ndef.chance or 1000
					if ndef.min_heat and not ndef.max_heat then
						ndef.max_heat = 1000
					elseif ndef.max_heat and not ndef.min_heat then
						ndef.min_heat = -1000
					end
				end
				def[i1][i2]=nil
			end
		end
	end

	def.teleporter = def.teleporter == nil

	local node = def.teleporter and table.copy(def.node or {})
	local craft = def.teleporter and def.craft and table.copy(def.craft) or nil

	def.node = nil
	def.craft = nil

	multidimensions.registered_dimensions[name]=def

	if def.teleporter then

		node.description = node.description or		"Teleport to dimension " .. name
		node.tiles = node.tiles or			{"default_steel_block.png"}
		node.groups = node.groups or		{cracky=2}
		node.sounds = node.sounds or		default.node_sound_wood_defaults()
		node.on_construct = function(pos)
			minetest.get_meta(pos):set_string("infotext",node.description)
		end
		node.on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			if multidimensions.loading_area[minetest.pos_to_string(pos)] then
				minetest.chat_send_player(player:get_player_name(),"Loading...")
				return
			end
			minetest.sound_play("default_door_open",{pos=pos,gain=1,max_hear_distance=10})
			local meta=minetest.get_meta(pos)
			local sp = meta:get_string("pos")
			if sp ~= "" then
				player:set_pos(minetest.string_to_pos(sp))
				multidimensions.apply_dimension(player)
			else
				local pos2 = {x=pos.x,y=def.dirt_start+def.dirt_depth+2,z=pos.z}
				multidimensions.move(player,pos2,pos)
			end
		end

		node.name = "teleporter_" .. name
		node.craft = craft
		node.texture = node.tiles[1]
		default.register_door(node)
	end

	if def.dim_y > 0 and def.dim_y < multidimensions.earth.above then
		multidimensions.earth.above = def.dim_y
	elseif def.dim_y < 0 and def.dim_y+def.dim_height > multidimensions.earth.under then
		multidimensions.earth.under = def.dim_y+def.dim_height
	end
end

minetest.register_on_generated(function(minp, maxp, seed)
	for i,d in pairs(multidimensions.registered_dimensions) do
	if minp.y >= d.dim_y and maxp.y <= d.dim_y+d.dim_height then
		local depth = 18
		local height = d.dirt_start
		local ground_limit = d.ground_limit
		local dirt_depth = d.dirt_depth
		local water_depth = d.water_depth
		local lenth = maxp.x-minp.x+1
		local cindx = 1
		local map = minetest.get_perlin_map(d.map,{x=lenth,y=lenth,z=lenth}):get_3d_map_flat(minp)
		local enable_water = d.enable_water
		local terrain_density = d.terrain_density
		local flatland = d.flatland
		local heat = minetest.get_heat(minp)
		local humidity = minetest.get_humidity(minp)

		local miny = d.dim_y
		local maxy = d.dim_y+d.dim_height
		local bedrock_depth = d.bedrock_depth

		local dirt = d.self.dirt
		local stone =d.self.stone
		local grass = d.self.grass
		local air = d.self.air
		local water = d.self.water
		local sand = d.self.sand
		local bedrock = d.self.bedrock

		d.self.heat = heat
		d.self.humidity = humidity

		local vm,min,max = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
		local data = vm:get_data()

		for z=minp.z,maxp.z do
		for y=minp.y,maxp.y do
			local id=area:index(minp.x,y,z)
		for x=minp.x,maxp.x do
			local den = math.abs(map[cindx]) - math.abs(height-y)/(depth*2) or 0
			if y <= miny+bedrock_depth then
				data[id] = bedrock
			elseif enable_water and den < 0.3 and y <= height+d.dirt_depth+1 and y >= height-water_depth  then	
				data[id] = water
				if y+1 == height+d.dirt_depth+1 then -- fix water holes
					data[id+area.ystride] = water
				else
					data[id-area.ystride]=sand
				end
			elseif y < height then
				data[id] = stone
			elseif y >= height and y <= height+dirt_depth then
				data[id] = dirt
				data[id+area.ystride]=grass
			elseif not flatland then
				if y >= height and y<= ground_limit and den > terrain_density then
					data[id] = dirt
					data[id+area.ystride]=grass
					data[id-area.ystride]=stone
					if den > 1 then
						data[id]=stone
					end
				elseif data[id] ~= grass then
					data[id] = air
				end
			else
				data[id] = air
			end

			if d.on_generate then
				data = d.on_generate(d.self,data,id,area,x,y,z) or data
			end

			cindx=cindx+1
			id=id+1
		end
		end
		end

		for i1,v1 in pairs(data) do
			local da = data[i1]
			local typ
			if da == air and d.ground_ores and data[i1-area.ystride] == grass then
				typ = "ground"
			elseif da == grass and d.grass_ores then
				typ = "grass"
			elseif da == dirt and d.dirt_ores then
				typ = "dirt"
			elseif da == stone and d.stone_ores then
				typ = "stone"
			elseif da == air and d.air_ores then
				typ = "air"
			elseif da == water and d.water_ores then
				typ = "water"
			elseif da == sand and d.sand_ores then
				typ = "sand"
			end
			if typ then
				for i2,v2 in pairs(d[typ.."_ores"]) do
					if math.random(1,v2.chance) == 1 and not (v2.min_heat and (heat < v2.min_heat or heat > v2.max_heat)) then
						if v2.chunk then
							for x=-v2.chunk,v2.chunk do
							for y=-v2.chunk,v2.chunk do
							for z=-v2.chunk,v2.chunk do
								local id =i1+x+(y*area.ystride)+(z*area.zstride)
								if da == data[id] then
									data[id]=i2
								end
							end
							end
							end
						else
							data[i1]=i2
						end
					end
				end
			end
		end
		vm:set_data(data)
		vm:write_to_map()
		vm:update_liquids()
	end
	end
end)

minetest.register_node("multidimensions:bedrock", {
	description = "Bedrock",
	tiles = {"default_stone.png","default_cloud.png","default_stone.png","default_stone.png","default_stone.png","default_stone.png",},
	groups = {unbreakable=1,not_in_creative_inventory = 1},
	paramtype = "light",
	sunlight_propagates = true,
	drop = "",
	diggable = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("multidimensions:blocking", {
	description = "Blocking",
	drawtype="airlike",
	groups = {unbreakable=1,not_in_creative_inventory = 1,fall_damage_add_percent=1000},
	paramtype = "light",
	sunlight_propagates = true,
	drop = "",
	pointable=false,
	diggable = false,
})

minetest.register_node("multidimensions:killing", {
	description = "Killing",
	drawtype="airlike",
	groups = {unbreakable=1,not_in_creative_inventory = 1},
	paramtype = "light",
	sunlight_propagates = true,
	drop = "",
	walkable=false,
	damage_per_second = 9000,
	pointable=false,
	diggable = false,
})


--if multidimensions.limited_chat then
--minetest.register_on_chat_message(function(name, message)
--	local msger = minetest.get_player_by_name(name)
--	local pos1 = msger:get_pos()
--	for _,player in ipairs(minetest.get_connected_players()) do
--		local pos2 = player:get_pos()
--		if player:get_player_name()~=name and vector.distance(pos1,pos2)<multidimensions.max_distance_chatt then
--			minetest.chat_send_player(player:get_player_name(), "<"..name.."> "..message)
--		end
--	end
--	return true
--end)
--end

minetest.register_node("multidimensions:teleporterre", {
	description = "Teleport back",
	tiles = {"default_steelblock.png"},
	groups = {unbreakable=1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	drop = "default:cobble",
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local p = minetest.get_meta(pos):get_string("pos")
		if p == "" then
			minetest.remove_node(pos)
			return
		end
		player:set_pos(minetest.string_to_pos(p))
		multidimensions.apply_dimension(player)
	end,
})

if multidimensions.limeted_nametag==true and minetest.settings:get_bool("unlimited_player_transfer_distance")~=false then
	minetest.settings:set_bool("unlimited_player_transfer_distance",false)
	minetest.settings:set_bool("player_transfer_distance",multidimensions.max_distance)
	--minetest.settings:save()
elseif multidimensions.limeted_nametag==false and minetest.settings:get_bool("unlimited_player_transfer_distance")==false then
	minetest.settings:set_bool("unlimited_player_transfer_distance",true)
	minetest.settings:set_bool("player_transfer_distance",0)
end