minetest.register_on_dieplayer(function(player)
	local e = minetest.add_item(apos(player:get_pos(),0,1),"examobs:flesh")
	if e then
		e:set_velocity({
			x=math.random(-1.5,1.5),
			y=math.random(0.5,1),
			z=math.random(-1.5,1.5)
		})
	end
end)

minetest.register_globalstep(function(dtime)
	if examobs.global_timer <= os.clock() then
		examobs.global_lifetime = (math.floor(examobs.global_time*100) / 100) + 1
		examobs.global_lifetime = examobs.global_lifetime <= 1.1 and examobs.global_lifetime or examobs.global_lifetime * 10
		examobs.global_timer = os.clock() + 1
		examobs.global_time = 0
	end
end)

examobs.on_step=function(self, dtime)
	local time = os.clock()
	self.timer1 = self.timer1 + dtime
	self.timer2 = self.timer2 + dtime
	self.lifetimer = self.lifetimer - (dtime*examobs.global_lifetime)
	examobs.main(self, dtime)
	examobs.global_time = examobs.global_time + os.clock() - time
end

exaachievements.register({
	type="customize",
	name="Hunter",
	count=100,
	description="Kill 100 animals",
	skills=5,
	hide_until=10,
})

exaachievements.register({
	type="customize",
	name="Monsters_nightmare",
	count=100,
	description="Kill 100 monsters",
	skills=10,
	hide_until=10,
})

walkable=function(pos)
	local n = minetest.get_node(pos).name
	return (n ~= "air" and false) or examobs.def(n).walkable
end

examobs.jump=function(self,y)
	local v = self.object:get_velocity() or {x=0, y=0, z=0}
	if v.y == 0 then
		y = y or 5.5
		self.object:set_velocity({x=v.x, y=5.5, z=v.z})
	end
end

examobs.environment=function(self)
	self.environment_timer = 0
	if (self.flee or self.fight or self.folow or self.target) and not (self.dead or self.dying) then
		self.lifetimer = self.lifetime
		if not (self.updatetime_reset or self.folow) then
			self.updatetime_reset = self.updatetime
			self.updatetime = self.updatetime*0.1
		end
	elseif self.updatetime_reset then
		self.updatetime = self.updatetime_reset
		self.updatetime_reset = nil
	elseif self.lifetimer < 0 then
		if self:on_lifedeadline() then
			self.lifetimer = self.lifetime
		else
			self.object:remove()
		end
		return self
	end

	local pos = self:pos()
	local posf = examobs.pointat(self)
	pos = apos(pos,0,self.bottom)
	posf = apos(posf,0,self.bottom)
	local def = examobs.defpos(pos)
	local deff = examobs.defpos(posf)
	local v = self.object:get_velocity()

--Infected

	if self.storage.infected then
		if self.fight then
			if examobs.team(self.fight) == self.team then 
				self.fight = nil
			else
				local en = self.fight:get_luaentity()
				if en and en.examob then
					en.fight = nil
					self.fight = nil
					en.team = "infection_poison"
					en.aggressivity = 2
					en.type = "monster"
					en.storage.infected = 101
				end
			end
		end

		for _, ob in pairs(minetest.get_objects_inside_radius(self:pos(), 5)) do
			local en = ob:get_luaentity()
			if en and en.examob and en.team ~= self.team and en.examob ~= self.examob and examobs.visiable(self,ob) and examobs.gethp(ob) > 0 then
				en.fight = nil
				en.team = "infection_poison"
				en.aggressivity = 2
				en.type = "monster"
				en.storage.infected = 101
			end
		end
		self.storage.infected = self.storage.infected -1
		if self.storage.infected <= 0 then
			self:hurt(1)
		else
			examobs.showtext(self,"Infected ("..self.storage.infected..")","ff00ff")
		end
	end

