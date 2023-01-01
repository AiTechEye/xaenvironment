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
		{name="atlantis_building1",chance=15,area=31,spawn=function(pos)
			villages.chests_to_treasures_in_area(pos,16)
		end},
		{name="atlantis_building2",chance=15,area=17,spawn=function(pos)
			villages.chests_to_treasures_in_area(pos,16)
		end},
		{name="atlantis_building3",chance=15,area=10,spawn=function(pos)
			protect.add_game_rule_area(apos(pos,6,14,6),apos(pos,-6,-1,-6),"atlantis",nil,nil,true)
			villages.chests_to_treasures_in_area(pos,17)
		end},
		{name="atlantis_building4",chance=15,area=13},
		{name="atlantis_building5",chance=15,area=16},
		{name="atlantis_building6",chance=15,area=36,spawn=function(pos)
			protect.add_game_rule_area(vector.subtract(pos,18),vector.add(pos,18),"atlantis",nil,nil,true)
			villages.chests_to_treasures_in_area(pos,18)
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
		{name="atlantis_building7",chance=15,area=10},
		{name="atlantis_building8",chance=15,area=6},
		{name="atlantis_building9",chance=15,area=10,spawn=function(pos)
			villages.chests_to_treasures_in_area(pos,16)
		end},
		{name="atlantis_building10",chance=15,area=32,spawn=function(pos)
			protect.add_game_rule_area(vector.subtract(pos,16),vector.add(pos,16),"atlantis",nil,nil,true)
			villages.chests_to_treasures_in_area(pos,16)
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


minetest.register_tool("villages:biocheck", {
	description = "Biocheck",
	inventory_image = "default_stick.png",
	on_use=function(itemstack, user, pointed_thing)
		local pos = user:get_pos()
		local i = 3
		minetest.place_schematic(pos,minetest.get_modpath("villages").."/schematics/atlantis_building"..i..".mts","random",nil,true,"place_center_x,place_center_z")
		villages.atlantis[i].spawn(pos)
	end
})

villages.chests_to_treasures_in_area=function(pos,rad)
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

villages.set_atlantis=function(pos)
	if pos.y > -25 or minetest.get_node(apos(pos,0,1)).name ~= "default:salt_water_source" then
		return
	end
	pos.y=pos.y+1
	local dir = {vector.new(pos),vector.new(pos),vector.new(pos),vector.new(pos)}
	local hit = {}
	local h = 0

	for a=1,200 do
		dir[1] = apos(dir[1],1)
		dir[2] = apos(dir[2],-1)
		dir[3] = apos(dir[3],0,0,1)
		dir[4] = apos(dir[4],0,0,-1)
		for i=1,4 do
			if not hit[i] and minetest.get_node(dir[i]).name ~= "default:salt_water_source" then
				hit[i] = vector.new(dir[i])
				h = h +1
				if h >= 4 then
					break
				end
			end
		end
		if h >= 4 then
			break
		end
	end
	for i=1,4 do
		hit[i] = hit[i] or dir[i]
	end
	local sx = pos.x-hit[1].x + pos.x-hit[2].x
	local sz = pos.z-hit[3].z + pos.z-hit[4].z
	local npos = {x=pos.x-sx/2,y=pos.y,z=pos.z-sz/2}	-- center of area

	local sizex,sizez = hit[1].x-hit[2].x,hit[3].z-hit[4].z


	if sizez < 50 or sizez < 50 then
		return
	end


	local num = math.random(10,20)
	local list = {}
	local i = 0
	local n = #villages.atlantis

	for I=0,100 do
		local p = {x=npos.x+math.random(-sizex,sizex),y=npos.y,z=npos.z+math.random(-sizez,sizez)}
		local b = villages.atlantis[math.random(1,n)]
		local able = true
		for i,v in pairs(list) do
			local d = vector.distance(v.pos,npos)
			if (d-b.area)-v.area <= 0 then
				able = false
				break
			end
		end
		if able then
			table.insert(list,{pos=p,area=b.area})
			minetest.place_schematic(p,minetest.get_modpath("villages").."/schematics/"..b.name..".mts","random",nil,true,"place_center_x,place_center_z")
			if b.spawn then
				b.spawn(p)
			end
			num = num -1
			if num <= 0 then
				return
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
			local self = minetest.add_entity(v,"examobs:villager_npc"):get_luaentity()
			self.storage.npc_generated = true
			self.storage.property_area = prop.area
			self.storage.property_area_pos = pos
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
	on_load=function(pos)
		minetest.remove_node(pos)
		local n = minetest.get_node({x=pos.x+math.random(-1,1),y=pos.y,z=pos.z+math.random(-1,1)})
		minetest.set_node(pos,n)
		if math.random(1,10) == 1 then
			villages.set_village(pos)
		end
	end,
})

