exa2d={
	storage = minetest.get_mod_storage(),
	user={},
	playeranim={
		stand={x=1,y=39,speed=30},
		walk={x=41,y=61,speed=30},
		run={x=41,y=61,speed=60},
		mine={x=65,y=75,speed=30},
		hugwalk={x=80,y=99,speed=30},
		lay={x=113,y=123,speed=0},
		sit={x=101,y=111,speed=0},
	},
	map = {},
	active_map = {}
}

dofile(minetest.get_modpath("exa2d") .. "/nodes_items.lua")
dofile(minetest.get_modpath("exa2d").."/entities.lua")

minetest.register_on_mods_loaded(function()
	exa2d.active_map = minetest.deserialize(exa2d.storage:get_string("active_map")) or {}
end)

minetest.register_privilege("ability2d", {
	description = "Enter to 2D (Stand close to a wall and hold right mouse button/place on a wall in 1 second with empty hand)",
	give_to_singleplayer= false,
	on_grant=function(name)
		player_style.players[name].ability2d = {time=0}
		minetest.chat_send_player(name,"Stand close to a wall and hold right mouse button/place on a wall in 1 second with empty hand")
	end,
	on_revoke=function(name)
		player_style.players[name].ability2d = nil
	end
})

exa2d.is_item=function(pos)
	return minetest.get_item_group(minetest.get_node(pos).name,"exa2d_item") > 0
end

exa2d.spawn_super_coconut=function(pos,dir,fdir)
	local ob = minetest.add_entity(apos(pos),"exa2d:super_coconut")
	ob:get_luaentity().dir = dir
	ob:get_luaentity().fdir = fdir
	minetest.after(0, function(ob)
		ob:set_velocity({x=0,y=8,z =0})
	end,ob)
end

exa2d.spawn_item=function(pos,dir,fdir,item,popup)
	local ob = minetest.add_entity(apos(pos),"exa2d:item")
	ob:get_luaentity().dir = dir
	ob:get_luaentity().fdir = fdir
	ob:get_luaentity().item = ItemStack(item)
	if popup then
		ob:set_velocity({x=0,y=8,z =0})
	end
	return ob
end

exa2d.mapgen=function(pos,dir,fdir)
	local save
	local p = {
		x=math.floor(pos.x*0.1)*10,
		y=math.floor(pos.y*0.1)*10,
		z=math.floor(pos.z*0.1)*10
	}
-- activate items

	for xz=20,-20,-1 do
	for y=5,-5,-1 do
		local mp
		if dir.z ~= 0 then
			mp = {x=pos.x+xz,y=pos.y+y,z=pos.z-(dir.z*0.5)}
		else
			mp = {x=pos.x-(dir.x*0.5),y=pos.y+y,z=pos.z+xz}
		end
		local n = minetest.get_node(mp)
		if n.name == "exa2d:inactive_item" and n.param2 == fdir then
			exa2d.activate_item(mp)
		end
	end
	end

--time map to generate items

	for i,v in pairs(exa2d.active_map) do
		if default.date("h",v.date) >= 1 then
			table.remove(exa2d.active_map,i)
			save = true
		elseif v.fdir == fdir and vector.distance(p,v.pos) <= 20 then
			return
		end
	end
	table.insert(exa2d.active_map,{pos=p, date=default.date("get"),fdir=fdir})

--generate items

	local blockset
	local dxz = dir.z ~= 0 and (-dir.z*0.5) or (-dir.x*0.5)
	local dx = 0
	local dz = 0
	local x = 0
	local z = 0
	local coinset = math.random(0,10)
	local enemyset = math.random(0,3)
	local blockset = math.random(0,3)

	for xz=20,-20,-1 do
	if xz <= 2 and xz >= 0 -2 then
		goto conti
	end
	for y=5,-5,-1 do
		if dir.z ~= 0 then
			x = xz
			dz = dxz
		else
			z = xz
			dx = dxz
		end
		local mp = {x=pos.x+x+dx,y=pos.y+y,z=pos.z+z+dz}

--enemy

		if enemyset > 0 and default.defpos(mp,"buildable_to") and not minetest.is_protected(mp, "")
		and default.defpos(apos(mp,dir.x,0,dir.z),"walkable")
		and default.defpos(apos(mp,0,-1),"walkable") then
			enemyset = enemyset -1
			local ob = minetest.add_entity(apos(mp,dir.x*0.49,1,dir.z*0.49),"exa2d:enemy")
			ob:get_luaentity().dir = dir
			ob:get_luaentity().fdir = fdir
		end

