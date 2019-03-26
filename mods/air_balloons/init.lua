minetest.register_tool("air_balloons:balloon", {
	description = "Air baloon",
	inventory_image = "air_balloons_item.png",
	--groups={not_in_creative_inventory=1},
	on_place=function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			local en=minetest.add_entity(pointed_thing.above,"air_balloons:balloon")
			en:get_luaentity().owner = user:get_player_name()
			itemstack:take_item()

		end
		return itemstack	
	end,
})

minetest.register_entity("air_balloons:balloon",{
	hp_max = 20,
	physical = true,
	--weight = 0,
	collisionbox = {-2,-0.5,-2,2,7,2},
	visual = "mesh",
	mesh = "air_balloons.obj",
	visual_size = {x=1,y=1},
	textures ={"air_balloons_material1.png"},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	--is_visible = true,
	makes_footstep_sound = true,
	on_rightclick=function(self, clicker,name)
		if clicker:is_player() and clicker:get_player_name() == self.owner then

			if self.user then
				self.user:set_detach()
				self.user = nil
			else
				self.user = clicker
				self.user:set_attach(self.object, "",{x = 0, y = -5, z = 0}, {x = 0, y = 0, z = 0})
			end
--e.user:get_attach()
--user:set_eye_offset({x = 0, y = -10, z = 5}, {x = 0, y = 0, z = 0})
--


			
			return self
		end




	end,


	on_punch=function(self,puncher)
		if puncher:is_player() and (self.owner == "" or (puncher:get_player_name() == self.owner)) then
			puncher:get_inventory():add_item("main","air_balloons:balloon")
	--		minetest.add_item(self.object:get_pos(),self.drop)
			self.object:remove()
			return self
		end
	end,
	on_activate=function(self, staticdata)
		self.owner = staticdata
		self.dir = {x=0,y=0,z=0}
		---if not aliveai_nitroglycerine.new_dust then self.object:remove() return self end
		--self.drop=aliveai_nitroglycerine.new_dust.drop
		--self.object:set_properties({textures = aliveai_nitroglycerine.new_dust.t})
		--self.object:set_acceleration({x=0,y=-10,z=0})
		--return self
	end,
	get_staticdata = function(self)
		return self.owner
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		if self.time<self.timer then return self end
		self.time=0
		if self.user then
			local d = self.user:get_look_dir()
			self.dir.x = d.x
			self.dir.z = d.z
			local key = self.user:get_player_control()


			if key.up then
				if self.speed <2 then
					self.speed = self.speed + 0.1
				end
				self.vset = true
			end
			if key.jump then
				if self.dir.y < 1 then
					self.dir.y = self.dir.y + 0.1
				end
				self.vset = true
			elseif key.sneak then
				if self.dir.y > -1 then
					self.dir.y = self.dir.y - 0.1
				end
				self.vset = true
			end
		end

		if not self.vset then

			if self.speed > 0.1 then
				self.speed = self.speed * 0.95
				self.rep = true
			end

			local p = self.object:get_pos()

			if self.dir.y > -0.1 and minetest.get_node({x=p.x,y=p.y-1,z=p.z}).name == "air" then
				self.dir.y = self.dir.y - 0.1
				self.rep = true
			elseif math.abs(self.dir.y) > 0.1 then
				self.dir.y = self.dir.y*0.95
				self.rep = true
			end
		end
		if not self.vset and not self.rep then
			self.speed = 0
			self.dir.y = 0
		end
		self.vset = nil
		self.rep = nil
		self.object:set_velocity({
			x=self.dir.x*self.speed,
			y=self.dir.y,
			z=self.dir.z*self.speed,
		})



--not in water


--[[

		
		if not self.rounded and x+y+z<1 then
			self.object:set_pos({x=math.floor(pos.x),y=math.floor(pos.y),z=math.floor(pos.z)})
			self.rounded=1
		end

		local u=minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name]
		if u and u.walkable then
			local n=minetest.registered_nodes[minetest.get_node(pos).name]
			if n and n.buildable_to and minetest.registered_nodes[self.drop] then
				minetest.set_node(pos,{name=self.drop})
				self.object:remove()
			else
				self.on_punch2(self)
			end
			return self
		elseif self.timer2<0 then
			self.on_punch2(self)
		end
		return self

--]]
	end,
	time=0,
	timer=0.1,
	timer2=10,
	speed=0,
	owner="",
})