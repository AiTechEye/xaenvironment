minetest.register_entity("exatec:tubeitem",{
	visual="wielditem",
	visual_size={x=0.20,y=0.20},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	timer = 0,
	get_staticdata = function(self)
		return minetest.serialize(self.storage)
	end,
	on_activate = function(self, staticdata)
		self.storage = minetest.deserialize(staticdata) or {}
		self.storage.oldpos = self.object:get_pos()
		if self.storage.name then
			self.stack = ItemStack(self.storage.stack)
			self.object:set_properties({textures={self.storage.name}})
		end
	end,
	new_item=function(self,stack,dir)
		self.stack = stack
		self.storage.stack = stack:to_table()
		self.storage.name = stack:get_name()
		self.storage.dir = dir
		self.object:set_properties({textures={self.storage.name}})
		self.object:set_velocity(dir)
	end,
	on_step=function(self, dtime)
		self.timer = self.timer +dtime
		local pos = self.object:get_pos()
		if self.timer > 0.5 then
			self.timer = 0
			if minetest.get_item_group(minetest.get_node(pos).name,"exatec_tube") == 0 or not self.storage.dir then
				if self.storage.stack then
					minetest.add_item(pos,ItemStack(self.storage.stack))
				end
				self.object:remove()
				return
			end
		end

		local ap = {x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.5),z=math.floor(pos.z+0.5)}
		for i,d in pairs(exatec.tube_rules) do
			local t = {x=ap.x+d.x,y=ap.y+d.y,z=ap.z+d.z}
			local e = exatec.def(t)
			if minetest.get_item_group(minetest.get_node(t).name,"exatec_tube") == 1 and vector.distance(t,self.storage.oldpos) > 1 and vector.distance(pos,ap) < 0.2 then
				self.storage.oldpos = ap
				self.object:set_velocity(d)
				if vector.distance(self.storage.dir,d) > 0 then
					self.storage.dir = d
					self.object:set_pos(ap)
				end
				return
			elseif e and e.input_list and exatec.test_input(t,self.stack) then
				exatec.input(t,self.stack)
				self.object:remove()
				return
			end
		end
	end,
})