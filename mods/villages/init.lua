villages = {
	default_area = 12,
	village_size = {3,5},
	buildings = {
		["villages_dubble_balcony"]={chance=15,area=10,height=6},
		["villages_family_curbroof"]={chance=15,area=12,height=8},
		["villages_foodbar"]={chance=15,area=9,height=7},
		["villages_litle_house_balcony"]={chance=10,area=5,height=6},
		["villages_middle_house"]={chance=12,area=7,height=7},
		["villages_storey"]={chance=15,area=8,height=9},
		["villages_tiny_curbroof"]={chance=8,area=7,height=5},
		["villages_tower"]={chance=15,area=6,height=18},
		["villages_cabbage_farm"]={chance=18,area=10,height=2},
		["villages_chicken_farm"]={chance=18,area=10,height=3},
		["villages_cistern"]={chance=18,area=8,height=2},
		["villages_cotton_farm"]={chance=18,area=10,height=2},
		["villages_mine_shaft"]={chance=19,area=5,height=1},
		["villages_pig_farm"]={chance=18,area=10,height=3},
		["villages_sheep_farm"]={chance=18,area=10,height=3},
		["villages_wheat_farm"]={chance=18,area=10,height=2},
	},
	atlantis = {
		["atlantis_building1"]={chance=15,area=31,spawn=function(pos)
			villages.chetsts_to_treasures_in_area(pos,16)
		end},
		["atlantis_building2"]={chance=15,area=17,spawn=function(pos)
			villages.chetsts_to_treasures_in_area(pos,16)
		end},
		["atlantis_building3"]={chance=15,area=34,spawn=function(pos)
			protect.add_game_rule_area(vector.subtract(pos,17),vector.add(pos,17),"atlantis")
			villages.chetsts_to_treasures_in_area(pos,17)
		end},
		["atlantis_building4"]={chance=15,area=13},
		["atlantis_building5"]={chance=15,area=16},
		["atlantis_building6"]={chance=15,area=36,spawn=function(pos)
			protect.add_game_rule_area(vector.subtract(pos,18),vector.add(pos,18),"atlantis")
			villages.chetsts_to_treasures_in_area(pos,18)
			local code = math.random(0,9)..math.random(0,9)..math.random(0,9)..math.random(0,9)
			local nodes = minetest.find_nodes_in_area(vector.subtract(pos,18),vector.add(pos,18),{"exatec:codelock","materials:granite_orb"})
			local I = 0
			for i,v in pairs(nodes) do
				local n = minetest.get_node(v)
				if n.name == "exatec:codelock" then
					minetest.set_node(v,{name="exatec:codelock",param2=n.param2})
					minetest.get_meta(v):set_string("code",code)
					I = i
					break
				end
			end
			table.remove(nodes,I)
			local p = nodes[math.random(1,#nodes)]
			minetest.get_meta(p):set_string("infotext",code)
		end},
		["atlantis_building7"]={chance=15,area=10},
		["atlantis_building8"]={chance=15,area=6},
		["atlantis_building9"]={chance=15,area=10,spawn=function(pos)
			villages.chetsts_to_treasures_in_area(pos,16)
		end},
		["atlantis_building10"]={chance=15,area=32,spawn=function(pos)
			protect.add_game_rule_area(vector.subtract(pos,16),vector.add(pos,16),"atlantis")
			villages.chetsts_to_treasures_in_area(pos,16)
		end},
	},
	nodes_reset = {
		"default:paper_compressor",
		"default:craftguide",
		"default:workbench",
		"default:recycling_mill",
		"default:dye_workbench",
		"default:chest",
		"examobs:woodbox",
		"default:furnace",
		"plants:apple_wood_door",
		"clock:clock1",
		"examobs:villager_npc_spawner",
		"examobs:chicken_spawner",
		"examobs:sheep_spawner",
		"examobs:pig_spawner",
	}
}

villages.chetsts_to_treasures_in_area=function(pos,rad)
	local nodes = minetest.find_nodes_in_area(vector.subtract(pos,rad),vector.add(pos,rad),"default:chest")
	for i,v in pairs(nodes) do
		default.treasure({level=2,pos=v,node=minetest.get_node(v).name})
	end

end

villages.set_village=function(pos)
	local s = math.random(villages.village_size[1],villages.village_size[2])
	local cs = 0
	local used_pos = {}
	local node

	local nodes1 = minetest.find_nodes_in_area(vector.subtract(pos,20),vector.add(pos,20),{"group:tree"})
	if #nodes1 > 0 then
		for i,v in pairs(nodes1) do
			local tree = minetest.registered_nodes[minetest.get_node(v).name].tree
			if tree then
				node = tree
				break
			end
		end
	else
		local nodes2 = minetest.find_nodes_in_area(vector.subtract(pos,10),vector.add(pos,10),{"default:desert_sand"})
		if #nodes2 > 0 then
			node = "default:desert_cobble"
		else
			local nodes3 = minetest.find_nodes_in_area(vector.subtract(pos,10),vector.add(pos,10),{"default:dirt_with_grass"})
			if #nodes3 > 0 then
				node = "default:cobble"
			end
		end
	end
	
	for i = 0,math.random(100,1000) do
		if villages.set_building_pos(pos,s,node,used_pos) then
			cs = cs + 1
			if cs >= (s*s)*s then
				break
			end
		end
	end
end

villages.set_building_pos=function(pos,size,node,used_pos)
	local p = {x=pos.x,y=pos.y,z=pos.z}
	local up
	for i = 0,10 do
		p.x = pos.x + math.random(-size,size)*villages.default_area
		p.z = pos.z + math.random(-size,size)*villages.default_area
		up = p.x.." "..p.z
		if not used_pos[up] then
			used_pos[up] = up
			local g = villages.find_ground(p)
			if g then
				if villages.set_building(g,node) then
					return true
				end
				
			end
		end
	end
	return false
end

villages.find_ground=function(pos)
	for i = pos.y-10,pos.y+10 do
		local p1 = {x=pos.x,y=i,z=pos.z}
		local l1 = minetest.get_node_light(p1,0.5) 
		local p2 = {x=pos.x,y=i+1,z=pos.z}
		local l2 = minetest.get_node_light(p2,0.5)

		if l1 == nil then
			minetest.emerge_area(p1,p2)
			l1 = minetest.get_node_light(p1,0.5)
			l2 = minetest.get_node_light(p2,0.5)
		end

		if i > 0 and (l2 or 0) > 9 and (l1 or 0) == 0 then
			return p1
		end
	end
end

villages.set_building=function(pos,node)
	local s
	local name

	minetest.emerge_area(vector.subtract(pos,-villages.default_area),vector.add(pos,villages.default_area))

	local ground = minetest.get_node(pos)

	for i,v in pairs(villages.buildings) do
		if math.random(1,v.chance) == 1 then
			local a = minetest.find_nodes_in_area(vector.subtract(pos,v.area/2),vector.add(pos,v.area/2),{"group:stone","group:dirt"})
			local c = #a
			local bc = ((v.area*v.area) * v.area)/2 + (v.area*v.area)*2
			if c <= bc and c >bc/1.5 then
				minetest.place_schematic(pos,minetest.get_modpath("villages").."/schematics/"..i..".mts","random",nil,true,"place_center_x,place_center_z")
				name = i
				break
			end
		end
	end

	if not name then
		return false
	end

	local prop = villages.buildings[name]
	local a = math.ceil(prop.area/2)
	local h = prop.height

	local nodes = minetest.find_nodes_in_area({x=pos.x+a,y=pos.y,z=pos.z+a},{x=pos.x-a,y=pos.y+h,z=pos.z-a},villages.nodes_reset)
	for i,v in pairs(nodes) do
		local n = minetest.get_node(v)
		if n.name == "examobs:villager_npc_spawner" then
			minetest.remove_node(v)
			minetest.add_entity(v,"examobs:villager_npc"):set_yaw(math.random(0,6.28))
		elseif n.name == "examobs:chicken_spawner" then
			minetest.remove_node(v)
			minetest.add_entity(v,"examobs:chicken"):set_yaw(math.random(0,6.28))
		elseif n.name == "examobs:sheep_spawner" then
			minetest.remove_node(v)
			minetest.add_entity(v,"examobs:sheep"):set_yaw(math.random(0,6.28))
		elseif n.name == "examobs:pig_spawner" then
			minetest.remove_node(v)
			minetest.add_entity(v,"examobs:pig"):set_yaw(math.random(0,6.28))
		elseif n.name == "default:chest" or n.name == "examobs:woodbox" then
			default.treasure({pos=v,node=n})
		else
			minetest.set_node(v,n)
		end
	end

	for x = -a,a do
	for z = -a,a do
		local p = {x=pos.x+x,y=pos.y,z=pos.z+z}
		local p2 = {x=pos.x+x,y=pos.y-1,z=pos.z+z}
		if minetest.get_node(p).name == "air" and minetest.get_node(p2).name ~= "air" then
			minetest.set_node(p,ground)
		end
	end
	end


	if not node then
		return true
	end

	local nodes = minetest.find_nodes_in_area({x=pos.x-a,y=pos.y,z=pos.z-a},{x=pos.x+a,y=pos.y+h,z=pos.z+a},{"group:chair","group:door","group:wood","group:tree","group:fence"})

	if string.find(node,":") then
		for i,v in pairs(nodes) do
			local n = minetest.get_node(v)
			local na = n.name
			if minetest.get_item_group(na,"wood") > 0 or minetest.get_item_group(na,"tree") > 0 then
				minetest.set_node(v,{name=node})
			else
				minetest.remove_node(v)
			end
		end
	else
		for i,v in pairs(nodes) do
			local n = minetest.get_node(v)
			local na = string.gsub(n.name,"apple",node)
			minetest.set_node(v,{name=na,param2=n.param2})
		end
	end
	return true
end

minetest.register_node("villages:spawner", {
	drawtype = "airlike",
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups={on_load=1,not_in_creative_inventory=1},
	on_construct=function(pos)
		minetest.remove_node(pos)
		villages.set_village(pos)
	end,
	on_load=function(pos)
		minetest.remove_node(pos)
		local n = minetest.get_node({x=pos.x+math.random(-1,1),y=pos.y,z=pos.z+math.random(-1,1)})
		minetest.set_node(pos,n)
		if math.random(1,10) == 1 then
			villages.set_village(pos)
		end
	end,
})

minetest.register_ore({
	ore_type = "blob",
	ore= "villages:spawner",
	wherein= "default:dirt",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 1,
	y_min= 0,
	y_max= 50,
})
minetest.register_ore({
	ore_type = "blob",
	ore= "villages:spawner",
	wherein= "default:snow",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 1,
	y_min= 0,
	y_max= 50,
})
minetest.register_ore({
	ore_type = "blob",
	ore= "villages:spawner",
	wherein= "default:desert_sand",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 1,
	y_min= 0,
	y_max= 50,
})