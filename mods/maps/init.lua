maps = {
	user={},
	maps={
		["tutorial"]={
			info = "Tutorials",
			image="default_craftguide.png",
			pos={x=0,y=28501,z=0},
			size={y=51,x=133,z=100},
			locked=true,
			hide_items = true,
			singleplayer=true,
			on_enter=function(player)
				if default.storage:get_int("Tutorials") == 0 then
					default.storage:set_int("Tutorials",1)
					nodeextractor.set({x=0,y=28501,z=0},minetest.get_modpath("maps").."/nodeextractor/".."maps_tutorial.exexn",true)
				end
				minetest.after(0.1, function(player)
					player:set_pos({x=60,y=28531,z=42})
				end,player)
			end,
			on_exit=function(player)
				player:set_pos(minetest.pos_to_string(m:get_string("Tutorials_pos")))
			end,
			on_die=function(player)
			end,
		},
	}
}

dofile(minetest.get_modpath("maps") .. "/items.lua")

player_style.register_button({
	name="special",
	image="map_map.png",
	type="image",
	info="Abilities",
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
			form = form
			.. "image_button["..x..","..y..";1,1;"..(v.image or "map_map.png")..(v.locked and "^default_lock_icon.png" or "")..(v.unable and "^default_cross.png" or "")..";mapsbut_"..i..";]"
			.. (v.info and "tooltip[mapsbut_"..i..";"..v.info.."]" or "")
			x = x + 1
			if x >= 8 then
				x = 0
				y = y +1
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
					maps.set_exit_player(player)
								
					if map.hide_items then
						player_style.inventory_handle(player,{hide=true})
						if m:get_string("maps_pos") == "" then
							m:set_string("maps_pos",minetest.pos_to_string(player:get_pos()))
						end
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

		if not m.on_exit then
			minetest.log("warning","Maps: "..map.." Is missing on_exit (function)")
			maps.maps[map].unable = true
		end

		if not m.on_die then
			minetest.log("warning","Maps: "..map.." Is missing on_die (function)")
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
	inv.adds["maps_exit"] = "image_button[7,1;1,1;map_map.png^default_cross.png;maps_exit;]tooltip[maps_exit;Exit map]"
	m:set_int("maps_exit",1)

	inv.adds_func["maps_exit"] = function(player)
		local m = player:get_meta()
		local name = player:get_player_name()
		local inv = player_style.players[name].inv
		local p = minetest.string_to_pos(m:get_string("maps_pos"))
		if p then
				player:set_pos(p)
		end
		inv.adds["maps_exit"] = nil
		inv.adds_func["maps_exit"] =nil
		m:set_string("maps_pos","")
		m:set_int("maps_exit",0)
		player_style.inventory_handle(player,{show=true})
		minetest.close_formspec(name,"")
	end
end