--jumping

	if not (self.dying or self.dead or self.is_floating) then
		local target = self.fight or self.flee or self.folow
		if def.walkable and v.x+v.z == 0 then
			if walkable(apos(pos,0,1)) and walkable(apos(pos,0,2)) and (minetest.get_node_light(pos,0,1) or 0) == 0 then
				self:hurt(1)

			else
				examobs.jump(self)
			end
		elseif v.x+v.z ~= 0 and deff.walkable or (target and examobs.gethp(target) > 0 and not walkable(apos(posf,0,-1)) and target:get_pos().y >= pos.y) then
			examobs.jump(self)
		elseif (deff.damage_per_second or 0) > 0 then
			examobs.stand(self)
		end
	end

--drowning & breath

	if self.breathing > 0 and not self.dead and self.environment_timer2 > 1 then
		if (def.drowning or 0) > 0 then
			self.breath = (self.breath or 20) -1
			if self.breath <= 0 then
				self.breath = 0
				self:hurt(1)
			else
				examobs.showtext(self,self.breath .."/20","0000ff")
			end
		else
			self.breath = 20
		end	
	end

--damage

	if self.environment_timer2 > 1 and (def.damage_per_second or 0) > 0 and not self.resist_nodes[def.name] then
		self:hurt(def.damage_per_second)
		if not (self.dying or self.dead) then
			self.object:set_yaw(math.random(0,6.28))
			examobs.jump(self)
			examobs.walk(self,true)
		end

		if minetest.get_item_group(def.name, "igniter") > 0 then
			minetest.add_particlespawner({
				amount = 5,
				time =0.2,
				minpos = {x=pos.x-0.5, y=pos.y, z=pos.z-0.5},
				maxpos = {x=pos.x+0.5, y=pos.y, z=pos.z+0.5},
				minvel = {x=0, y=0, z=0},
				maxvel = {x=0, y=math.random(3,6), z=0},
				minacc = {x=0, y=2, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 1,
				maxexptime = 3,
				minsize = 3,
				maxsize = 8,
				texture = "default_item_smoke.png",
				collisiondetection = true,
			})
		end
	end

-- timer = 0

	if self.environment_timer2 > 1 then
		self.environment_timer2 = 0
	end

--floating

	if self.floating_in_group and minetest.get_item_group(def.name,self.floating_in_group) > 0 or self.floating[def.name] then
		if not self.is_floating then
			self.is_floating = true
			local v = self.object:get_velocity() or {x=0, y=0, z=0}
			self.object:set_acceleration({x =0, y=0, z =0})
			self.object:set_velocity({x=v.x, y=0, z =v.y})
		end
		return
	elseif self.is_floating then
		self.is_floating = nil
		local v = self.object:get_velocity()
		self.object:set_acceleration({x =0, y=-10, z =0})
	elseif not self.is_floating then
		if v.y < 0 and not self.falling then
			self.falling = pos.y
		end
		if self.falling and v.y >= 0 and walkable(apos(pos,0,-1)) then
			local d = math.floor(self.falling+0.5) - math.floor(pos.y+0.5)
			if d >= 10 then
				self:hurt(d)
			end
			self.falling = nil
		end
	end

--liquid and viscosity

	if def.liquid_viscosity > 0 then
		if not self.in_liquid and v.y <= 0 and minetest.get_item_group(def.name,"water") > 0 then
			minetest.sound_play("default_object_watersplash", {object=self.object, gain = 4,max_hear_distance = 10})
		end

		self.in_liquid = true
		local s=1
		local v = self.object:get_velocity() or {x=0,y=0,z=0}
		if self.dying or self.dead then s=-1 end

		if self.swiming < 1 and s == 1 then
			s = -1
			self:hurt(1)
			if not (self.dying or self.dead) then
				examobs.stand(self)
				examobs.anim(self,"run")
				if math.random(1,2) == 1 then
					self.object:set_yaw(math.random(0,6.28))
				end
			end
			if v.y < 0 then
				self.object:set_acceleration({x =0, y=20, z =0})
				self.object:set_velocity({x =0, y=v.y/2, z =0})
			elseif v.y > 0 then
				self.object:set_velocity({x =0, y=0, z =0})
				self.object:set_acceleration({x =0, y=0, z =0})
			end
			return true
		end

		self.object:set_acceleration({x =0, y =0.1*s, z =0})
		
		if v.y<-0.1 then
			self.object:set_velocity({x = v.x, y =v.y/2, z =v.z})
			return self
		end
		self.object:set_velocity({x = v.x, y =1*s - (def.liquid_viscosity*0.1), z = v.z})
		return self
	elseif self.in_liquid and (examobs.defpos(apos(pos,0,-1)).liquid_viscosity or 0) > 0 then
		local v=self.object:get_velocity() or {x=0, y=0, z=0}
		self.object:set_acceleration({x=0, y=0, z=0})
		self.object:set_velocity({x=v.x, y=0, z=v.z})
		if walkable(apos(posf,0,-1)) then
			examobs.jump(self)
			self.object:set_acceleration({x=0, y=-10, z=0})
		end
	elseif self.in_liquid then
		self.in_liquid = nil
		self.object:set_acceleration({x =0, y = -10, z =0})
	end
end

examobs.defpos=function(pos)
	return minetest.registered_items[minetest.get_node(pos).name] or {}
end

examobs.def=function(name)
	return minetest.registered_items[name] or {}
end

examobs.following=function(self)
	if self.folow and examobs.visiable(self.object,self.folow) then
		local d = examobs.distance(self.object,self.folow)
		if d > self.range/2 then
			examobs.lookat(self,self.folow)
			examobs.walk(self,true)
			return true
		elseif d > self.reach then
			examobs.lookat(self,self.folow)
			examobs.walk(self)
			return true
		end
	elseif self.folow then
		self.folow = nil
	end
end

examobs.exploring=function(self)
	if math.random(1,2) == 1 and examobs.find_objects(self) then return end

	local r = math.random(1,10)
	if r <= 5 and self.walking then		-- keep walk
		examobs.walk(self)
	elseif r <= 2 then					-- rnd walk
		self.object:set_yaw(math.random(0,6.28))
		self.walking = true
		examobs.walk(self)
	elseif r == 3 then					-- rnd look
		self.walking = nil
		examobs.stand(self)
		self.object:set_yaw(math.random(0,6.28))
	else						-- stand
		self.walking = nil
		examobs.stand(self)
	end
end

examobs.fleeing=function(self)
	if self.flee and examobs.gethp(self.flee) > 0 and (examobs.viewfield(self,self.flee) or examobs.distance(self.object,self.flee) <= self.range/2) then
		local p = examobs.pointat(self)
		if walkable(p) and walkable(apos(p,0,1)) then
			if  self.aggressivity > -2 and examobs.distance(self.object,self.flee) <= self.reach then
				examobs.lookat(self,self.flee)
				local flee = self.flee
				self.fight = self.flee
				minetest.after(2, function(self,flee)
					if self and self.object and flee then
						self.fight = nil
						self.flee = flee
					end
				end, self,flee)
			else
				self.object:set_yaw(math.random(0,6.28))
				examobs.jump(self)
				examobs.walk(self,true)
				
			end
			return self
		end

		examobs.lookat(self,self.flee)
		local yaw=examobs.num(self.object:get_yaw())
		self.object:set_yaw(yaw+math.pi)
		examobs.walk(self,true)
		return self
	elseif self.flee then
		self.flee = nil
	end
end

examobs.fighting=function(self)
	if self.fight and examobs.gethp(self.fight) > 0 and examobs.visiable(self.object,self.fight) then
		if examobs.distance(self.object,self.fight) <= self.reach then
			examobs.stand(self)
			examobs.lookat(self,self.fight)
			if math.random(1,self.punch_chance) == 1 then
				if self.fight:get_pos().y > self:pos().y then
					examobs.jump(self)
				end
				local en = self.fight:get_luaentity()
				if en and en.name == "__builtin:item" then
					self:eat_item(en.itemstring)
				end
				self:before_punching()
				examobs.punch(self.object,self.fight,self.dmg)
				self:on_punching()
				examobs.anim(self,"attack")
				if examobs.gethp(self.fight) < 1 then
					self.fight = nil
				end
			end
		else
			examobs.lookat(self,self.fight)
			examobs.walk(self,true)

			if not self.is_floating and math.abs(self.fight:get_pos().y)-5 > math.abs(self:pos().y) then
				self.fight = nil
			end
		end

		for _, ob in pairs(minetest.get_objects_inside_radius(self:pos(), self.range)) do
			local en = ob:get_luaentity()
			if en and en.examob and not en.fight and en.team == self.team and en.examob ~= self.examob and examobs.visiable(self,ob) then
				en.fight = self.fight
				examobs.lookat(en,en.fight)
			end
		end
		return true
	else
		self.fight = nil
		examobs.stand(self)
	end
end

examobs.stand=function(self)
	local v = self.object:get_velocity() or {x=0,y=0,z=0}
	self.object:set_velocity({
		x = 0,
		y = v.y,
		z = 0})
	if not self.on_stand(self) then
		examobs.anim(self,"stand")
	end
	return self
end

examobs.fly=function(self,run)
	if self.fight or self.folow or self.flee or self.target then
		local pos1 = self:pos()
		local pos2 = (self.fight and self.fight:get_pos()) or (self.folow and self.folow:get_pos()) or (self.flee and self.flee:get_pos()) or (self.target and self.target:get_pos())
		run = run and self.walk_run*2 or self.walk_speed
		if not self.flee then
			run = run *-1
		end
		if not pos2 then return end
		local d = examobs.distance(pos1,pos2)
		local x = ((pos1.x-pos2.x)/d)*run
		local y = ((pos1.y-pos2.y)/d)*run
		local z = ((pos1.z-pos2.z)/d)*run
		self.object:set_velocity({x=examobs.num(x),y=examobs.num(y),z=examobs.num(z)})
		self.on_fly(self,x,y,z)
		return true
	end
end

examobs.walk=function(self,run)
	if self.is_floating and examobs.fly(self,run) then return end
	local yaw=examobs.num(self.object:get_yaw())
	local running = run
	self.movingspeed = run and self.run_speed or self.walk_speed
	local v = self.object:get_velocity() or {x=0,y=0,z=0}
	local x = (math.sin(yaw) * -1) * self.movingspeed
	local z = (math.cos(yaw) * 1) * self.movingspeed
	self.object:set_velocity({
		x = x,
		y = v.y,
		z = z
	})

	if self.on_walk(self,x,v.yy,z) then return end

	if running then
		examobs.anim(self,"run")
	else
		examobs.anim(self,"walk")
	end

	return self
end

examobs.lookat=function(self,pos2)
	if type(pos2) == "userdata" then
		pos2=pos2:get_pos()
	end
	if not (pos2 and pos2.z) then
		return
	end
	local pos1=self:pos()
	local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
	local yaw = examobs.num(math.atan(vec.z/vec.x)-math.pi/2)
	if pos1.x >= pos2.x then yaw = yaw+math.pi end
	self.object:set_yaw(yaw)
end

examobs.num=function(a)
	return (a == math.huge or a == -math.huge or a ~= a) == false and a or 0
end

examobs.anim=function(self,type)
	if self.visual ~= "mesh" or type == self.anim or not self.animation then return end
	local a=self.animation[type]
	if not a then return end
	self.object:set_animation({x=a.x, y=a.y,},a.speed,false,a.loop)
	self.anim=type
	return self
end

examobs.team=function(target)
	if not target then return "" end
	local en = target:get_luaentity()
	return (en and (en.team or en.type or "")) or target:is_player() and "default"
end

examobs.find_objects=function(self)
	if self.aggressivity == 0 or self.fight or self.flee then return end
	local flee = self.aggressivity == -2
	local fight = self.aggressivity == 2
	local obs = {}
	local hungry = self.hp < self.hp_max
	local p = self:pos()
	if not p then return self end
	for _, ob in pairs(minetest.get_objects_inside_radius(p, self.range)) do
		local en = ob:get_luaentity()
		if not (en and (not en.type or (en.examob == self.examob))) and examobs.visiable(self.object,ob) then
			local infield = examobs.viewfield(self,ob)
			local team = examobs.team(ob)
			local known = examobs.known(self,ob)
			local player = ob:is_player()
			local hiding
			if player then
				self.lifetimer = self.lifetime
				local invtool = examobs.hiding[ob:get_player_name()]
				local inv = ob:get_inventory()
				if invtool and inv:get_stack("main",invtool):get_name() == "examobs:hiding_poison" then
					local item = inv:get_stack("main",invtool)
					local w = item:get_wear()
					if w >= 60000 then
						inv:set_stack("main",invtool,nil)
						examobs.hiding[ob:get_player_name()] = nil
					else
						item:add_wear(600)
						inv:set_stack("main",invtool,item)
						hiding = true
					end
				elseif invtool then
					examobs.hiding[ob:get_player_name()] = nil
				end
			end
			if hiding then
			elseif infield and ((self.aggressivity == 1 and self.hp < self.hp_max and self.team ~= team) or known == "fight") then
				self.fight = ob
				return
			elseif known == "flee" or (flee and team ~= self.team and (self.flee_from_threats_only == 0 or player)) or (self.aggressivity == -1 and en and en.type == "monster") then
				self.flee = ob
				return
			elseif known == "folow" then
				self.folow = ob
				return
			elseif infield and ((self.aggressivity == 1 and en and en.type == "monster") or self.aggressivity == 2) and team ~= self.team then
				table.insert(obs,ob)
			end
		elseif hungry and en and en.name == "__builtin:item" and examobs.visiable(self.object,ob) and examobs.viewfield(self,ob) then
			if minetest.get_item_group(string.split(en.itemstring," ")[1],"eatable") > 0 and self.is_food(self,string.split(en.itemstring," ")[1]) then
				self.fight = ob
				return
			end
		end
	end
	if #obs > 0 then
		self.fight = obs[#obs]
		examobs.known(self,self.fight,"fight")
		return true
	end
end

examobs.known=function(self,ob,type,get)
	if not ob then return end
	self.storage.known = self.storage.known or {}
	local en = ob:get_luaentity()
	local name = (en and (en.examob or en.type or en.name)) or (ob:is_player() and ob:get_player_name()) or ""
	if not type then
		return self.storage.known[name]
	elseif get then
		return self.storage.known[name] == type
	else
		self.storage.known[name] = type
	end
end

examobs.visiable=function(self,pos2)
	if not self.object then
		return self
	end
	local pos1 = self:pos()
	pos2 = type(pos2) == "userdata" and pos2:get_pos() or pos2	

	local v = {x = pos1.x - pos2.x, y = pos1.y - pos2.y-1, z = pos1.z - pos2.z}
	v.y=v.y-1
	local amount = (v.x ^ 2 + v.y ^ 2 + v.z ^ 2) ^ 0.5
	local d=vector.distance(pos1,pos2)
	v.x = (v.x  / amount)*-1
	v.y = (v.y  / amount)*-1
	v.z = (v.z  / amount)*-1
	for i=1,d,1 do
		local node = minetest.registered_nodes[minetest.get_node({x=pos1.x+(v.x*i),y=pos1.y+(v.y*i),z=pos1.z+(v.z*i)}).name]
		if node and node.walkable then
			return false
		end
	end
	return true
end

examobs.gethp=function(ob,even_dead)
	if not (ob and ob:get_pos()) then
		return 0
	elseif ob:is_player() then
		return ob:get_hp()
	end
	local en = ob:get_luaentity()
	return en and ((even_dead and en.examob and en.dead and en.hp) or (en.examob and en.dead and 0) or en.hp or en.health) or ob:get_hp() or 0
end

examobs.viewfield=function(self,ob2)
	local ob1 = self and self.object or self

	local p1 = ob1 and ob1:get_pos()
	local p2 = ob2 and ob2:get_pos()
	if not (ob1 and ob2 and p2 and p1) then return false end

	local a = vector.normalize(vector.subtract(p2, p1))
	local b
	if ob1:get_luaentity() then
		local yaw = math.floor(ob1:get_yaw()*100)/100
		b = {x=math.sin(yaw)*-1,y=0,z=math.cos(yaw)*1}
	elseif ob1:is_player() then
		b=ob1:get_look_dir()
	else
		return false
	end
	local deg = math.acos((a.x*b.x)+(a.y*b.y)+(a.z*b.z)) * (180 / math.pi)
	return not (deg < 0 or deg > 50) --45
end

examobs.faceside=function(self,ob)
	if not (self and self.object and ob) then return false end
	local pos1=self:pos()
	local pos2 = type(ob) == "userdata" and ob:get_pos() or ob
	return examobs.distance(pos1,pos2)>examobs.distance(examobs.pointat(self,0.1),pos2)
end

examobs.pointat=function(self,d)
	local pos=self:pos()
	local yaw=examobs.num(self.object:get_yaw())
	d=d or 1
	local x =math.sin(yaw) * -d
	local z =math.cos(yaw) * d
	return {x=pos.x+x,y=pos.y,z=pos.z+z}
end

examobs.distance=function(pos1,pos2)
	pos1 = type(pos1) == "userdata" and pos1:get_pos() or pos1
	pos2 = type(pos2) == "userdata" and pos2:get_pos() or pos2
	return pos2 and pos1.z and pos2.z and vector.distance(pos1,pos2) or 0
end

examobs.punch=function(puncher,target,damage)
	target:punch(puncher,1,{full_punch_interval=1,damage_groups={fleshy=damage}})
end

examobs.showtext=function(self,text,color)
	self.delstatus=math.random(0,1000) 
	local del=self.delstatus
	color=color or "ff0000"
	self.object:set_properties({nametag=text,nametag_color="#" ..  color})
	minetest.after(1.5, function(self,del)
		if self and self.object and self.delstatus==del then
			self.delstatus = nil
			self.object:set_properties({nametag="",nametag_color=""})
		end
	end, self,del)
	return self
end

examobs.dropall=function(self)
	local pos = self:pos()
	if not pos then
		return
	end
	for i,v in pairs(self.inv) do
		if minetest.registered_items[i] then
			local e = minetest.add_item(pos,i .. " " .. v)
			if e then
				e:set_velocity({
					x=math.random(-1.5,1.5),
					y=math.random(0.5,1),
					z=math.random(-1.5,1.5)

				})
			end
		end
		self.inv[i] = nil
	end
end

examobs.dying=function(self,set)
	if self.lay_on_death ~= 1 then return end
	if set==1 then
		examobs.anim(self,"lay")
		self.object:set_acceleration({x=0,y=-10,z =0})
		self.object:set_velocity({x=0,y=-3,z =0})
		if self.hp<=self.hp_max*-1 then
			examobs.dying(self,2)
			return self
		end
		self.dying={step=self.hp_max+self.hp,try=self.hp+self.hp_max/2}
		self.hp=self.hp_max/2
		self.object:set_hp(self.hp)
	elseif set==2 then
		minetest.after(0.1, function(self)
			if self.object:get_luaentity() then
				examobs.anim(self,"lay")
			end
		end, self)
		self.object:set_properties({nametag=""})
		self.type=""
		self.hp=self.hp_max
		self.object:set_hp(self.hp)
		self.dying=nil
		self.dead=20
		self.death(self)
		examobs.dropall(self)
	elseif set==3 and (self.dying or self.dead) then
		self.dying={step=0,try=self.hp_max*2}
		self.dead=nil
	end

	if self.dying then
		local v = self.object:get_velocity() or {x=0,y=0,z=0}
		self.object:set_velocity({x=0,y=v.y,z=0})
		if self.hp<=self.hp_max*-1 then
			examobs.dying(self,2)
			return self
		end
		self.dying.try=self.dying.try+math.random(-1,1)
		self.dying.step=self.dying.step-1
		examobs.showtext(self,(self.dying.try+self.hp) .."/".. self.hp_max,"ff5500")
		self.on_dying(self)

		if self.dying.step<1 and self.dying.try+self.hp>=self.hp_max then
			local h=math.random(1,5)
			self.dying=nil
			self.hp=h
			self.object:set_hp(h)
			examobs.stand(self)
			examobs.showtext(self,"")
			return self
		elseif self.dying.step<1 and self.dying.try+self.hp<self.hp_max then
			examobs.dying(self,2)
			return self
		end
		return self
	elseif self.dead then
		self.dead=self.dead-1
		self:achievements()
		if self.dead<0 then
			examobs.dropall(self)
			self.object:remove()
		end
		return self
	end
end

examobs.generate_npc_house=function(pos)
	local s = math.random(2,7)
	local h = math.random(2,4)
	local sa = 0
	local n=0
	local wood

	s = math.floor(s/2) ~= s/2 and s or s + 1

-- if param2 ~=0 return
--on_place param2 = 1

	for x=-s,s do
	for z=-s,s do
	for y=-1,h do
		sa = sa +1
		local p = apos(pos,x,y,z)
		if walkable(p) then
			n=n+1
		end
	end
	end
	end

	if n > sa/2 or n < sa/10 then
		return
	end

	for i,v in pairs(minetest.find_nodes_in_area(apos(pos,-20,-1,-20),apos(pos,20,5,20),"group:tree")) do
		local it = minetest.get_craft_result({method = "normal",width = 1, items = {minetest.get_node(v).name}})
		if it.item:get_count() > 0 then
			wood = it.item:get_name()
			break
		end
	end

	local door_item = minetest.get_craft_result({method = "normal",width = 3, items = {wood,wood,"",wood,wood,"",wood,wood,""}})
	local door_wood = door_item.item:get_count() > 0 and door_item.item:get_name() or nil
	local wall = "default:cobble"
	local window = "default:glass"
	local wint = math.random(0,3)
	local door_rnd = math.random(1,2)
	local door = {-s,s}
	door = door[math.random(1,2)]

	local furn_floor = {}
	local furn_wall = {}
	local items = {}
	local items2 = {}
	local mirror = {[0]=2,[1]=3,[2]=0,[3]=1}
	local wallmounted=function(x,z,s)
		if z==-s+1 then
			return 5
		elseif z==s-1 then
			return 4
		elseif x==-s+1 then
			return 3
		elseif x==s-1 then
			return 2
		else
			return 0
		end
	end

	for i,v in pairs(minetest.registered_items) do
		if v.groups then
			if v.groups.treasure == 1 then
				table.insert(items,i)
			elseif v.groups.treasure == 2 then
				table.insert(items2,i)
			end
		end
	end

	for i,v in pairs(minetest.registered_nodes) do
		if v.groups and v.groups.used_by_npc then
			if v.groups.used_by_npc == 1 then
				table.insert(furn_floor,i)
			elseif v.groups.used_by_npc == 2 then
				table.insert(furn_wall,i)
			end
		end
	end

	for x=-s,s do
	for z=-s,s do
	for y=-1,h do
		local nset
		local p
		local plpos = apos(pos,x,y,z)
		if y >-1 and y< h and ((x==-s+1 or x==s-1 or z==-s+1 or z==s-1)) and x ~= 0 and z ~= 0 and math.abs(x)~=s and math.abs(z)~=s and (y==0 and math.random(1,s) == 1 or math.random(1,s*h*2) == 1) then
			if y==0 then
				nset = furn_floor[math.random(1,#furn_floor)]
			else
					nset = furn_wall[math.random(1,#furn_wall)]
			end

			if default.def(nset).paramtype2 == "wallmounted" then
				p = wallmounted(x,z,s)
			elseif x == s-1 then
				p = 1
			elseif x == -s+1 then
				p = 3
			elseif z == s-1 then
				p = 0
			elseif x == -s+1 then
				p = 2
			end
			p = minetest.get_item_group(nset,"bed") > 0 and mirror[p] or p
			p = minetest.get_item_group(nset,"tankstorage") > 0 and 0 or p
		elseif (y==0 or y== 1) and ((wint == 2 and x == 0 and (z==door)) or (wint == 1 and z == 0 and x == door)
		or ((wint == 0 or wint == 3) and ((door_rnd == 1 and z == 0 and x == door) or (door_rnd == 2 and x == 0 and z == door)))) then
--door
			if y == 0 then
				if wint == 1 or wint ~= 2 and door_rnd == 1 then
					p = {1,3}
					p = p[math.random(1,2)]
				elseif wint == 2 or wint ~= 1 and door_rnd == 2 then
					p = {0,2}
					p = p[math.random(1,2)]
				end
				nset = door_wood
			end

		elseif y > 0 and y < h/1.5 and (((wint == 0 or wint == 1) and (z == -s or z == s) and (x > -s/2 and x < s/2)) or ((wint == 0 or wint == 2) and (x == -s or x == s) and (z > -s/2 and z < s/2))) then
-- window
			nset = window 
		elseif y ==- 1 or y == h or x == -s or x == s or z == -s or z == s then
-- wall & floor & ceiling
			nset = wood or wall
		end

		minetest.set_node(plpos,{name=nset or "air",param2 = p or 0})

		if nset and nset ~= wood and nset ~= wall and minetest.get_meta(plpos):get_inventory():get_size("main") > 0 then
--items
			local m = minetest.get_meta(plpos):get_inventory()
			local size = m:get_size("main")


			if nset == "examobs:woodbox" then
				for i=1,size do
					if math.random(1,math.floor(size/2)) == 1 then
						m:set_stack("main",i,items2[math.random(1,size)].." ".. math.random(1,10))
					end
				end
			else
				for i=1,size do
					if math.random(1,math.floor(size/2)) == 1 then
						m:set_stack("main",i,items[math.random(1,size)].." ".. math.random(1,10))
					end
				end
			end
		end
	end
	end
	end
	minetest.add_entity(apos(pos,0,1),"examobs:npc"):get_luaentity().storage.npc_generated = true
end

minetest.register_ore({
	ore_type = "scatter",
	ore = "examobs:npc_house_spawner",
	wherein = "group:spreading_dirt_type",
	clust_scarcity = 30 * 30 * 30,
	clust_num_ores = 1,
	clust_size	 = 1,
	y_min= 1,
	y_max = 200,
})

minetest.register_node("examobs:npc_house_spawner", {
	drawtype = "airlike",
	groups = {dig_immediate=3,not_in_creative_inventory=1,not_in_craftguide=1},
})

minetest.register_lbm({
	name="examobs:npchouse_spawner",
	nodenames={"examobs:npc_house_spawner"},
	run_at_every_load = true,
	action=function(pos,node)
		minetest.remove_node(pos)
		examobs.generate_npc_house(pos)
	end
})