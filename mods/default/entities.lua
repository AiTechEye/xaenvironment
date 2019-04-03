local builtin_item = minetest.registered_entities["__builtin:item"]

local item = {
	burn_up = function(self)
		local pos = self.object:get_pos()
		self.object:remove()
		minetest.add_particlespawner({
			amount = math.random(3,7),
			time =0.2,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-0.1, y=0, z=-0.1},
			maxvel = {x=0.1, y=1, z=0.1},
			minacc = {x=0, y=2, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 1,
			maxexptime = 5,
			minsize = 2,
			maxsize = 5,
			texture = "default_item_smoke.png",
			collisiondetection = true,
		})
	end,
	on_step = function(self,dtime)
		builtin_item.on_step(self,dtime)

		local pos = self.object:get_pos()
		local n = minetest.get_node(pos).name
		local igniter = minetest.get_item_group(n,"igniter")
		local def = minetest.registered_items[n]

		if not self.flammable then
			local count = string.find(self.itemstring," ")
			local item = self.itemstring
			if count ~= nil then
				item = string.sub(item,1,count-1)
			end

			self.flammable = minetest.get_item_group(item,"flammable")
		end

		if igniter > 0 then
			if not self.igniter_burn_timer then
				if self.flammable == 0 then
					self.heat_sensitivity = 0.01
				else
					self.heat_sensitivity = self.flammable
				end
				self.igniter_burn_timer = 0
			end
			self.igniter_burn_timer = self.igniter_burn_timer + igniter*self.heat_sensitivity
			if self.igniter_burn_timer > 10 then
				self.burn_up(self)
				return
			end
		end

		if not self.in_viscosity and def.liquid_viscosity>0 then
			local s = def.liquid_viscosity
			local v = self.object:get_velocity()
			if self.flammable == 0 then
				self.object:set_velocity({x=math.floor((v.x*0.95)*100)/100, y=(math.abs(v.y)*-1)*0.1, z=math.floor((v.z*0.95)*100)/100})
				self.object:set_acceleration({x=0, y=0, z=0})

			else
				self.object:set_velocity({x=math.floor((v.x*0.95)*100)/100, y=v.y, z=math.floor((v.z*0.95)*100)/100})
				self.object:set_acceleration({x=0, y=self.flammable*4, z=0})
			end
			self.in_viscosity = true
		elseif self.in_viscosity then
			if def.liquid_viscosity == 0 then
				self.object:set_acceleration({x=0, y=0, z=0})
				self.object:set_velocity({x=0, y=0 , z=0})
			elseif self.flammable == 0 then
				local def2 = minetest.registered_items[minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name]
				local v = self.object:get_velocity()

				if v.y == 0 and def2 and not def2.walkable then
					v.y = -0.3
				elseif v.y == 0 and def2 and def2.walkable then
					v.x = 0
					v.z = 0
				end
				self.object:set_velocity({x=math.floor((v.x*0.95)*100)/100, y=v.y, z=math.floor((v.z*0.95)*100)/100})
			end
		end
	end
}

setmetatable(item,builtin_item)
minetest.register_entity(":__builtin:item",item)