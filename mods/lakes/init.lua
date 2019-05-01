lakes={registered_lakes={}}

minetest.register_tool("lakes:test", {
	inventory_image = "default_stick.png",
	groups={not_in_creative_inventory=1},
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type~="node" then return itemstack end
	lakes.set_lake({
		radius = 5, --math.random(5,20),
		source = "default:water_source",
		pos = pointed_thing.under,
		in_nodes = {
			"default:dirt",
			"default:dirt_with_grass",
			"default:sand",
			"default:water_source",
		}
	})
	end,
})

minetest.register_tool("lakes:test2", {
	inventory_image = "default_stick.png",
	groups={not_in_creative_inventory=1},
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type~="node" then return itemstack end

		local d=lakes.registered_lakes["lava"]
		d.pos=pointed_thing.under
		lakes.set_lake(d)
	end
})

lakes.registry_lake=function(name,def)
	def.spawn_in=minetest.get_content_id(def.spawn_in)
	lakes.registered_lakes[name]=def
end

lakes.set_lake=function(def)
	local rad = type(def.radius)=="number" and def.radius or type(def.radius)=="table" and math.random(def.radius[1],def.radius[2]) or 5

	local nodes_n
	local c_source = minetest.get_content_id(def.source)
	local c_air = minetest.get_content_id("air")
	local nodes={}
	local pos=def.pos

	nodes[c_source]=true

	for i, v in pairs(def.in_nodes) do
		nodes_n=i
		nodes[minetest.get_content_id(v)]=true
	end

	local pos1 = vector.subtract(pos, rad+2)
	local pos2 = vector.add(pos, rad+2)
	local vox = minetest.get_voxel_manip()
	local min, max = vox:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vox:get_data()
	for y = 0, -math.floor(rad/2),-1 do
	for z = -rad-y, rad+y do
	for x = -rad-y, rad+y do
		local r = vector.length(vector.new(x,y,z))
		local c = {x=pos.x+x,y=pos.y+y,z=pos.z+z}
		if rad/r>=1
		and nodes[data[area:index(c.x+1,c.y,c.z+1)]]
		and nodes[data[area:index(c.x+1,c.y,c.z-1)]]
		and nodes[data[area:index(c.x-1,c.y,c.z-1)]]
		and nodes[data[area:index(c.x-1,c.y,c.z+1)]]
		and nodes[data[area:index(c.x,c.y-1,c.z)]] then
			local uid = data[area:index(c.x,c.y+1,c.z)]
			if (y~=0 and uid == c_source) or def.underground then
				data[area:index(c.x,c.y,c.z)] = c_source
			else
				local ndef = minetest.registered_items[minetest.get_name_from_content_id(uid)]
				if uid == c_air or (ndef and not ndef.walkable) then
					data[area:index(c.x,c.y,c.z)] = c_source
					data[area:index(c.x,c.y+1,c.z)] = c_air
				end
			end
		end
	end
	end
	end
	vox:set_data(data)
	vox:write_to_map()
	vox:update_map()
	vox:update_liquids()
end

minetest.register_on_generated(function(min, max, seed)
	for _,def in pairs(lakes.registered_lakes) do
		if def.chance == math.random(1,def.chance) and def.min_y <= min.y and def.max_y >= max.y then
			local c = {x=min.x+math.floor((max.x-min.x)/2),y=min.y+math.floor((max.y-min.y)/2),z=min.z+math.floor((max.z-min.z)/2)}
			local pos1 = vector.subtract(c, 30)
			local pos2 = vector.add(c, 30)
			local vox = minetest.get_voxel_manip()
			local pmin, pmax = vox:read_from_map(pos1, pos2)
			local area = VoxelArea:new({MinEdge = pmin, MaxEdge = pmax})
			local data = vox:get_data()
			for y=-30,30 do
				if c.y+y >= def.min_y and c.y+y <= def.max_y and data[area:index(c.x,c.y+y,c.z)] == def.spawn_in then
					def.pos = {x=c.x,y=c.y+y,z=c.z}
					lakes.set_lake(def)
					break
				end
			end
		end
	end
end)

lakes.registry_lake("frech water lakes",{
	spawn_in = "default:dirt_with_grass",
	chance = 10,
	min_y = -50,
	max_y = 50,
	radius = math.random(5,20),
	source = "default:water_source",
	in_nodes = {
		"default:dirt",
		"default:dirt_with_grass",
		"default:sand",
		"default:water_source",
	}
})

lakes.registry_lake("lava",{
	spawn_in = "default:stone",
	chance = 5,
	min_y = -31000,
	max_y = -30,
	radius = {5,30},
	source = "default:lava_source",
	underground = true,
	in_nodes = {
		"default:stone",
	}
})