minetest.register_entity("exa2d:cam",{
	hp_max = 99999,
	collisionbox = {0,0,0,0,0,0},
	visual =  "sprite",
	textures = {"default_air.png"},
	--on_activate=function(self, staticdata)
	--	return self
	--end,
	on_step=function(self, dtime)
		if not (self.user and exa2d.user[self.username] and exa2d.user[self.username].id==self.id ) then
			self.object:remove()
			return self
		elseif not (self.ob and self.ob:get_luaentity()) then
			local pos=self.object:get_pos()
			self.ob=minetest.add_entity({x=pos.x,y=pos.y+1,z=pos.z}, "exa2d:player")

			if self.dir.x ~= 0 then
				self.ob:set_yaw(0)
			else
				self.ob:set_yaw(math.pi+math.pi/2)
			end

			self.ob:get_luaentity().user=self.user
			self.ob:get_luaentity().id=self.id
			self.ob:get_luaentity().username=self.username

			local pos2 = vector.floor(self.ob:get_pos())

			self.ob:set_pos(apos(pos2,self.dir.x*0.46,0,self.dir.z*0.46))

			self.ob:set_properties({
				textures={"character.png",exa2d.user[self.username].texture},
				nametag=self.username,
				nametag_color="#FFFFFF"
			})

			self.user:set_properties({
				textures="default_air.png",
				nametag="",
			})

			exa2d.user[self.username].object=self.ob

			if self.dir.z == -1 then
				self.r = 3.14
			elseif self.dir.z == 1 then
				self.r = 0
			elseif self.dir.x == -1 then
				self.r = 1.57
				self.ob:set_properties({collisionbox = {-0.01,-1,-0.35,0.01,0.8,0.35}})
			elseif self.dir.x == 1 then
				self.r = 4.71
				self.ob:set_properties({collisionbox = {-0.01,-1,-0.35,0.01,0.8,0.35}})
			end

			if self.user:get_player_control().RMB then
				self.prevexit = true
			end

		end

		local pos=self.object:get_pos()
		local pos2=self.ob:get_pos()
		local key=self.user:get_player_control()

		local v=self.ob:get_velocity()
		if not pos2 then
			local user=self.user
			self.object:remove()
			user:set_hp(0)
			return
		end

		local n1 = minetest.get_node({x=pos2.x,y=pos2.y-1,z=pos2.z})
		local node=minetest.registered_nodes[n1.name]
		local node2=minetest.registered_nodes[minetest.get_node({x=pos2.x,y=pos2.y+1,z=pos2.z}).name]
		local cp
--coin
		if n1.name == "exa2d:coin" and not self.sit then
			cp = {x=pos2.x,y=pos2.y-1,z=pos2.z}
		elseif minetest.get_node(pos2).name == "exa2d:coin" then
			cp = pos2
		end
		if cp then
			minetest.sound_play("exa2d_coin",{pos=pos2,gain=0.1,max_hear_distance=10})
			Coin(self.user,1)
			self.user:hud_change(exa2d.user[self.username].ui_coins,"text",self.user:get_meta():get_int("coins"))
			minetest.remove_node(cp)
		end

		if not (node and node2) then return end

		if node.damage_per_second>0 then
			self.dmgtimer=self.dmgtimer+dtime
			if self.dmgtimer>1 then
				self.dmgtimer=0
				exa2d.punch(self.user,self.ob,node.damage_per_second)
			end
		end
--breath
		if node2.drowning>0 then
			self.breath=self.breath-dtime
			self.user:set_breath(self.breath)
			if self.breath<=0 then
				self.breath=0
				self.dmgtimer=self.dmgtimer+dtime
				if self.dmgtimer>1 then
					self.dmgtimer=0
					exa2d.punch(self.user,self.ob,1)
				end
			end
		elseif self.breath<11 then
			self.breath=self.breath+dtime
			self.user:set_breath(self.breath)
		end
--physics
		if node.liquid_viscosity>0 or node.climbable then
			if v.y<-0.1 then
				v={x = v.x*0.99, y =v.y*0.99, z =v.z*0.99}
			end
			if not self.floating then
				self.fallingfrom=nil
				self.ob:set_acceleration({x=0,y=0,z=0})
				self.floating=true
				minetest.sound_play("default_object_watersplash", {object=self.ob, gain = 4,max_hear_distance = 10})
			end
		elseif self.floating then
			self.ob:set_acceleration({x=0,y=-20,z =0})
			self.floating=nil
		elseif v.y<0 and not self.fallingfrom then
			self.fallingfrom=pos.y
		elseif self.fallingfrom and v.y==0 then
			local from=math.floor(self.fallingfrom+0.5)
			local hit=math.floor(pos.y+0.5)
			local d=from-hit
			self.fallingfrom=nil
			if minetest.get_node({x=pos2.x,y=pos2.y-2,z=pos2.z}).name~="ignore" and d>=10 then
				exa2d.punch(self.ob,self.ob,d)
			end
		end

--input & anim

		if key.RMB and not self.prevexit or not default.defpos(apos(pos2,self.dir.x,0,self.dir.z),"walkable") and not default.defpos(apos(pos2,self.dir.x,1,self.dir.z),"walkable") then
			exa2d.leave(self.user)
			return
		end

		if self.ob:get_luaentity().dead or exa2d.attach[self.username] then
			self.object:set_velocity({x=((pos2.x-pos.x)*10),y=(-0.5+(pos2.y-pos.y))*10,z=(5-(pos.z-pos2.z))*10})
			return self
		elseif self.laying then
			v={x=0,y=0,z=0}
			self.ob:set_acceleration({x=0,y=0,z=0})
			exa2d.player_anim(self,"lay")
			if key.up or key.left or key.right or self.wakeup then
				self.laying=nil
				self.wakeup=nil
				self.ob:set_acceleration({x=0,y=-20,z=0})
			end
		elseif key.sneak then
			exa2d.player_anim(self,"sit")
			if not self.sit then
				self.sit = true
				local cb = self.ob:get_properties().collisionbox
				cb[2] = -0.65
				cb[5] = 0.5
				self.ob:set_properties({collisionbox = cb})
			end

		elseif key.up and self.floating then
			v.y=4
		elseif key.up and v.y==0 and self.jump_timer <= 0 then
			self.jump_timer = 0.05
			v.y=10
			minetest.sound_play("exa2d_jump",{pos=pos2,gain=1,max_hear_distance=10})
		elseif key.left then
			exa2d.player_anim(self,"walk")
			if self.dir.x == 1 then
				v.z = 4
				self.ob:set_yaw(0)
			elseif self.dir.x == -1 then
				v.z = -4
				self.ob:set_yaw(3.14)
			elseif self.dir.z == 1 then
				v.x = -4
				self.ob:set_yaw(1.57)
			else
				v.x = 4
				self.ob:set_yaw(4.71)
			end
		elseif key.right then
			exa2d.player_anim(self,"walk")
			if self.dir.x == 1 then
				v.z = -4
				self.ob:set_yaw(3.14)
			elseif self.dir.x == -1 then
				v.z = 4
				self.ob:set_yaw(0)
			elseif self.dir.z == 1 then
				v.x = 4
				self.ob:set_yaw(4.71)
			else
				v.x = -4
				self.ob:set_yaw(1.57)
			end
		elseif key.LMB then
			exa2d.player_anim(self,"mine")
			v.x=0
		else
			if self.sit and not key.sneak then
				self.sit = nil
				local cb = self.ob:get_properties().collisionbox
				cb[2] = -1
				cb[5] = 0.8
				self.ob:set_properties({collisionbox = cb})
				v.y=5
			end
			exa2d.player_anim(self,"stand")
			v={x=0,y=v.y,z=0}
		end

		if self.jump_timer > 0 and v.y == 0 then
			self.jump_timer = self.jump_timer -dtime
		elseif self.floating then
			v.x=v.x/2
			v.y=v.y/2
			if key.down then
				v.y=-2
			end
		end

		if key.aux1 then
			v.x = v.x*2
			v.z = v.z*2
			exa2d.player_anim(self,"run")
		end
--movment
		self.ob:set_velocity(v)
		self.object:set_velocity({
			x=((pos2.x-pos.x) - (self.dir.x*3)) * 10,
			y=((pos2.y-pos.y) - 0.5) * 10,
			z=((pos2.z-pos.z) - (self.dir.z*3)) * 10
		})
		
		local yaw = self.user:get_look_horizontal()
		local vertical = self.user:get_look_vertical()
		local res = self.r-yaw

		if self.r == 0 then
			if yaw > 3 and yaw < 5.64 then
				self.user:set_look_horizontal(6)
			elseif yaw < 3 and yaw > 0.5 then
				self.user:set_look_horizontal(0.4)
			end
		elseif yaw > self.r+0.5 or yaw < self.r-0.5 then
			self.user:set_look_horizontal(yaw+(res*0.1))
		end

		if math.abs(vertical) > 0.5 then
			self.user:set_look_vertical(vertical+(vertical*-0.25))
		end

		self.timer = self.timer + dtime
		if self.timer > 1 then
			if self.prevexit and not key.RMB then
				self.prevexit = nil
			end
			self.timer = 0
			exa2d.mapgen(pos2,self.dir,self.fdir)
		end
		return self
	end,
	jump_timer = 0,
	timer = 2,
	dmgtimer = 0,
	breath = 11,
	start = 0.1,
})

