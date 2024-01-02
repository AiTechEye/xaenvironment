places.buildings.city={
	chance=50,sx=100,sy=100,miny=-50,maxy=150,spawn_at={"default:dirt"},
	on_spawn=function(pos)
		places.city(pos)
	end
}

places.citybuildings = {
	{name="house1",chance=5,size=1},
	{name="places_plot",chance=30,size=1},
	{name="uncraft_sell_service",chance=30,size=1,freespace={{-1,0}}},
	{name="places_shop",chance=20,size=1,freespace={{0,-1}}},
	{name="places_burnserivce",chance=20,size=1,freespace={{-1,0}}},
	{name="places_portal_service",chance=30,size=1,freespace={{0,-1}}},
	{name="places_police_station",chance=30,size=1,freespace={{0,1}}},
	{name="places_building_skeleton",chance=40,size=1},
	{name="places_general_shop",chance=20,size=1,freespace={{0,-1}},
		on_spawn=function(pos)
			local g = {"store","stone","wood","flammable","exatec","eatable","ingot"}
			local group = g[math.random(1,#g)]
			local nodes = minetest.find_nodes_in_area(vector.subtract(pos,10),vector.add(pos,10),"xesmartshop:gamerules_shop")
			for i,v in pairs(nodes) do
				local m = minetest.get_meta(v)
				if m:get_string("add_group_stuff") == "" then
					m:set_string("add_group_stuff",group)
				end
			end
		end
	},
	{name="places_brickhousing1",chance=5,size=1,
		on_spawn=function(pos1)
			local pos = vector.new(pos1.x-8,pos1.y,pos1.z-8)
			local r = math.random(4,10)
			local y = 5
			for i=1,r do
				nodeextractor.set(apos(pos,0,y),minetest.get_modpath("places").."/nodeextractor/places_brickhousing2.exexn")
				y = y + 4
			end
			nodeextractor.set(apos(pos,0,y),minetest.get_modpath("places").."/nodeextractor/places_brickhousing3.exexn")
		end
	},
}

minetest.register_tool("places:genc", {
	groups = {not_in_creative_inventory=1,},
	inventory_image = "default_stick.png",
	on_use=function(itemstack, user, pointed_thing)
		if minetest.check_player_privs(user:get_player_name(), {server=true}) then
			places.city(vector.round(user:get_pos()))
		end
	end
})

places.ishouse=function(a)
	return a and a.house
end

places.city=function(pos)

	local min_size_for_middle_split = 5
	local citysize = 10
	local scale = 16
	local houses = 0
	local map = {}
	local ignore = {}
	local sewer_map = {}
	local sr1 = {{1,0},{-1,0},{0,1},{0,-1}}
	local sr2 = {{2,0},{-2,0},{0,2},{0,-2}}
	local sr3 = {{3,0},{-3,0},{0,3},{0,-3}}

--test map
	for y=math.floor(pos.y),0,-1 do
		local n = minetest.get_node(vector.new(pos.x,y,pos.z)).name
		if n ~= "ignore" and n ~= "air" or y < 3 then
			pos.y = y
			break
		end
	end

	for i=1,citysize do
		local terrain = 0
		for x=-citysize,citysize do
		for z=-citysize,citysize do
			local dpos = vector.new(pos.x+(x*16),pos.y,pos.z+(z*16))
			local def = minetest.registered_nodes[minetest.get_node(dpos).name]
			if def and def.groups and (def.groups.dirt or def.groups.stone) then
				terrain = terrain +1
			end
		end
		end

		if terrain >= citysize then
			citysize = citysize - 1
			if citysize < 1 then
				return
			end
		end
	end

	for i=citysize,1,-1 do
		if math.random(1,i > 3 and i*2 or i) == 1 then
			citysize = i
			break
		end
	end

	print("Generating a city",citysize,minetest.pos_to_string(pos))
	if citysize > 4 then
		minetest.chat_send_all("Generating a city in size " .. citysize..", expect a long lag")
	end
--gen map

	pos = vector.round(pos)
	for z=-citysize,citysize do
	local fil = false
	for x=-citysize,citysize do
		local p = apos(pos,x,0,z)
		map[x..","..z] = {street=true,pos=vector.new(x,0,z)}
		local z1 = places.ishouse(map[x..","..(z-1)])
		local z2 = places.ishouse(map[x..","..(z-2)])
		local x0 = places.ishouse(map[(x-1)..","..z])
		local x1 = places.ishouse(map[(x-1)..","..(z-1)])
		local x2 = places.ishouse(map[(x+1)..","..(z-1)])

		if fil then
			if z1 then
				map[x..","..z] = {house=true,pos=vector.new(x,0,z)}
				houses = houses +1
			else
				fil = false
			end
		elseif z == -10 and not (z==0 or z==1) then
			if not x0 or math.random(1,2) == 1 then
				map[x..","..z] = {house=true,pos=vector.new(x,0,z)}
				houses = houses +1
			end
		elseif not ((citysize >= min_size_for_middle_split and (z==0 or z==1)) or z1 and math.random(1,2) == 1) and (z1 or not (x1 or x2)) and (not x0 or math.random(1,2) == 1) then
			map[x..","..z] = {house=true,pos=vector.new(x,0,z)}
			houses = houses +1
			if z1 then
				fil = true
			end
		end

		if math.random(0,2) == 0 then
			sewer_map[x..","..z] = {
				manhole_cover = map[x..","..z].street,
				pos = vector.new(x,0,z),
			}

			for i,v in ipairs(sr2) do
				if sewer_map[x+sr3[i][1]..","..z+sr3[i][2]] then
					local s = x+sr2[i][1]..","..z+sr2[i][2]
					sewer_map[s] = {
						manhole_cover = map[s].street,
						pos = vector.new(x+sr2[i][1],0,z+sr2[i][2])
					}
				end
				if sewer_map[x+v[1]..","..z+v[2]] then
					local s = x+sr1[i][1]..","..z+sr1[i][2]
					sewer_map[s] = {
						manhole_cover = map[s].street,
						pos = vector.new(x+sr1[i][1],0,z+sr1[i][2])
					}
				end
			end
		end
	end
	end

--changes

	for i,v in pairs(map) do
		local dpos = vector.add(apos(pos,8,0,8),vector.multiply(v.pos,16))
		local def = minetest.registered_nodes[minetest.get_node(dpos).name]
		if def and def.groups and (def.groups.dirt or def.groups.stone) then
			ignore[v.pos.x..","..v.pos.z] = true
			map[i].house = nil
			map[i].street = nil
		elseif v.house then
			local X = v.pos.x
			local Z = v.pos.z
--park
			if math.random(1,houses) == 1 and citysize > 3 then
				local block = {[X..","..Z]={X,Z}}
				local done = true
				map[X..","..Z].park = true
				map[X..","..Z].house = nil
				while(done) do
					local found = false
					for bi,b in pairs(block) do
					for x=-1,1 do
					for z=-1,1 do
						local id = (b[1]+x)..","..(b[2]+z)
						local h = map[id]
						if h and h.house and not block[id] then
							block[id] = {b[1]+x,b[2]+z}
							map[id].park =  true
							map[id].house =  nil
							found = true
						end
					end
					end
					end
					done = found
				end
			else
--courtyard
				local traped = true
				for i2,p in pairs({{-1,0},{0,0},{1,0},{0,-1},{0,1}}) do
					local h = map[(X+p[1])..","..(Z+p[2])]
					if not (h and (h.house or h.courtyard)) then
						traped = false
						break
					end
				end
				if traped then
					map[X..","..Z].house = nil
					map[X..","..Z].courtyard = true
				end
			end
		end
	end
--testing

--[[
	for i,v in pairs(map) do
		local n = "default:bedrock"
		if v.house then
			n = "materials:concrete"
		elseif v.courtyard then
			n = "default:dirt_with_grass"
		elseif v.park then
			n = "default:dirt_with_grass"
		end
		minetest.set_node(apos(pos,v.pos.x,0,v.pos.z),{name=n})
		local smap = sewer_map[i]
		if smap then
			minetest.set_node(apos(pos,v.pos.x,-2,v.pos.z),{name="default:stone"})
			if smap.manhole_cover then
				minetest.set_node(apos(pos,v.pos.x,-1,v.pos.z),{name="default:glass"})
			end
		end

	end

if 1 then return end
--]]


	local citysize2 = (citysize*scale)+scale+10

	local vox = minetest.get_voxel_manip()
	local min, max = vox:read_from_map(vector.add(pos,citysize2), vector.subtract(pos,citysize2))
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vox:get_data()

	local road = minetest.get_content_id("materials:asphalt") --materials:asphalt_slab
	local dirt = minetest.get_content_id("default:dirt")
	local stone = minetest.get_content_id("default:stone")
	local sidewalk = minetest.get_content_id("materials:concrete")
	local grass = minetest.get_content_id("default:dirt_with_grass")
	local air = minetest.get_content_id("air")
	local water = minetest.get_content_id("default:salt_water_source")
	local brick = minetest.get_content_id("default:brickblock")

	protect.add_game_rule_area(vector.add(pos,citysize2+scale),vector.subtract(pos,citysize2+scale),"City")

--roads

	for x = -citysize2+scale,citysize2 do
	for z = -citysize2+scale,citysize2 do
		local id = area:index(pos.x+x,pos.y,pos.z+z)
		local ig = ignore[math.floor(x/16)..","..math.floor(z/16)]

		if not ig then
			for y = -scale*2,scale do
				local id = area:index(pos.x+x,pos.y+y,pos.z+z)
				if y < 0 then
					data[id] = stone
				elseif y > 0 then
					data[id] = air
				end
			end
		end
		
		if not ig and (citysize >= min_size_for_middle_split and z >scale-2 and z < scale+3 and math.abs(x) >= scale/2) then
			if (z == scale or z == scale+1) and math.abs(x) ~= scale/2 then
				data[id] = grass
				--data[id+area.ystride] = grass
			else
				data[id] = sidewalk
			end
		elseif not ig then
			data[id]=road
		end
	end
	end


--make more complex sewer systems


	for i,v in pairs(sewer_map) do
		local dirs = 0
		for i2,sr in ipairs(sr1) do
			if sewer_map[v.pos.x+sr[1]..","..v.pos.z+sr[2]] then
				dirs = dirs + 1
			end
		end
		if dirs > 2 and math.random(1,6-dirs) == 1 then
			sewer_map[i] = nil
		end
	end


--sewer


	for i1,v in pairs(sewer_map) do
		local dpos = vector.add(apos(pos,0,-11,0),vector.multiply(v.pos,16))
		local uy = math.random(1,5) == 1 and -scale*2 or -1
		local underroom_width = math.random(1,4)
		local hole = math.random(1,4) == 1
		local deep_treasure

		for y=uy,10 do
		for x=-8,8 do
		for z=-8,8 do
			local id = area:index(dpos.x+x,dpos.y+y,dpos.z+z)
			data[id] = brick
			if hole and y < 7 and y > uy and math.abs(x) <= underroom_width and math.abs(z) < underroom_width then
				minetest.after(1,function()
					minetest.set_node(vector.new(dpos.x+x,dpos.y+y,dpos.z+z),{name="air"})
				end)
			elseif y > uy and y <= -1 and math.abs(x) <= underroom_width and math.abs(z) < underroom_width then
				data[id] = water
				if not deep_treasure and y+1 == uy and math.random(1,3) == 1 then
					deep_treasure = true
					minetest.after(1,function()
						default.treasure({level=math.random(1,3),pos=vector,new(dpos.x+x,dpos.y+y,dpos.z+z)})
					end)
				end
			end
		end
		end
		end

		for i2,sr in ipairs(sr1) do
			local neighbour = sewer_map[v.pos.x+sr[1]..","..v.pos.z+sr[2]]
			local mx = sr[1] * 4
			local mz = sr[2] * 4
			local X = 4
			local Z = 4
			local width = 4
			local r = math.random(1,3)
			local treasure_pos
			local treasure_id

			if i2 <= 2 then
				Z = neighbour and neighbour.width or v.width or math.random(1,4)
				sewer_map[i1].width = Z
				width = Z
			else
				X = neighbour and neighbour.width or v.width or math.random(1,4)
				sewer_map[i1].width = X
				width = X
			end

			for y=0,5 do
			for x=-X,X do
			for z=-Z,Z do
				local id = area:index(dpos.x+x+mx,dpos.y+y,dpos.z+z+mz)
				local absx = math.abs(x)
				local absz = math.abs(z)

				if not treasure_pos and y == 0 and math.random(1,10) == 1 then
					treasure_pos = vector.new(dpos.x+x+mx,dpos.y+y,dpos.z+z+mz)
					treasure_id = id
				end

				if neighbour and data[id] == brick then
					data[id] = air
					if y <= 2 then
						data[id] = water
					end
					if width <= 2 then
						if r == 1 and y > 1 or r == 2 and y > 2 or r == 3 and (y < 1 or y > 1) then
							data[id] = brick
						end
					elseif width >= 3 and y <= 2 then
						if sr[1] > 0 and x > -2 and absz >= 3
						or sr[1] < 0 and x < 2 and absz >= 3
						or sr[2] > 0 and z > -2 and absx >= 3
						or sr[2] < 0 and z < 2 and absx >= 3 then
							data[id] = sidewalk
						elseif y < 2 and absx < 3 or absz < 3 then
							data[id] = water
						end
					end
				elseif data[id] == brick then
					if width >= 3 and y <= 2 then
						if sr[1] > 0 and x <= 0 and x > -2
						or sr[1] < 0 and x >= 0 and x < 2
						or sr[2] > 0 and z <= 0 and z > -2
						or sr[2] < 0 and z >= 0 and z < 2 then
							data[id] = sidewalk
						end
					end
				end
			end
			end
			end
			if treasure_pos  and math.random(1,4) == 1 and (data[treasure_id] == water or data[treasure_id+area.ystride] == water) then
				local y = data[treasure_id] == water and 0 or 1
				minetest.after(5,function()
					default.treasure({level=math.random(1,10) == 1 and 2 or 1,pos=apos(treasure_pos,0,y)})
				end)
			end

			if v.manhole_cover then
				local dir
				for i,v in ipairs(sr1) do
					local id = area:index(dpos.x+width+v[1],dpos.y+1,dpos.z+v[2])
					if data[id] == brick then
						dir = vector.new(v[1],0,v[2])
						break
					end
				end

				local a = area:index(dpos.x+width,dpos.y+2,dpos.z)
				if sidewalk == data[a] or water == data[a] then
					for y=3,11 do
						if dir then
							minetest.after(1,function()
								minetest.set_node(vector.new(dpos.x+width,dpos.y+y,dpos.z),{name="default:ladder_metal",param2=minetest.dir_to_wallmounted(dir)})
							end)
						else
							data[area:index(dpos.x+width,dpos.y+y,dpos.z)] = air
						end
					end
					minetest.after(5,function()
						minetest.set_node(vector.new(dpos.x+width,dpos.y+12,dpos.z),{name="places:manhole_cover"})
					end)
				end
			end
		end
	end


--build city


	local sidewalk_paths1 = {}
	local sidewalk_paths2 = {}
	local road_paths = {vector.new(pos.x,pos.y+1,pos.z+scale)}
	local plantspos = {}
	local lamppos = {}
	for i,v in pairs(map) do

		local X = v.pos.x
		local Z = v.pos.z

		local xm = map[(X-1)..","..Z]
		local xp = map[(X+1)..","..Z]
		local zm = map[X..","..(Z-1)]
		local zp = map[X..","..(Z+1)]

		if ignore[X..","..Z] then
		elseif v.street then
			table.insert(road_paths,vector.new(pos.x+(X*scale)+(scale/2),pos.y+1,pos.z+(Z*scale)+(scale/2)))
		elseif v.house then
			for x=1,scale, scale-1 do
				for z=-1,scale+2, scale+3 do
					table.insert(sidewalk_paths1,vector.new(pos.x+(X*scale)+x,pos.y+1,pos.z+(Z*scale)+z))
					table.insert(sidewalk_paths1,vector.new(pos.x+(X*scale)+z,pos.y+1,pos.z+(Z*scale)+x))
				end
			end

			for x=-2,scale+3 do
			for z=-2,scale+3 do
				local id = area:index(pos.x+(X*scale)+x,pos.y,pos.z+(Z*scale)+z)
				data[id]=sidewalk
--lamps
				if x == scale/2 and z == -2 and not (zm and zm.house) then
					table.insert(lamppos,{pos=vector.new(pos.x+(X*scale)+x,pos.y,pos.z+(Z*scale)+z),dir=vector.new(0,0,-1)})
				elseif x == scale/2 and z == scale+3 and not (zp and zp.house) then
					table.insert(lamppos,{pos=vector.new(pos.x+(X*scale)+x,pos.y,pos.z+(Z*scale)+z),dir=vector.new(0,0,1)})
				elseif x == -2  and z == scale/2 and not (xm and xm.house) then
					table.insert(lamppos,{pos=vector.new(pos.x+(X*scale)+x,pos.y,pos.z+(Z*scale)+z),dir=vector.new(-1,0,0)})
				elseif x == scale+3  and z == scale/2 and not (xp and xp.house) then
					table.insert(lamppos,{pos=vector.new(pos.x+(X*scale)+x,pos.y,pos.z+(Z*scale)+z),dir=vector.new(1,0,0)})
				end
			end
			end
		elseif v.courtyard or v.park then
			for x=1,scale do
			for z=1,scale do
				local id = area:index(pos.x+(X*scale)+x,pos.y,pos.z+(Z*scale)+z)
				data[id]=grass
				table.insert(plantspos,vector.new(pos.x+(X*scale)+x,pos.y+1,pos.z+(Z*scale)+z))
			end
			end
		end
	end

	vox:set_data(data)
	vox:write_to_map()
	vox:update_map()
	vox:update_liquids()

	for i,p in ipairs(plantspos) do
		local r = math.random(1,1000)
		if r == 1 then
			minetest.set_node(p,{name=default.registered_trees[math.random(1,#default.registered_trees)]})
			minetest.get_node_timer(p):start(0.1)
		elseif r == 2 then
			minetest.set_node(p,{name=default.registered_bushies[math.random(1,#default.registered_bushies)]})
		elseif r < 100 then
			local j = default.registered_plants[math.random(1,#default.registered_plants)]
			local def = minetest.registered_nodes[j]
			if def.drawtype ~= "plantlike_rooted" and j ~= "plants:lily_pad" then
				minetest.set_node(p,{name=j})
			end
		else
			minetest.set_node(p,{name="plants:grass"..math.random(1,5)})
		end
	end

	for i,v in pairs(map) do
		if v.house and not ignore[v.pos.x..","..v.pos.z] then
			local X = v.pos.x
			local Z = v.pos.z
			local house
			local s = #places.citybuildings
			while(house == nil) do
				local h = places.citybuildings[math.random(1,s)]
				if math.random(1,h.chance) == 1 then
					if h.freespace then
						local block
						for f,r in ipairs(h.freespace) do	
							local spc = map[(X+r[1])..","..(Z+r[2])]
							if not (spc == nil or spc.street) then
								block = true
								break
							end
						end
						if not block then
							house = h
						end
					else
						house = h
					end
				end
			end

			nodeextractor.set(vector.new(pos.x+(v.pos.x*scale)+1,pos.y+v.pos.y,pos.z+(v.pos.z*scale)+1),minetest.get_modpath("places").."/nodeextractor/"..house.name..".exexn")
			if house.on_spawn then
				house.on_spawn(vector.new(pos.x+(v.pos.x*scale)+1+math.floor(scale/2),pos.y+v.pos.y,pos.z+(v.pos.z*scale)+1+math.floor(scale/2)))
			end
		end
	end
	for i,v in pairs(lamppos) do
		for h=1,7 do
			minetest.set_node(apos(v.pos,0,h),{name="exatec:wire",param2=112})
		end
		local l = apos(v.pos,0,8)
		minetest.set_node(l,{name="exatec:light_detector"})
		minetest.set_node(apos(v.pos,v.dir.x,v.dir.y+7,v.dir.z),{name="exatec:wire",param2=112})
		minetest.set_node(apos(v.pos,v.dir.x,v.dir.y+8,v.dir.z),{name="default:lamp_off"})
		local m = minetest.get_meta(l)
		m:set_int("level",7)
		m:set_int("type",2)
		m:set_string("infotext","")
		minetest.get_node_timer(l):start(20)
	end
	local pathpoints = "{"
	for i,p in ipairs(sidewalk_paths1) do
		local n = minetest.get_node(p).name
		if n == "air" or n == "ignore" then
			minetest.set_node(p,{name="exatec:light_detector"})	
			table.insert(sidewalk_paths2,p)
			pathpoints = pathpoints .."{x="..p.x..",y="..p.y..",z="..p.z.."},"
		end
	end
	pathpoints = pathpoints .."}"

	for i,p in ipairs(sidewalk_paths2) do
		minetest.set_node(p,{name="places:city_roadwalker_path"})	
		minetest.get_meta(p):set_string("paths",pathpoints)
	end

	local rp = {}
	for x = -citysize2+scale,citysize2 do
	for z = -citysize2+scale,citysize2 do
		local min = -citysize2+scale+4
		local max = citysize2-4
		local x1 = x+5
		local z1 = z+5
		if not ignore[math.floor(x1/16)..","..math.floor(z1/16)] then
		elseif (x == min or x == max) and z1/16 == math.floor(z1/16) or (z == min or z == max) and x1/16 == math.floor(x1/16) then
			local p = vector.new(pos.x+x,pos.y+1,pos.z+z)
			local i = p.x..","..p.z
			if not rp[i] then
				rp[i] = true
				table.insert(road_paths,p)
			end
		end
	end
	end

	local road_paths2 = "{"
	for i,p in ipairs(road_paths) do
		road_paths2 = road_paths2 .."{x="..p.x..",y="..p.y..",z="..p.z.."},"
	end
	road_paths2 = road_paths2 .."}"

	for _, player in pairs(minetest.get_connected_players()) do
		local pp = player:get_pos()
		if pp.x <= pos.x+citysize2 and pp.x >= pos.x-citysize2
		or pp.z <= pos.z+citysize2 and pp.z >= pos.z-citysize2
		or pp.y <= pos.y+citysize2 and pp.y >= pos.y-citysize2 then
			local nearest_d
			local nearest_path
			for i,p in ipairs(road_paths) do
				local d = vector.distance(pp,p)
				if not nearest_path or d < nearest_d then
					nearest_d = d
					nearest_path = p
				end
			end
			if nearest_path then
				player:set_pos(nearest_path)
			end
		end
	end

	for i,p in ipairs(road_paths) do
		minetest.set_node(p,{name="places:city_roaddriver_path"})	
		minetest.get_meta(p):set_string("paths",road_paths2)
	end
end

minetest.register_node("places:manhole_cover", {
	description = "Manhole cover",
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(pos,{name="places:manhole_cover_open"})
		minetest.sound_play("default_metal_place", {pos=pos, gain = 2,max_hear_distance = 5})
	end,
	on_construct=function(pos)
		minetest.get_meta(pos):set_string("infotext","Manhole cover")
	end,
	tiles={"default_ironblock.png"},
	groups = {cracky=2,treasure=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
		}
	}
})
minetest.register_node("places:manhole_cover_open", {
	description = "Manhole cover open",
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(pos,{name="places:manhole_cover"})
		minetest.sound_play("default_metal_place", {pos=pos, gain = 2,max_hear_distance = 5})
	end,
	drop = "places:manhole_cover",
	tiles={"default_ironblock.png"},
	groups = {cracky=2},
	sounds = default.node_sound_metal_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{0.5, -0.5, -0.5, 1.5, -0.45, 0.5},
		}
	},
})

minetest.register_craft({
	output="places:manhole_cover",
	recipe={
		{"default:ironingot","default:ironlump","default:ironingot"},
	},
})