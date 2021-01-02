vexcazer_schematic = {user={}}

minetest.register_on_leaveplayer(function(player)
	vexcazer_schematic.user[player:get_player_name()] = nil
end)

vexcazer_schematic.a=function(itemstack, user, pointed_thing,input,typ)
	if not vexcazer_schematic.user[input.user_name] then
		vexcazer_schematic.user[input.user_name] = {}
	end
	local u = vexcazer_schematic.user[input.user_name]
	local pos
	local jump = user:get_player_control().jump
	if not jump then
		if typ == "change" then
			pos = pointed_thing.under
			u.p = u.p == 1 and 2 or 1
			return itemstack
		elseif typ == "node" then
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

		local o = minetest.add_entity(pos, "vexcazer_schematic:pos")
		o:get_luaentity().user = input.user_name
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
			local m = minetest.add_entity({x=u.pos1.x+(u.pos2.x-u.pos1.x)/2,y=u.pos1.y+(u.pos2.y-u.pos1.y)/2,z=u.pos1.z+(u.pos2.z-u.pos1.z)/2}, "vexcazer_schematic:mark")
			m:set_properties({visual_size = {x=x, y=y, z=z}})
			m:get_luaentity().user = input.user_name
			m:get_luaentity().num1 = u.ob1
			m:get_luaentity().num2 = u.ob2
			minetest.chat_send_player(input.user_name,"Size: "..x.." "..y.." "..z)
		end

	elseif jump and u.pos1 and u.pos2 then
		vexcazer_schematic.b(user)
	end
end

vexcazer_schematic.b=function(user,text,replace,saved)
	text = text or vexcazer_schematic.user[user:get_player_name()].name or ""
	local gui="" ..
	"size[4.5,2]" ..
	"background[0,0;4.5,2;vexcazer_background.png]"..
	"field[0.2,0.2;4.7,1;text;;" .. text .."]" ..
	"button_exit[0,1;1.5,1;exit;Quit]" ..
	"button[1.5,1;1.5,1;save;Save]" ..
	(replace and "button[3,1;1.5,1;replace;Replace]" or "") ..
	"label[0,0.6;"..(saved or "").."]"
	minetest.after(0.1, function(user,gui)
		return minetest.show_formspec(user:get_player_name(), "vexcazer_schematic",gui)
	end, user, gui)
end

vexcazer_schematic.place=function(user,text,msg)
	local n = user:get_player_name()
	vexcazer_schematic.user[n] = vexcazer_schematic.user[n] or {path="",pname=""}
	local u = vexcazer_schematic.user[n]
	text = text or n.placetext or ""
	local gui="" ..
	"size[4.5,2]" ..
	"background[0,0;4.5,2;vexcazer_background.png]"..
	"field[0.2,0.2;4.7,1;text;;" .. (u.pname or text or "") .."]" ..
	"button_exit[0,1;1.5,1;go;Update]" ..
	"checkbox[2,1;world;;"..(u.world or "false").."]" ..
	"checkbox[1.7,1;addsch;;"..(u.sch or "true").."]" ..
	"field[2.9,1.3;2,1;mod;;" .. (u.mod or "") .."]" ..
	"tooltip[world;World path]" ..
	"tooltip[mod;Mod path]" ..
	"tooltip[addsch;Add ''/schematics'']" ..
	"label[0,0.6;"..(msg or "").."]" ..
	(u.path and "tooltip[text;"..u.path.."]" or "tooltip[text;Path and filename (folder/fodler2/filename)]")
	minetest.after(0.1, function(user,gui)
		return minetest.show_formspec(user:get_player_name(), "vexcazer_schematic_place",gui)
	end, user, gui)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="vexcazer_schematic" then
		local n = player:get_player_name()
		if pressed.exit then
			vexcazer_schematic.user[n] = nil
		end

		local u = vexcazer_schematic.user[n]

		if not u or not pressed.text or pressed.text == "" or pressed.quit and not (pressed.replace or pressed.save) then
			return
		end

		if string.find(pressed.text," ") then
			vexcazer_schematic.b(player,string.gsub(pressed.text," ",""),true)
			return
		end
		vexcazer_schematic.user[n].name = pressed.text
		local f = minetest.get_worldpath().."/schematics/"..pressed.text..".mts"
		if pressed.save then
			local o=io.open(f, "r")
			if o then
				o:close()
				vexcazer_schematic.b(player,pressed.text,true)
				return
			end
		end
		minetest.mkdir(minetest.get_worldpath().."/schematics")
		minetest.create_schematic(u.pos1,u.pos2,nil,f)
		vexcazer_schematic.b(player,pressed.text,nil,".../schematics/"..pressed.text..".mts")
	elseif form=="vexcazer_schematic_place" then
		local n = player:get_player_name()
		local u = vexcazer_schematic.user[n]
		if not u or not pressed.text then
			return
		end

		vexcazer_schematic.user[n].sch = pressed.addsch ~= nil and pressed.addsch or vexcazer_schematic.user[n].sch or "true"
		local adds = vexcazer_schematic.user[n].sch == "true" and "/schematics" or ""

		if pressed.world then
			vexcazer_schematic.user[n].world = pressed.world
			u.path = minetest.get_worldpath()..adds.."/"..pressed.text..".mts"
			u.mod = nil
			u.pname = pressed.text
			vexcazer_schematic.place(player,pressed.text)
		elseif pressed.mod and pressed.mod ~= "" then
			local m = minetest.get_modpath(pressed.mod)
			u.world = nil
			u.pname = pressed.text
			if m then
				u.path = m .. adds.."/" .. pressed.text .. ".mts"
			end
			local m2 = m and "" or (pressed.mod.." not found")
			vexcazer_schematic.user[n].mod = pressed.mod
			vexcazer_schematic.place(player,pressed.text,m2)
		end

		if u.world and u.path ~= nil then
			local o=io.open(u.path, "r")
			if o then
				o:close()
			else
				vexcazer_schematic.place(player,nil,"schematic not found")
			end
		else
			vexcazer_schematic.place(player,nil,"(can't check files outside world folder, just try to place)")
		end
	end
