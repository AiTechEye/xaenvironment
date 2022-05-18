places.citybuildings = {
	{name="house1",chance=5,size=1},
	{name="uncraft_sell_service",chance=20,size=1,freespace={{-1,0}}},
}

places.buildings.city={
	chance=50,sx=100,sy=100,miny=-50,maxy=150,spawn_at={"default:dirt"},
	on_spawn=function(pos)
		places.city(pos)
	end
}

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

--test map

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
print(citysize,terrain)
		if terrain >= citysize then
			citysize = citysize - 1
			if citysize < 1 then
				return
			end
		end
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
	end

if 1 then return end
--]]


	local citysize2 = (citysize*scale)+scale+10

	local vox = minetest.get_voxel_manip()
	local min, max = vox:read_from_map(vector.add(pos,citysize2), vector.subtract(pos,citysize2))
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vox:get_data()

	local road = minetest.get_content_id("materials:asphalt_slab")
	local dirt = minetest.get_content_id("default:dirt")
	local stone = minetest.get_content_id("default:stone")
	local sidewalk = minetest.get_content_id("materials:concrete")
	local grass = minetest.get_content_id("default:dirt_with_grass")
	local air = minetest.get_content_id("air")
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
		minetest.set_node(p,{name="places:city_npcspawner"})	
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

	for i,p in ipairs(road_paths) do
		minetest.set_node(p,{name="places:city_npccarspawner"})	
		minetest.get_meta(p):set_string("paths",road_paths2)
	end

end

minetest.register_node("places:city_npcspawner", {
	groups = {attached_node=1,not_in_creative_inventory=1,on_load=1},
	pointable=false,
	paramtype = "light",
	drawtype="airlike",
	drop="",
	walkable=false,
	floodable = true,
	sunlight_propagates = true,
	on_construct=function(pos)
		minetest.registered_nodes["places:city_npcspawner"].on_load(pos)
	end,
	on_load=function(pos)
		minetest.get_node_timer(pos):start(math.random(1,60))
	end,
	on_timer = function (pos, elapsed)

		if (examobs.active.types["examobs:npc"] or 0) > 20 then
			return true
		end

		local paths = minetest.get_meta(pos):get_string("paths")
		if paths == "" then
			minetest.remove_node(pos)
			return
		end
		local skin = player_style.skins.skins[math.random(1,26)].skin
		local file = io.open(minetest.get_modpath("places") .. "/city_npc.txt", "r")
		local text = file:read("*all")
		file:close()

		if text == "" then
			return
		end

		text = text:gsub("#skin#",player_style.skins.skins[math.random(1,26)].skin)
		text = text:gsub("#code#",paths)
		text = text:gsub("#distance#",2.4)

		local self = minetest.add_entity(apos(pos,0,1),"examobs:npc"):get_luaentity()

		self.storage.code_execute_interval = text
		self.storage.code_execute_interval_user = "singleplayer"
		self.object:set_properties({textures={skin},static_save = false})
		return true
	end
})

minetest.register_node("places:city_npccarspawner", {
	groups = {attached_node=1,not_in_creative_inventory=1,on_load=1},
	pointable=false,
	paramtype = "light",
	drawtype="airlike",
	drop="",
	walkable=false,
	floodable = true,
	sunlight_propagates = true,
	on_construct=function(pos)
		minetest.registered_nodes["places:city_npccarspawner"].on_load(pos)
	end,
	on_load=function(pos)
		minetest.get_node_timer(pos):start(math.random(1,60))
	end,
	on_timer = function (pos, elapsed)
		if (examobs.active.types["examobs:npc"] or 0) > 20 then
			return true
		end

		local paths = minetest.get_meta(pos):get_string("paths")
		if paths == "" then
			minetest.remove_node(pos)
			return
		end
		local skin = player_style.skins.skins[math.random(1,26)].skin
		local file = io.open(minetest.get_modpath("places") .. "/city_npc.txt", "r")
		local text = file:read("*all")
		file:close()

		if text == "" then
			return
		elseif not places.car_colors then
			places.car_colors = {}
			for i,v in pairs(minetest.registered_nodes) do
				if v.tiles and type(def.tiles) == "table" and type(def.tiles[1]) == "string" and not (v.groups and (v.groups.not_in_creative_inventory or v.groups.rail)) then
					table.insert(places.car_colors,{name=v.name,texture=v.tiles[1]})
				end
			end
		end
		local ndef = places.car_colors[math.random(1,#places.car_colors)]

		text = text:gsub("#skin#",player_style.skins.skins[math.random(1,26)].skin)
		text = text:gsub("#code#",paths)
		text = text:gsub("#distance#",4)

		local self = minetest.add_entity(apos(pos,0,1),"examobs:npc"):get_luaentity()
		
		self.storage.code_execute_interval = text
		self.storage.code_execute_interval_user = "singleplayer"
		self.object:set_properties({textures={skin},static_save = false})

		local car = minetest.add_entity(apos(pos,0,1),"quads:car"):get_luaentity()
		self.object:set_attach(car.object, "",{x=-5, y=-3, z=2})
		car.object:set_properties({static_save = false})
		car.user = self.object
		car.user_name= self.examob
		car.bot = self
		car.texture_node = ndef.name
		car.texture = ndef.texture
		car.color(car)

		return true
	end
})