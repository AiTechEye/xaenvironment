vexcazer={
	gui="",
	auto_ad_mod=false,
	max_amount={default=10,mod=15,admin=30,world=99},
	wear_use=65535/1000,
	range={default=10,mod=15,admin=15},
	registry_modes={},
	creative=minetest.settings:get("creative_mode"),
	pvp=minetest.settings:get_bool("enable_pvp"),
	gui_user={},
	undo = {},
}

minetest.register_on_leaveplayer(function(player)
	vexcazer.undo[player:get_player_name()] = nil
end)

minetest.register_chatcommand("vexcazer", {
	params = "",
	description = "Vexcazer info",
	func = function(name, param)
		local version="10"
		local info={version=version,modes=0,functions=0,text=""}
		for i, func in pairs(vexcazer.registry_modes) do
			info.modes=i
			if func.on_place then info.functions=info.functions+1 end
			if func.on_use then info.functions=info.functions+1 end
		end
		minetest.chat_send_player(name, "<Vexcazer> Version: ".. info.version .." Modes: " .. info.modes .. " Functions: ".. info.functions)
	end
})

vexcazer.registry_mode=function(a)
	a.name= a.name or "Mode"
	a.info= a.info or ""
	a.info_mod= a.info_mod or ""
	a.info_admin= a.info_admin or ""
	a.info_default= a.info_default or ""
	a.hide_mode_mod= a.hide_mode_mod or false
	a.hide_mode_admin= a.hide_mode_admin or false
	a.hide_mode_default= a.hide_mode_default or false
	a.wear_on_use= a.wear_on_use or 0
	a.wear_on_place= a.wear_on_place or 0
	a.disallow_damage_on_use= a.disallow_damage_on_use or false
	table.insert(vexcazer.registry_modes,a)
end

