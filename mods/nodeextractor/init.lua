nodeextractor = {user={}}

minetest.register_on_leaveplayer(function(player)
	nodeextractor.user[player:get_player_name()] = nil
end)

nodeextractor.create=function(pos1,pos2,filename)
	if not filename then
		print("default.nodeextractor: filename is missing")
		return
	end
	pos1 = vector.round(pos1)
	pos2 = vector.round(pos2)
	protect.sort(pos1,pos2)
	local m = {}
	for x=0,pos2.x-pos1.x do
	for y=0,pos2.y-pos1.y do
	for z=0,pos2.z-pos1.z do
		local pos = apos(pos1,x,y,z)
		local m1 = minetest.get_meta(pos):to_table()
		local inv = next(m1.inventory)
		local fields = next(m1.fields)
		if inv then
			for l,v1 in pairs(m1.inventory) do
				local stacks = {}
				for i,v2 in pairs(v1) do
					if v2:get_count() > 0 then
						stacks[i] = minetest.serialize(v2:to_table())
					end
				end
				m1.inventory[l] = stacks
			end
		else
			m1.inventory = nil
		end
		if fields == nil then
			m1.fields = nil
		else
			for i,f in pairs(m1.fields) do
				if type(f) == "string" then
					m1.fields[i] = f:gsub("\n","´½`")
				end
			end
		end
		
		m1.node = minetest.get_node(pos)

		if m1.node.name == "air" or m1.node.param1 == 0 then
			m1.node.param1 = nil
		end
		if m1.node.name == "air" or m1.node.param2 == 0 then
			m1.node.param2 = nil
		end

		local t = minetest.get_node_timer(pos)
		if t:is_started() then
			m1.timer = t:get_timeout()
		end

		m[x..","..y..","..z] = m1
	end
	end
	end
	local s = vector.new((pos2.x-pos1.x)+1,(pos2.y-pos1.y)+1,(pos2.z-pos1.z)+1)
	minetest.log("size: "..minetest.pos_to_string(s))
	return minetest.serialize({nodes=m,size=s})
end

nodeextractor.set=function(pos,filepath)
	if not filepath then
		print("nodeextractor set: filepath is missing")
		return false
	end

	local file = io.open(filepath, "r") or {}
	local f = file:read()
	file:close()
	pos = vector.round(pos)
	local dat = minetest.deserialize(f)

	minetest.emerge_area(vector.add(pos,dat.size),vector.subtract(pos,dat.size))

	for i,v in pairs(dat.nodes) do
		local p = i.split(i,",")
		local pos2 = vector.add(pos,vector.new(tonumber(p[1]),tonumber(p[2]),tonumber(p[3])))
		minetest.set_node(pos2,v.node)

		local meta = minetest.get_meta(pos2)
		local m = minetest.deserialize(v)

		if v.inventory then
			for l,v1 in pairs(v.inventory) do
				local stacks = {}
				for i,v2 in pairs(v1) do
					stacks[i] = ItemStack(minetest.deserialize(v2))
				end
				meta:get_inventory():set_list(l,stacks)
			end
		end
		if v.fields then
			for i,v in pairs(v.fields) do
				if type(v) == "string" then
					meta:set_string(i,v:gsub("´½`","\n"))
				elseif type(v) == "int" then
					meta:set_int(i,v)
				elseif type(v) == "float" then
					meta:set_float(i,v)
				end
			end
		end
		if v.timer then
			minetest.get_node_timer(pos2):start(v.timer)
		end
	end
	return true
end

minetest.register_tool("nodeextractor:creater", {
	description = "Creater\nUse to mark\nPlace to change\nDrop for gui",
	inventory_image = "default_stick.png^[colorize:#f00",
	groups={not_in_craftguide=1},
	range=20,
	on_use=function(itemstack, user, pointed_thing)
		if minetest.check_player_privs(user:get_player_name(), {server=true}) then
			nodeextractor.a(itemstack, user, pointed_thing,1)
		else
			minetest.chat_send_player(user:get_player_name(),"the server privilege is required")
		end
	end,
	on_place=function(itemstack, user, pointed_thing)
		if minetest.check_player_privs(user:get_player_name(), {server=true}) then
			nodeextractor.a(itemstack, user, pointed_thing,2)
		else
			minetest.chat_send_player(user:get_player_name(),"the server privilege is required")
		end
	end,
	on_secondary_use=function(itemstack, user, pointed_thing)
		if minetest.check_player_privs(user:get_player_name(), {server=true}) then
			nodeextractor.a(itemstack, user, pointed_thing,2)
		else
			minetest.chat_send_player(user:get_player_name(),"the server privilege is required")
		end
	end,
	on_drop=function(itemstack, user, pos)
		local u = nodeextractor.user[user:get_player_name()]
		if u and u.pos1 and u.pos2 and minetest.check_player_privs(user:get_player_name(), {server=true}) then
			nodeextractor.b(user)
		else
			minetest.chat_send_player(user:get_player_name(),"the server privilege is required")
		end
	end,
})