--? block

		if blockset > 0 and not exa2d.is_item(mp) and not minetest.is_protected(mp, "")
		and default.defpos(mp,"buildable_to") and default.defpos(apos(mp,dir.x,0,dir.z),"walkable")
		and default.defpos(apos(mp,0,-1),"buildable_to") and default.defpos(apos(mp,dir.x,-1,dir.z),"walkable")
		and default.defpos(apos(mp,0,-2),"buildable_to") and default.defpos(apos(mp,dir.x,-2,dir.z),"walkable")
		and default.defpos(apos(mp,0,-3),"walkable") then
			blockset = blockset -1
			minetest.set_node(mp,{name="exa2d:block",param2=fdir})
		end

--hole

		if math.random(0,2) == 1 and not exa2d.is_item(mp) and default.defpos(mp,"buildable_to") and not minetest.is_protected(mp, "")
		and default.defpos(apos(mp,dir.x,0,dir.z),"walkable")
		and default.defpos(apos(mp,0,-1),"walkable") then
			minetest.set_node(mp,{name="exa2d:hole",param2=fdir})
		end

--coin

		if coinset > 0 and not exa2d.is_item(mp) and default.defpos(mp,"buildable_to") and not minetest.is_protected(mp, "")
		and default.defpos(apos(mp,dir.x,0,dir.z),"walkable")
		and default.defpos(apos(mp,0,-1),"walkable") then
			coinset = coinset -1
			minetest.set_node(mp,{name="exa2d:coin",param2=fdir})
			if math.random(1,2) == 1 then
				brcoin = true
			end
		end

	end
		::conti::
	end

	if save then
		exa2d.storage:set_string("active_map",minetest.serialize(exa2d.active_map))
	end
end

exa2d.activate_item=function(pos)
	local p2 = minetest.get_node(pos).param2
	local m = minetest.get_meta(pos)
	local name = m:get_string("exa2d_item")
	if name ~= "" then
		local m = minetest.get_meta(pos)
		if m:get_int("object") == 1 then
			local ob = minetest.add_entity(minetest.string_to_pos(m:get_string("pos")),m:get_string("exa2d_item"))
			local en = ob:get_luaentity()
			local item = m:get_string("item")
			en.dir = minetest.string_to_pos(m:get_string("dir"))
			en.fdir = m:get_int("fdir")
			if item ~= "" then
				en.item = ItemStack(minetest.deserialize(item))
			end

			minetest.remove_node(pos)
		else
			minetest.swap_node(pos, {name=name, param2=p2})
			minetest.get_node_timer(pos):start(1)
		end
	else
		minetest.remove_node(pos)
	end
end
	
exa2d.inactivate_item=function(pos,en)
	if en then
		if not exa2d.is_item(pos) and not minetest.is_protected(pos, "") and default.defpos(pos,"buildable_to") then
			minetest.set_node(pos, {name="exa2d:inactive_item", param2=en.fdir})
			local m = minetest.get_meta(pos)
			m:set_string("exa2d_item",en.name)
			m:set_int("object",1)
			m:set_string("dir",minetest.pos_to_string(en.dir))
			m:set_int("fdir",en.fdir)
			m:set_string("pos",minetest.pos_to_string(pos))
			m:set_int("date",default.date("get"))

			if en.item then
				m:set_string("item",minetest.serialize(en.item:to_table()))
			end

			return true
		end
		return
	end

	local n = minetest.get_node(pos)
	local p2 = n.param2
	for i,v in pairs(exa2d.user) do
		if v.object and v.fdir == p2 then
			local p = v.object:get_pos()
			if p and vector.distance(p,pos) <= 20 then
				return true
			end
		end
	end
	local m = minetest.get_meta(pos)
	m:set_string("exa2d_item",n.name)
	m:set_int("date",default.date("get"))
	minetest.swap_node(pos, {name="exa2d:inactive_item", param2=p2})
end

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local name = placer:get_player_name()
	if exa2d.user[name] then
		minetest.set_node(pos,oldnode)
		return true
	end
end)

