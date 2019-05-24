examobs.register_bird=function(def)
	def = def or {}
	local def2 = {}
	def2.name = def.name or "bird"
	def2.textures = def.textures or {"examobs_bird.png"}
	def2.mesh = def.mesh or "examobs_bird.b3d"
	def2.type = def.type or "animal"
	def2.team = def.team or "bird"
	def2.dmg = def.dmg or 1
	def2.hp = def.hp or 5
	def2.aggressivity = def.aggressivity or -2
	def2.inv = def.inv or {["examobs:chickenleg"]=1,["examobs:feather"]=2}
	def2.walk_speed = def.run_speed or 2
	def2.run_speed = def.run_speed or 4
	def2.animation = {
		stand = {x=20,y=25,speed=0},
		walk = {x=40,y=50,speed=20},
		run = {x=5,y=15,speed=40},
		lay = {x=55,y=60,speed=0},
		attack = {x=20,y=25},
		eat = {x=25,y=35},
		fly = {x=5,y=15},
		float = {x=0,y=0,speed=0},
	}
	def2.collisionbox = def.collisionbox or {-0.3,-0.22,-0.3,0.3,0.15,0.3}
	def2.spawn_on = def.spawn_on or {"group:spreading_dirt_type"}
	def.on_spawn = def.on_spawn or function() end
	def.on_load = def.on_load or function() end
	def.is_food = def.is_food or function() end
	def.on_click = def.on_click or function() end
	def.on_fly = def.on_fly or function() end
	def.on_walk = def.on_walk or function() end
	def.on_stand = def.on_stand or function() end
	def.step = def.step or function() end

	def2.on_spawn=function(self)
		def.on_spawn(self)
		examobs.anim(self,"stand")
	end
	def2.on_load=function(self)
		def.on_load(self)
		if self.storage.fly then
			examobs.anim(self,"fly")
			self.floating = {"air"}
			self.object:set_velocity({x=0,y=0,z=0})
			self.object:set_acceleration({x=0, y=0, z=0})
		else
			examobs.anim(self,"stand")
		end
	end
	def2.is_food=function(self,item)
		return def.is_food(self)
	end
	def2.on_click=function(self,clicker)
		if def.on_click(self) then return end
		if clicker:is_player() then
			if math.random(1,10) == 1 and not (self.fight or self.flee) then
				clicker:get_inventory():add_item("main",self.name .. "_spawner")
				self.object:remove()
			else
				self.flee = clicker
				examobs.known(self,clicker,"flee")
			end
		end
	end
	def2.on_fly=function(self)
		def.on_fly(self)
		examobs.anim(self,"fly")
		if self.flee then
			local v = self.object:get_velocity()
			self.object:set_velocity({x=v.x,y=3,z=v.z})
		end
	end
	def2.on_walk=function(self)
		def.on_walk(self)
		if self.storage.fly then
			examobs.anim(self,"fly")
			local v = self.object:get_velocity()
			if self.fight and self:pos().y-0.4 > self.fight:get_pos().y then
				self.object:set_velocity({x=v.x,y=self.run_speed*-1,z=v.z})
			elseif self.fight and self:pos().y+0.4 < self.fight:get_pos().y then
				self.object:set_velocity({x=v.x,y=self.run_speed,z=v.z})
			elseif self.movingspeed > self.walk_speed then
				self.object:set_velocity({x=v.x,y=3,z=v.z})
			else
				self.object:set_velocity({x=v.x,y=0.5,z=v.z})
			end
			return 1
		end
	end
	def2.on_stand=function(self)
		def.on_stand(self)
		if self.storage.fly then
			examobs.walk(self)
			examobs.anim(self,"float")
			local v = self.object:get_velocity()
			self.object:set_velocity({x=v.x,y=-0.5,z=v.z})
			return 1
		end
	end
	def2.step=function(self)
		if def.step(self) then
			return self
		elseif not self.storage.fly and (self.flee or self.fight or self.object:get_velocity().y < 0 or math.random(1,10) == 1) then
			self.object:set_velocity({x=0,y=1,z=0})
			self.storage.fly = 1
			self.floating = {["air"]=1}
			examobs.anim(self,"fly")
		elseif self.storage.fly and walkable(apos(self:pos(),0,-1)) then
			self.falling = nil
			self.storage.fly = nil
			self.floating = {}
			examobs.stand(self)
			examobs.anim(self,"stand")
		end
	end
	for i,v in pairs(def) do
		if not def2[i] then
			def2[i]=v
		end
	end
	examobs.register_mob(def2)
end