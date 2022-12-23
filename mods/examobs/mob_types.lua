examobs.register_bird=function(def)
	def = def or {}
	local def2 = {}
	def2.name = def.name or "bird"
	def2.textures = def.textures or {"examobs_bird.png"}
	def2.mesh = def.mesh or "examobs_bird.b3d"
	def2.type = def.type or "animal"
	def2.team = def.team or "bird"
	def2.bird = true
	def2.dmg = def.dmg or 1
	def2.hp = def.hp or 5
	def2.aggressivity = def.aggressivity or -2
	def2.inv = def.inv or {["examobs:chickenleg"]=1,["examobs:feather"]=2}
	def2.walk_speed = def.walk_speed or 2
	def2.run_speed = def.run_speed or 4
	def2.swiming = def2.swiming or 0
	def2.animation = def.animation or {
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
			local v = self.object:get_velocity() or {x=0,y=0,z=0}
			self.object:set_velocity({x=v.x,y=3,z=v.z})
		end
	end
	def2.on_walk=function(self,x,y,z)
		def.on_walk(self)
		if self.storage.fly then
			examobs.anim(self,"fly")
			local target = self.target or self.fight
			target = target and target:get_pos()
			if target and self:pos().y-0.4 > target.y then
				y = self.run_speed*-1
			elseif target and self:pos().y+0.4 < target.y then
				y = self.run_speed
			elseif self.movingspeed > self.walk_speed then
				y = 3
			else
				y = 0.5
			end
			if target then
				x = x * self.run_speed
				z = z * self.run_speed
			end
			self.object:set_velocity({x=x,y=y,z=z})
			return 1
		end
	end
	def2.on_stand=function(self)
		def.on_stand(self)
		if self.storage.fly then
			examobs.walk(self)
			examobs.anim(self,"float")
			local v = self.object:get_velocity() or {x=0,y=0,z=0}
			self.object:set_velocity({x=v.x,y=-0.5,z=v.z})
			return 1
		end
	end
	def2.step=function(self,dtime)
		if def.step(self,dtime) then
			return self
		elseif self.fight and self.storage.fly then
			local v = self.object:get_velocity()
			self.object:set_velocity({x=v.x*self.run_speed,y=v.y*self.run_speed,z=v.z*self.run_speed})
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

examobs.register_fish=function(def)
	def = def or {}
	def.name = def.name or "fish"

	local mobname = minetest.get_current_modname() ..":" .. def.name
	local step = def.step or function() end
	local is_food = def.is_food or function() end
	local on_click = def.on_click or function() end

	def.makes_footstep_sound = false
	def.textures = def.textures or {"examobs_fish.png"}
	def.mesh = def.mesh or "examobs_fish.obj"
	def.type = def.type or "animal"
	def.team = def.team or "fish"
	def.dmg = def.dmg or 1
	def.hp = def.hp or 2
	def.aggressivity = def.aggressivity or -2
	def.walk_speed = def.walk_speed or 2
	def.run_speed = def.run_speed or 3
	def.collisionbox = def.collisionbox or {-0.4,-0.4,-0.4,0.4,0.4,0.4}
	def.spawn_on = def.spawn_on or {"group:water"}
	def.spawn_in = def.spawn_in or "group:water"
	def.floating_in_group = def.floating_in_group or "water"
	def.light_min = def.light_min or 5
	def.breathing = 0
	def.hurt_outside = def.hurt_outside or 1
	def.lay_on_death = def.lay_on_death or 0
	def.inv = def.inv or {[mobname]=1}
	def.is_food = def.is_food or function() end
	def.on_click = def.on_click or function() end

	def.is_food=function(self,item)
		return is_food(self)
	end
	def.on_click=function(self,clicker)
		if on_click(self) then
			return
		elseif clicker:is_player() then
			self.flee = clicker
			examobs.known(self,clicker,"flee")
		end
	end
	def.step=function(self)
		if step(self) then
			return self
		elseif def.hurt_outside == 1 and minetest.get_item_group(minetest.get_node(self:pos()).name,"water") == 0 and walkable(apos(self:pos(),0,-1)) then
			self:hurt(1)
			examobs.stand(self)
		elseif self.hurt_outside == 1 and self.fight and self.fight:get_pos() and minetest.get_node(self.fight:get_pos()).name == "air" then
			self.fight = nil
		elseif def.lay_on_death == 0 and not (self.target or self.fight or self.flee) and math.random(1,5) == 1 then
			for _, ob in pairs(minetest.get_objects_inside_radius(self:pos(), self.range)) do
				local en = ob:get_luaentity()
				local p = ob:get_pos()
				if en and (en.name == "__builtin:item" or en.examobs_fishing_target) and (minetest.get_node(p).name ~= "air" or minetest.get_item_group(minetest.get_node(apos(p,0,-1)).name,"water") > 0) and examobs.viewfield(self,ob) and examobs.visiable(self.object,ob) then
					self.target =  ob
					return
				elseif not examobs.team(ob) and examobs.visiable(self.object,ob) and not (ob:is_player() and examobs.hiding[ob:get_player_name()]) then
					self.flee = ob
					return
				end
			end
		elseif self.target then
			if examobs.gethp(self.target) <= 0 or not (self.target:get_pos() and examobs.visiable(self.object,self.target)) then
				self.target = nil
				return
			elseif examobs.distance(self.object,self.target) <= 1 then
				local en = self.target:get_luaentity()
				if not en then
					self.target = nil
					return
				elseif en.examobs_fishing_target then
					en:on_trigger(self.object)
					self.target = nil
					return
				end
				local item = string.split(en.itemstring," ")
				if minetest.get_item_group(item[1],"eatable") > 0 then
					self:eat_item(item[1])
				elseif item[1] then
					self.inv[item[1]] = (self.inv[item[1]] or 0) + (item[2] and tonumber(item[2]) or 1)
				end
				self.lifetimer = self.lifetime
				self.target:remove()
				self.target = nil
			else
				examobs.lookat(self,self.target)
				examobs.walk(self)
			end
		end
	end

	examobs.register_mob(def)

	if def.lay_on_death == 0 then
		minetest.register_node(mobname, {
			description = "Dead " .. def.name,
			wield_scale = {x=0.3,y=0.3,z=0.3},
			visual_scale=0.1,
			selection_box = {
				type = "fixed",
				fixed = {-0.2,-0.2,-0.2,0.2,0.2,0.2}
			},
			use_texture_alpha = "clip",
			drawtype = "mesh",
			mesh = def.mesh,
			tiles=def.textures,
			paramtype ="light",
			paramtype2 ="facedir",
			groups = {dig_immediate = 3,eatable=1,meat=1,fish=1},
			sounds = default.node_sound_defaults(),
			walkable = false,
		})
	end
end

examobs.register_roadwalker=function(def)
	def = def or {}

	def.name = def.name or "roadwalker"
	local mobname = minetest.get_current_modname() ..":" .. def.name
	local is_food = def.is_food or function(item) return minetest.get_item_group(item,"meat") > 0 end

	local amount_limit = def.amount_limit or 30
	def.path_range = def.path_range or 20
	def.path_pass_range = def.path_pass_range or 2
	def.path_finished = def.path_finished or function() end
	def.new_path = def.new_path or function() end
 	def.right_hand_traffic = def.right_hand_traffic	-- distance

	def.description = def.description or "A random person thats life is to move from a to b"
	def.static_save = def.static_save or false
	def.coin = def.coin or 1
	def.textures = def.textures or {"character.png"}
	def.type = def.type or "npc"
	def.team = def.team or "fish"
	def.dmg = def.dmg or 1
	def.hp = def.hp or 20
	def.walk_speed = def.walk_speed or 4
	def.run_speed = def.run_speed or 8
	def.animation = def.animation or "default"
	def.spawning = false
	def.inv = def.inv or {["examobs:flesh"]=1}

	def.step = def.step or function() end

	def.on_lifedeadline=function(self)
		return self.storage.npc_generated
	end

	def.on_spawn = function(self)
		local skin = player_style.skins.skins[math.random(1,26)].skin
		self.object:set_properties({textures={skin}})
	end

	def.on_abs_step=function(self,dtime)
		local pos = self.object:get_pos()

		if self.step(self) then
			return self
		elseif self.fight or self.flee then
			return
		elseif not self.current_path or pos and vector.distance(self.current_path,pos) <= def.path_pass_range then
			local paths = {}
			if self.current_path then
				def.path_finished(self)
			end

			for i,v in pairs(examobs.paths[mobname] or {}) do
				if vector.distance(v,pos) < def.path_range and self.past_path_key ~= i then
					local c = minetest.raycast(v,pos)
					local n = c:next()
					local skip
					while n do
						if n and n.type == "node" and default.defpos(n.under,"walkable") then
							skip = true
							break
						end
						n = c:next()
					end
					if not skip then
						table.insert(paths,{pos=v,key=i})
					end
				end
			end
			if next(paths) then
				self.ctimer = 0
				local r = paths[math.random(1,#paths)]
				local pos1 = self.current_path or pos
				local pos2 = r.pos

				if def.right_hand_traffic then
					local dir = vector.subtract(pos2,pos1)
					local right_side = vector.normalize(vector.new(dir.z,dir.y,-dir.x))
					pos2 = vector.add(pos2,vector.multiply(right_side,def.right_hand_traffic))
				end

				self.past_path_key = self.current_path_key
				self.current_path_key = r.key
				self.current_path = pos2
				self.new_path(self,pos1,pos2)
				return self
			else
				self.object:remove()
			end
		elseif self.current_path then
			self.ctimer = self.ctimer + dtime
			if self.ctimer > 0.1 then
				self.ctimer = 0
				if self.moveresult.collides and next(self.moveresult.collisions) and vector.length(self.moveresult.collisions[1].new_velocity) < 0.1 then
					self.object:set_yaw(math.random(0,6.28))
					self.ctimer = -0.5
				else
					examobs.lookat(self,self.current_path)
					examobs.walk(self)
				end
			elseif self.ctimer < 0 then
				examobs.walk(self)
			end
			return self
		end
	end

	local nodedef = table.copy(def.node or {})
	local on_load = nodedef.on_load or function() end
	local on_timer = nodedef.on_timer or function() return true end
	local on_construct = nodedef.on_construct or function() end
	local on_destruct = nodedef.on_destruct or function() end

	local on_spawn = nodedef.on_spawn or function() end

	nodedef.groups = nodedef.groups or {on_load=1,attached_node=1,not_in_creative_inventory=1}
	nodedef.drawtype = nodedef.drawtype or "airlike"
	nodedef.sunlight_propagates = nodedef.sunlight_propagates or true
	nodedef.drop = nodedef.drop or ""
	nodedef.walkable = nodedef.walkable or false
	nodedef.pointable = nodedef.pointable or false
	nodedef.paramtype = nodedef.paramtype or "light"

	nodedef.on_load = function(pos)
		examobs.paths[mobname] = examobs.paths[mobname] or {}
		examobs.paths[mobname][minetest.pos_to_string(pos)] = pos
		minetest.get_node_timer(pos):start(math.random(1,60))
		on_load(pos)
	end
	nodedef.on_construct=function(pos)
		examobs.paths[mobname] = examobs.paths[mobname] or {}
		examobs.paths[mobname][minetest.pos_to_string(pos)] = pos
		minetest.get_node_timer(pos):start(math.random(1,60))
		on_construct(pos)
	end
	nodedef.on_destruct=function(pos)
		examobs.paths[mobname] = examobs.paths[mobname] or {}
		examobs.paths[mobname][minetest.pos_to_string(pos)] = nil
		on_destruct(pos)
	end
	nodedef.on_timer = function(pos, elapsed)
		if (examobs.active.types[mobname] or 0) >= amount_limit then
			for i,v in pairs(examobs.active.ref) do
				if examobs.active.types[mobname] > amount_limit then
					v:remove()
				else
					return true
				end
			end
			return true
		end

		if on_timer(pos) == false then
			return
		end

		local ob = minetest.add_entity(apos(pos,0,1),mobname)
		on_spawn(pos,ob)
		return true
	end

	def.node = nil
	def.amount_limit = nil

	examobs.register_mob(def)
	minetest.register_node(mobname.."_path", nodedef)
end