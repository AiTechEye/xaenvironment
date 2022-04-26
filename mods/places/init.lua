places = {
	buildings = {
		["cloud castle"]={
			chance=100,sx=112,sy=16,miny=200,maxy=300,spawn_at={"air"},
			on_spawn=function(pos)
				minetest.place_schematic(pos,minetest.get_modpath("places").."/schematics/places_cloudcastle.mts","random",nil,true,"place_center_x,place_center_z")
				local nodes = minetest.find_nodes_in_area(vector.subtract(pos,50),vector.add(pos,50),"examobs:cloud_chest")
				for i,v in pairs(nodes) do
					default.treasure({level=2,pos=v,node="examobs:cloud_chest"})
				end
			end
		},
		["lava castle"]={
			chance=200,sx=50,sy=50,miny=-30000,maxy=-200,spawn_at={"default:stone"},
			on_spawn=function(pos)
				local s = 75
				local pos1 = vector.subtract(pos,s)
				local pos2 = vector.add(pos,s)
				local air = minetest.get_content_id("air")
				local lava = minetest.get_content_id("default:lava_source")
				local bedrock = minetest.get_content_id("default:bedrock")
				local water = minetest.get_content_id("default:salt_water_source")
				local vm = minetest.get_voxel_manip()
				local min, max = vm:read_from_map(pos1, pos2)
				local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
				local data = vm:get_data()
				for z=-s,s do
				for y=-s,s do
				for x=-s,s do
					local id=area:index(pos.x+x,pos.y+y,pos.z+z)
					local d1 = vector.length(vector.new({x=x,y=y,z=z}))/s
					local d2 = vector.length(vector.new({x=x,y=0,z=z}))/s

					if y <=-1 and (math.abs(x) <= 24 and math.abs(z) <= 24) then
						data[id] = bedrock
					elseif y <= -s/1.5 and d2 < 1.1 then
						data[id] = lava
					elseif d1 < 1 or y <= 0 and d2 < 1 then
						data[id] = air
					elseif d1 >= 1 and data[id] == water then
						data[id] = bedrock
					end
					id=id+1
				end
				end	
				end
				vm:set_data(data)
				vm:write_to_map()

				local r = {"0","90","180","270"}
				local pos3
				r = r[math.random(1,4)]

				minetest.place_schematic(pos,minetest.get_modpath("places").."/schematics/places_lavacastle.mts",r,nil,true,"place_center_x,place_center_z")

				if r == "0" then
					pos3 = vector.new(pos.x,pos.y+1,pos.z-50)
				elseif r == "180" then
					pos3 = vector.new(pos.x,pos.y+1,pos.z+50)
				elseif r == "90" then
					pos3 = vector.new(pos.x-50,pos.y+1,pos.z)
				elseif r == "270" then
					pos3 = vector.new(pos.x+50,pos.y+1,pos.z)
				end
				minetest.place_schematic(pos3,minetest.get_modpath("places").."/schematics/places_lavacastle_bridge.mts",r,nil,false,"place_center_x,place_center_z")
				local nodes = minetest.find_nodes_in_area(vector.subtract(pos,30),vector.add(pos,30),"materials:iron_chest")
				for i,v in pairs(nodes) do
					default.treasure({level=2,pos=v,node="materials:iron_chest"})
				end
			end
		},
		["stairs to sky"]={
			chance=50,sx=10,sy=250,miny=-20,maxy=70,spawn_at={"default:dirt"},
			on_spawn=function(pos)
				local p2
				for y=0,5 do
					local p = vector.new(pos.x,pos.y+y,pos.z)

					if minetest.get_item_group(minetest.get_node(p).name,"spreading_dirt_type") > 0 then
						p2 = p
						break
					end
				end

				if p2 then
					local height = 250
					local e = {{-6,-6},{6,-6},{-6,6},{6,6}}
					local nodes = {"default:stone","default:cobble","default:mossycobble","default:bedrock","default:cobble_porous","air"}
					local node2p = "default:stone"
					for x=-6,6 do
					for z=-6,6 do
						if math.random(0,#nodes) == 0 then
							node2p = nodes[math.random(1,#nodes)]
						end
						if node2p ~= "air" then
							minetest.set_node(vector.new(p2.x+x,p2.y,p2.z+z),{name=node2p})
							if math.abs(x) == 6 or math.abs(z) == 6 then
								minetest.set_node(vector.new(p2.x+x,height+1,p2.z+z),{name=node2p})
							end
						end
					end
					end
					local x = -6
					local z = -5
					local s = 0
					local p = 1

					for y=p2.y,height do
						if s <= 10 then
							x = x + 1
							p = 1
						elseif s <= 20 then
							z = z + 1
							p = 0
						elseif s <= 30 then
							x = x - 1
							p = 3
						elseif s <= 41 then
							z = z - 1
							p = 2
						end
						s = s +1
	
						if math.random(0,#nodes) == 0 then
							node2p = nodes[math.random(1,#nodes)]
						end
						if node2p ~= "air" then
							minetest.set_node(vector.new(p2.x+x,y,p2.z+z),{name=node2p})
						end
						if math.random(0,#nodes) == 0 then
							node2p = nodes[math.random(1,#nodes)]
						end
						if node2p ~= "air" then
							minetest.set_node(vector.new(p2.x+x,y+1,p2.z+z),{name=node2p.."_stair",param2=p})
						end

						for i,v in pairs(e) do
							if math.random(0,#nodes) == 0 then
								node2p = nodes[math.random(1,#nodes)]
							end
							if node2p ~= "air" then
								minetest.set_node(vector.new(p2.x+v[1],y,p2.z+v[2]),{name=node2p})
							end
						end

						if s >= 41 then
							s = 1
							x = -5
							z = -5
						end

					end
				end
			end
		},
	--	["city"]={
	--		chance=50,sx=10,sy=250,miny=0-20,maxy=50,spawn_at={"default:dirt"},
	--		on_spawn=function(pos)
	--		end,
	--	}
	}
}

minetest.register_on_generated(function(minp, maxp, seed)
	local vm,min,max
	local area
	local data
	for i,v in pairs(places.buildings) do
		if math.random(0,v.chance) == 0 and (v.miny <= minp.y and v.maxy >= maxp.y) then
			local spawn_at = {}
			for i1,v1 in pairs(v.spawn_at) do
				spawn_at[minetest.get_content_id(v1)] = true
			end
			if not data then
				vm,min,max = minetest.get_mapgen_object("voxelmanip")
				area = VoxelArea:new({MinEdge = min, MaxEdge = max})
				data = vm:get_data()
			end
			for t=0,10 do
				local tx = vector.new(math.random(minp.x,maxp.x),maxp.y,math.random(minp.z,maxp.z))
				for y=maxp.y,minp.y,-1 do
					if spawn_at[data[area:index(tx.x,y,tx.z)]] then
						local sp = vector.new(tx.x,y,tx.z)
						minetest.emerge_area(vector.subtract(sp,v.sx,v.sy,v.sx),vector.add(sp,v.sx,v.sy,v.sx))
						minetest.after(0.01,function(v,sp)
							v.on_spawn(sp)
						end,v,sp)
						return
					end
				end
			end
		end
	end
end)

minetest.register_tool("places:spawn", {
	description = "Spawn place",
	inventory_image = "default_stick.png",
	on_use=function(itemstack, user, pointed_thing)
		local pos = user:get_pos()
		--places.buildings["lava castle"].on_spawn(vector.round(pos))
		--places.city(pos)
	end
})

places.ishouse=function(a)
	return a and a.house
end

places.city=function(pos)
--gen map
	local citysize = 10
	local scale = 16
	local houses = 0
	local map = {}
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
		elseif not ((z==0 or z==1)    or z1 and math.random(1,2) == 1) and (z1 or not (x1 or x2)) and (not x0 or math.random(1,2) == 1) then
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
		if v.house then
			local X = v.pos.x
			local Z = v.pos.z
--park
			if math.random(1,houses) == 1 then
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

	local vox = minetest.get_voxel_manip()
	local min, max = vox:read_from_map(vector.add(pos,citysize*scale ), vector.subtract(pos,citysize*scale ))
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vox:get_data()

	local road = minetest.get_content_id("default:bedrock")
	local house = minetest.get_content_id("default:dirt")
	local sidewalk = minetest.get_content_id("materials:concrete")
	local grass = minetest.get_content_id("default:dirt_with_grass")
	local dirt = minetest.get_content_id("default:dirt")

--roads
	for x = -citysize*scale,citysize*scale do
	for z = -citysize*scale,citysize*scale do
		local id = area:index(pos.x+x,pos.y,pos.z+z)
		if z >scale-2 and z < scale+3 and math.abs(x) > scale/2 then
			local s = scale/2
			if (z == scale or z == scale+1) and (math.abs(x-1) > s or math.abs(x+1) > s) then

				data[id] = dirt
				data[id+area.ystride] = grass
			else

				data[id] = sidewalk
				data[id+area.ystride] = sidewalk
			end
		else
			data[id]=road
		end
	end
	end
--build city
	for i,v in pairs(map) do

		local X = v.pos.x
		local Z = v.pos.z

		local xm = map[(X-1)..","..(Z)]
		local xp = map[(X+1)..","..(Z)]
		local zm = map[(X)..","..(Z-1)]
		local zp = map[(X)..","..(Z+1)]

		if v.house then
			for x=-2,scale+3 do
			for z=-2,scale+3 do
				local id = area:index(pos.x+(X*scale)+x,pos.y,pos.z+(Z*scale)+z)
				data[id]=sidewalk
			end
			end
		elseif v.courtyard or v.park then
			for x=1,scale do
			for z=1,scale do
				local id = area:index(pos.x+(X*scale)+x,pos.y,pos.z+(Z*scale)+z)
				data[id]=grass
			end
			end
		end
	end
	vox:set_data(data)
	vox:write_to_map()
	vox:update_map()
	vox:update_liquids()

	for i,v in pairs(map) do
		if v.house then
--			nodeextractor.set(vector.new(pos.x+(v.pos.x*scale)+1,pos.y+v.pos.y,pos.z+(v.pos.z*scale)+1),minetest.get_modpath("places").."/nodeextractor/house1.exexn")
		end
	end

end
