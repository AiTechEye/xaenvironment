examobs.exploring=function(self)
	if self.exploring then
		if examobs.find_objects(self) then return end
		local r = math.random(1,10)
		if r <= 5 and self.exploring.walking then		-- keep walk
			examobs.walk(self)
		elseif r <= 2 then					-- rnd walk
			self.object:set_yaw(math.random(0,6.28))
			self.exploring.walking = true
			examobs.walk(self)
		elseif r == 3 then					-- rnd look
			self.exploring.walking = nil
			examobs.stand(self)
			self.object:set_yaw(math.random(0,6.28))
		else						-- stand
			self.exploring.walking = nil
			examobs.stand(self)
		end
	end
end

examobs.fighting=function(self)
	if self.fight and examobs.gethp(self.fight) > 0 and examobs.visiable(self,self.fight) then
		if examobs.distance(self.object,self.fight) <= self.reach then
			examobs.stand(self)
			examobs.lookat(self,self.fight)
			if math.random(1,2) == 1 then
				examobs.punch(self.fight,self.object,self.dmg)
				examobs.anim(self,"attack")
				if examobs.gethp(self.fight) < 1 then
					self.fight = nil
				end
			end
			return true
		else
			examobs.lookat(self,self.fight)
			examobs.walk(self,2,true)
			return true
		end
	elseif self.fight then
		self.fight = nil
	end
end

examobs.stand=function(self)
	self.move.x=0
	self.move.z=0
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
	local s=(self.move.speed+1)*run
	self.move.x=x*run
	self.move.z=z*run

	self.object:set_velocity({
		x = x*s,
		y = y,
		z = z*s
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
	pos2 = type(pos2) == "userdata" and pos2:get_pos() or pos2
	pos1 = type(pos1) == "userdata" and pos1:get_pos() or pos1.object and pos1.object:get_pos() or pos1
		
	local v = {x = pos1.x - pos2.x, y = pos1.y - pos2.y-1, z = pos1.z - pos2.z}
	v.y=v.y-1
	local amount = (v.x ^ 2 + v.y ^ 2 + v.z ^ 2) ^ 0.5
	local d=vector.distance(pos1,pos2)
	v.x = (v.x  / amount)*-1
	v.y = (v.y  / amount)*-1
	v.z = (v.z  / amount)*-1
	for i=1,d,1 do
		local node=minetest.registered_nodes[minetest.get_node({x=pos1.x+(v.x*i),y=pos1.y+(v.y*i),z=pos1.z+(v.z*i)}).name]
		if node and node.walkable then
			return false
		end
	end
	return true
end

examobs.gethp=function(ob,even_dead)
	if not ob then
		return 0
	end
	local en = ob:get_luaentity()
	return en and (even_dead and en.dead and 0 or en.hp or en.health) or ob:get_hp() or 0
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

examobs.punch=function(target,puncher,damage)
	target:punch(puncher,1,{full_punch_interval=1,damage_groups={fleshy=damage}})
end