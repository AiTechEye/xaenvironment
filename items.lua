minetest.register_node("maps:node_set", {
	description = "Node setter",
	tiles={"default_stone.png^[invert:rb"},
	groups = {unbreakable=1,exatec_wire_connected=1,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("formspec","size[2,1]button_exit[0,0;2,1;setup;Setup]")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if (pressed.save or pressed.setup) and minetest.check_player_privs(sender:get_player_name(), {server=true}) then
			local m = minetest.get_meta(pos)
			local node = minetest.registered_nodes[pressed.node]
			local n = tonumber(pressed.pos2)
			local pos1
			local pos2

			if pressed.save then
				local name = sender:get_player_name()
				local p = protect.user[name]
				if p and p.pos1 and p.pos2 then
					pressed.node = minetest.get_node(p.pos1).name
					node = true
					pos1 = p.pos1
					pos2 = p.pos2
					pressed.pos1 =  p.pos1.x.." "..p.pos1.y.." "..p.pos1.z 
					pressed.pos2 =  p.pos2.x.." "..p.pos2.y.." "..p.pos2.z
					protect.clear(name)
				elseif p and p.pos1 then
					local nod = minetest.get_node(p.pos1)
					n = nod.param2
					pressed.node = nod.name
					pos1 = p.pos1
					node = true
					pressed.pos1 =  p.pos1.x.." "..p.pos1.y.." "..p.pos1.z
					protect.clear(name)
				else
					pos1 = minetest.string_to_pos("("..pressed.pos1:gsub(" ",",")..")")
					pos2 = minetest.string_to_pos("("..pressed.pos2:gsub(" ",",")..")")
				end
			end

			if node then
				m:set_string("node",pressed.node)
			end

			if pos1 and (pos1.y > 26000 and pos1.y < 31000) then
				m:set_string("pos1l",minetest.pos_to_string(vector.subtract(pos1,pos)))
				m:set_string("pos1",pressed.pos1:gsub(","," "))
			end
			if pos2 and (pos2.y > 26000 and pos2.y < 31000) then
				m:set_string("pos2l",minetest.pos_to_string(vector.subtract(pos2,pos)))
				m:set_string("pos2",pressed.pos2:gsub(","," "))
			else
				m:set_string("pos2","")
				m:set_string("pos2l","")
				m:set_int("n",n or 0)
			end
			m:set_string("formspec","size[1.5,3]"
			.."button_exit[-0.2,-0.2;2,1;save;Save]"
			.."field[0,1;2,1;node;;"..m:get_string("node").."]"
			.."field[0,2;2,1;pos1;;"..m:get_string("pos1").."]"
			.."field[0,3;2,1;pos2;;"..(m:get_string("pos2") ~= "" and m:get_string("pos2") or m:get_string("n")).."]"
			.."tooltip[save;You can also Mark with /protect 1 or both /protect 1 /protect 2 to select the position/area.\nDo not protect, just mark it then press save]"
			.."tooltip[node;A valid node, eg default:stone]"
			.."tooltip[pos1;Position 1, (eg 1,0,-5)]"
			.."tooltip[pos2;Position 2, (eg -1,10,5) or (eg 4) (param2/rotation number) if you only will place 1 block, can be empty]"
			)        
		end
	end,
	exatec={
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local node = m:get_string("node")
			local n = m:get_int("n")
			local pos1 = minetest.string_to_pos(m:get_string("pos1l"))
			local pos2 = minetest.string_to_pos(m:get_string("pos2l"))

			if node ~= "" and pos1 then
				pos1 = vector.add(pos1,pos)
				if pos2 then
					pos2 = vector.add(pos2,pos)
					pos1,pos2 = protect.sort(pos1,pos2)
					local p = {}
					for x=pos1.x,pos2.x do
					for z=pos1.z,pos2.z do
					for y=pos1.y,pos2.y do
						table.insert(p,vector.new(x,y,z))
					end
					end
					end
					minetest.bulk_set_node(p,{name=node})
				else
					minetest.set_node(pos1,{name=node,param2=n})
				end
			end
		end
	}
})

minetest.register_node("maps:playermove", {
	description = "player moveer",
	tiles={"default_stone.png^[invert:gr"},
	groups = {unbreakable=1,exatec_wire_connected=1,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("formspec","size[2,1]button_exit[0,0;2,1;setup;Setup]")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.save or pressed.setup then
			local m = minetest.get_meta(pos)
			local pos1
			local dir = sender:get_look_dir()

			if pressed.save then
				local name = sender:get_player_name()
				local p = protect.user[name]
				if p and p.pos1 then
					pos1 = p.pos1
					pressed.pos1 =  p.pos1.x.." "..p.pos1.y.." "..p.pos1.z
					protect.clear(name)
				else
					pos1 = minetest.string_to_pos("("..pressed.pos1:gsub(" ",",")..")")
				end
			end

			if pos1 then
				m:set_string("pos1l",minetest.pos_to_string(vector.subtract(pos1,pos)))
				m:set_string("pos1",pressed.pos1:gsub(","," "))
			end
			m:set_int("rad",tonumber(pressed.rad) or 0)
			m:set_string("dir",(math.floor(sender:get_look_horizontal()*100)*0.01) .." ".. (math.floor(sender:get_look_vertical()*100)*0.01))

			m:set_string("formspec","size[1.5,3]"
			.."button_exit[-0.2,-0.2;2,1;save;Save]"
			.."field[0,1;2,1;rad;;"..m:get_int("rad").."]"
			.."field[0,2;2,1;pos1;;"..m:get_string("pos1").."]"
			.."field[0,3;2,1;dir;;"..m:get_string("dir") .."]"
			.."tooltip[save;Mark with /protect 1 to mark the position, then press save]"
			.."tooltip[pos1;Position 1, (eg 1,0,-5)]"
			.."tooltip[rad;Max radius to objects]"
			)        
		end
	end,
	exatec={
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local node = m:get_string("node")
			local n = m:get_int("rad")
			local pos1 = minetest.string_to_pos(m:get_string("pos1l"))
			local dir = m:get_string("dir"):split(" ")

			if pos1 and #dir > 1 then
				local h = tonumber(dir[1])
				local v = tonumber(dir[2])
				pos1 = vector.add(pos1,pos)

				for _, ob in pairs(minetest.get_objects_inside_radius(pos,n)) do
					local en = ob:get_luaentity()
					if ob:is_player() then
						ob:set_look_horizontal(h)
						ob:set_look_vertical(v)
					end
					if not (en and en.decoration) then
						ob:set_pos(pos1)
					end
				end
			end
		end
	}
})

minetest.register_node("maps:clearinv", {
	description = "player clearinv",
	tiles={"default_stone.png^[invert:bg"},
	groups = {unbreakable=1,exatec_wire_connected=1,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local r = meta:get_int("r")
			r = r < 20 and r or 0
			meta:set_int("r",r+1)
			meta:set_string("infotext","Radius (" .. (r+1) ..")")
		end
	end,
	exatec={
		on_wire = function(pos)
			for _, ob in pairs(minetest.get_objects_inside_radius(pos,minetest.get_meta(pos):get_int("r"))) do
				if ob:is_player() then
					player_style.inventory_handle(ob,{clear=true})
				end
			end
		end
	}
})

minetest.register_node("maps:button", {
	description = "Button",
	tiles={"default_wood.png",},
	drawtype = "nodebox",
	node_box = {type = "fixed",fixed={{0.5, 0.5, 0.5, -0.5, -0.5, -0.5},{-0.2, 0.5, -0.2, 0.2, 0.7, 0.2}}},
	paramtype = "light",
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	sounds = default.node_sound_wood_defaults(),
	groups = {unbreakable=1,exatec_wire_connected=1,not_in_creative_inventory=1},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		exatec.send(pos)
	end,
})

minetest.register_node("maps:settime", {
	description = "Set time",
	tiles={"default_stone.png^[invert:r"},
	groups = {unbreakable=1,exatec_wire_connected=1,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:set_float("t",12.0)
		m:set_string("infotext","Time (12)")
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local m = minetest.get_meta(pos)
			local t = m:get_float("t")
			t = t+1 < 25 and t+1 or 0
			m:set_float("t",t)
			m:set_string("infotext","Time (" .. t ..")")
		end
	end,
	exatec={
		on_wire = function(pos)
			minetest.set_timeofday(minetest.get_meta(pos):get_float("t")/24)
		end
	}
})

minetest.register_node("maps:protect", {
	description = "protects area, removes area when reused",
	tiles={"default_stone.png^[invert:gbr"},
	groups = {unbreakable=1,exatec_wire_connected=1,not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("formspec","size[2,1]button_exit[0,0;2,1;setup;Setup]")
	end,
	after_place_node=function(pos, placer, itemstack, pointed_thing)
		local m = minetest.get_meta(pos)
		m:set_string("owner",placer:get_player_name())
		m:set_int("id",-1)
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if (pressed.save or pressed.setup or pressed.toggle) and minetest.check_player_privs(sender:get_player_name(), {server=true}) then
			local m = minetest.get_meta(pos)
			local pos1
			local pos2
			if pressed.save then
				local name = sender:get_player_name()
				local p = protect.user[name]
				if p and p.pos1 and p.pos2 then
					pressed.node = minetest.get_node(p.pos1).name
					node = true
					pos1 = p.pos1
					pos2 = p.pos2
					pressed.pos1 =  p.pos1.x.." "..p.pos1.y.." "..p.pos1.z 
					pressed.pos2 =  p.pos2.x.." "..p.pos2.y.." "..p.pos2.z
					protect.clear(name)
				end
			elseif pressed.toggle then
				minetest.registered_nodes["maps:protect"].exatec.on_wire(pos)
			end
			m:set_string("name",pressed.name)
			if pos1 and (pos1.y > 26000 and pos1.y < 31000) then
				m:set_string("pos1l",minetest.pos_to_string(vector.subtract(pos1,pos)))
				m:set_string("pos1",pressed.pos1:gsub(","," "))
			end
			if pos2 and (pos2.y > 26000 and pos2.y < 31000) then
				m:set_string("pos2l",minetest.pos_to_string(vector.subtract(pos2,pos)))
				m:set_string("pos2",pressed.pos2:gsub(","," "))
			end
			m:set_string("formspec","size[1.5,4]"
			.."button_exit[-0.2,-0.2;2,1;save;Save]"
			.."field[0,1;2,1;name;;"..m:get_string("name").."]"
			.."field[0,2;2,1;pos1;;"..m:get_string("pos1").."]"
			.."field[0,3;2,1;pos2;;"..m:get_string("pos2").."]"
			.."tooltip[save;Mark with both /protect 1 /protect 2 to select the position/area.\nDo not protect, just mark it then press save]"
			.."tooltip[node;A valid node, eg default:stone]"
			.."tooltip[pos1;Position 1]"
			.."tooltip[pos2;Position 2]"
			.."button_exit[-0.2,3.5;2,1;toggle;Toggle "..(m:get_int("id") == -1 and "on" or "off").."]"
			)
		end
	end,
	exatec={
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local id = m:get_int("id")
			local owner = m:get_string("owner")

			if id ~= -1 then
				protect.remove_game_rule_area(id)
				m:set_int("id",-1)
				return
			end

			local pos1 = minetest.string_to_pos(m:get_string("pos1l"))
			local pos2 = minetest.string_to_pos(m:get_string("pos2l"))

			if pos1 and pos2 and owner ~= "" then
				pos1,pos2 = protect.sort(vector.add(pos1,pos),vector.add(pos2,pos))
				local pr,o = protect.test(pos1,pos2,owner)
				if pr == false then
					minetest.chat_send_player(owner,"The area is protected by "..o)
					return
				end
				id = protect.add_game_rule_area(pos1,pos2,m:get_string("name"),owner,false)
				if id then
					m:set_int("id",id)
				end
			end
		end
	}
})