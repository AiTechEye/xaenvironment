--min skills, requere to be done, function

exaachievements={
	events={
		customize={
			["hunter"]={
				count=100,
				name="Hunter",
				description="Kill 100 animals",
				skills=10,
				approve=function(user)
					--return minetest.get_item_group(minetest.get_node(apos(pos,0,1)).name,"water") > 0
				end
			},
		},
		dig={
			["default:sand"]={
				count=25,
				name="Sand_treasures",
				description="Dig sand under water",
				skills=1,
				approve=function(user,item,pos)
					return minetest.get_item_group(minetest.get_node(apos(pos,0,1)).name,"water") > 0
				end
			},
			["spreading_dirt_type"]={
				image="default:dirt_with_grass",
				count=25,
				name="Mud_dive",
				description="Dig 25 dirts",
				skills=1,
			},
			["tree"]={
				image="plants:apple_tree",
				count=25,
				name="tree_cutter",
				description="Dig 25 tree",
				skills=2,
			},
		},
		place={
			["default:dirt"]={
				count=25,
				name="Dirt_house",
				description="Place 25 dirts",
				skills=1,
			},
		},
		craft={
			["wood"]={
				image="plants:apple_wood",
				count=50,
				name="House_builder",
				description="Craft 50 wood",
				skills=1,
			},
			["default:stick"]={
				count=10,
				name="Item_maker",
				description="Craft 10 sticks",
				skills=1,
			},
		},
		eat={
			["plants:apple"]={
				count=1,
				name="Apples",
				description="Eat an apple",
				skills=1,
			},
		}
	},
}

exaachievements.register=function(event,def)
	if not def.name then
		error('exaachievements: "name" required')
	elseif not def.item then
		error('exaachievements: "item" required')
	elseif not def.description then
		error('exaachievements: "description" required')
	elseif not exaachievements.events[event] then
		error('exaachievements: invalid event: "dig", "place", "craft", "eat", "functions"')
	end

	if event == "functions" then
		def.item=def.name
	end

	exaachievements.events[event][def.item]={
		count=		def.count or 10,
		name=		def.name:gsub(" ","_"),
		description=	def.description,
		skills=		def.skills or 1,
		image=		def.image,
		approve=		def.approve,
	}
end


exaachievements.register("eat",{
	name="Pears g",
	count=1,
	description="Eat a pear",
})

exaachievements.customize=function(user,name)
	local a = exaachievements.events.customize[name]
	if a then
		exaachievements.skills(a,1,user)
	else
		minetest.log("exaachievements: " ..name.."isn't registered")
	end
end

apos=function(pos,x,y,z)
	return {x=pos.x+(x or 0),y=pos.y+(y or 0),z=pos.z+(z or 0)}
end

minetest.register_chatcommand("a", {
	params = "",
	description = "Achievements (pre alpha)",
	func = function(name, param)
		exaachievements.form(name,minetest.get_player_by_name(name))
	end
})

minetest.register_chatcommand("aaa", {
	params = "",
	description = "Clear achievements",
	privs = {ban=true},
	func = function(name, param)
		local m = minetest.get_player_by_name(name):get_meta()
		m:set_int("exaskills",0)
		for i1,v1 in pairs(exaachievements.events) do
		for i2,v2 in pairs(v1) do
			m:set_int("exaachievements_"..v2.name,0)
		end
		end
	end
})

