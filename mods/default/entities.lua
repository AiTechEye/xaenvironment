local builtin_item = minetest.registered_entities["__builtin:item"]

local item = {
	get_staticdata = function(self)
		local s1 = builtin_item.get_staticdata(self) or ""
		local s2 = minetest.deserialize(s1)
		s2.just_spawned = self.just_spawned
		return minetest.serialize(s2)
	end,
	on_rightclick=default.pickupable,
	on_activate=function(self,staticdata,dtime_s)
		builtin_item.on_activate(self,staticdata,dtime_s)
		local pos = self.object:get_pos()
		self.gravity = 9
		if pos then
			local def = minetest.registered_items[minetest.get_node(pos).name]
			if def and not self.in_viscosity and def.liquid_viscosity > 0 then
				self.spawn_in_viscosity = true
			end
		end
		local d = minetest.deserialize(staticdata) or {}
		self.just_spawned = d.just_spawned

		for i,v in pairs(multidimensions.registered_dimensions) do
			if pos.y >= v.dim_y and pos.y <= v.dim_y+v.dim_height then
				local acc = self.object:get_acceleration()
				acc.y = acc.y*v.gravity
				self.object:set_acceleration(acc)
				self.gravity = acc.y
				break
			end
		end
	end,
	burn = function(self)
		default.smoke(self.object:get_pos(),{item=true})
	end,
	on_punch = function(self,hitter)
		if hitter:is_player() then
			local c = 1
			local stack = ItemStack(self.itemstring)
			if minetest.get_item_group(stack:get_name(),"coin") > 0 then
				Coin(hitter,stack:get_count())
				self.object:remove()
				return self
			end
		end
		builtin_item.on_punch(self,hitter)
	end,
	on_detach = function(self,parent)
		self.physical_state = false
		self:enable_physics()
		self.nodetriggerd = nil
	end,
	on_step = function(self,dtime,moveresult)
		local pos = self.object:get_pos()

		if pos and not self.object:get_attach() then
			if not self.nodetriggerd and moveresult and moveresult.collides then
				self.nodetriggerd = true
				for i,v in pairs(moveresult.collisions) do
					if v.type == "node" then
						local def = default.def(minetest.get_node(v.node_pos).name)
						if def.on_item_touch then
							def.on_item_touch(v.node_pos,self.object)
							if not self.object:get_luaentity() then
								return
							else
								break
							end
						end
					end
				end
			end

			if self.age > 2 and self.moveto_object and not not self.just_spawned then
				local pos = self.object:get_pos()
				local obpos = self.moveto_object:get_pos()

				self.moveto_startpos = self.moveto_startpos or pos

				if obpos then
					obpos = self.moveto_object:is_player() and apos(obpos,0,0.5) or obpos
					local d = vector.distance(pos,obpos)
					if d < 0.2 then
						self:on_punch(self.moveto_object)
						return
					elseif d < 3 then
						self.object:set_acceleration({x=0, y=0, z=0})
						local v = vector.distance(obpos,self.moveto_startpos)*2
						self.object:set_velocity(vector.multiply(vector.subtract(obpos,pos),v))
						return
					else
						self.object:set_acceleration({x=0, y=-self.gravity, z=0})
						self.moveto_object = nil
						self.moveto_startpos = nil
					end
				end
			end

			builtin_item.on_step(self,dtime,moveresult)
		end

		if not pos then
			self.object:remove()
			return self
		elseif not self.just_spawned then
			self.just_spawned = true
			for _,v in pairs(default.registered_item_drops) do
				v(pos,self.itemstring,self.object,self.dropped_by)
			end
		end
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
			self.smoketimer = (self.smoketimer or 0) -dtime
			self.igniter_burn_timer = self.igniter_burn_timer + igniter*self.heat_sensitivity
			if self.igniter_burn_timer > 10 then
				self.object:remove()
				return
			elseif self.smoketimer <= 0 then
				self.burn(self)
				self.smoketimer = 1
			end
		end

		if def and not self.in_viscosity and def.liquid_viscosity>0 then
			local s = def.liquid_viscosity
			local v = self.object:get_velocity() or {x=0, y=0, z=0}
			if not self.spawn_in_viscosity then
				if minetest.get_item_group(def.name,"water") > 0 then
					default.watersplash(pos,true)
				elseif minetest.get_item_group(def.name,"lava") > 0 then
					minetest.sound_play("default_clay_step", {object=self.object, gain = 4,max_hear_distance = 10})
				end
			end
			if self.flammable == 0 then
				self.object:set_velocity({x=math.floor((v.x*0.95)*100)/100, y=(math.abs(v.y)*-1)*0.1, z=math.floor((v.z*0.95)*100)/100})
				self.object:set_acceleration({x=0, y=0, z=0})

			else
				self.object:set_velocity({x=math.floor((v.x*0.95)*100)/100, y=v.y, z=math.floor((v.z*0.95)*100)/100})
				self.object:set_acceleration({x=0, y=self.flammable*4, z=0})
			end
			self.in_viscosity = true
		elseif self.in_viscosity then
			if default.flowing(self.object) then
				return
			elseif def.liquid_viscosity == 0 then
				self.object:set_acceleration({x=0, y=0, z=0})
				self.object:set_velocity({x=0, y=0 , z=0})
			elseif self.flammable == 0 then
				local def2 = minetest.registered_items[minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name]
				local v = self.object:get_velocity() or {x=0,y=0,z=0}

				if v.y == 0 and def2 and not def2.walkable then
					v.y = -0.3
				elseif v.y == 0 and def2 and def2.walkable then
					v.x = 0
					v.z = 0
				end
				self.object:set_velocity({x=math.floor((v.x*0.95)*100)/100, y=v.y, z=math.floor((v.z*0.95)*100)/100})
			end
		end

		if self.dropped_by and not self.trash and not self.igniter_burn_timer and self.age > 30 and moveresult and moveresult.touching_ground then
			self.trash = 1
			local itemstack = ItemStack(self.itemstring)
			local fn = minetest.find_node_near(pos,1.5,"group:trashbag",true)

			if fn then
				local inv = minetest.get_meta(fn):get_inventory()
				if inv:room_for_item("main",itemstack) then
					inv:add_item("main",itemstack)
					minetest.registered_items["default:trashbag1"].update(fn)
					self.object:remove()
					return
				else
					for i=3,1,-1 do
						local fn2 = minetest.find_node_near(pos,1.5,"default:trashbag"..i,true)
						local inv = fn2 and minetest.get_meta(fn2):get_inventory()
						if fn2 and inv:room_for_item("main",itemstack) then
							inv:add_item("main",itemstack)
							minetest.registered_items["default:trashbag1"].update(fn2)
							self.object:remove()
							return
						end
					end
				end
			end

			local air = minetest.find_node_near(pos,1.5,"air",true)
			if default.defpos(pos,"buildable_to") and not minetest.is_protected(pos, self.dropped_by or "") then
				minetest.set_node(pos,{name="default:trashbag1"})
				minetest.get_meta(pos):get_inventory():add_item("main",itemstack)
				minetest.registered_items["default:trashbag1"].update(pos)
				self.object:remove()
				return
			elseif air and not minetest.is_protected(air, self.dropped_by or "") then
				minetest.set_node(air,{name="default:trashbag1"})
				minetest.get_meta(air):get_inventory():add_item("main",itemstack)
				minetest.registered_items["default:trashbag1"].update(air)
				self.object:remove()
				return
			end
		end
	end
}