vexcazer.use=function(itemstack, user, pointed_thing,input)
	if type(user)~="userdata" then
		return itemstack
	elseif user:get_luaentity() then
		local dir=user:get_look_dir()
		local pos=user:get_pos()
		pos={x=pos.x+(dir.x)*2,y=pos.y+(dir.y)*2,z=pos.z+(dir.z)*2}
		vexcazer.bot_use(itemstack, user, pos,dir,input)
		return itemstack
	end

	if (input.mod and minetest.check_player_privs(input.user_name, {vexcazer=true})==false) or (input.admin and minetest.check_player_privs(input.user_name, {vexcazer_ad=true})==false) or (input.world and minetest.check_player_privs(input.user_name, {vexcazer_wo=true})==false) then
		local tool=user:get_inventory():get_stack("main", input.index):get_name()
		itemstack:replace(nil)
		for i, player in pairs(minetest.get_connected_players()) do
			local p_n=player:get_player_name()
			if minetest.check_player_privs(p_n, {vexcazer=true})==true
			or minetest.check_player_privs(p_n, {vexcazer_ad=true})==true then
				minetest.chat_send_player(p_n,"<vexcazer> " .. input.user_name .." tried to use an unallowed tool (" .. tool ..") ...removed from the inventory")
			end
		end
		minetest.log("action", "vexcazer " .. input.user_name .." tried to use an unallowed tool (" .. tool ..") ...removed from the inventory")
		minetest.chat_send_player(input.user_name,"<vexcazer:> You are unallowed to use this tool")
		return itemstack
	end

	if input.admin then
		user:set_properties({hp_max=100,breath_max=51})
		user:set_hp(100)
		user:set_breath(51)
		player_style.hunger(user,0,true)
		player_style.thirst(user,0,true)
	end

	if input.mod then
		user:set_properties({hp_max=50,breath_max=51})
	end

	if pointed_thing.type=="object" and not (pointed_thing.ref:get_luaentity() or pointed_thing.ref:is_player()) then
		pointed_thing.ref:set_hp(0)
		pointed_thing.ref:punch(pointed_thing.ref,1,{full_punch_interval=1,damage_groups={fleshy=9999}})
		return itemstack
	 end

	if pointed_thing.type=="node" and (minetest.get_node(pointed_thing.under)==nil or minetest.get_node(pointed_thing.above)==nil) then return itemstack end

	if pointed_thing.type=="node" and (not minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]) then
		vexcazer.unknown_remove(pointed_thing.under)
		return itemstack
	end

	local key=user:get_player_control()
	input.itemstack=itemstack


	input.mode=vexcazer.set_mode({user=user,add=1,index=input.index,get_mode=true})
	if input.mode==0 then key.sneak=true end
	if key.aux1 then
		vexcazer.gui_user[input.user_name]={user=user,input=input}
		vexcazer.form_update(user,input.index)
		return itemstack
	elseif key.sneak and input.on_use then
		return vexcazer.set_mode({user=user,add=1,index=input.index},itemstack)
	elseif key.sneak and input.on_place then
		return vexcazer.set_mode({user=user,add=-1,index=input.index},itemstack)
	end

	if input.on_place and input.default==false and pointed_thing.type=="node"
	and user:get_inventory():get_stack("main", input.index-1):get_name()==""
	and not (vexcazer.registry_modes[input.mode] and vexcazer.registry_modes[input.mode].disallow_damage_on_use) then
		local si=5
		if input.world then
			si=15
		end
		vexcazer.lazer_damage(pointed_thing.above,input,si)
		minetest.sound_play("vexcazer_lazer", {pos=pointed_thing.above, gain = 1.0, max_hear_distance = 7,})
	end

	if pointed_thing.type=="object" and not (input.on_use and vexcazer.registry_modes[input.mode] and vexcazer.registry_modes[input.mode].disallow_damage_on_use) then
		local ob=pointed_thing.ref
		if ob:is_player() then
			local is_mod=minetest.check_player_privs(ob:get_player_name(), {vexcazer=true})==true
			local is_admin=minetest.check_player_privs(ob:get_player_name(), {vexcazer_ad=true})==true
			if not(ob:is_player() and ((vexcazer.pvp==false and input.default) or (ob:get_player_name()==input.user_name))
			or (input.default and (is_mod or is_admin))) then
				if input.mod or input.default then
					if input.mod then ob:set_hp(ob:get_hp()-10) end
					ob:punch(user,1,{full_punch_interval=1,damage_groups={fleshy=10}})
				else
					ob:set_hp(0)
					ob:punch(user,1,{full_punch_interval=1,damage_groups={fleshy=9999}})
				end
				minetest.sound_play("vexcazer_lazer", {pos =ob:get_pos(), gain = 1.0, max_hear_distance = 7,})	
			end
		else
			if input.mod or input.default then
				ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=10}})
				minetest.sound_play("vexcazer_lazer", {pos =ob:get_pos(), gain = 1.0, max_hear_distance = 7,})
			else
				minetest.sound_play("vexcazer_lazer", {pos =ob:get_pos(), gain = 1.0, max_hear_distance = 10,})

				if input.world and ob:get_luaentity() then
					ob:remove()
				else
					ob:set_hp(0)
					ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=9999}})
				end
			end
		end
	end

	if vexcazer.auto_ad_mod==true and (vexcazer.creative=="true" or minetest.check_player_privs(input.user_name, {give=true})==true or minetest.check_player_privs(input.user_name, {creative=true})==true) then
		input.creative=true
	else
		input.creative=false
	end

	if key.LMB and key.RMB and (input.admin or input.mod) then
		local pos=user:get_pos()
		pointed_thing.under={x=pos.x,y=pos.y-1,z=pos.z}
		pointed_thing.above={x=pos.x,y=pos.y-0.5,z=pos.z}
		pointed_thing.type="node"
	end

	if input.admin and (input.on_use or input.on_place) then
		vexcazer.undo[input.user_name]={}
	end

	if input.on_use and vexcazer.registry_modes[input.mode] and vexcazer.registry_modes[input.mode].on_use then
		if not vexcazer.wear(itemstack,input,vexcazer.registry_modes[input.mode].wear_on_use) then return itemstack end
		input.mode_name=vexcazer.registry_modes[input.mode].name
		return vexcazer.registry_modes[input.mode].on_use(itemstack, user, pointed_thing,input)
	elseif input.on_place and vexcazer.registry_modes[input.mode] and vexcazer.registry_modes[input.mode].on_place then
		if not vexcazer.wear(itemstack,input,vexcazer.registry_modes[input.mode].wear_on_place) then return itemstack end
		input.mode_name=vexcazer.registry_modes[input.mode].name
		return vexcazer.registry_modes[input.mode].on_place(itemstack, user, pointed_thing,input)
	else
		input.set=1
		vexcazer.set_mode(input,itemstack)
	end
	return itemstack
