maps = {
	user={},
	maps={
		["tutorial"]={
			info = "Tutorials",
			image="default_craftguide.png",
			pos={x=0,y=0,z=0},
			size={y=51,x=133,z=100},
			--locked=true,
			--unable=true,
			hide_items = true,
			singleplayer=true,
			bones_disabled=true,
			--bones_drop_only = true,
			special_disabled=true,
			store_disabled=true,
			on_enter=function(player)
				if default.storage:get_int("Tutorials") < 3 then
					local pos = maps.get_pos({x=0,y=0,z=0})
					minetest.emerge_area(vector.add(pos,50),vector.subtract(pos,50),function(pos, action, calls_remaining, param)
						if calls_remaining == 0 then
							nodeextractor.set(maps.get_pos({x=0,y=0,z=0}),minetest.get_modpath("maps").."/nodeextractor/".."maps_tutorial.exexn",true)
							default.storage:set_int("Tutorials",3)
							maps.set_pos(player,{x=60,y=31,z=42})
						end
					end)
					return
				end
				minetest.after(0.1, function(player)
					maps.set_pos(player,{x=60,y=31,z=42})
				end,player)
			end,
			on_exit=function(player)
			end,
			on_die=function(player)
			end,
			on_respawn=function(player)
				maps.set_pos(player,{x=60,y=31,z=42})
			end,
		},
	}
}

dofile(minetest.get_modpath("maps") .. "/items.lua")

minetest.register_chatcommand("ttmd", {
	params = "<pos>",
	description = "Teleport to maps dimension",
	privs = {teleport=true},
	func = function(name, param)
		local p = minetest.get_player_by_name(name)
		local p2 = param:gsub(","," "):split(" ")
		if p and p2[3] then
			local x,y,z = tonumber(p2[1]),tonumber(p2[2]),tonumber(p2[3])
			if math.abs(y) > 2500 then
				return false, "Not allowed to move outside the dimension"
			elseif x and y and z then
				maps.set_pos(p,vector.new(x,y,z))
				return true
			else
				return false, "Not a valid position, eg: 0 1 0 or 0,1,0"
			end
		end
	end
})


maps.get_pos=function(pos)
	return vector.add(pos,{x=0,y=28500,z=0})
end

maps.set_pos=function(object,pos)
	if math.abs(pos.y) < 2500 then
		object:set_pos(maps.get_pos(pos))
	else
		minetest.log("warning","Maps: Not allowed to move outside the dimension")
	end
end


player_style.register_button({
	name="maps",
	image="map_map.png",
	type="image",
	info="Maps",
	action=function(user)
		local name = user:get_player_name()
		local inv = player_style.players[name].inv
		if inv.adds["maps_exit"] then
			minetest.chat_send_player(name,"You have to exit the current map first")
		else
			maps.show(user)
		end
	end
})

maps.show=function(player)
	minetest.after(0.2, function(player)
		local name = player:get_player_name()
		local x,y = 0,0
		local form = "size[8,8]listcolors[#77777777;#777777aa;#000000ff]"
		for i,v in pairs(maps.maps) do
			if not (v.singleplayer and minetest.is_singleplayer() == false) then
				form = form
				.. "image_button["..x..","..y..";1,1;"..(v.image or "map_map.png")..(v.locked and "^default_lock_icon.png" or "")..(v.unable and "^default_cross.png" or "")..";mapsbut_"..i..";]"
				.. (v.info and "tooltip[mapsbut_"..i..";"..v.info..(v.singleplayer and "\n(Singleplayer only)" or "").."]" or "")
				x = x + 1
				if x >= 8 then
					x = 0
					y = y +1
				end
			end
		end
		return minetest.show_formspec(name, "maps",form)
	end, player)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "maps" then
		for i,v in pairs(pressed) do
			if i:sub(1,8) == "mapsbut_" then
				local b = i:gsub("mapsbut_","")
				local map = maps.maps[b]
				if not (maps.maps[b].unable or maps.maps[b].locked) then
					local m = player:get_meta()
					m:set_string("maps_current",b)
					maps.set_exit_player(player)
								
					if map.hide_items then
						player_style.inventory_handle(player,{hide=true})
						if m:get_string("maps_pos") == "" then
							m:set_string("maps_pos",minetest.pos_to_string(player:get_pos()))
						end
					end
					if map.bones_disabled then
						m:set_int("bones_disabled",1)
					elseif map.bones_drop_only then
						m:set_int("bones_drop_only",1)
					end
					if map.killme_disabled then
						m:set_int("killme_disabled",1)
					end
					if map.special_disabled then
						m:set_int("special_disabled",1)
					end
					if map.store_disabled then
						m:set_int("store_disabled",1)
					end

					player_style.inventory(player)
					maps.maps[b].on_enter(player)
					minetest.close_formspec(player:get_player_name(),"")
				end
			end
		end
	end
