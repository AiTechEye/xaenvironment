plasma = {}
minetest.register_tool("plasma:plasma_cannon",{
	description = "Plasma cannon",
	inventory_image = "plasma_cannon.png",
	wield_scale={x=2,y=2,z=4},
	on_use=function(itemstack, user, pointed_thing)
		if itemstack:get_wear() > 60000 then
			local inv = user:get_inventory()
			if inv:contains_item("main","plasma:cannon_battery") then
				inv:remove_item("main",ItemStack("plasma:cannon_battery"))
				itemstack:set_wear(1)
				itemstack:get_meta():set_int("power",100)
				minetest.sound_play("spacestuff_pff", {pos=user:get_pos(), gain = 1, max_hear_distance = 8})
			else
				minetest.chat_send_player(user:get_player_name(),"Have  'Plasma cannon battery' in your inventory to reload")

			end
			return itemstack
		end
		local m =  itemstack:get_meta()
		if m:get_int("power") == 0 then
			m:set_int("power",100)
		end

		local dir = user:get_look_dir()
		local p = user:get_pos()
		local e = minetest.add_entity({x=p.x+(dir.x*2),y=p.y+1+(dir.y*2),z=p.z+(dir.z*2)},"plasma:orb")
		local en = e:get_luaentity()
		en.charging = true
		en.user = user
		en.user_name = user:get_player_name()
		return itemstack
	end
})

minetest.register_entity("plasma:orb",{
	hp_max = 100,
	physical = false,
	pointable=false,
	visual="sprite",
	textures={"plasma_orb1.png"},
	visual_size = {x=1,y=1},
	use_texture_alpha = true,
	charging = false,
	charging_time = 0,
	img = 1,
	timer = 0,
	start_timeout = 0,
	plasmaorb = true,
	get_staticdata = function(self)
		self:explode(true)
		return minetest.serialize({power=self.power,user_name=self.user_name})
	end,
	anim=function(self)
		self.img = self.img +1
		if self.img > 8 then
			self.img = 1
		end
		self.object:set_properties({textures={"plasma_orb"..self.img..".png"}})
	end,
	on_activate=function(self, staticdata)
		local s = minetest.deserialize(staticdata) or {}
		self.power = s.power or 1
		self.user_name = s.user_name
		self.object:set_properties({visual_size = {x=1+self.power*0.01,y=1+self.power*0.01,z=1+self.power*0.01}})
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		self:explode()
	end,
	explode=function(self,juststop)
		if self.sound1 then
			minetest.sound_stop(self.sound1)
		end
		if self.sound2 then
			minetest.sound_stop(self.sound2)
		end
		if self.sound3 then
			minetest.sound_stop(self.sound3)
		end
		if juststop then
			return
		end
		if self.ex then
			return
		end

		self.ex = true

		local pos = self.opos or self.object:get_pos()

		if self.power > 50 then
			minetest.sound_play("plasma_explosion", {pos=pos, gain = 9,max_hear_distance = 100})
		else
			minetest.sound_play("plasma_boom", {pos=pos, gain = 4,max_hear_distance = 50})
		end

		self.power = self.power > 8 and self.power or 8

		if self.user and self.user_name then
			if self.power >= 100 then
				exaachievements.customize(self.user,"100% Clean")
			end
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2+(self.power/2))) do
				local en = ob:get_luaentity()
				local p = ob:get_pos()
				if p and not (ob:is_player() and ob:get_player_name() == self.user_name) and not (en and (en.plasmaorb or en.name == "__builtin:item" )) then
					local d = self.power-vector.distance(pos,p)
					if d > 90 then
						d = 1000
					end
					default.punch(ob,self.user,d)
					self.obs(ob)
				end
			end
		else
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2+(self.power/2))) do
				local en = ob:get_luaentity()
				local p = ob:get_pos()
				if p and not (en and en.plasmaorb) then
					local d = self.power-vector.distance(pos,p)
					if d > 90 then
						d = 1000
					end
					default.punch(ob,ob,self.power-vector.distance(pos,p))
					self.obs(ob)
				end
			end
		end
		local o = minetest.add_entity(pos,"plasma:impulse")
		local en = o:get_luaentity()
		en.end_scale = self.power
		minetest.check_for_falling(self.object:get_pos())
		self.object:remove()
	end,
	obs=function(ob)
		if ob and ob:get_pos() then
			local en = ob:get_luaentity()
			if en and en.examob and (en.hp <= 0 or en.dying or en.dead) then
				examobs.dying(en,2)
				local t = "default_cloud.png^[colorize:#000"
				ob:set_properties({textures={t,t,t,t,t,t}})
				en.on_abs_step =  function(self)
					examobs.anim(self,"stand")
					self.smplasmatimer = self.smplasmatimer and self.smplasmatimer + 1 or 50
					if self.smplasmatimer >= 50 then
						self.smplasmatimer = 0
						local pos = self.object:get_pos()
						minetest.add_particlespawner({
							amount = math.random(3,7),
							time =0.2,
							minpos = pos,
							maxpos = pos,
							minvel = {x=-0.1, y=0, z=-0.1},
							maxvel = {x=0.1, y=1, z=0.1},
							minacc = {x=0, y=2, z=0},
							maxacc = {x=0, y=0, z=0},
							minexptime = 2,
							maxexptime = 7,
							minsize = 1,
							maxsize = 3,
							texture = "default_item_smoke.png",
							collisiondetection = true,
						})
					end
				end
			end
		end
	end,
	on_step=function(self,dtime)
		local pos = self.object:get_pos()
		if not pos then
			self:explode(ob,true)
			return
		end
		self.timer = self.timer + dtime
		if self.timer > 0.1 then
			self.timer = 0
			self:anim()
		end
		if self.start_timeout < 0.01 then
			self.start_timeout = self.start_timeout + dtime
			return
		end
		if self.user and self.charging then
			self.start_timeout = 0
			local key = self.user:get_player_control()
			if key.LMB then

				local dir = self.user:get_look_dir()
				local p = self.user:get_pos()
				local npos = {x=p.x+dir.x, y=p.y+dir.y+1.6, z=p.z+dir.z}
				if vector.distance(npos,pos) > 1 then
					self.object:set_velocity({x=0,y=0,z=0})
					self.object:set_pos(npos)
				else
					local v = {x = (npos.x - pos.x)*20, y = (npos.y - pos.y)*20, z = (npos.z - pos.z)*20}
					self.object:set_velocity(v)
				end

				local stack = self.user:get_wielded_item()
				local m = stack:get_meta()

				if stack:get_name() ~= "plasma:plasma_cannon" then
					self.charging = nil
				elseif self.power >= m:get_int("power") then
					if self.sound1 then
						minetest.sound_stop(self.sound1)
					end
					if not self.sound2 then
						self.sound2 = minetest.sound_play("plasma_core_loaded", {object=self.object, gain = 4,max_hear_distance = 10,loop=true})
					end
					return
				end

				self.power = self.power + dtime*40
				self.charging_time = self.charging_time + dtime

				if not self.sound1 then
					self.sound1 = minetest.sound_play("plasma_charge_orb", {object=self.object, gain = 4,max_hear_distance = 10})
				end

				if self.power > 100 then
					self.power = 100
				else
					self.object:set_properties({visual_size = {x=1+self.power*0.01,y=1+self.power*0.01,z=1+self.power*0.01}})
				end



				if self.charging_time >= 2.2 then
					if not self.sound2 then
						self.power = 100
						self.sound2 = minetest.sound_play("plasma_core_loaded", {object=self.object, gain = 4,max_hear_distance = 10,loop=true})
					end
				end

				return
			else
				self.charging = nil
				if self.sound1 then
					minetest.sound_stop(self.sound1)
				end
				if self.sound2 then
					minetest.sound_stop(self.sound2)
				end
				if not self.sound3 then
					local stack = self.user:get_wielded_item()
					local w = stack:get_wear() + math.floor((65535*(self.power*0.01)))

					stack:set_wear(w < 60001 and w or 60001)
					local m = stack:get_meta()
					m:set_int("power",m:get_int("power") - self.power)

					self.user:get_inventory():set_stack("main",self.user:get_wield_index(),stack)
					self.sound3 = minetest.sound_play("plasma_orb", {object=self.object, gain = 4,max_hear_distance = 10,loop=true})
					minetest.sound_play("plasma_shoot", {object=self.object, gain = 4,max_hear_distance = 10})
					local dir = self.user:get_look_dir()
					local v = self.object:set_velocity({x=dir.x*20,y=dir.y*20,z=dir.z*20})
					self.start_timeout = 1
				end
			end
		end

		if default.defpos(pos,"walkable") then
			self:explode()
			return
		end
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2+self.power*0.03)) do
			local en = ob:get_luaentity()
			if not (ob:is_player() and ob:get_player_name() == self.user_name) and not (en and (en.plasmaorb or en.name == "__builtin:item" )) then
				self:explode()
				return
			end
		end
		self.opos = pos
	end
})