end


vexcazer.set_mode=function(input,itstack) -- {user,add,set,index}
	if input.index==nil then return false end
	local itemstack=input.user:get_inventory():get_stack("main", input.index)
	local item=itemstack:to_table()
	local meta=minetest.deserialize(item.metadata)
	if input.get_mode and meta~=nil then
		return meta.mode
	elseif input.get_mode and meta==nil then
		return 0
	end
	local wear=itemstack:get_wear()

	if meta==nil then
		meta={mode=0}
		vexcazer.new_user(input.user,input.index)
	end
	local mode=(meta.mode)

	if input.set then
		mode=input.set
	else
		mode=mode+input.add
	end

	if vexcazer.registry_modes[mode]==nil and input.add<=0 then
		mode=#vexcazer.registry_modes
	end
	if vexcazer.registry_modes[mode]==nil then mode=1 end
	meta.mode=mode
	item.metadata=minetest.serialize(meta)
	item.meta=minetest.serialize(meta)
	item.wear=wear
	minetest.sound_play("vexcazer_mode", {pos=input.user:get_pos(), gain = 2.0, max_hear_distance = 3,})
	minetest.chat_send_player(input.user:get_player_name(),"Mode" .. mode ..": " .. vexcazer.registry_modes[mode].name)
	if itstack then
		itstack:replace(item)
		return itemstack
	else
		input.user:get_inventory():set_stack("main", input.index,item)
	end
end

vexcazer.save=function(input,string,value,global)
	local item=input.itemstack:to_table()
	local meta = minetest.deserialize(item["metadata"])
	if meta==nil then meta={} end
	meta[input.mode_name .."."..string]=value
	item.metadata=minetest.serialize(meta)
	item.meta=minetest.serialize(meta)
	if global then
		input.user:get_inventory():set_stack("main", input.index,item)
	else
		input.itemstack:replace(item)
	end


end

vexcazer.load=function(input,string)
	local item=input.itemstack:to_table()
	local meta = minetest.deserialize(item["metadata"])
	if meta==nil then return nil end 
	return meta[input.mode_name .."."..string]
end