end)

minetest.register_on_mods_loaded(function()
	for map,m in pairs(maps.maps) do
		local p1 = m.pos
		local p2 = vector.add(m.pos,m.size)

		if not m.pos then
			minetest.log("warning","Maps: "..map.." Is missing pos (position/vector)")
			maps.maps[map].unable = true
		end

		if not m.size then
			minetest.log("warning","Maps: "..map.." Is missing size (vector)")
			maps.maps[map].unable = true
		end

		if not m.on_enter then
			minetest.log("warning","Maps: "..map.." Is missing on_enter (function)")
			maps.maps[map].unable = true
		end

		if not m.on_respawn then
			minetest.log("warning","Maps: "..map.." Is missing on_respawn (function)")
			maps.maps[map].unable = true
		end

		for i,v in pairs(maps.maps) do
			local pos1,pos2 = protect.sort(v.pos,vector.add(v.pos,v.size))
			if map ~= i and not maps.maps[map].unable
			and (pos1.x <= p2.x and pos2.x >= p1.x)
			and (pos1.y <= p2.y and pos2.y >= p1.y)
			and (pos1.z <= p2.z and pos2.z >= p1.z) then
				minetest.log("error","Maps: "..i.." interacts with "..map)
				maps.maps[i].unable = true
			end
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	if player:get_meta():get_int("maps_exit") == 1 then
		maps.set_exit_player(player)
	end
end)

maps.set_exit_player=function(player)
	local name = player:get_player_name()
	local inv = player_style.players[name].inv
	local m = player:get_meta()
	inv.adds["maps_exit"] = "image_button[7,2;1,1;map_map.png^default_cross.png;maps_exit;]tooltip[maps_exit;Exit map]"
	m:set_int("maps_exit",1)
	m:set_int("respawn_disallowed",1)
	player:hud_set_flags({basic_debug=false})
	inv.adds_func["maps_exit"] = function(player)
		player:hud_set_flags({basic_debug=true})
		local m = player:get_meta()
		local name = player:get_player_name()
		local inv = player_style.players[name].inv
		local p = minetest.string_to_pos(m:get_string("maps_pos"))
		local map = maps.maps[m:get_string("maps_current")]
		if map and map.on_exit then
			map.on_exit(player)
		end

		if p then
				player:set_pos(p)
		end
		inv.adds["maps_exit"] = nil
		inv.adds_func["maps_exit"] =nil
		m:set_string("maps_pos","")
		m:set_int("maps_exit",0)
		m:set_int("respawn_disallowed",0)
		m:set_string("maps_current","")
		m:set_int("bones_disabled",0)
		m:set_int("bones_drop_only",0)
		m:set_int("killme_disabled",0)
		m:set_int("special_disabled",0)
		m:set_int("store_disabled",0)
		player_style.inventory_handle(player,{show=true})
		minetest.close_formspec(name,"")
	end
end

minetest.register_on_respawnplayer(function(player)
	local map = maps.maps[player:get_meta():get_string("maps_current")]
	if map then
		minetest.after(0, function(player,map)
			map.on_respawn(player)
		end,player,map)
	end
end)

minetest.register_on_dieplayer(function(player)
	local map = maps.maps[player:get_meta():get_string("maps_current")]
	if map and map.on_die then
		map.on_die(player)
	end
end)