minetest.register_entity("exa2d:player",{
	hp_max = 20,
	physical = true,
	collisionbox = {-0.35,-1,-0.01,0.35,0.8,0.01},
	visual =  "mesh",
	mesh = "mt2d_character.b3d",
	textures = {"default_air.png","default_air.png"},
	is_visible = true,
	makes_footstep_sound = true,
	on_activate=function(self, staticdata)
		local rndlook={4.71,1.57}
		self.object:set_yaw(rndlook[math.random(1,2)])
		self.object:set_acceleration({x=0,y=-20,z =0})
		return self
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not self.user then
			self.object:remove()
		elseif not (puncher:is_player() and puncher:get_player_name(puncher)==self.username) and tool_capabilities and tool_capabilities.damage_groups and tool_capabilities.damage_groups.fleshy then
			self.user:set_hp(self.user:get_hp()-tool_capabilities.damage_groups.fleshy)
		end
		return self
	end,
	on_step=function(self, dtime)
		self.timer=self.timer+dtime
		if self.start>0 then
			self.start=self.start-dtime
			return self
		elseif not (exa2d.user[self.username] and exa2d.user[self.username].id==self.id) then
			self.object:remove()
			return self
		elseif self.user:get_hp()<=0 then
			self.ob=self.object
			self.ob:get_luaentity().dead=true
			exa2d.player_anim(self,"lay")
		end
	end,
	id=0,
	username="",
	start=0.1,
	type="npc",
	team="default",
	timer=0,
})

exa2d.dot=function(pos,v)
	v=v or "008"
	local a=""
	for i=1,3,1 do
		local n=tonumber(v:sub(i,i))
		if not n or n==0 or n>8 then n=1 end
		a=a .. string.sub("13579bdf",n,n):rep(2)
	end
	minetest.add_entity(pos, "exa2d:dot"):set_properties({textures = {"bubble.png^[colorize:#"..a}})
end

minetest.register_entity("exa2d:dot",{
	hp_max = 1,
	physical = false,
	collisionbox = {0,0,0,0,0,0},
	visual = "sprite",
	visual_size = {x=0.2, y=0.2},
	textures = {"bubble.png"},
	makes_footstep_sound = false,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<0.1 then return self end
		self.object:remove()
	end,
	timer=0,
})