vexcazer.form_update=function(user,index,info)

	local name=user:get_player_name()
	local pre=""
	if info==nil then info="" end

	local gui="" ..
	"size[12,8]" ..
	"background[-0.2,-0.2;12.4,8.6;vexcazer_background.png]"..
	"field[5,0;0,0;index;;" .. index.."]"

	local inv = user:get_inventory()
	for i=1,3,1 do 
		inv:set_stack(name.."_vexcazer_inv",i,nil)
	end
	local item1=inv:get_stack("main",index-1):get_name()
	local item2=inv:get_stack("main",index+1):get_name()
	local item1c=inv:get_stack("main",index-1):get_count()
	local item2c=inv:get_stack("main",index+1):get_count()
	local tool=inv:get_stack("main",index):get_name()
	local vex={default=false,mod=false,admin=false}

	if tool=="vexcazer:default" then
		vex.default=true
		if item1c>vexcazer.max_amount.default then item1c=vexcazer.max_amount.default end
		if item2c>vexcazer.max_amount.default then item2c=vexcazer.max_amount.default end
	elseif tool=="vexcazer:mod" then
		vex.mod=true
		if item1c>vexcazer.max_amount.mod then item1c=vexcazer.max_amount.mod end
		if item2c>vexcazer.max_amount.mod then item2c=vexcazer.max_amount.mod end
	elseif tool=="vexcazer:admin" then
		vex.admin=true
		if item1c>vexcazer.max_amount.admin then item1c=vexcazer.max_amount.admin end
		if item2c>vexcazer.max_amount.admin then item2c=vexcazer.max_amount.admin end
	end

	if vex.admin or vex.mod then
		pre="\nPLACE+USE = use even if you pointing at nothing"
	end

	if item1c==0 then item1c="" end
	if item2c==0 then item2c="" end
	if info=="" then info=item1 .." " .. item1c .. "\n" .. item2 .." " .. item2c .. "\n\nIf you have a kayboard:\nSNEAK+USE = change modes frontwards\nSNEAK+PLACE = Change modes backwards\nRUN/AUX1+USE = Open this gui" .. pre .."\n\nThe controler is also a powerbank\nPut it in a power generator --> top slot to load it,\nput it under to load a vexcazer" end

	if item1~="" and minetest.registered_nodes[item1] then
		item1="vexcazer:block ".. item1c
	elseif  item1~="" and minetest.registered_nodes[item1]==nil then
		item1="vexcazer:item ".. item1c
	end
	if item2~="" and minetest.registered_nodes[item2] then
		item2="vexcazer:block ".. item2c
	elseif  item2~="" and minetest.registered_nodes[item2]==nil then
		item2="vexcazer:item " ..item2c
	end

	gui=gui .."item_image_button[7,0;1,1;".. item1 ..";name1;]"
	.."item_image_button[8,0;1,1;".. tool..";name2;]"
	.."item_image_button[9,0;1,1;" .. item2 ..";name3;]"

	gui=gui .. "label[5.1,2;" .. info .."]" 

	local mb_posx=-0.1
	local mb_posy=-0.2

	for i, func in pairs(vexcazer.registry_modes) do

		if not (vex.default and func.hide_mode_default)
		and not (vex.mod and func.hide_mode_mod)
		and not (vex.admin and func.hide_mode_admin) then
			gui=gui .."button_exit[" ..mb_posx .."," .. mb_posy.. "; 2.5,1;m" .. i .."; ".. func.name.. " " .. i .. "]"
			gui=gui .."button_exit[" ..(mb_posx+2.2) .."," .. mb_posy.. "; 0.6,1;m" .. i .."info;?]"

			mb_posx=mb_posx+2.6
			if mb_posx>=5 then
				mb_posy=mb_posy+0.6
				mb_posx=-0.1
			end
		end
	end
	minetest.after(0.1, function(name,gui)
		return minetest.show_formspec(name, "vexcazer_gui",gui)
	end,name, gui)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="vexcazer_gui" then

		if pressed.quit then
			minetest.after(0.1, function(player)
				vexcazer.gui_user[player:get_player_name()]=nil
			end,player)
		end

		local index=tonumber(pressed.index)
		for i=1,30,1 do
			if pressed["m" .. i]~=nil then
				if vexcazer.registry_modes[i].on_button then
					local input=(vexcazer.gui_user[player:get_player_name()] and vexcazer.gui_user[player:get_player_name()].input) or nil
					vexcazer.registry_modes[i].on_button(player,input)
					return
				end
				return vexcazer.set_mode({index=index,user=player,add=0,set=i})
			end
			if pressed["m" .. i .."info"]~=nil then
				local moinf=""
				local adinf=""
				local deinf=""
				local item=player:get_inventory():get_stack("main",index):get_name()
				if item=="vexcazer:mod" and vexcazer.registry_modes[i].info_mod~="" then
					moinf="\n" .. vexcazer.registry_modes[i].info_mod
				elseif item=="vexcazer:admin" and vexcazer.registry_modes[i].info_admin~="" then
					adinf="\n" ..vexcazer.registry_modes[i].info_admin
				elseif item=="vexcazer:default" and vexcazer.registry_modes[i].info_default~="" then
					deinf="\n" ..vexcazer.registry_modes[i].info_default
				end
				return vexcazer.form_update(player,index,vexcazer.registry_modes[i].info .. deinf.. moinf .. adinf)
			end
		end
	end
