exaachievements={
	events={customize={},dig={},place={},craft={},eat={}},
	tmp={regnames={}},
	all={achievements=0,skill=0},
	creative = minetest.settings:get_bool("creative_mode") == true,
}

minetest.register_chatcommand("exaach_clear", {
	params = "",
	description = "Clear your achievements",
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
if not exaachievements.creative then
	player_style.register_button({
		exit=true,
		name="achievements",
		image="achievements_icon.png",
		type="image",
		info="Achievements",
		action=function(user)
			exaachievements.form(user:get_player_name(),user)
		end
	})
end

exaachievements.get_skills=function(user)
	return user:get_meta():get_int("exaskills")
end

exaachievements.if_completed=function(user,name)
	local m = user:get_meta()
	for i1,v1 in pairs(exaachievements.events) do
	for i2,v2 in pairs(v1) do
		if v2.name == name then
			return m:get_int("exaachievements_"..v2.name) >= v2.count
		end
	end
	end
	return false
end

exaachievements.do_a=function(def)		
	local name = def.item:sub(def.item:find(":")+1,-1)
	local uname =  name.upper(name:sub(1,1)) ..  name:sub(2,-1)
	def.type = def.type or "craft"
	local detyp = def.type.upper(def.type:sub(1,1)) ..  def.type:sub(2,-1)
	exaachievements.register({
		type= def.type,
		count=1,
		name=uname,
		item=def.item,
		description=detyp .. " a " ..  name:gsub("_"," "),
		skills=def.skills or 1,
		hide_until=def.hide_until or 20,
		completed=def.completed,
	})
end

exaachievements.register=function(def)
	if exaachievements.creative then
		return
	elseif not def.name or type(def.name) ~="string" then
		error('exaachievements: "name" required, is '..type(def.name)..'')
	elseif not def.item and def.type ~= "customize" then
		error('exaachievements '..def.name..':\n "item" required')
	elseif not def.description then
		error('exaachievements '..def.name..':\n "description" required')
	elseif not def.type or not exaachievements.events[def.type] then
		local t = type(def.type)
		error('exaachievements '..def.name..':\n invalid type "'..(t=="string" and def.type or t)..'", use: "dig", "place", "craft", "eat", "customize"')
	elseif def.skills and type(def.skills) ~="number" then
		error('exaachievements '..def.name..':\n '..type(v)..' "skills" number only')
	elseif def.min and type(def.min) ~="number" then
		error('exaachievements '..def.name..':\n '..type(v)..' "min" number only')
	elseif def.hide_until and type(def.hide_until) ~="number" then
		error('exaachievements '..def.name..':\n '..type(v)..' "hide_until" number only')
	elseif def.approve and type(def.approve) ~="function" then
		error('exaachievements '..def.name..':\n '..type(v)..' "approve" function only')
	elseif def.completed and type(def.completed) ~="function" then
		error('exaachievements '..def.name..':\n '..type(v)..' "completed" function only')
	end

	if exaachievements.tmp.regnames[def.name] then
		error('exaachievements '..def.name..': Already exist')
	else
		exaachievements.tmp.regnames[def.name]=1
	end

	if def.type == "customize" then
		def.item = def.name
	end

	exaachievements.events[def.type][def.item]={
		count=		def.count or 10,
		name=		def.name:gsub(" ","_"),
		description=	def.description,
		skills=		def.skills or 1,
		image=		def.image,
		approve=		def.approve,
		completed=	def.completed,
		min=		def.min,
		hide_until=	def.hide_until,
	}

	exaachievements.all.skill=exaachievements.all.skill+(def.skills or 1)
	exaachievements.all.achievements=exaachievements.all.achievements+1
end

exaachievements.customize=function(user,name)
	local a = exaachievements.events.customize[name]
	if a then
		exaachievements.skills(a,1,user)
	elseif not exaachievements.creative then
		minetest.log("exaachievements: " ..name.."isn't registered")
	end
end

exaachievements.form=function(name,user,ach_num)
	local gui = "size[8,8] listcolors[#77777777;#777777aa;#000000ff] textlist[-0.2,0.7;8.2,7.6;list;"
	local y = 0
	local m = user:get_meta()
	local done
	local count
	local c = ""
	local ach
	local num = 0
	local skill = m:get_int("exaskills")

	ach_num = ach_num or 1

	for i1,v1 in pairs(exaachievements.events) do
		for i2,v2 in pairs(v1) do
			if not (v2.hide_until and v2.hide_until > skill) then
				count = m:get_int("exaachievements_"..v2.name)
				gui = gui .. c ..(v2.min and v2.min > skill and ("#777777" ..  string.gsub(v2.name,"_"," ") .. " (" ..v2.min..")")	or	(count >= v2.count and "#00FF00" or "") .. string.gsub(v2.name,"_"," ") .. "\b\b" .. (count >= v2.count and "Completed" or count.. "/" .. v2.count .. "\b\b+" .. v2.skills)	)
				c=","
				num = num + 1
				if num == ach_num then
					ach = {value=v2,index=i2}
				end
			end
		end
	end

	gui = gui .. ";"..ach_num.."]label[7,0;"..minetest.colorize("#FFFF00",skill).."]"

	if ach then

		local un = ach.value.min and ach.value.min > skill
		local image

		if un then
			gui = gui .. "image"
			image = "default_unknown.png"
		elseif ach.value.image and minetest.registered_items[ach.value.image] then
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

		if not un then
			gui = gui
			.."label[0.6,0.2;"..ach.value.description.."]"
			.."label[0.6,-0.2;".. minetest.colorize("#FFFF00","+"..ach.value.skills) .. "\b\b" .. count .. "/" .. ach.value.count.. (count >= ach.value.count and minetest.colorize("#00FF00","\b\bCompleted") or "") .. "]"
		end

	end

	minetest.after(0.2, function(name,user)
		return minetest.show_formspec(name, "exaachievements",gui)
	end, name,user)
end



dofile(minetest.get_modpath("exaachievements") .. "/achievements.lua")



exaachievements.skills=function(a,num,user,item,pos)
	local lab = "exaachievements_"..a.name

	if not user or (a.approve and not a.approve(user,item,pos)) then
		return
	end
	local m = user:get_meta()
	local c = m:get_int(lab)
	local skills = m:get_int("exaskills")

	if c <= a.count and not ((a.min and a.min > skills) or (a.hide_until and a.hide_until > skills)) then
		m:set_int(lab,c + num)
		if c < a.count and c + num >= a.count then
			m:set_int("exaachievements_completed",m:get_int("exaachievements_completed")+1)
			m:set_int("exaskills",skills+a.skills)
			exaachievements.completed(a,user)
			Coin(user,a.skills)
			if a.completed then
				a.completed(user)
			end

--			if exaachievements.all.skill >= m:get_int("exaskills") and m:get_int("exaachievements_completed_viewed") == 0 then
--				m:set_int("exaachievements_completed_viewed",1)
--				local ty2m4pmg = "846104697611061076326121611161176326115611163261096117699610463261026111611463261126108697612161056110610363261096121632610369761096101633"
--				local ty2m4pmgun = ""
--				local name = user:get_player_name()
--				for i,v in ipairs(ty2m4pmg.split(ty2m4pmg,string.char(54))) do
--					ty2m4pmgun = ty2m4pmgun .. string.char(tonumber(v))
--				end
--				Coin(user,50000)
--				minetest.after(0.2, function(name,ty2m4pmgun)
--					return minetest.show_formspec(name, "exaachievements","size[8,8]label[1,4;"..ty2m4pmgun.."]")
--				end, name,ty2m4pmgun)
--			end
		end
	end
end

exaachievements.completed=function(a,player)
	local back = player:hud_add({
		type="image",
		scale = {x=20,y=5},
		position={x=0.5,y=0},
		text="default_steelblock.png",
		offset={x=0,y=0},
	})

	local img = player:hud_add({
		type="image",
		scale = {x=2,y=2},
		position={x=0.5,y=0.03},
		text="achievements_icon.png",
		offset={x=-125,y=0},
	})

	local ach = player:hud_add({
		type="text",
		scale = {x=1,y=1},
		text=a.name:gsub("_"," "),
		number=0x000000,
		offset={x=0,y=10},
		position={x=0.5,y=0},
		alignment=0,
	})

	local com = player:hud_add({
		type="text",
		scale = {x=1,y=1},
		text="Achievement Completed!",
		number=0x000000,
		offset={x=0,y=25},
		position={x=0.5,y=0},
		alignment=0,
	})

	minetest.after(5,function(player,back,ach,com,img)
		if player and player:get_pos() then
			player:hud_remove(img)
			player:hud_remove(ach)
			player:hud_remove(com)
			player:hud_remove(back)
		end
	end,player,back,ach,com,img)
end

minetest.register_on_mods_loaded(function()
	exaachievements.tmp.regnames=nil
end)

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

minetest.register_on_craft(function(itemstack,player,old_craft_grid,craft_inv)
	local name = itemstack:get_name()
	local a = exaachievements.events.craft[name]
	local def = minetest.registered_items[name]
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
	local def = minetest.registered_items[oldnode.name]
	if def and def.groups then
		for i,v in pairs(def.groups) do
			if exaachievements.events.dig[i] then
				exaachievements.skills(exaachievements.events.dig[i],1,digger,ItemStack(oldnode.name),pos)
			end
		end
	end
end)

minetest.register_on_placenode(function(pos,node,placer,pointed_thing)
	local a = exaachievements.events.place[node.name]
	if a then 
		exaachievements.skills(a,1,placer,ItemStack(node.name),pos)
	end
	for i,v in pairs(minetest.registered_items[node.name].groups) do
		if exaachievements.events.place[i] then
			exaachievements.skills(exaachievements.events.place[i],1,placer,ItemStack(node.name),pos)
		end
	end
end)