exaachievements.form=function(name,user,ach_num)
	local gui = "size[8,8]textlist[-0.2,0.7;8.2,7.6;list;"
	local y = 0
	local m = user:get_meta()
	local done
	local count
	local c = ""
	local ach
	local num = 0

	ach_num = ach_num or 1

	for i1,v1 in pairs(exaachievements.events) do
		for i2,v2 in pairs(v1) do
			count = m:get_int("exaachievements_"..v2.name)
			gui = gui .. c .. (count >= v2.count and "#00FF00" or "") .. string.gsub(v2.name,"_"," ") .. "\b\b" .. (count >= v2.count and "Completed" or count.. "/" .. v2.count .. "\b\b+" .. v2.skills)
			c=","
			num = num + 1
			if num == ach_num then
				ach = {value=v2,index=i2}
			end

		end
	end

	gui = gui .. ";"..ach_num.."]"

	if ach then
		local image
		if ach.value.image and minetest.registered_items[ach.value.image] then
			gui = gui .."item_image"
			image = ach.value.image
		elseif ach.value.image and ach.value.image:sub(-4,-1) == ".png" then
			gui = gui .. "image"
			image = ach.value.image
		elseif minetest.registered_items[ach.index] then
			gui = gui .."item_image"
			image = ach.index
		end
		count = m:get_int("exaachievements_"..ach.value.name)
		gui = gui .. (image and "[-0.2,-0.2;1,1;"..image.."]" or "")
		.."label[0.6,0.2;"..ach.value.description.."]"
		.."label[0.6,-0.2;".. minetest.colorize("#FFFF00","+"..ach.value.skills) .. "\b\b" .. count .. "/" .. ach.value.count.. (count >= ach.value.count and minetest.colorize("#00FF00","\b\bCompleted") or "") .. "]"
	end

	minetest.after(0.2, function(name,user)
		return minetest.show_formspec(name, "exaachievements",gui)
	end, name,user)
end

minetest.register_on_player_receive_fields(function(user, form, pressed)
	if form=="exaachievements" then
		if pressed.list then
			exaachievements.form(user:get_player_name(),user,tonumber(pressed.list:sub(5,-1)))
		end
	end
end)

minetest.register_on_item_eat(function(hp_change,replace_with_item,itemstack,user,pointed_thing)
	local a = exaachievements.events.eat[itemstack:get_name()]
	local def = minetest.registered_nodes[itemstack:get_name()]
	if a then
		exaachievements.skills(a,1,user,itemstack)
	end
	if def and def.groups then
		for i,v in pairs(def.groups) do
			if exaachievements.events.eat[i] then
				exaachievements.skills(exaachievements.events.eat[i],itemstack:get_count(),user,itemstack)
			end
		end
	end
end)

exaachievements.skills=function(a,num,user,item,pos)
	local lab = "exaachievements_"..a.name
	if a.approve and not a.approve(user,item,pos) then
		return true
	end
	local m = user:get_meta()
	local c = m:get_int(lab) + num
	if c <= a.count then
		m:set_int(lab,c)
		if c == a.count then
			m:set_int("exaskills",m:get_int("exaskills")+a.skills)
		end
	end
end

minetest.register_on_craft(function(itemstack,player,old_craft_grid,craft_inv)
	local name = itemstack:get_name()
	local a = exaachievements.events.craft[name]
	local def = minetest.registered_nodes[name]
	if a then 
		exaachievements.skills(a,itemstack:get_count(),player,itemstack)
	end
	if def and def.groups then
		for i,v in pairs(def.groups) do
			if exaachievements.events.craft[i] then
				exaachievements.skills(exaachievements.events.craft[i],itemstack:get_count(),player,itemstack)
			end
		end
	end
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
	local a = exaachievements.events.dig[oldnode.name]
	if a then 
		exaachievements.skills(a,1,digger,ItemStack(oldnode.name),pos)
	end
	for i,v in pairs(minetest.registered_nodes[oldnode.name].groups) do
		if exaachievements.events.dig[i] then
			exaachievements.skills(exaachievements.events.dig[i],1,digger,ItemStack(oldnode.name),pos)
		end
	end
end)

minetest.register_on_placenode(function(pos,node,placer,pointed_thing)
	local a = exaachievements.events.place[node.name]
	if a then 
		exaachievements.skills(a,1,placer,ItemStack(node.name),pos)
	end
	for i,v in pairs(minetest.registered_nodes[node.name].groups) do
		if exaachievements.events.place[i] then
			exaachievements.skills(exaachievements.events.place[i],1,placer,ItemStack(node.name),pos)
		end
	end
end)