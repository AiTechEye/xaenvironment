minetest.register_entity("exatec:tubeitem",{
	visual="wielditem",
	visual_size={x=0.20,y=0.20},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	automatic_rotate = math.pi/3,
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
	new_item=function(self,stack,opos)
		local pos = self.object:get_pos()
		for i,d in pairs(exatec.tube_rules) do
			local npos = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			if minetest.get_item_group(minetest.get_node(npos).name,"exatec_tube") > 0 and not exatec.samepos(npos,opos) then
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
	end,
	input=function(self,pos)
		if exatec.test_input(pos,self.stack,self.storage.oldpos) then
			local ap = {x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.5),z=math.floor(pos.z+0.5)}
			exatec.input(ap,self.stack,self.storage.oldpos)
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
		local node = minetest.get_node(pos).name
		if node ~= "exatec:tube" and self:input(pos) then
			return self
		elseif minetest.get_item_group(node,"exatec_tube") == 0 or not self.storage.curpos then
			if self.storage.stack then
				minetest.add_item(pos,ItemStack(self.storage.stack))
			end
			self.object:remove()
		elseif not exatec.samepos(ap,self.storage.curpos) then
			if minetest.get_item_group(minetest.get_node(npos).name,"exatec_tube") > 0 then
				self.storage.oldpos = self.storage.curpos
				self.storage.curpos = ap
				self.object:set_velocity(self.storage.dir)
			else
				for i,d in pairs(exatec.tube_rules) do
					npos = {x=ap.x+d.x,y=ap.y+d.y,z=ap.z+d.z}
					if minetest.get_item_group(minetest.get_node(npos).name,"exatec_tube") > 0 and vector.distance(pos,ap) < 0.1 and not exatec.samepos(npos,self.storage.curpos) then
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