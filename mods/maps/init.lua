maps = {
	user={},
	maps={
		["tutorial"]={
			info = "Tutorials",
			image="default_craftguide.png",
			pos={x=0,y=28501,z=0},
			size={y=51,x=133,z=100},
			locked=true,
			singleplayer=true,
			on_enter=function(player)
				--nodeextractor.set({x=0,y=28501,z=0},minetest.get_modpath("maps").."/nodeextractor/".."maps_tutorial.exexn",true)
					local m = player:get_meta()

					if m:get_string("Tutorials_pos") ~= "" then
						player_style.inventory_handle(player,{show=true})
						m:set_string("Tutorials_pos","")
						return
					else
						m:set_string("Tutorials_pos",minetest.pos_to_string(player:get_pos()))
						player_style.inventory_handle(player,{hide=true})
					end
					player_style.inventory(player)

				minetest.after(0.5, function(player)
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

player_style.register_button({
	name="special",
	image="map_map.png",
	type="image",
	info="Abilities",
	action=function(user)
		maps.show(user)
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
				if not (maps.maps[b].unable or maps.maps[b].locked) then
					maps.maps[b].on_enter(player)
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