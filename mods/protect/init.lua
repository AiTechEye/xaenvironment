protect = {
	areas={},
	user={},
	storage = minetest.get_mod_storage(),
	global_timer = 0,
	max_size = tonumber(minetest.settings:get("xaenvironment_protection_max_size")) or 100,
	max_areas = tonumber(minetest.settings:get("xaenvironment_protection_max_amount")) or 5,
}

minetest.register_on_mods_loaded(function()
	protect.areas = minetest.deserialize(protect.storage:get_string("areas")) or {}
	for i,v in pairs(protect.areas) do
		if v.game_rule and default.date("d",v.date) > 90 then
			protect.remove_game_rule_area(v.id)
		end
	end
end)

minetest.register_on_punchnode(function(pos,node,puncher,pointed_thing)
	local name = puncher:get_player_name()
	local p = protect.user[name]
	if p and p.current then
		if p.pos1 and p.current == 1 then
			p.pos1 = pos
			p.pos1id = math.random(0,9999)
		elseif p.pos2 and p.current == 2 then
			p.pos2 = pos
			p.pos2id = math.random(0,9999)
		else
			return
		end

		local m = minetest.add_entity(p["pos"..p.current], "protect:pos"):get_luaentity()
		m.user = name
		m.pos = p.current
		m["pos"..p.current.."id"] = p["pos"..p.current.."id"]

		if p.pos1 and p.pos2 then
			protect.user[name].markid = math.random(0,9999)
			local self = minetest.add_entity(pos, "protect:mark"):get_luaentity()
			self.user = name
			self.markid = protect.user[name].markid
		end
	end
end)


minetest.register_privilege("protect_unlimited", {
	description = "Protection without limits",
	give_to_singleplayer = true,
})

minetest.register_chatcommand("protect", {
	params = "/protect <number 1 or 2> (select position 1 or 2  or punch to select)\n/protect name (protect) /protect     (to abort)",
	description = "Select protection position 1 or 2",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local n = tonumber(param)
			if param == "1" or param == "2" then
				local pos = vector.round(player:get_pos())
				local p = protect.user[name]
				p["pos"..param.."id"] = math.random(0,9999)
				p["pos"..param] = pos
				p.current = n
				local m = minetest.add_entity(p["pos"..param], "protect:pos"):get_luaentity()
				m.user = name
				m.pos = n
				m["pos"..param.."id"] = p["pos"..param.."id"]

				if p.pos1 and p.pos2 then
					protect.user[name].markid = math.random(0,9999)
					local self = minetest.add_entity(pos, "protect:mark"):get_luaentity()
					self.user = name
					self.markid = protect.user[name].markid
				end
				return true,"Position "..param.." selected"
			elseif n then
				return false, "Numberitic names are unalowed"
			elseif param ~= "" then
				protect.add_area(name,param)
			else
				protect.clear(name)
				return false, "Aborted protection"
			end
		end
	end
})