minetest.register_node("villages:atlantis_spawner", {
	drawtype = "airlike",
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups={on_load=1,not_in_creative_inventory=1},
	on_load=function(pos)
		minetest.remove_node(pos)
		local n = minetest.get_node({x=pos.x+math.random(-1,1),y=pos.y,z=pos.z+math.random(-1,1)})
		minetest.set_node(pos,n)
		if math.random(1,10) == 1 then
			villages.set_atlantis(pos)
		end
	end,
})


minetest.register_ore({
	ore_type = "blob",
	ore= "villages:atlantis_spawner",
	wherein= "default:sand",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 1,
	y_min= -200,
	y_max= -25,
	noise_params = default.ore_noise_params()
})
minetest.register_ore({
	ore_type = "blob",
	ore= "villages:spawner",
	wherein= "default:dirt",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 1,
	y_min= 0,
	y_max= 50,
	noise_params = default.ore_noise_params()
})
minetest.register_ore({
	ore_type = "blob",
	ore= "villages:spawner",
	wherein= "default:snow",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 1,
	y_min= 0,
	y_max= 50,
	noise_params = default.ore_noise_params()
})
minetest.register_ore({
	ore_type = "blob",
	ore= "villages:spawner",
	wherein= "default:desert_sand",
	clust_scarcity = 30 * 30 * 30,
	clust_size = 1,
	y_min= 0,
	y_max= 50,
	noise_params = default.ore_noise_params()
})

minetest.register_node("villages:trader", {
	groups = {attached_node=1,not_in_creative_inventory=1,on_load=1},
	pointable=false,
	paramtype = "light",
	drawtype="airlike",
	drop="",
	walkable=false,
	floodable = true,
	sunlight_propagates = true,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(3)
	end,
	on_timer = function (pos, elapsed)
		local npc
		local item
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos,10)) do
			local en = ob:get_luaentity()
			if en and en.examob and en.type == "npc" then
				npc = true
			elseif en and en.traderitem and vector.distance(ob:get_pos(),pos) <= 0.3 then
				item = ob
			end
			if npc and item then
				break
			end
		end

		if minetest.get_meta(pos):get_string("item1") == "" then
			minetest.registered_nodes["villages:trader"].newitem(pos)
		end

		if not npc then
			if item then
				item:remove()
			end
		elseif not item then
			minetest.registered_nodes["villages:trader"].spawnitem(pos)
		end
		return true
	end,
	on_load=function(pos)
		if math.random(1,5) == 1 or minetest.get_meta(pos):get_string("item1") == "" then
			minetest.get_node_timer(pos):start(3)
			minetest.registered_nodes["villages:trader"].newitem(pos)
			minetest.registered_nodes["villages:trader"].spawnitem(pos)
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos,0.3)) do
				local en = ob:get_luaentity()
				if en and en.traderitem then
					ob:remove()
				end
			end
		end
	end,
	spawnitem=function(pos)
		local e = minetest.add_entity(pos,"villages:traderitem"):get_luaentity()
		e.index = minetest.get_meta(pos):get_int("index")
		e:on_rightclick()
	end,
	newitem=function(pos)
		local items = {}
		local m = minetest.get_meta(pos)
		for i,v in pairs(minetest.registered_items) do
			if minetest.get_item_group(i,"store") > 1 then
				table.insert(items,i)
			end
		end
		for i=1,10 do
			local item = items[math.random(1,#items)]
			local cost = minetest.get_item_group(item,"store")
			m:set_string("item"..i,item)
			m:set_int("index",1)
			m:set_int("count"..i,math.random(1,10))
			m:set_int("cost"..i,cost+math.floor(math.random(cost*0.1,cost*2)))
		end
	end,
})