minetest.register_entity("plasma:impulse",{
	hp_max = 1000,
	physical = false,
	pointable=false,
	visual="mesh",
	mesh = "plasma_impulse.obj",
	textures={"default_cloud.png^[colorize:#ff008caa"},
	use_texture_alpha = true,
	visual_size = {x=1,y=1},
	timer = 0,
	plasmaorb = true,
	on_activate=function(self, staticdata)
		self.scale = 1
		self.end_scale = 1
	end,
	on_step=function(self,dtime)
		self.timer = self.timer + dtime
		if not self.timeout then
			if self.timer < 0.01 then
				return
			else
				self.timeout = true
				self.timer = 0
			end
		end
		if self.scale < self.end_scale then
			self.scale = self.scale + dtime * (self.end_scale*5)
			self.object:set_properties({visual_size = {x=self.scale*3,y=self.scale*3,z=self.scale*3}})
		else
			self.object:remove()
		end
	end
})

minetest.register_craftitem("plasma:cannon_battery", {
	description = "Plasma cannon battery",
	inventory_image = "plasma_battery.png",
})


minetest.register_craft({
	output="plasma:plasma_cannon",
	recipe={
		{"default:diamondblock","default:titaniumblock","default:uraniumactive_ingot"},
		{"default:emerald","examobs:titan_core","default:electricblock"},
	}
})

minetest.register_craft({
	output="plasma:cannon_battery 3",
	recipe={
		{"default:titanium_ingot","default:iron_ingot",""},
		{"default:emerald","default:emerald",""},
		{"default:titanium_ingot","default:iron_ingot",""},
	}
})