end)

vexcazer.dig=function(pos,input,nolazer)-- pos,input
	if pos==nil then return false end
	if minetest.is_protected(pos,input.user_name) then
		minetest.chat_send_player(input.user_name, pos.x .."," .. pos.y .."," .. pos.z ..", is protected.")
		return true
	end
	local node=minetest.get_node(pos)
	local def=minetest.registered_nodes[node.name]
	if node.name=="air" or node.name=="ignore" then return true end
	if input.default and def~=nil and (def.drop=="" or def.unbreakable) then return false end

	if vexcazer.undo[input.user_name] then
		local nundo = minetest.pos_to_string(pos)
		if not vexcazer.undo[input.user_name][nundo] then
			vexcazer.undo[input.user_name][nundo] = minetest.get_node(pos).name
		end
	end

	if input.admin==false then
		minetest.node_dig(pos,node,input.user)
		if vexcazer.def(pos,"walkable")==false then
			if nolazer then
				minetest.set_node(pos, {name="air"})
			else
				minetest.set_node(pos, {name=input.lazer})
			end
		end
	else
		if nolazer then
			minetest.set_node(pos, {name="air"})
		else
			minetest.set_node(pos, {name=input.lazer})
		end
	end
	return true
end

vexcazer.place=function(use,input)--{pos,node={name=name}},input
	if minetest.is_protected(use.pos, input.user:get_player_name()) then
		minetest.chat_send_player(input.user_name, use.pos.x .."," .. use.pos.y .."," .. use.pos.z ..", is protected.")
		return false
	end
	local fn = minetest.registered_nodes[minetest.get_node(use.pos).name]

	if not fn or (fn and input.default and fn.drop=="" and fn.name:find("maptools:",1)~=nil) then
		return false
	end

	if vexcazer.undo[input.user_name] then
		local nundo = minetest.pos_to_string(use.pos)
		if not vexcazer.undo[input.user_name][nundo] then
			vexcazer.undo[input.user_name][nundo] = minetest.get_node(use.pos).name
		end
	end

	if (input.default and fn.buildable_to) or ((input.admin or input.mod) and (fn.walkable==false or fn.buildable_to)) then
		minetest.set_node(use.pos, use.node)
		if not (input.admin or input.creative) then
			input.user:get_inventory():remove_item("main", use.node.name)
			return true
		end
		return true
	else
		return false
	end
end


vexcazer.replace=function(use,input)--{pos,stack,replace,invert},input
	if minetest.is_protected(use.pos, input.user:get_player_name()) then
		minetest.chat_send_player(input.user_name, use.pos.x .."," .. use.pos.y .."," .. use.pos.z ..", is protected.")
		return false
	end
	local def=minetest.get_node(use.pos)

	if use.invert==nil then use.invert=false end
	if input.default and def~=nil and (def.drop=="" or def.unbreakable) then return false end

	if vexcazer.undo[input.user_name] then
		local nundo = minetest.pos_to_string(use.pos)
		if not vexcazer.undo[input.user_name][nundo] then
			vexcazer.undo[input.user_name][nundo] = minetest.get_node(use.pos).name
		end
	end

	if (use.invert==false and def.name==use.stack) or (use.invert and def.name~=use.stack) then
		if input.admin==false then
			minetest.node_dig(use.pos,{name=def.name},input.user)
			if not input.creative then input.user:get_inventory():remove_item("main", use.replace) end
		end
			minetest.set_node(use.pos, {name=use.replace})
		
		return true
	else
		return true
	end
end