local trader2 = table.copy(default.def("villages:trader"))
trader2.on_timer = function(pos, elapsed)
	local item
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos,10)) do
		local en = ob:get_luaentity()
		if en and en.traderitem and vector.distance(ob:get_pos(),pos) <= 0.3 then
			item = ob
			break
		end
	end
	if minetest.get_meta(pos):get_string("item1") == "" then
		minetest.registered_nodes["villages:trader"].newitem(pos)
	end
	if not item then
		minetest.registered_nodes["villages:trader"].spawnitem(pos)
	end
	return true
end
minetest.register_node("villages:trader2", trader2)

minetest.register_entity("villages:traderitem",{
	hp_max = 1000,
	physical = false,
	collisionbox = {-0.3,-0.3,-0.3,0.3,0.3,0.3},
	visual = "wielditem",
	visual_size = {x=0.3,y=0.3},
	textures = {"default:stick"},
	decoration=true,
	traderitem=true,
	static_save = false,
	automatic_rotate = math.pi/4,
	timer = 0,
	on_step=function(self, dtime)
		self.timer = self.timer -dtime
		if self.timer < 0 then
			self.timer = 1
			local n = minetest.get_node(self.object:get_pos()).name
			if n ~= "villages:trader" and n ~= "villages:trader2" then
				self.object:remove()
			end
		end
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		self.object:set_hp(1000)
		if puncher:is_player() then
			local inv = puncher:get_inventory()
			local c = Getcoin(puncher)
			local pos = self.object:get_pos()
			local m2 = minetest.get_meta(pos)
			if c >= self.cost and inv:room_for_item("main",self.item) then
				inv:add_item("main",self.item)
				Coin(puncher,c-self.cost,true)
				local ic = m2:get_int("count"..self.index)-1
				m2:set_int("count"..self.index,ic)
				self.update = true
				self.on_rightclick(self)
			end
		end
	end,
	on_rightclick=function(self)
		local pos = self.object:get_pos()
		local items = {}
		local m = minetest.get_meta(pos)
		local set

		if self.update == nil or m:get_int("count"..self.index) <= 0 then
			for i = self.index+1,10 do
				if m:get_int("count"..i) > 0 then
					self.index = i
					set = true
					break
				end
			end
			if not set then
				for i = 1,self.index do
					if m:get_int("count"..i) > 0 then
						self.index = i
						set = true
						break
					end
				end
				if not set then
					minetest.registered_nodes["villages:trader"].newitem(pos)
					minetest.registered_nodes["villages:trader"].spawnitem(pos)
					self.object:remove()
					return
				end
			end
			m:set_int("index",self.index)
		end
		self.update = nil
		self.item = m:get_string("item"..self.index)
		self.cost = m:get_int("cost"..self.index)
		local def = minetest.registered_items[self.item]

		if not def then
			minetest.registered_nodes["villages:trader"].newitem(pos)
			minetest.registered_nodes["villages:trader"].spawnitem(pos)
			self.object:remove()
			return
		end

		self.object:set_properties(
			{textures={self.item},
			infotext=(def.description or def.name) .. "\nCost: "..self.cost.."\n"..m:get_int("count"..self.index).." left\n"..self.index.."/10\n\nRight click to change"
		})
	end,
})