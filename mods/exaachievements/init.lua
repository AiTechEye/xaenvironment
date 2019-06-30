--min skills, requere to be done, function

exaachievements={
	events={
		functions={},
		dig={
			["default:sand"]={
				count=25,
				label="Sand_treasures",
				text="Dig sand under water",
				skills=1,
				approve=function(node,pos,user)
					return minetest.get_item_group(minetest.get_node(apos(pos,0,1)).name,"water") > 0
				end
			},
			["spreading_dirt_type"]={
				image="default:dirt_with_grass",
				count=25,
				label="Mud_dive",
				text="Dig 25 dirt",
				skills=1,
			},
			["tree"]={
				image="plants:apple_tree",
				count=25,
				label="tree_cutter",
				text="Dig 25 tree",
				skills=2,
			},
		},
		place={
			["default:dirt"]={
				count=25,
				label="Dirt_house",
				text="Place 25 dirt",
				skills=1,
			},
		},
		craft={
			["wood"]={
				image="plants:apple_wood",
				count=50,
				label="House_builder",
				text="Craft 50 wood",
				skills=1,
			},
			["default:stick"]={
				count=10,
				label="Item_maker",
				text="Craft 10 sticks",
				skills=1,
			},
		},
	},
}

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
			m:set_int("exaachievements_"..v2.label,0)
		end
		end
	end
})

exaachievements.form=function(name,user)
	local gui = "size[6,8]"
	local y = 0
	local m = user:get_meta()
	local done
	local count

	for i1,v1 in pairs(exaachievements.events) do
		for i2,v2 in pairs(v1) do
			local image
			if v2.image and minetest.registered_items[v2.image] then
				gui = gui .."item_image"
				image = v2.image
			elseif v2.image and v2.image:sub(-4,-1) == ".png" then
				gui = gui .. "image"
				image = v2.image
			elseif minetest.registered_items[i2] then
				gui = gui .."item_image"
				image = i2
			end

			gui = gui .. (image and "[-0.2,"..y..";1,1;"..image.."]" or "") .."\n"


			count = m:get_int("exaachievements_"..v2.label)

			gui = gui .. "label[0.6,"..y..";"..  string.gsub(v2.label,"_"," ").. "\b\b" .. (count >= v2.count and (minetest.colorize("#00FF00","Completed")) or count.. "/" .. v2.count) .. minetest.colorize("#FFFF00","\b\b+" .. v2.skills) .."]"

			.. "label[0.8,"..y..".4;"..v2.text.."]"

			y = y + 1
		end
	end

	minetest.after(0.5, function(name,user)
		return minetest.show_formspec(name, "exaachievements",gui)
	end, name,user)
end

minetest.register_on_player_receive_fields(function(user, form, pressed)
	if form=="exaachievements" then
	end
end)

minetest.register_on_item_eat(function(hp_change,replace_with_item,itemstack,user,pointed_thing)
end)


exaachievements.skills=function(a,num,user,item,pos)
	local lab = "exaachievements_"..a.label
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