setmetatable(item,builtin_item)
minetest.register_entity(":__builtin:item",item)

local builtin_falling_node = minetest.registered_entities["__builtin:falling_node"]
node = {
	set_node=function(self,node,meta)
		builtin_falling_node.set_node(self,node,meta)
		self.itemstring = node.name
		local def = default.def(self.itemstring)
		local s = def.sounds or {}
		self.damage = def.damage_per_second or 0
		self.damage = self.damage > 0 and self.damage or nil
		self.sound = (s.dug and s.dug.name) or (s.dig and s.dig.name) or (s.footstep and s.footstep.name) or (s.place and s.place.name)

		local pos = self.object:get_pos()
		if pos and minetest.find_node_near(pos,1,"group:on_update") then
			for i, p in pairs(minetest.find_nodes_in_area(vector.subtract(pos, 1),vector.add(pos,1),{"group:on_update"})) do
				local def=default.def(minetest.get_node(p).name)
				if def.on_update then
					def.on_update(p)
				end
			end
		end
	end,
	on_activate=function(self,staticdata)
		builtin_falling_node.on_activate(self,staticdata)
		local pos = self.object:get_pos()
		if pos then
			local def = minetest.registered_items[minetest.get_node(pos).name]
			if def and not self.in_viscosity and def.liquid_viscosity > 0 then
				self.in_viscosity = true
			end
		end
	end,
	on_step=function(self,dtime,moveresult)
		builtin_falling_node.on_step(self,dtime,moveresult)
		local pos = self.object:get_pos()
		if pos then
			local def = minetest.registered_items[minetest.get_node(pos).name]
			if def and not self.in_viscosity and def.liquid_viscosity > 0 then
				self.in_viscosity = true
				if minetest.get_item_group(def.name,"water") > 0 then
					default.watersplash(pos)
				elseif minetest.get_item_group(def.name,"lava") > 0 then
					minetest.sound_play("default_clay_step", {object=self.object, gain = 4,max_hear_distance = 10})
				end
			end	
		end
		if pos and self.damage then
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos,1)) do
				local en = ob:get_luaentity()
				if not (en and en.itemstring) then
					default.punch(ob,self.object,self.damage)
					if ob:get_hp() > 0 then
						self.object:remove()
						if self.sound then
							minetest.sound_play(self.sound, {pos=pos, gain = 1})
						end
						minetest.add_item(pos,self.itemstring)
						return self
					end
				end
			end
		end
	end
}

