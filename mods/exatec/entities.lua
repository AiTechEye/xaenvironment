minetest.register_entity("exatec:tubeitem",{
	visual="wielditem",
	visual_size={x=0.20,y=0.20},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	automatic_rotate = math.pi/3,
	exatec_item=true,
	get_staticdata = function(self)
		return minetest.serialize(self.storage)
	end,
	on_activate = function(self, staticdata)
		self.storage = minetest.deserialize(staticdata) or {}
		if self.storage.name then
			self.stack = ItemStack(self.storage.stack)
			self.object:set_properties({textures={self.storage.name}})
		end
	end,
	is_tube=function(self,pos)
		return minetest.get_item_group(minetest.get_node(pos).name,"exatec_tube") > 0
	end,
	is_connected=function(self,pos)
		return minetest.get_item_group(minetest.get_node(pos).name,"exatec_tube_connected") > 0
	end,
	new_item=function(self,stack,opos)
		local pos = self.object:get_pos()
		for i,d in pairs(exatec.tube_rules) do
			local npos = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			if (self:is_tube(npos) or self:is_connected(npos)) and not exatec.samepos(npos,opos) then
				self.storage.dir = d
				break
			end
		end
		self.stack = stack
		self.storage.stack = stack:to_table()
		self.storage.name = stack:get_name()
		self.storage.curpos = pos
		self.storage.oldpos = opos
		if not self.storage.dir then
			minetest.add_item(pos,stack)
			self.object:remove()
			return self
		end
		self.object:set_properties({textures={self.storage.name}})
		self.object:set_velocity(self.storage.dir)
		local def = exatec.def(pos)
		self.tube_activated = pos
		if def.on_tube then
			def.on_tube(pos,self.stack,opos,self.object)
		end
	end,
	input=function(self,pos)
		if exatec.test_input(pos,self.stack,self.storage.oldpos,self.storage.curpos) then
			local ap = {x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.5),z=math.floor(pos.z+0.5)}
			exatec.input(ap,self.stack,self.storage.oldpos,self.storage.curpos)
			self.object:remove()
			return self
		end
	end,
	on_step=function(self, dtime)
		if not self.storage.curpos then
			if self.storage.stack then
				minetest.add_item(pos,ItemStack(self.storage.stack))
			end
			self.object:remove()
			return
		end
		local pos = self.object:get_pos()
		local ap = {x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.5),z=math.floor(pos.z+0.5)}
		local npos = {x=ap.x+self.storage.dir.x,y=ap.y+self.storage.dir.y,z=ap.z+self.storage.dir.z}

		if self:is_connected(pos) and self:input(pos) then
			return self
		elseif not self:is_tube(pos) or not self.storage.curpos then
			if self.storage.stack then
				minetest.add_item(pos,ItemStack(self.storage.stack))
			end
			self.object:remove()
		elseif not exatec.samepos(ap,self.storage.curpos) then
			if not exatec.samepos(ap,self.tube_activated or pos) then
				if self:is_tube(ap) then
					local def = exatec.def(ap)
					self.tube_activated = ap
					if def.on_tube then
						def.on_tube(ap,self.stack,self.storage.oldpos,self.object)
					end
				end

			end
			if (self:is_tube(npos) or self:is_connected(npos)) and exatec.test_input(npos,self.stack,self.storage.oldpos,self.storage.curpos) then
				self.storage.oldpos = self.storage.curpos
				self.storage.curpos = ap
				self.object:set_velocity(self.storage.dir)
			else
				for i,d in pairs(exatec.tube_rules) do
					npos = {x=ap.x+d.x,y=ap.y+d.y,z=ap.z+d.z}
					if (self:is_tube(npos) or self:is_connected(npos)) and exatec.test_input(npos,self.stack,self.storage.oldpos,self.storage.curpos) and vector.distance(pos,ap) < 0.1 and not exatec.samepos(npos,self.storage.curpos) then
						self.storage.dir = d
						self.storage.oldpos = self.storage.curpos
						self.storage.curpos = ap
						self.object:set_velocity(d)
						self.object:set_pos(ap)
						break
					end
				end
			end
		end
	end,
})

minetest.register_entity("exatec:bow",{
	visual="wielditem",
	visual_size={x=0.30,y=0.30},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"default:bow_iron_loaded"},
	exatec_bow=true,
	exatec_item=true,
	get_staticdata = function(self)
		return minetest.serialize(self.dir)
	end,
	on_activate = function(self, staticdata)
		self.dir = minetest.deserialize(staticdata) or {x=0, y=0, z=0}
		if minetest.get_node(self.object:get_pos()).name ~= "exatec:bow" then
			self.object:remove()
		end
	end,
	lookat=function(self,pos2)
		if not pos2 then
			return
		end
		local pos1=self.object:get_pos()
		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))+(math.pi*0.7)
		if pos1.x >= pos2.x then y = y+math.pi end
		self.object:set_rotation({x=0,y=y,z=z})
		local d=vector.distance(pos1,pos2)--math.floor(+0.5)
		self.dir = {x=(pos1.x-pos2.x)/-d,y=((pos1.y-pos2.y)/-(d*2)),z=(pos1.z-pos2.z)/-d}
	end,
	shoot=function(self,stack)
		local pos = apos(self.object:get_pos(),0,-1.7)
		local user = {
			get_look_dir=function()
				return self.dir
			end,
			punch=function()
			end,
			get_pos=function()
				return pos
			end,
			set_pos=function(pos)
				return
			end,
			get_player_control=function()
				return {}
			end,
			get_look_horizontal=function()
				return self.object:get_yaw() or 0
			end,
			get_player_name=function()
				return ""
			end,
			is_player=function()
				return true
			end,
			object=self.object,
		}
		local item = ItemStack({
			name="default:bow_diamond_loaded",
			metadata=minetest.serialize({arrow=stack:get_name(),shots=stack:get_count()})
		})
		bows.shoot(item, user)
	end
})