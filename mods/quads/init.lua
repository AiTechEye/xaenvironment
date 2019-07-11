quads={}

apos=function(pos,x,y,z)
	return {x=pos.x+(x or 0),y=pos.y+(y or 0),z=pos.z+(z or 0)}
end

minetest.register_node("quads:quad", {
	stack_max=1,
	description="Quad",
	drawtype="mesh",
	mesh="quads_quad.b3d",
	tiles={"quads_quad1.png","quads_quad1.png"},
	groups = {dig_immediate = 3},
	wield_scale={x=0.1,y=0.1,z=0.1},
	visual_scale = 0.1,
	param2="facedir",
	on_place = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" and not minetest.is_protected(pointed_thing.above,user:get_player_name()) then
			local pos = pointed_thing.above
			pos.y=pos.y+0.5
			minetest.add_entity(pos, "quads:quad"):set_yaw(user:get_look_yaw() - math.pi/2)
			itemstack:take_item()
		end
		return itemstack
	end,
})

minetest.register_entity("quads:quad",{
	hp_max = 100,
	physical = true,
	collisionbox = {-0.75,-0.45,-0.75,0.75,0.4,0.75},
	visual="mesh",
	mesh="quads_quad.b3d",
	textures={"quads_quad1.png","quads_quad1.png"},
	visual_size = {x=1,y=1},
	makes_footstep_sound = true,
	type="npc",
	speed = 0,
	jump = 0,
	timer = 0,
	stepheight = 1.5,
	anim=function(self,s)
		if self.an ~= s then
			self.an = s
			self.object:set_animation({x=0,y=40},s*10,0)
		end
	end,
	on_rightclick=function(self, clicker)
		if self.user and self.user:get_player_name() == self.user_name then
			self.user:set_detach()
			self.user = nil
			self.user_name = nil
		else
			self.user = clicker
			self.user_name = clicker:get_player_name()
			self.user:set_attach(self.object, "",{x = 0, y = -5, z = 0}, {x = 0, y = 0, z = 0})
		end
		return self
	end,
	on_activate=function(self, staticdata)
		self.object:set_acceleration({x=0,y=-10,z =0})
		self.quad = math.random(1,9999)
	end,
	node_timer=function(self,dtime)
		self.timer = self.timer + dtime
		if self.timer > 1 then
			self.timer = 0
			local n = default.def(minetest.get_node(self:pos()).name)
			if (n.damage_per_second or 0) > 0 then
				self:hurt(n.damage_per_second)
			elseif not self.viscosity and (n.liquid_viscosity or 0) > 0 then
				self.viscosity = true
				self.object:set_acceleration({x=0,y=-10/(n.liquid_viscosity*2),z =0})
			elseif self.viscosity and n.liquid_viscosity == 0 then
				self.viscosity = nil
				self.object:set_acceleration({x=0,y=-10,z =0})
			end
		end
	end,
	showtext=function(self,text,color)
		self.delstatus=math.random(0,1000) 
		local del=self.delstatus
		color=color or "ff0000"
		self.object:set_properties({nametag=text,nametag_color="#" ..  color})
		minetest.after(1, function(self,del)
			if self and self.object and self.delstatus==del then
				self.delstatus = nil
				self.object:set_properties({nametag="",nametag_color=""})
			end
		end, self,del)
		return self
	end,
	hurt=function(self,d)
		d = self.object:get_hp() - d or 1
		self.object:set_hp(d)
		self:showtext(d .. "/" .. self.hp_max,"F00")
		local pos = self:pos()
		if minetest.get_item_group(minetest.get_node(pos).name, "igniter") > 0 then
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
				minsize = 5,
				maxsize = 10,
				texture = "default_item_smoke.png",
				collisiondetection = true,
			})
		end
		if d <= 0 then
			self.object:remove()
			nitroglycerin.explode(pos,{radius=3,set="fire:basic_flame"})
		end
	end,
	pos=function(self)
		return self.object:get_pos()
	end,
	yaw=function(self)
		local a = self.object:get_yaw()
		return (a == math.huge or a == -math.huge or a ~= a) == false and a or 0
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if puncher:is_player() and not self.user then
			local inv = puncher:get_inventory()
			if inv:room_for_item("main","quads:quad") then
				inv:add_item("main","quads:quad")
				self.object:remove()
			end
		else
			self:hurt(tool_capabilities.damage_groups.fleshy or 1)
		end
	end,
	on_step=function(self,dtime)
		local v = self.object:get_velocity()

		if not self.user and self.speed == 0 and v.y == 0 then
			self:node_timer(dtime)
			return
		end

		local key = self.user and self.user:get_player_control() or {}

		if key.left then
			local r = self.object:get_rotation()
			self.object:set_rotation({x=r.x,y=r.y+0.1,z=r.z})
		elseif key.right then
			local r = self.object:get_rotation()
			self.object:set_rotation({x=r.x,y=r.y-0.1,z=r.z})
		end

		if key.up and self.speed < 20 then
			self.speed = self.speed + 0.2
		elseif key.down and self.speed > -5 and not self.falling then
			self.speed = self.speed - 0.2
		elseif key.sneak and not self.falling  then
			self.speed = math.abs(self.speed) > 1 and self.speed * 0.95 or 0
		elseif self.speed ~= 0 then
			self.speed = math.abs(self.speed) > 1 and self.speed * 0.99 or 0
		end

		self.speed = math.abs(self.speed) > 0.1 and math.floor(self.speed*1000)*0.001 or 0

		self:anim(self.speed)

		local yaw = self:yaw()
		local X = (math.sin(yaw) * -1)
		local Z = (math.cos(yaw) * 1)
		local x = X * self.speed
		local z = Z * self.speed
		local p = self:pos()
		local ap = apos(p,X,0,Z)
		local walku = walkable(apos(p,0,-1,0))

		if not walku then
			local r = self.object:get_rotation()
			if key.down and key.aux1 then
				self.object:set_rotation({x=r.x-0.1,y=r.y,z=r.z})
				self.rotation = true
			elseif key.up and key.aux1 then
				self.object:set_rotation({x=r.x+0.1,y=r.y,z=r.z})
				self.rotation = true
			end
		end

		if walku or v.y >= -0.1 then
			local r = self.object:get_rotation()
			if self.falling then
				local dmg = math.floor(self.falling-p.y)*10
				if self.user and math.abs(r.x) > 1.3 and math.abs(r.x) < 5 then
					dmg = dmg*10
					default.punch(self.user,self.object,dmg)
				end
				if self.falling-p.y > 7 then
					self:hurt(dmg)
				end
				self.falling = nil
			end
			if walku and self.rotation and v.y <= 0.1 then
				self.rotation = nil
				self.object:set_rotation({x=0,y=r.y,z=r.z})
			end
		end

		if walkable(ap) then
			if walkable(apos(p,X,1,Z)) then
				x = 0
				z = 0
				self.speed = 0
			else
				self.rotation = true
				local r = self.object:get_rotation()
				self.object:set_rotation({x=0.785,y=r.y,z=r.z})
				self.jump = self.jump + self.jump< 3 and self.speed*0.1 or 0
			end
		else
			self.jump =  0
		end

		if not self.falling and (v.y < 0 or not walku) then
			self.falling = p.y
		elseif self.falling and v.y > -10 then
			self.falling = nil
		end

		if self.falling and math.abs(self.object:get_rotation().x) >=6.28 then
			local r = self.object:get_rotation()
			self.object:set_rotation({x=0,y=r.y,z=r.z})
		end

		self:node_timer(dtime)

		self.object:set_velocity({
			x=x,
			y=v.y + self.jump,
			z=z,
		})

		if self.speed > 4 then
			for _, ob in ipairs(minetest.get_objects_inside_radius(ap, 1)) do
				local en = ob:get_luaentity()
				if not (self.user_name and ob:is_player() and ob:get_player_name() == self.user_name or en and (en.quad == self.quad or en.item_string)) then
					if en then
						ob:set_velocity({x=x*2,y=ob:get_velocity().y,z=z*2})
						if not en.dead then
							default.punch(ob,self.object,self.speed)
						end
					else
						default.punch(ob,self.object,self.speed)
					end
				end
			end
		end
	end
})