setmetatable(node,builtin_falling_node)
minetest.register_entity(":__builtin:falling_node",node)

minetest.register_entity("default:item",{
	physical = false,
	collisionbox = {0,0,0,0,0,0},
	visual = "wielditem",
	visual_size = {x=0.3,y=0.3},
	textures = {"default:stick"},
	decoration=true,
	new_itemframe=function(self)
		local pos = self.object:get_pos()
		local node = minetest.get_node(pos)
		local p = node.param2
		local c = {
			[1]={x=0.45,z=0},
			[3]={x=-0.45,z=0},
			[2]={x=0,z=-0.45},
			[0]={x=0,z=0.45}
		}

		c = c[p]

		self.storage.itemframe = minetest.get_meta(pos):get_string("item")
		self.object:set_yaw(p*(6.28*-0.25))
		self.object:set_pos({x=pos.x+c.x,y=pos.y,z=pos.z+c.z})
		self.itemframe(self)
	end,
	itemframe=function(self)
		if minetest.get_item_group(minetest.get_node(self.object:get_pos()).name,"itemframe") == 0 then
			self.object:remove()
		else
			self.object:set_properties({
				textures={self.storage.itemframe},
				visual_size = {x=0.4,y=0.4,z=0.01},
			})
		end
	end,
	on_activate=function(self, staticdata)
		self.storage = minetest.deserialize(staticdata) or {}
		if self.storage.itemframe then
			self.itemframe(self)
		end
	end,
	get_staticdata = function(self)
		return minetest.serialize(self.storage)
	end,
})

minetest.register_entity("default:wielditem",{
	physical = false,
	pointable = false,
	visual = "wielditem",
	visual_size = {x=0.4,y=0.4},
	textures = {"default:stick"},
	static_save = false,
	decoration=true,
})

minetest.register_entity("default:watersplash_ring",{
	physical = false,
	pointable=false,
	visual="cube",
	visual_size = {x=0,y=0,z=0},
	textures = {"default_watersplash_ring.png","default_air.png"},
	size2 = 1.5,
	size1 = 0.5,
	speed = 2,
	object_use_texture_alpha="blend",
	decoration=true,
	static_save = false,
	on_step=function(self, dtime)
		self.size1 = self.size1 + dtime*self.speed
		self.object:set_properties({
			visual_size = {x=self.size1,y=0,z=self.size1},
		})
		if self.size1 > self.size2 then
			self.object:remove()
		end
	end,
})

minetest.register_entity("default:skeleton",{
	physical = true,
	visual="mesh",
	mesh = "examobs_skeleton.b3d",
	textures = {"bones_bone3.png","default_air.png"},
	collisionbox = {-0.35,-1.1,-0.35,0.35,0.8,0.35},
	decoration=true,
	static_save = false,
	from_character=function(self,ob)
		local p = ob:get_properties()
		if p.mesh == "character.b3d" then
			self.object:set_properties({
				visual_size = p.visual_size
			})
			if ob:get_luaentity() then
				self.object:set_yaw(ob:get_yaw())
			else
				self.object:set_yaw(ob:get_look_horizontal())
			end
			local pos = self.object:get_pos()
			self.object:set_pos(apos(pos,0,1))
		else
			self.object:remove()
		end
	end,
	on_activate=function(self, staticdata)
		self.object:set_acceleration({x=0,y=-10,z =0})
		self.t = 10
	end,
	on_step=function(self, dtime)
		self.t = self.t - dtime
		if self.t < 0 then
			self:cruch(self)
		end
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		self:cruch(self)
	end,
	cruch=function(self)
		local pos = self.object:get_pos()
		minetest.add_particlespawner({
			amount = 40,
			time = 0.1,
			minpos = vector.add(pos,0.5,1,0.5),
			maxpos = vector.subtract(pos,0.5,1,0.5),
			minvel = {x=-5, y=0, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=0, y=-10, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 1,
			maxsize = 5,
			texture = "bones_bone.png",
			collisiondetection = true,
		})
		self.object:remove()
	end
})