exa2d.join=function(player,pos)
	local name = player:get_player_name()
	local fdir = minetest.dir_to_facedir(player:get_look_dir())
	local dir = minetest.facedir_to_dir(fdir)

	if not default.defpos(apos(pos,dir.x,0,dir.z),"walkable") or not default.defpos(apos(pos,dir.x,1,dir.z),"walkable") then
		minetest.chat_send_player(name,"Place on a wall")
		return
	elseif default.defpos(pos,"walkable") then
		minetest.chat_send_player(name,"Error, try again")
		return
	else
		minetest.chat_send_player(name,"Punch to to exit")
	end

	player:set_pos(pos)
	local id=math.random(1,9999)
	local cam=minetest.add_entity({x=pos.x,y=pos.y,z=pos.z}, "exa2d:cam")
	cam:get_luaentity().user=player
	cam:get_luaentity().username=name
	cam:get_luaentity().id=id
	cam:get_luaentity().dir=dir
	cam:get_luaentity().fdir=fdir
	exa2d.user[name]={fdir=fdir,dir=dir,id=id,cam=cam,texture=player:get_properties().textures[1]}
	player:set_attach(cam, "",{x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
	player:hud_set_flags({wielditem=false})
	player:set_nametag_attributes({color={a=0,r=255,g=255,b=255}})
	player:set_properties({textures={"default_air.png"}})

	examobs.hiding[name] = ""
	for _, ob in pairs(minetest.get_objects_inside_radius(pos,30)) do
		local en = ob:get_luaentity()
		if en and en.examob then
			local target = en.fight or en.flee or en.target
			if target and target:is_player() and target:get_player_name() == name then
				en.fight = nil
				en.fight = nil
				en.flee = nil
			end
		end
	end

	exa2d.user[name].ui_coin = player:hud_add({
		hud_elem_type="image",
		scale = {x=2,y=2},
		position={x=0.9,y=0.03},
		text="player_style_coin.png",
		offset={x=0,y=0},
	})
	exa2d.user[name].ui_coins = player:hud_add({
		hud_elem_type="text",
		scale = {x=1,y=1},
		text=player:get_meta():get_int("coins"),
		number=0xFFFF00,
		offset={x=0,y=10},
		position={x=0.95,y=0.02},
		alignment=0,
	})
end
	
exa2d.leave=function(player)
	local name = player:get_player_name()
	if not exa2d.user[name] then
		return
	end

	player:set_nametag_attributes({color={a=255,r=255,g=255,b=255}})
	player:set_properties({textures={exa2d.user[name].texture}})
	player:hud_set_flags({wielditem=true})
	player:set_detach()
	if exa2d.user[name].object then
		local p = exa2d.user[name].object:get_pos()
		if p then
			local d = exa2d.user[name].dir
			p = apos(p,d.x*-0.5,0,d.z*-0.5)
			minetest.after(0, function(player,name,p)
				player:set_pos(p)
			end,player,name,p)
		end
	end

	player:hud_remove(exa2d.user[name].ui_coins)
	player:hud_remove(exa2d.user[name].ui_coin)

	exa2d.user[name]=nil
	examobs.hiding[name] = nil
end

minetest.register_on_leaveplayer(function(player)
	exa2d.leave(player)
end)

exa2d.player_anim=function(self,typ)
	if typ==self.anim then
		return
	end
	self.anim=typ
	self.ob:set_animation({x=exa2d.playeranim[typ].x, y=exa2d.playeranim[typ].y, },exa2d.playeranim[typ].speed,0)
	exa2d.update_wielded_item(self)
	return self
end

exa2d.update_wielded_item=function(self)
	if self.user and self.user:get_wielded_item() ~= self.wielditem then
		self.wielditem=self.user:get_wielded_item():get_name()
		local t="default_air.png"

		local def1=minetest.registered_items[self.wielditem]

		if def1 and def1.inventory_image and def1.inventory_image~="" then
			t=def1.inventory_image
		elseif def1 and def1.tiles and type(def1.tiles[1])=="string" then
			t=def1.tiles[1]
		end
		self.ob:set_properties({textures={t,exa2d.user[self.username].texture}})
	end
end

exa2d.punch=function(ob1,ob2,hp)
	if not (ob1 and ob2) then
		return
	end
	hp=hp or 1
	if ob1:is_player() then
		ob1:set_hp(ob1:get_hp()-hp)
	else
		ob1:punch(ob2,1,{full_punch_interval=1,damage_groups={fleshy=hp}})
	end	
end

default.register_on_item_drop(function(pos, itemstring, object, dropper)
	local p = exa2d.user[dropper]
	if p then
		local i = exa2d.spawn_item(p.object:get_pos(),p.dir,p.fdir,itemstring)
		local y = p.object:get_yaw()
		i:set_velocity({
			x = math.sin(y) * -4,
			y = 4,
			z = math.cos(y) * 4
		})
		object:remove()
		exa2d.update_wielded_item(p.cam:get_luaentity())
	end
end)
