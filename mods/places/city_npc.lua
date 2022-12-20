criminals = {}
jailspots = {}
jailspots_num = 0
prisoner = {}

minetest.register_node("places:police_spawner",{
	groups = {on_load=1,attached_node=1,not_in_creative_inventory=1},
	drawtype = "airlike",
	drop = "",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.49, 0.5}}
	},
	on_load = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function(pos, elapsed)
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, 7)) do
			if ob:get_luaentity() and ob:get_properties().textures[1] == "player_style_police.png" then
				minetest.get_node_timer(pos):start(math.random(1,60))
				return true
			end
		end
		local ob = minetest.add_entity(pos,"places:city_roadwalker")
		places.make_police(ob)
		minetest.get_node_timer(pos):start(math.random(1,60))
		return true
	end
})

minetest.register_node("places:jailspot",{
	groups = {on_load=1,attached_node=1,not_in_creative_inventory=1},
	drawtype = "airlike",
	drop = "",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.49, 0.5}}
	},
	on_load = function(pos)
		jailspots[minetest.pos_to_string(pos)] = pos
		jailspots_num = jailspots_num + 1
		minetest.get_node_timer(pos):start(1)
	end,
	on_destruct=function(pos)
		jailspots[minetest.pos_to_string(pos)] = pos
		jailspots_num = jailspots_num - 1
	end,
	on_construct = function(pos)
		jailspots[minetest.pos_to_string(pos)] = pos
		jailspots_num = jailspots_num + 1
		minetest.get_meta(pos):set_string("formspec","size[2,1]button_exit[0,0;2,1;setup;Setup]")
	end,
	on_timer = function(pos, elapsed)
		local m = minetest.get_meta(pos)
		local spos = minetest.pos_to_string(pos)
		prisoner[spos] = prisoner[spos] or {}
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do
			local new = true
			for i,v in ipairs(prisoner[spos]) do
				if ob == v.ob or default.is_decoration(ob) then
					new = false
					break
				end
			end
			if new then
				local r = math.random(5, ob:get_luaentity() and 180 or 60)
				table.insert(prisoner[spos],{date=default.date("get"),ob=ob,pos=pos,timeout=r})
				if ob:is_player() then
					local c = math.random(1,100)
					local coins = Getcoin(ob)
					c = c <= coins and c or coins
					Coin(ob,-c)
					minetest.chat_send_player(ob:get_player_name(),"You are confined in " .. r .. " seconds, and cost " .. c .. " coins")
				end
			end
		end
		for i,v in ipairs(prisoner[spos]) do
			local ppos = v.ob and v.ob:get_pos()
			if default.date("s",v.date) > v.timeout then
				if not ppos then
				elseif v.ob:is_player() then
					local pos1 = minetest.string_to_pos(m:get_string("pos1l"))
					v.ob:set_pos(vector.add(pos,pos1))
				else
					local pos2 = minetest.string_to_pos(m:get_string("pos2l"))
					v.ob:set_pos(vector.add(pos,pos2))
				end
				table.remove(prisoner[spos],i)
			elseif ppos and vector.distance(ppos,pos) >= 2 then
				v.ob:set_pos(pos)
			end
		end
		return #prisoner[spos] > 0
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.save or pressed.setup then
			local m = minetest.get_meta(pos)
			local pos1
			local pos2
			local dir = sender:get_look_dir()

			if pressed.save then
				local name = sender:get_player_name()
				local p = protect.user[name]
				if p and p.pos1 then
					pos1 = p.pos1
					pressed.pos1 =  p.pos1.x.." "..p.pos1.y.." "..p.pos1.z
				else
					pos1 = minetest.string_to_pos("("..pressed.pos1:gsub(" ",",")..")")
				end
				if p and p.pos2 then
					pos2 = p.pos2
					pressed.pos2 =  p.pos2.x.." "..p.pos2.y.." "..p.pos2.z
				else
					pos2 = minetest.string_to_pos("("..pressed.pos2:gsub(" ",",")..")")
				end
				if p and (p.pos1 or p.pos2) then
					protect.clear(name)
				end
			end

			if pos1 then
				m:set_string("pos1l",minetest.pos_to_string(vector.subtract(pos1,pos)))
				m:set_string("pos1",pressed.pos1:gsub(","," "))
			end
			if pos2 then
				m:set_string("pos2l",minetest.pos_to_string(vector.subtract(pos2,pos)))
				m:set_string("pos2",pressed.pos2:gsub(","," "))
			end

			m:set_string("formspec","size[1.5,3]"
			.."button_exit[-0.2,-0.2;2,1;save;Save]"
			.."field[0,1;2,1;pos1;;"..m:get_string("pos1").."]"
			.."field[0,2;2,1;pos2;;"..m:get_string("pos2").."]"
			.."button_exit[-0.2,2.5;2,1;done;Done]"
			.."tooltip[save;Mark with /protect 1 / /protect 2 to mark the position, then press save]"
			.."tooltip[pos1;Position 1 (players), (eg 1,0,-5)]"
			.."tooltip[pos2;Position 2 (entities), (eg 1,0,-5)]"
			)      
		elseif pressed.done then
			minetest.get_meta(pos):set_string("formspec","")
		end
	end,
})

