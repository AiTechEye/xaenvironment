places = {
	buildings = {
		["cloud castle"]={
			chance=100,sx=112,sy=16,miny=240,maxy=260,spawn_at={"air"},
			on_spawn=function(pos)
				minetest.place_schematic(pos,minetest.get_modpath("places").."/schematics/places_cloudcastle.mts","random",nil,true,"place_center_x,place_center_z")
				local nodes = minetest.find_nodes_in_area(vector.subtract(pos,50),vector.add(pos,50),"examobs:cloud_chest")
				for i,v in pairs(nodes) do
					default.treasure({level=2,pos=v,node="examobs:cloud_chest"})
				end
			end
		},
		["stairs to sky"]={
			chance=50,sx=10,sy=250,miny=0,maxy=50,spawn_at={"default:dirt"},
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
		}
	}
}

minetest.register_on_generated(function(minp, maxp, seed)
	local vm,min,max
	local area
	local data
	for i,v in pairs(places.buildings) do
local r = math.random(0,v.chance)
print(i," ",r)
		if math.random(0,v.chance) == 0 and minp.y-100 <= v.miny and maxp.y+100 >= v.maxy then
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

print(y," ", v.miny ," ", v.maxy," ",spawn_at[data[area:index(tx.x,y,tx.z)]])
					if y >= v.miny and y <= v.maxy and spawn_at[data[area:index(tx.x,y,tx.z)]] then
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
		places.buildings["stairs to sky"].on_spawn(vector.round(pos))
	end
})