minetest.register_chatcommand("remove_area", {
	params = "/remove <number>",
	description = "Remove an area",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local n = tonumber(param)
		if player and n then
			local pb = minetest.get_player_privs(name).protection_bypass == true
			for i,v in pairs(protect.areas) do
				if v.id == n then
					if v.game_rule then
						return false,"You can't remove a game rule area"
					elseif v.owner == name or pb then
						local t = v.title
						local id = v.id
						table.remove(protect.areas,i)
						protect.storage:set_string("areas",minetest.serialize(protect.areas))
						protect.global_timer = 2
						return true,t.." ("..id ..") removed"
					else
						return false,"That area doesn't belongs to you"
					end
				end
			end
			return false,"Doesn't exists"
		elseif not n then
			return false,"Not an id /remove_area <number>"
		end
	end
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	protect.user[name] = {
		hud = player:hud_add({
			hud_elem_type="text",
			scale = {x=200,y=60},
			text="",
			number=0xFFFFFF,
			offset={x=8,y=-8},
			position={x=0,y=0.95},
			alignment={x=1,y=1},
		})
	}
	protect.global_timer = 2
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	protect.user[name] = nil
end)

minetest.register_on_protection_violation(function(pos,name)
	local player = minetest.get_player_by_name(name)
	if player then
		player_style.thirst(player,-1)
		player_style.hunger(player,-1)
	end
end)

local old_is_protected = minetest.is_protected
minetest.is_protected=function(pos,name)
	local pb = (minetest.player_exists(name) and minetest.get_player_privs(name).protection_bypass == true) or false
	local inside
	local interacts
	local owner
	for i,v in pairs(protect.areas) do
		if (pos.x >= v.pos1.x and pos.x <= v.pos2.x)
		and (pos.y >= v.pos1.y and pos.y <= v.pos2.y)
		and (pos.z >= v.pos1.z and pos.z <= v.pos2.z) then
			if v.owner == name then
				return false
			else
				owner = (v.game_rule or pb == false) and v.owner or nil
			end
		end
	end
	if owner then
		return true,owner
	else
		return old_is_protected(pos,name)
	end
end

protect.inside_area=function(pos)
	local list = ""
	local count = 0
	for i,v in pairs(protect.areas) do
		if (pos.x >= v.pos1.x and pos.x <= v.pos2.x)
		and (pos.y >= v.pos1.y and pos.y <= v.pos2.y)
		and (pos.z >= v.pos1.z and pos.z <= v.pos2.z) then
			list = list..v.title.." (" ..v.owner..":"..v.id..")\n"
			count = count +1
		end
	end
	return list,count
end

protect.add_area=function(name,title,pos1,pos2)
	local p = protect.user[name]
	if not (p and p.pos1 and p.pos2) then
		minetest.chat_send_player(name,"You have to select 2 positions first")
		return false
	end
	local test,name2 = protect.test(p.pos1,p.pos2,name)
	local count = 0
	local pu = minetest.get_player_privs(name).protect_unlimited == true

	local x = math.abs(p.pos1.x-p.pos2.x)
	local y = math.abs(p.pos1.z-p.pos2.z)
	local z = math.abs(p.pos1.z-p.pos2.z)
	if not pu and (x > protect.max_size or y > protect.max_size or z > protect.max_size) then
		minetest.chat_send_player(name,"The area are too big (max "..protect.max_size.."x"..protect.max_size.."x"..protect.max_size..") your are "..x.."x"..y.."x"..z)
		return false
	end

	if test then
		local id = 0
		local a = {}
		for i,v in pairs(protect.areas) do
			a[v.id] = true
			if v.owner == name and not pu then
				count = count +1
				if count >= protect.max_areas then
					minetest.chat_send_player(name,"You reached your max ("..protect.max_areas..") amount of areas")
					return false
				end
			end
		end
		for i=0,#protect.areas+1 do
			if not a[i] then
				id = i
				break
			end
		end

		p.pos1,p.pos2 = protect.sort(p.pos1,p.pos2)
		table.insert(protect.areas,{id=id,owner=name,pos1=p.pos1,pos2=p.pos2,title=title,date=default.date("get")})
		protect.clear(name)
		protect.storage:set_string("areas",minetest.serialize(protect.areas))
		minetest.chat_send_player(name,"Protected "..title.." ("..id..")")
		protect.global_timer = 2
		return true
	else
		minetest.chat_send_player(name,"The area interacts with "..name2.."'s area")
	end
	return false
end

protect.add_game_rule_area=function(pos1,pos2,title,name,game_rule)
	local id = 0
	local a = {}
	for i,v in pairs(protect.areas) do
		a[v.id] = true
	end
	for i=0,#protect.areas+1 do
		if not a[i] then
			id = i
			break
		end
	end
	pos1,pos2 = protect.sort(pos1,pos2)
	table.insert(protect.areas,{id=id,game_rule=game_rule == nil,owner=name or "game",pos1=pos1,pos2=pos2,title=title,date=default.date("get")})
	protect.storage:set_string("areas",minetest.serialize(protect.areas))
	return id
end

protect.remove_game_rule_area=function(id)
	for i,v in pairs(protect.areas) do
		if v.id == id then
			table.remove(protect.areas,i)
			protect.storage:set_string("areas",minetest.serialize(protect.areas))
			protect.global_timer = 2
			return true
		end
	end
end

protect.clear=function(name)
	protect.user[name] = {hud=protect.user[name].hud}
end

protect.test=function(p1,p2,name)
	protect.sort(p1,p2)
	local pb = (minetest.player_exists(name) and minetest.get_player_privs(name).protection_bypass == true) or false
	for i,v in pairs(protect.areas) do
		if v.game_rule or (v.owner ~= name and pb == false) then
			if (v.pos1.x <= p2.x and v.pos2.x >= p1.x)
			and (v.pos1.y <= p2.y and v.pos2.y >= p1.y)
			and (v.pos1.z <= p2.z and v.pos2.z >= p1.z) then
				return false,v.owner
			end
		end
	end
	return true
end

protect.sort=function(a,b)
	if a.x > b.x then
		b.x,a.x = a.x,b.x
	end
	if a.y > b.y then
		b.y,a.y = a.y,b.y
	end
	if a.z > b.z then
		b.z,a.z = a.z,b.z
	end
	return a, b
end

minetest.register_globalstep(function(dtime)
	protect.global_timer = protect.global_timer + dtime
	if protect.global_timer > 1 then
		protect.global_timer = 0
		for _, player in pairs(minetest.get_connected_players()) do
			local name=player:get_player_name()
			local pos = vector.round(player:get_pos())
			local t,count = protect.inside_area(pos)
			local p = protect.user[name]
			player:hud_change(p.hud, "text", t)
			player:hud_change(p.hud, "position", {x=0,y=0.95-((count*0.1)*0.2)})
		end
	end
end)

minetest.register_entity("protect:pos",{
	physical = false,
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png","vexcazer_schematic_pos1.png"}, 
	is_visible = true,
	t2 = {"vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png","vexcazer_schematic_pos2.png"},
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if puncher:is_player() and puncher:get_player_name() == self.user and protect.user[self.user or ""] then
			minetest.chat_send_player(self.user,"Aborted protection")
			protect.clear(self.user)
		end
	end,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 0.1 then
			self.timer = 0
			local u = protect.user[self.user or ""]
			if u and (self.pos1id and self.pos1id == u.pos1id or self.pos2id and self.pos2id == u.pos2id) then
				if not self.textset and self.pos == 2 then
					self.textset = true
					self.object:set_properties({textures = self.t2})
					local pos = (self.pos == 1 and u.pos1) or (self.pos == 2 and u.pos2)
					self.object:set_pos(pos)
				end
			else
				self.object:remove()
			end
		end
	end,
	timer=0.09
})

minetest.register_entity("protect:mark",{
	physical = false,
	pointable = false,
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png","vexcazer_schematic_mark.png"}, 
	is_visible = true,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 0.1 then
			self.timer = 0
			local u = protect.user[self.user or ""]
			if u and u.pos1 and u.pos2 and self.markid == u.markid then
				if not self.posset then
					self.posset = true
					local x = math.abs(u.pos1.x-u.pos2.x) + 1
					local y = math.abs(u.pos1.y-u.pos2.y) + 1
					local z = math.abs(u.pos1.z-u.pos2.z) + 1
					self.object:set_pos({x=u.pos1.x+(u.pos2.x-u.pos1.x)/2,y=u.pos1.y+(u.pos2.y-u.pos1.y)/2,z=u.pos1.z+(u.pos2.z-u.pos1.z)/2})
					self.object:set_properties({visual_size = {x=x, y=y, z=z}})
				end
			else
				self.object:remove()
			end
		end
	end,
	timer=0.09
})

minetest.register_node("protect:area_breaker", {
	tiles = {"default_goldblock.png"},
	groups = {exatec_wire_connected=1,unbreakable=1,not_in_creative_inventory=1},
	exatec={
		on_wire = function(pos)
			minetest.registered_nodes["protect:area_breaker"].del(pos)
			minetest.remove_node(pos)
		end,
	},
	del=function(pos)
		for i,v in pairs(protect.areas) do
			if v.game_rule then
				if (pos.x >= v.pos1.x and pos.x <= v.pos2.x)
				and (pos.y >= v.pos1.y and pos.y <= v.pos2.y)
				and (pos.z >= v.pos1.z and pos.z <= v.pos2.z) then
					protect.remove_game_rule_area(v.id)
					return true
				end
			end
		end
	end,
	after_destruct = function(pos)
		minetest.registered_nodes["protect:area_breaker"].del(pos)
	end
})