places.make_police=function(ob)
	ob:set_properties({textures={"player_style_police.png"}})
	local self = ob:get_luaentity()
	self.hp = 200

	self.before_punching=function(self)
		if self.fight:is_player() then
			self.fight:set_hp(self.fight:get_hp()+1)
		end
	end

	self.on_punching=function(self)
		if self.fight and next(jailspots) then
			local pos = self.object:get_pos()
			local jails = {}
			local distance
			for i,v in pairs(jailspots) do
				local d = vector.distance(pos,v)
				if minetest.get_node_timer(v):is_started() == false and (not distance or d <= distance) then
					table.insert(jails,v)
					distance = d
				end
			end

			if #jails > 0 then
				self.criminal = nil
				for i,v in ipairs(criminals) do
					if v == self.fight then
						table.remove(criminals,i)
						break
					end
				end

				local j = jails[math.random(1,#jails)]
				for _, ob in pairs(minetest.get_objects_inside_radius(j, 1.5)) do
					if default.is_decoration(ob,true) then
						ob:remove()
					end
				end
				self.fight:set_pos(j)
				self.fight = nil
				minetest.get_node_timer(j):start(0.5)
			elseif self.fight:get_luaentity() then
				self.fight:remove()
				self.fight = nil
			end
		end
	end

	self.on_abs_step=function(self,dtime)
		local pos1 = self.object:get_pos()
		local pos2 = self.fight and self.fight:get_pos()

		if pos2 and pos2.x and not self.criminal then
			self.criminal = self.fight
			local new = true
			for i,v in ipairs(criminals) do
				if v == self.fight then
					new = false
					break
				end
			end
			if new then
				table.insert(criminals,self.fight)
			end
		elseif not pos2 and #criminals > 0 then
			for i,ob in ipairs(criminals) do
				if not (ob and ob:get_pos()) then
					table.remove(criminals,i)
				elseif examobs.visiable(self.object,ob) then
					self.fight = ob
					self.criminal = ob
					break
				end
			end
		elseif self.criminal then
			if not self.criminal:get_pos() then
				self.criminal = nil
				return
			end
			self.ptimer = (self.ptimer or 0) + dtime*math.random(1,10)
			self.ptimeout = self.ptimeout or math.random(3,20)
			if self.ptimer > self.ptimeout then
				self.ptimer =0
				self.ptimeout = nil
				local name = examobs.get_name(self.criminal)
				local r = {"Police STOP " .. name,"You are under arrest","You are risking your life!","You are a criminal, stop now!","This is your chanse to survive, stay".. name,"Police","Im a officer, ".. name.."!"}
				self:say(r[math.random(1,#r)])
			end
		end
	end
end

examobs.register_roadwalker({
	name = "city_roadwalker",
	right_hand_traffic = 1.2,
	node={
	on_spawn = function(pos,ob)
		if ob:get_properties().textures[1] == "player_style_police.png" or #criminals > 0 and math.random(1,10) == 1 or math.random(1,20) == 1 then
			places.make_police(ob)
		else
			ob:get_luaentity().step = function(self)
				if self.fight then
					if math.random(1,5) == 1 then
						places.make_police(self.object)
					end
					self.step = function() return end
				end
			end
		end
	end
}})

examobs.register_roadwalker({
	name="city_roaddriver",
	amount_limit = 15,
	right_hand_traffic = 4,
	path_pass_range = 5,
	new_path=function(self,pos1,pos2)
		self.carpos = {time=0,pos=pos1}
		self.drive_to_pos = pos2
	end,
	step=function(self,dtime)
		if self.c2timer and self.c2timer < 0 then
			self.c2timer = self.c2timer + (dtime or 0.01)
			return self
		end

		local a = self.object:get_attach()
		if not a or not a:get_luaentity() or a:get_luaentity().name ~= "quads:car" then
			return
		end
		local pos1 = self.object:get_pos()

		self.carpos = self.carpos or {time=0,pos=pos1}
		self.carpos.time = self.carpos.time + (dtime or 0.01)
		if self.carpos.time > 1 then
			self.carpos.time = 0
			local d = vector.distance(self.carpos.pos,pos1)
			if d <= 0.5 then
				self.c2timer = -1
				self.object:set_yaw(math.random(0,6.28))
				return self
			end
			self.carpos.pos = pos1
		end

		local pos2 = examobs.pointat(self,10)
		local c = minetest.raycast(pos1,pos2)
		local n = c:next()
		while n do
			if n and n.type == "object" then
				local en = n.ref:get_luaentity()
				if n.ref:is_player() or n.ref ~= self.object and n.ref ~= a then
					local s = a:get_luaentity().speed
					a:get_luaentity().speed = math.abs(s) > 0.1 and s*0.5 or 0
					if n.ref:is_player() == false and not n.ref:get_luaentity().examob then
						self.object:set_yaw(math.random(0,6.28))
						self.c2timer = -1
					end
					return true
				end
			end
			n = c:next()
		end
	end,
	node = {
		on_timer = function(pos, elapsed)
			for _, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
				local en = ob:get_luaentity()
				if en and en.name == "quads:car" then
					return false
				end
			end
		end,
		on_spawn = function(pos,ob)
			if ob:get_properties().textures[1] == "player_style_police.png" then
				ob:remove()
				return
			end

			examobs.car_colors = {}
			for i,v in pairs(minetest.registered_nodes) do
				if v.tiles and type(def.tiles) == "table" and type(def.tiles[1]) == "string" and not (v.groups and (v.groups.not_in_creative_inventory or v.groups.rail or v.use_texture_alpha)) then
					table.insert(examobs.car_colors,{name=v.name,texture=v.tiles[1]})
				end
			end
			local ndef = examobs.car_colors[math.random(1,#examobs.car_colors)]
			local self = ob:get_luaentity()
			local car = minetest.add_entity(apos(pos,0,1),"quads:car"):get_luaentity()

			self.object:set_attach(car.object, "",{x=-5, y=-3, z=2})

			car.user = self.object
			car.user_name= self.examob
			car.bot = self
			car.citycar = true
			car.texture_node = ndef.name
			car.texture = ndef.texture
			car.color(car)
			car.citycar = true
		end
	}
})

minetest.register_node("places:city_npcspawner", {
	groups = {not_in_creative_inventory=1,on_load=1},
	drawtype="airlike",
	on_load=function(pos)
		minetest.set_node(pos,{name="places:city_roadwalker_path"})
	end,
})

minetest.register_node("places:city_npccarspawner", {
	groups = {not_in_creative_inventory=1,on_load=1},
	drawtype="airlike",
	on_load=function(pos)
		minetest.set_node(pos,{name="places:city_roaddriver_path"})
	end,
})