minetest.register_tool("nodeextractor:placer", {
	description = "Placer",
	inventory_image = "default_stick.png^[colorize:#0f0",
	range=20,
	groups={not_in_craftguide=1},
	on_use=function(itemstack, user, pointed_thing)
		if minetest.check_player_privs(user:get_player_name(), {server=true}) then
			nodeextractor.place(user,nil,nil,pointed_thing)
		else
			minetest.chat_send_player(user:get_player_name(),"the server privilege is required")
		end
	end,
})

nodeextractor.a=function(itemstack, user, pointed_thing,typ)
	local username = user:get_player_name()
	if not nodeextractor.user[username ] then
		nodeextractor.user[username ] = {}
	end
	local u = nodeextractor.user[username]
	local pos
	local jump = user:get_player_control().jump
	if not jump then
		if typ == 2 then
			pos = pointed_thing.under
			u.p = u.p == 1 and 2 or 1
			return itemstack
		elseif typ == 1 and pointed_thing.under then
			u.p = u.p or 1
			pos = pointed_thing.under
			u["pos"..u.p] = pos
		else
			u.p = u.p or 1
			local up = user:get_pos()
			up.y = up.y +0.5
			pos = vector.round(up)
			u["pos"..u.p] = pos
		end

		local o = minetest.add_entity(pos, "nodeextractor:pos")
		o:get_luaentity().user = username 
		o:get_luaentity().num = u.p

		if u.p == 1 then
			u.ob1 = math.random(1,9999)
		else
			u.ob2 = math.random(1,9999)
		end

		if u.pos1 and u.pos2 then
			local x = math.abs(u.pos1.x-u.pos2.x) + 1
			local y = math.abs(u.pos1.y-u.pos2.y) + 1
			local z = math.abs(u.pos1.z-u.pos2.z) + 1
			local m = minetest.add_entity({x=u.pos1.x+(u.pos2.x-u.pos1.x)/2,y=u.pos1.y+(u.pos2.y-u.pos1.y)/2,z=u.pos1.z+(u.pos2.z-u.pos1.z)/2}, "nodeextractor:mark")
			m:set_properties({visual_size = {x=x, y=y, z=z}})
			m:get_luaentity().user = username 
			m:get_luaentity().num1 = u.ob1
			m:get_luaentity().num2 = u.ob2
			minetest.chat_send_player(username ,"Size: "..x.." "..y.." "..z)
		end
	end
end

nodeextractor.b=function(user,text,replace,saved)
	text = text or nodeextractor.user[user:get_player_name()].name or ""
	local gui="" ..
	"size[4.5,2]" ..
	"background[0,0;4.5,2;default_stone.png]"..
	"field[0.2,0.2;4.7,1;text;;" .. text .."]" ..
	"button_exit[0,1;1.5,1;exit;Quit]" ..
	"button[1.5,1;1.5,1;save;Save]" ..
	(replace and "button[3,1;1.5,1;replace;Replace]" or "") ..
	"label[0,0.6;"..(saved or "").."]"
	minetest.after(0.1, function(user,gui)
		return minetest.show_formspec(user:get_player_name(), "nodeextractor",gui)
	end, user, gui)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="nodeextractor" then
		local n = player:get_player_name()
		if pressed.exit then
			nodeextractor.user[n] = nil
		end

		local u = nodeextractor.user[n]

		if not u or not pressed.text or pressed.text == "" or pressed.quit and not (pressed.replace or pressed.save) then
			return
		end

		if string.find(pressed.text," ") then
			nodeextractor.b(player,string.gsub(pressed.text," ",""),true)
			return
		end
		nodeextractor.user[n].name = pressed.text


		minetest.mkdir(minetest.get_worldpath().."/nodeextractor")
		local fp = minetest.get_worldpath() .. "/nodeextractor/"..pressed.text..".exexn"

		if pressed.save then
			local o=io.open(fp, "r")
			if o then
				o:close()
				nodeextractor.b(player,pressed.text,true)
				return
			end
		end

		local t = nodeextractor.create(u.pos1,u.pos2,pressed.text)
		local f = io.open(fp, "w")
		f:write(t)
		f:close()
		minetest.log("nodeextractor created:: "..fp)
		nodeextractor.b(player,pressed.text,nil,"worlds/.../nodeextractor/"..pressed.text..".exexn")
	elseif form=="nodeextractor_place" then
		local n = player:get_player_name()
		local u = nodeextractor.user[n]
		if not u or not pressed.text then
			return
		end

		nodeextractor.user[n].sch = pressed.addsch ~= nil and pressed.addsch or nodeextractor.user[n].sch or "true"
		local adds = nodeextractor.user[n].sch == "true" and "/nodeextractor" or ""

		if pressed.world then
			nodeextractor.user[n].world = pressed.world
			u.path = minetest.get_worldpath()..adds.."/"..pressed.text..".exexn"
			u.mod = nil
			u.pname = pressed.text
			nodeextractor.place(player,pressed.text)
		elseif pressed.mod and pressed.mod ~= "" then
			local m = minetest.get_modpath(pressed.mod)
			u.world = nil
			u.pname = pressed.text
			if m then
				u.path = m .. adds.."/" .. pressed.text .. ".exexn"
			end
			local m2 = m and "" or (pressed.mod.." not found")
			nodeextractor.user[n].mod = pressed.mod
			nodeextractor.place(player,pressed.text,m2)

		elseif pressed.place and u.path and u.pos then
			local o = io.open(u.path, "r")
			if o then
				o:close()
				nodeextractor.set(u.pos,u.path)
			end
			return
		end

		if u.world and u.path ~= nil then
			local o=io.open(u.path, "r")
			if o then
				o:close()
			else
				nodeextractor.place(player,nil,"file not found")
			end
		else
			nodeextractor.place(player,nil,"(can't check files outside world folder, just try to place)")
		end
	end
