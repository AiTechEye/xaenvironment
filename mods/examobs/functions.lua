apos=function(pos,x,y,z)
	return {x=pos.x+(x or 0),y=pos.y+(y or 0),z=pos.z+(z or 0)}
end

walkable=function(pos)
	local n = minetest.get_node(pos).name
	return (n ~= "air" and false) or examobs.def(n).walkable
end

examobs.jump=function(self)
	local v = self.object:get_velocity()
	if v.y == 0 then
		self.object:set_velocity({x=v.x, y=5.5, z=v.z})
	end
end

examobs.environment=function(self)
	local pos = self:pos()
	pos = apos(pos,nil,self.bottom)
--jumping
	if walkable(pos) then
		if walkable(apos(pos,nil,1)) and walkable(apos(pos,nil,2)) then
			examobs.punch(self.object,self.object,1)
		else
			examobs.jump(self)
		end
	elseif walkable(examobs.pointat(self)) then
		examobs.jump(self)
	end
--liquid
	local def = examobs.defpos(apos(pos,0,0))

	if def.liquid_viscosity > 0 then
		self.in_liquid = true
		local s=1
		local v=self.object:get_velocity()
		if self.dying or self.dead then s=-1 end

		if self.swiming < 1 and s == 1 then
			s = -1
			examobs.stand(self)
			examobs.punch(self.object,self.object,1)
			examobs.anim(self,"run")
			if math.random(1,2) == 1 then
				self.object:set_yaw(math.random(0,6.28))
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
		local v=self.object:get_velocity()
		self.object:set_acceleration({x=0, y=0, z=0})
		self.object:set_velocity({x=v.x, y=0, z=v.z})
		if walkable(apos(examobs.pointat(self),0,-1)) then
			examobs.jump(self)
			self.object:set_acceleration({x=0, y=-10, z=0})
		end
	elseif self.in_liquid then
		self.in_liquid = nil
		self.object:set_acceleration({x =0, y = -10, z =0})
	end

	if type(self.breathing) == "number" then
		if (def.drowning or 0) > 0 then
			self.breathing = self.breathing -0.5
			if self.breathing <= 0 then
				self.breathing = 0
				examobs.punch(self.object,self.object,1)
			end
		else
			self.breathing = 20
		end	
	end
	if (def.damage_per_second or 0) > 0 and def.name ~= self.resist_node then
		examobs.punch(self.object,self.object,def.damage_per_second)
	end


end

examobs.defpos=function(pos)
	return minetest.registered_items[minetest.get_node(pos).name] or {}
end

examobs.def=function(name)
	return minetest.registered_items[name] or {}
end

examobs.exploring=function(self)
	if examobs.find_objects(self) then return end
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

examobs.fighting=function(self)
	if self.fight and examobs.gethp(self.fight) > 0 and examobs.visiable(self,self.fight) and examobs.viewfield(self,self.fight) then
		if examobs.distance(self.object,self.fight) <= self.reach then
			examobs.stand(self)
			examobs.lookat(self,self.fight)
			if math.random(1,2) == 1 then
				if self.fight:get_pos().y > self:pos().y then
					examobs.jump(self)
				end
				examobs.punch(self.object,self.fight,self.dmg)
				examobs.anim(self,"attack")
				if examobs.gethp(self.fight) < 1 then
					self.fight = nil
				end
			end
		else
			examobs.lookat(self,self.fight)
			examobs.walk(self,2,true)
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
	self.object:set_velocity({
		x = 0,
		y = self.object:get_velocity().y,
		z = 0})
	examobs.anim(self,"stand")
	return self
end

examobs.walk=function(self,run)
	local pos=self.object:get_pos()
	local yaw=examobs.num(self.object:get_yaw())

	run=run or 1
	local x =math.sin(yaw) * -1
	local z =math.cos(yaw) * 1
	local y=self.object:get_velocity().y

	self.object:set_velocity({
		x = x*run,
		y = y,
		z = z*run
	})

	if run == 1 then
		examobs.anim(self,"walk")
	else
		examobs.anim(self,"run")
	end
	return self
end

examobs.lookat=function(self,pos2)
	if type(pos2) ~= "table" then
		pos2=pos2:get_pos()
	end
	local pos1=self.object:get_pos()
	local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
	local yaw = examobs.num(math.atan(vec.z/vec.x)-math.pi/2)
	if pos1.x >= pos2.x then yaw = yaw+math.pi end
	self.object:set_yaw(yaw)
end

examobs.num=function(a)
	return (a == math.huge or a == -math.huge or a ~= a) == false and a or 0
end

examobs.anim=function(self,type)
	if self.visual ~= "mesh" or type == self.anim then return end
	local a=self.animation[type]
	if not a then return end
	self.object:set_animation({x=a.x, y=a.y,},a.speed)
	self.anim=type
	return self
end

examobs.team=function(target)
	if not target then return "" end
	local en = target:get_luaentity()
	return (en and (en.team or en.type or "")) or target:is_player() and "default"
end

examobs.find_objects=function(self)
	if self.fight then return end
	local obs = {}
	for _, ob in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), self.range)) do
		local team = examobs.team(ob)
		if team ~= "" and team ~= self.team and examobs.viewfield(self,ob) then
			table.insert(obs,ob)
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
	local name = (en and (en.examobs or en.type or en.name)) or (ob:is_player() and ob:get_player_name()) or ""

	if get then
		return self.storage.known[name] == type
	else
		self.storage.known[name] = type
	end
end

examobs.visiable=function(pos1,pos2)
	pos1 = type(pos1) == "userdata" and pos1:get_pos() or pos1.object and pos1.object:get_pos() or pos1
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
	end
	local en = ob:get_luaentity()
	return en and ((even_dead and en.dead and 0) or en.hp or en.health) or ob:get_hp() or 0
end

examobs.viewfield=function(self,ob)
	if not (self and self.object and ob) then return false end
	local pos1=self.object:get_pos()
	local pos2 = type(ob) == "userdata" and ob:get_pos() or ob
	return examobs.distance(pos1,pos2)>examobs.distance(examobs.pointat(self,0.1),pos2)
end

examobs.pointat=function(self,d)
	local pos=self.object:get_pos()
	local yaw=examobs.num(self.object:get_yaw())
	d=d or 1
	local x =math.sin(yaw) * -d
	local z =math.cos(yaw) * d
	return {x=pos.x+x,y=pos.y,z=pos.z+z}
end

examobs.distance=function(pos1,pos2)
	pos1 = type(pos1) == "userdata" and pos1:get_pos() or pos1
	pos2 = type(pos2) == "userdata" and pos2:get_pos() or pos2
	return vector.distance(pos1,pos2)
end

examobs.punch=function(puncher,target,damage)
	target:punch(puncher,1,{full_punch_interval=1,damage_groups={fleshy=damage}})
end