end)

vexcazer.registry_mode({
	wear_on_use=1,
	wear_on_place=1,
	name="Create schematic",
	info="USE to set pos\nPLACE to change pos1/pos2\nUSE somewhere else to switch pos in air\nUSE and JUMP to create schematic",
	disallow_damage_on_use=true,
	hide_mode_default=true,
	hide_mode_mod=true,
	on_place=function(itemstack, user, pointed_thing,input)
		if not input.world then
			minetest.chat_send_player(input.user_name,"<vexcazer> schematic only able with admin world for safety")
		else
			vexcazer_schematic.a(itemstack, user, pointed_thing,input,"change")
		end
	end,
	on_use=function(itemstack, user, pointed_thing,input)
		if not input.world then
			minetest.chat_send_player(input.user_name,"<vexcazer> schematic only able with admin world for safety")
		elseif pointed_thing.type == "node" then
			vexcazer_schematic.a(itemstack, user, pointed_thing,input,"node")
		else
			vexcazer_schematic.a(itemstack, user, pointed_thing,input,"air")
		end
	end
})

vexcazer.registry_mode({
	wear_on_use=1,
	wear_on_place=1,
	name="Place schematic",
	info="USE to on a node to place above\nPLACE to place under\nUSE somewhere else to place on your position\nUSE and JUMP to open the form",
	disallow_damage_on_use=true,
	hide_mode_default=true,
	hide_mode_mod=true,
	on_place=function(itemstack, user, pointed_thing,input)
		local n = user:get_player_name()
		local u = vexcazer_schematic.user[n]
		if not input.world then
			minetest.chat_send_player(input.user_name,"<vexcazer> schematic only able with admin world for safety")
		elseif not u or not u.path or u.path == "" then
			vexcazer_schematic.place(user)
		else
			minetest.place_schematic(pointed_thing.above, u.path,"random",nil,false,"place_center_x,place_center_z")
		end
	end,
	on_use=function(itemstack, user, pointed_thing,input)
		local n = user:get_player_name()
		local u = vexcazer_schematic.user[n]
		if not input.world then
			minetest.chat_send_player(input.user_name,"<vexcazer> schematic only able with admin world for safety")
		elseif not u or not u.path or u.path == "" or user:get_player_control().jump then
			vexcazer_schematic.place(user)
		else
			if pointed_thing.type == "node" then
				minetest.place_schematic(pointed_thing.under, u.path,"random",nil,false,"place_center_x,place_center_z")
			else
				minetest.place_schematic(vector.round(user:get_pos()), u.path,"random",nil,false,"place_center_x,place_center_z")
			end
		end
	end
})

minetest.register_entity("vexcazer_schematic:pos",{
	hp_max = 1,
	physical = false,
	pointable = false,
	collisionbox = {-0.52,-0.52,-0.52, 0.52,0.52,0.52},
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png"}, 
	is_visible = true,
	t2 = {"vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png"},
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 0.1 and self.user then
			self.timer = 0
			local u = vexcazer_schematic.user[self.user]
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

minetest.register_entity("vexcazer_schematic:mark",{
	hp_max = 1,
	physical = false,
	pointable = false,
	collisionbox = {-0.52,-0.52,-0.52, 0.52,0.52,0.52},
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png"}, 
	is_visible = true,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 0.1 and self.user then
			self.timer = 0
			local u = vexcazer_schematic.user[self.user]
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