end)

nodeextractor.place=function(user,text,msg,pos)
	local n = user:get_player_name()
	nodeextractor.user[n] = nodeextractor.user[n] or {path="",pname=""}

	if pos then
		nodeextractor.user[n].pos = pos.above or user:get_pos()
	end

	local u = nodeextractor.user[n]
	text = text or n.placetext or ""
	local gui="" ..
	"size[4.5,2]" ..
	"background[0,0;4.5,2;default_stone.png]"..
	"field[0.2,0.2;4.7,1;text;;" .. (u.pname or text or "") .."]" ..
	"button_exit[0,1;1.5,1;place;Place]" ..
	"checkbox[2,1;world;;"..(u.world or "false").."]" ..
	"checkbox[1.7,1;addsch;;"..(u.sch or "true").."]" ..
	"field[2.9,1.3;2,1;mod;;" .. (u.mod or "") .."]" ..
	"tooltip[world;World path]" ..
	"tooltip[mod;Mod path]" ..
	"tooltip[addsch;Add ''/nodeextractor'']" ..
	"label[0,0.6;"..(msg or "").."]" ..
	(u.path and "tooltip[text;"..u.path.."]" or "tooltip[text;Path and filename (folder/fodler2/filename)]")
	minetest.after(0.1, function(user,gui)
		return minetest.show_formspec(user:get_player_name(), "nodeextractor_place",gui)
	end, user, gui)
end

minetest.register_entity("nodeextractor:pos",{
	hp_max = 1,
	physical = false,
	pointable = false,
	collisionbox = {-0.52,-0.52,-0.52, 0.52,0.52,0.52},
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"nodeextractor_pos1.png","nodeextractor_pos1.png","nodeextractor_pos1.png","nodeextractor_pos1.png","nodeextractor_pos1.png","nodeextractor_pos1.png"}, 
	is_visible = true,
	t2 = {"nodeextractor_pos2.png","nodeextractor_pos2.png","nodeextractor_pos2.png","nodeextractor_pos2.png","nodeextractor_pos2.png","nodeextractor_pos2.png"},
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 0.1 and self.user then
			self.timer = 0
			local u = nodeextractor.user[self.user]
			if not u then
				self.user = nil
				return
			elseif self.num == 2 and not self.rndn then
				self.object:set_properties({textures = self.t2})
			end
			self.rndn = self.rndn or u["ob"..self.num]
			if u["ob"..self.num] ~= self.rndn then
				self.user = nil
			end
		elseif not self.user then
			self.object:remove()
			return self
		end
	end,
	timer=0.09
})

minetest.register_entity("nodeextractor:mark",{
	hp_max = 1,
	physical = false,
	pointable = false,
	collisionbox = {-0.52,-0.52,-0.52, 0.52,0.52,0.52},
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"nodeextractor_mark.png","nodeextractor_mark.png","nodeextractor_mark.png","nodeextractor_mark.png","nodeextractor_mark.png","nodeextractor_mark.png","nodeextractor_mark.png"}, 
	is_visible = true,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 0.1 and self.user then
			self.timer = 0
			local u = nodeextractor.user[self.user]
			if not u or self.num1 ~= u.ob1 or self.num2 ~= u.ob2 then
				self.user = nil
			end
		elseif not self.user then
			self.object:remove()
			return self
		end
	end,
	timer=0.09
})