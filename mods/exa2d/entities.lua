minetest.register_entity("exa2d:cam",{
	visual =  "sprite",
	textures = {"default_air.png"},
	pointable = false,
	on_step=function(self, dtime)
		if not (self.user and exa2d.user[self.username] and exa2d.user[self.username].id==self.id ) then
			self.object:remove()
			return self
		elseif not (self.ob and self.ob:get_luaentity()) then
			local pos = self.object:get_pos()
			self.ob = minetest.add_entity({x=pos.x,y=pos.y+1,z=pos.z}, "exa2d:player")

			if self.dir.x ~= 0 then
				self.ob:set_yaw(0)
			else
				self.ob:set_yaw(math.pi+math.pi/2)
			end

			self.ob:get_luaentity().user = self.user
			self.ob:get_luaentity().id = self.id
			self.ob:get_luaentity().username = self.username

			local pos2 = vector.floor(self.ob:get_pos())

			self.ob:set_pos(apos(pos2,self.dir.x*0.46,0,self.dir.z*0.46))

			if pos.y > 3000 and pos.y < 4000 then
				self.jump_v = 7
			end

			self.ob:set_properties({
				textures={"character.png",exa2d.user[self.username].texture},
				nametag=self.username,
				nametag_color="#FFFFFF"
			})

			self.user:set_properties({
				textures={"default_air.png"},
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
		local above = minetest.get_node({x=pos2.x,y=pos2.y+1,z=pos2.z})
		local cp
--coin
		if n1.name == "exa2d:coin" and not self.sit then
			cp = {x=pos2.x,y=pos2.y-1,z=pos2.z}
		elseif minetest.get_node(pos2).name == "exa2d:coin" then
			cp = pos2
		elseif not self.block_hit and v.y ~= 0 and above.name == "exa2d:block" then
			self.block_hit = true
			minetest.sound_play("exa2d_blockhit",{pos=pos2,gain=1,max_hear_distance=10})
			minetest.set_node({x=pos2.x,y=pos2.y+1,z=pos2.z},{name="exa2d:block_empty",param2=above.param2})

			if math.random(1,5) == 1 then
				local pf = {
					x=self.dir.z ~= 0 and math.floor(pos2.x+0.5) or pos2.x,
					y=math.floor(pos2.y+2),
					z=self.dir.x ~= 0 and math.floor(pos2.z+0.5) or pos2.z
				}

				local items = {}
				for i,v in pairs(minetest.registered_items) do
					if v.groups and v.groups.treasure then
						table.insert(items,i)
					end
				end

				local spitem = items[math.random(1,#items)]
				exa2d.spawn_item(pf,self.dir,self.fdir,spitem,true)
				minetest.sound_play("exa2d_item_popup",{pos=pos2,gain=0.2,max_hear_distance=10})
			else

				minetest.sound_play("exa2d_coin",{pos=pos2,gain=0.1,max_hear_distance=10})
				
				Coin(self.user,1)
				local cef = apos(pos2,0,2)
				if default.defpos(cef,"buildable_to") and not minetest.is_protected(cef, "") and not exa2d.is_item(cef) then
					minetest.set_node(cef,{name="exa2d:coin_effect",param2=above.param2})
				end
				self.user:hud_change(exa2d.user[self.username].ui_coins,"text",self.user:get_meta():get_int("coins"))
			end
		elseif not self.block_hit and v.y ~= 0 and above.name == "exa2d:block_empty" then
			self.block_hit = true
			minetest.sound_play("exa2d_blockhit",{pos=pos2,gain=1,max_hear_distance=10})
		end
		if cp then
			minetest.sound_play("exa2d_coin",{pos=pos2,gain=0.1,max_hear_distance=10})
			Coin(self.user,1)
			self.user:hud_change(exa2d.user[self.username].ui_coins,"text",self.user:get_meta():get_int("coins"))
			minetest.remove_node(cp)
		elseif self.block_hit and self.jump_timer <= 0 then
			self.block_hit = false
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

		if key.LMB or self.user:get_hp() <= 0 or not default.defpos(apos(pos2,self.dir.x,0,self.dir.z),"walkable") and not default.defpos(apos(pos2,self.dir.x,1,self.dir.z),"walkable") then
			exa2d.leave(self.user)
			return
		elseif key.sneak then
			exa2d.player_anim(self,"sit")
			if not self.sit then
				v.x=0
				v.z=0
				self.sit = true
				local cb = self.ob:get_properties().collisionbox
				cb[2] = -0.65
				cb[5] = 0.45
				self.ob:set_properties({collisionbox = cb})
			end

		elseif key.up and self.floating then
			v.y=4
		elseif key.up and v.y==0 and self.jump_timer <= 0 then
			self.jump_timer = 0.05
			v.y = self.jump_v
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
				v.y=6
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
			self.timer = 0
			exa2d.update_wielded_item(self)
			exa2d.mapgen(pos2,self.dir,self.fdir)
		end
		return self
	end,
	jump_v = 10,
	jump_timer = 0.5,
	block_hit = true,
	timer = 2,
	dmgtimer = 0,
	breath = 11,
	start = 0.1,
})

minetest.register_entity("exa2d:player",{
	hp_max = 20,
	physical = true,
	pointable = false,
	collisionbox = {-0.35,-1,-0.01,0.35,0.8,0.01},
	visual =  "mesh",
	mesh = "mt2d_character.b3d",
	textures = {"default_air.png","default_air.png"},
	is_visible = true,
	makes_footstep_sound = true,
	on_activate=function(self, staticdata)
		local rndlook={4.71,1.57}
		self.object:set_yaw(rndlook[math.random(1,2)])
		local p = self.object:get_pos()
		if p and p.y > 3000 and p.y < 4000 then
			self.object:set_acceleration({x=0,y=-6,z =0})
		else
			self.object:set_acceleration({x=0,y=-20,z =0})
		end
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
		if self.start > 0 then
			self.start=self.start-dtime
			return self
		elseif not (exa2d.user[self.username] and exa2d.user[self.username].id==self.id) then
			self.object:remove()
			return self
		end
	end,
	id=0,
	username="",
	start=0.1,
	timer=0,
})

minetest.register_entity("exa2d:enemy",{
	hp_max = 20,
	physical = true,
	pointable = false,
	collisionbox = {-0.6,-0.8,-0.01,0.6,0.3,0.01},
	visual_size = {x=0.01,y=1,z=1},
	visual =  "mesh",
	mesh = "examobs_wolf.b3d",
	textures = {"examobs_wolf.png"},
	is_visible = true,
	makes_footstep_sound = true,
	on_activate=function(self, staticdata)
		self.object:set_acceleration({x=0,y=-20,z =0})
		self.object:set_animation({x=11, y=32, },30,0)
		self.face = math.random(1,2)
		self.rot = 0
		self.move_dir = {
			[1]={
				["1 0"]={x=0,z=2,r=0},
				["-1 0"]={x=0,z=-2,r=3.14},
				["0 1"]={x=-2,z=0,r=1.57},
				["0 -1"]={x=2,z=0,r=4.71},
			},
			[2]={
				["1 0"]={x=0,z=-2,r=3.14},
				["-1 0"]={x=0,z=2,r=0},
				["0 1"]={x=2,z=0,r=4.71},
				["0 -1"]={x=-2,z=0,r=1.57},
			}
		}
		return self
	end,
	walk=function(self)
		local v = self.object:get_velocity()

		if v.x+v.z == 0 then
			self.face = self.face == 2 and 1 or 2
			local d = self.move_dir[self.face][self.dir.x.." "..self.dir.z]
			v.x = d.x
			v.z = d.z
			self.object:set_yaw(d.r)
			self.object:set_velocity(v)
			self.rot = d.r
		end
	end,
	on_step=function(self, dtime)
		if not self.dir or self.del and self.del < 0 then
			self.object:remove()
			return self
		elseif self.del then
			self.del = self.del -dtime
			return self
		end
		if self.hittimer < 0.5 then
			self.hittimer = self.hittimer + dtime
		end

		if not self.start then
			self.start = true
			if self.dir.x ~= 0 then
				self.object:set_properties({collisionbox = {-0.01,-0.8,-0.6,0.01,0.3,0.6}})
			end
		end

		self:walk()
		local pos = self.object:get_pos()

		for _, ob in pairs(minetest.get_objects_inside_radius(pos,2.5)) do
			local en = ob:get_luaentity()
			if en and en.name == "exa2d:player" then
				local p = ob:get_pos()
				local pf = vector.floor(p)
				local opf = vector.floor(pos)
				local d = vector.distance(p,pos)
				if p.y-1 > pos.y and d <=1.5 then
					local cb = self.object:get_properties().collisionbox
					cb[2] = -0.1
					cb[5] = 0.1
					self.object:set_properties({collisionbox = cb,visual_size = {x=0.01,y=0.15,z=1}})
					self.object:set_velocity({x=0,y=self.object:get_velocity().y,z=0})
					self.del = 0.5
					minetest.sound_play("exa2d_blockhit",{pos=pos,gain=1,max_hear_distance=10})
					minetest.sound_play("exa2d_coin",{pos=pos,gain=0.1,max_hear_distance=10})
					Coin(en.user,1)
					local cef = apos(pos,0,1)
					if default.defpos(cef,"buildable_to") and not minetest.is_protected(cef, "") and not exa2d.is_item(cef) then
						minetest.set_node(cef,{name="exa2d:coin_effect",param2=self.fdir})
					end
					break
				elseif pf.y == opf.y and vector.distance(pf,opf) < 1.5 and self.hittimer >= 0.5 then
					self.hittimer = 0
					exa2d.punch(ob,self.object,2)
				end
			end
		end

		if not default.defpos(apos(pos,self.dir.x,0,self.dir.z),"walkable") and not default.defpos(apos(pos,self.dir.x,1,self.dir.z),"walkable") then
			local ob = minetest.add_entity(apos(pos,self.dir.x*-0.5,1,-self.dir.z*0.5),"examobs:wolf")
			ob:set_yaw(self.rot)
			ob:set_velocity(self.object:get_velocity())
			examobs.anim(ob:get_luaentity(),"walk")
			self.object:remove()
			return self
		end
		if self.checktimer > 0 then
			self.checktimer = self.checktimer -dtime
		else
			self.checktimer = self.reset_checktimer
			if minetest.get_item_group(minetest.get_node(pos).name,"igniter") > 0 then
				self.object:remove()
				return self
			end

			local f
			for _, ob in pairs(minetest.get_objects_inside_radius(pos,10)) do
				local en = ob:get_luaentity()
				if en and en.name == "exa2d:player" then
					f = true
					break
				end
			end
			if not f then
				if n == "exa2d:inactive_item" or minetest.get_item_group(n,"exa2d_item") > 0 then
					local v = {x=0,y=math.random(-10,10),z=0}
					if self.dir.x ~= 0 then
						v.z = math.random(-5,5)
					else
						v.x = math.random(-5,5)
					end
					self.object:set_velocity(v)
					self.reset_checktimer = 0.1
					return
				end
				if exa2d.inactivate_item(pos,self) then
					self.object:remove()
					return self
				end
			end
		end
		return self
	end,
	hittimer = 0.5,
	checktimer = 0,
	reset_checktimer = 0.5,
})

minetest.register_entity("exa2d:item",{
	physical = true,
	pointable = false,
	collisionbox = {0,0,0,0,0,0},
	visual_size = {x=0.25,y=0.25,z=0.01},
	visual =  "wielditem",
	textures = {"default:vacuum"},
	is_visible = true,
	get_staticdata = function(self)
		return minetest.serialize({dir=self.dir, fdir=self.fdir, item=self.item:to_table()})
	end,
	on_activate=function(self, staticdata)
		self.object:set_acceleration({x=0,y=-20,z =0})
		self.id = math.random(1,9999)
		local d = minetest.deserialize(staticdata) or {}
		self.dir = d.dir
		self.fdir = d.fdir
		self.item = ItemStack(d.item or "")
		return self
	end,
	on_step=function(self, dtime)
		local pos = self.object:get_pos()

		if default.defpos(apos(pos,0,-0.5),"walkable") then
			local n = minetest.get_node(pos).name
			if n ~= "exa2d:inactive_item" and minetest.get_item_group(n,"exa2d_item") == 0 then
				self.object:set_velocity({x=0,y=self.object:get_velocity().y,z=0})
			end
		end

		if not self.item then
			self.object:remove()
			return self
		elseif not self.start then
			self.start = 0
			self.tool_item = minetest.registered_items[self.item:get_name()].type == "tool"
			self.object:set_yaw(self.face[self.dir.x.." "..self.dir.z])
			self.object:set_properties({textures={self.item:get_name()}})
			if self.dir.x ~= 0 then
				self.object:set_properties({collisionbox = {-0.01,-0.25,-0.25,0.01,0.25,0.25}})
			else
				self.object:set_properties({collisionbox = {-0.25,-0.25,-0.01,0.25,0.25,0.01}})
			end
			return
		elseif self.start < 0.5 then
			self.start = self.start + dtime
			return
		end

		for _, ob in pairs(minetest.get_objects_inside_radius(pos,1.5)) do
			local en = ob:get_luaentity()
			if en and en.name == "exa2d:player" then
				local inv = en.user:get_inventory()
				if inv:room_for_item("main",self.item) then
					inv:add_item("main",self.item)
					self.object:remove()
					minetest.sound_play("exa2d_item_pickup",{pos=pos,gain=0.2,max_hear_distance=10})
					return self
				end
			elseif not self.tool_item and en and en.name == "exa2d:item" and en.id ~= self.id then
				local n = en.item:get_name()
				if n == self.item:get_name() then
					local r = minetest.registered_items[n]
					local c1 = self.item:get_count()
					local c2 = en.item:get_count()
					if r.stack_max >= c1+c2 then
						en.item:set_count(c1+c2)
						self.object:remove()
						return self
					end
				end
			end
		end

		if not default.defpos(apos(pos,self.dir.x,0,self.dir.z),"walkable") then
			local ob = minetest.add_item(apos(pos,self.dir.x*-0.5,0,-self.dir.z*0.5),self.item)
			ob:set_velocity(self.object:get_velocity())
			self.object:remove()
			return self
		end
		if self.checktimer > 0 then
			self.checktimer = self.checktimer -dtime
		else
			self.checktimer = self.reset_checktimer
			local f
			for _, ob in pairs(minetest.get_objects_inside_radius(pos,10)) do
				local en = ob:get_luaentity()
				if en and en.name == "exa2d:player" then
					f = true
					break
				end
			end

			local n = minetest.get_node(pos).name

			if minetest.get_item_group(n,"igniter") > 0 then
				self.object:remove()
				return
			end

			if not f then
				if n == "exa2d:inactive_item" or minetest.get_item_group(n,"exa2d_item") > 0 then
					local v = {x=0,y=math.random(-10,10),z=0}
					if self.dir.x ~= 0 then
						v.z = math.random(-5,5)
					else
						v.x = math.random(-5,5)
					end
					self.object:set_velocity(v)
					self.reset_checktimer = 0.1
					return
				end
				if exa2d.inactivate_item(pos,self) then
					self.object:remove()
					return
				end
			end
		end
		return self
	end,
	face = {
		["1 0"] = 4.71,
		["-1 0"] = 1.57,
		["0 1"] = 3.14,
		["0 -1"] = 0,
	},
	reset_checktimer = 0.5,
	checktimer = 0,
})