vexcazer.lazer_damage=function(pos,input,size)
	if minetest.is_protected(pos, input.user_name) or not input.user:is_player() then
		return false
	end
	if size==nil then size=1 end
	local user=input.user
	local con={}

	for i, ob in pairs(minetest.get_objects_inside_radius(pos, size)) do
		if not (ob:is_player() and ((vexcazer.pvp==false and input.default)
		or (ob:get_player_name()==input.user_name))) then
			if type(user)=="table" then user=ob end
			if input.mod or input.default then
				ob:punch(user,1,{full_punch_interval=1,damage_groups={fleshy=10}})
			else
				if input.world then
					if ob:get_luaentity() then
						table.insert(con,ob:get_pos())
						ob:remove()
					else
						ob:set_hp(0)
						ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=9999}})
					end
				else
					ob:set_hp(0)
					ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=9999}})
				end
			end	
		end
	end

	if #con>0 then
		for i, pos in ipairs(con) do
			minetest.after(0.1, function(pos,input,size)
				vexcazer.lazer_damage(pos,input,size)
			end, pos,input,size)
		end
	end
end

vexcazer.round=function(a)
	return math.floor(a+ 0.5)
end

vexcazer.new_user=function(user,index)
	local inv=user:get_inventory()
	local name=user:get_player_name()
	local have_controler=false
	for i=0,32,1 do
		if inv:get_stack("main",i):get_name()=="vexcazer:controler" then
			have_controler=true
			break
		end
	end
	if not have_controler then 
		inv:add_item("main", ItemStack("vexcazer:controler 1 65534"))
		minetest.chat_send_player(name,"<vexcazer> Use the controler to change modes or open the gui on the tool")
	end
	if vexcazer.auto_ad_mod==false then return end


	if inv:get_stack("main",index):get_name()=="vexcazer:default" then
		if minetest.check_player_privs(name, {vexcazer_ad=true})==true then
			for i=0,32,1 do
				if inv:get_stack("main",i):get_name()=="vexcazer:admin" then
					return
				end
			end
			inv:add_item("main", "vexcazer:admin")
			if minetest.get_modpath("vexcazer_adpick")~=nil then inv:add_item("main","vexcazer_adpick:pick") end
			minetest.chat_send_player(name,"<vexcazer> vexcazer for admins added to your inventory")
		elseif minetest.check_player_privs(name, {vexcazer=true})==true then
			for i=0,32,1 do
				if inv:get_stack("main",i):get_name()=="vexcazer:mod" then
					return
				end
			end
			inv:add_item("main","vexcazer:mod")
			if minetest.get_modpath("vexcazer_adpick")~=nil then inv:add_item("main","vexcazer_adpick:pick") end
			minetest.chat_send_player(name,"<vexcazer> vexcazer for moderators added to your inventory")
		end
	end
end

vexcazer.wear=function(itemstack,input,wear)
	if input.default and input.creative==false then
		local use=itemstack:get_wear()+(vexcazer.wear_use*wear)
		if use>=65536 then
			minetest.chat_send_player(input.user_name,"<vexcazer> The power is end, and I need to be reloaded")
			return false
		elseif use<0 then
			use=1
		end
		itemstack:set_wear(use-1)
	end
	return itemstack
end

vexcazer.def=function(pos,n)
	if not (pos and pos.x and pos.y and pos.z and n) then
		return nil
	elseif not minetest.registered_nodes[minetest.get_node(pos).name] then
		minetest.remove_node(pos)
		return nil
	end
	return minetest.registered_nodes[minetest.get_node(pos).name][n]
end

vexcazer.unknown_remove=function(pos)		
	local a=50
	for y=-a,a,1 do
	for x=-a,a,1 do
	for z=-a,a,1 do
		local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		local cc=vector.length(vector.new({x=x,y=y,z=z}))/a
		if not minetest.registered_nodes[minetest.get_node(p).name] then
			minetest.remove_node(p)
		end
	end
	end
	end

end

dofile(minetest.get_modpath("vexcazer") .. "/stuff.lua")
dofile(minetest.get_modpath("vexcazer") .. "/default_modes.lua")
dofile(minetest.get_modpath("vexcazer") .. "/craft.lua")

minetest.register_alias("vex_item", "vexcazer:item")
minetest.register_alias("vex_wo", "vexcazer:world")
minetest.register_alias("vex_ad", "vexcazer:admin")
minetest.register_alias("vex_mod", "vexcazer:mod")
minetest.register_alias("vex_def", "vexcazer:default")
minetest.register_alias("vex_con", "vexcazer:controler")
