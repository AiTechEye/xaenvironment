exaachievements={
	events={
		dig={
			["default:dirt"]={
				count=25,
				label="Mud_dive",
				text="Dig 25 dirt",
				skills=1,
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
	},
}

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


exaachievements.new_player=function(player)
end

exaachievements.form=function(name,user)
	local gui = "size[6,8]"
	local y = 0
	local m = user:get_meta()
	local done
	local count

	for i1,v1 in pairs(exaachievements.events) do
		for i2,v2 in pairs(v1) do
			if minetest.registered_items[i2] then
				gui = gui .."item_image[-0.2,"..y..";1,1;"..i2.."]"
			elseif string.sub(i2,-4,string.len(i2)) == ".png" then
				gui = gui .. "image[-0.2,"..y..";1,1;"..i2.."]"
			end

			count = m:get_int("exaachievements_"..v2.label)

			gui = gui .. "label[0.6,"..y..";"..  string.gsub(v2.label,"_"," ").. "\b\b" .. (count >= v2.count and (minetest.colorize("#00FF00","Completed")) or count.. "/" .. v2.count) .. minetest.colorize("#FFFF00","\b\b+" .. v2.skills) .."]"

			.. "label[0.8,"..y..".4;"..v2.text.."]"

			y = y + 1
		end
	end

	minetest.after(1, function(name,user)
		return minetest.show_formspec(name, "exaachievements",gui)
	end, name,user)
end

minetest.register_on_player_receive_fields(function(user, form, pressed)
	if form=="exaachievements" then
	end
end)




minetest.register_on_punchnode(function(pos,node,puncher,pointed_thing)
end)
minetest.register_on_item_eat(function(hp_change,replace_with_item,itemstack,user,pointed_thing)
end)


minetest.register_on_newplayer(function(player)
	exaachievements.new_player(player)
end)


minetest.register_on_dignode(function(pos, oldnode, digger)
	local a = exaachievements.events.dig[oldnode.name]
	if a then
		local lab = "exaachievements_"..a.label
		local m = digger:get_meta()
		local c = m:get_int(lab)+1
		if c <= a.count then
			m:set_int(lab,c)
			if c == a.count then
				m:set_int("exaskills",m:get_int("exaskills")+a.skills)
			end
		end
	end
end)

minetest.register_on_placenode(function(pos,node,placer,pointed_thing)
	local a = exaachievements.events.place[node.name]
	if a then
		local lab = "exaachievements_"..a.label
		local m = placer:get_meta()
		local c = m:get_int(lab)+1
		if c <= a.count then
			m:set_int(lab,c)
			if c == a.count then
				m:set_int("exaskills",m:get_int("exaskills")+a.skills)
			end
		end
	end
end)