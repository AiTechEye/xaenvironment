catchballs={type=0}

minetest.register_craft({
	output = "catchballs:catchball1",
	recipe = {
		{"default:gold_ingot","default:steel_ingot","default:gold_ingot"},
		{"default:steel_ingot","default:electric_lump","default:steel_ingot"},
		{"default:gold_ingot","default:steel_ingot","default:gold_ingot"},
	}
})

minetest.register_craft({
	output = "catchballs:catchball2",
	recipe = {
		{"default:gold_ingot","default:steel_ingot","default:gold_ingot"},
		{"default:steel_ingot","default:electricblock","default:steel_ingot"},
		{"default:gold_ingot","default:steel_ingot","default:gold_ingot"},
	}
})

minetest.register_entity("catchballs:catchball",{
	hp_max = 10,
	physical =true,
	weight = 1,
	collisionbox = {-0.2,-0.2,-0.2,0.2,0.2,0.2},
	visual = "wielditem",
	visual_size = {x=0.3,y=0.3},
	textures ={"catchballs:catchball1"},
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = true,
	automatic_rotate =3.14,
	kill=function(self)
		self.object:set_hp(0)
		self.object:punch(self.object, 100,{full_punch_interval=1.0,damage_groups={fleshy=4}})
		return self
	end,
	ret=function(self)
		local pos=self.object:get_pos()
		if not self.retur and self.meta then
			self.retur=1
			local e=minetest.add_entity({x=pos.x,y=pos.y+1,z=pos.z}, self.meta.name)
			local en=e:get_luaentity()
			if en.on_activate then
				en.on_activate(en,self.meta.data)
			end
			self.object:set_properties({physical=false})
			self.object:set_acceleration({x =0, y =0, z =0})
			minetest.add_particlespawner({
				amount = 40,
				time =0.5,
				minpos = pos,
				maxpos =pos,
				minvel = {x=-2, y=0, z=-2},
				maxvel = {x=2, y=2, z=2},
				minacc = {x=0, y=0, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 2,
				maxexptime = 1,
				minsize = 0.5,
				maxsize = 1,
				glow=10,
				texture = "catchballs_catchball.png^[colorize:#ffcf42ff",
			})
			local nod=minetest.registered_nodes[minetest.get_node(pos).name]
			if nod and nod.buildable_to==true then minetest.set_node(pos,{name="default:lightsource"}) end
		end
		if self.retur then
			local pos2=self.user:get_pos()
			pos2.y=pos2.y+1
			local v={x=(pos.x-pos2.x)*-4,y=(pos.y-pos2.y)*-4,z=(pos.z-pos2.z)*-4}
			self.object:set_velocity(v)
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 1.5)) do
				if ob:is_player() and ob:get_player_name()==self.user_name then
					ob:get_inventory():add_item("main", self.item)
					self.kill(self)
					return self
				end
			end
		end
		if self.timer<=0 then
			minetest.add_item(pos,self.item)
			self.kill(self)
			return self
		end
	end,
	on_activate=function(self, staticdata)
		self.type=catchballs.type
		self.item=catchballs.item
		self.object:set_properties({textures={self.item}})
		if self.type==1 then 
		elseif self.type==2 then
			self.user=catchballs.user
			self.meta=catchballs.meta
			self.user_name=self.user:get_player_name()
			self.rego=1
		elseif self.type==3 then
			self.user=catchballs.user
			self.user_name=self.user:get_player_name()
		else
			minetest.add_item(self.object:get_pos(),self.item)
			self.kill(self)
			return self
		end
		catchballs.type=0
		catchballs.user=nil
		catchballs.meta=nil
		catchballs.item=nil
		self.object:set_acceleration({x =0, y =-10, z =0})
		return self
	end,
	on_step=function(self, dtime)
		self.time=self.time-dtime
		if self.time>0 then return self end
		if self.catch and self.rego then
			self.timer=self.timer-dtime
			self.ret(self)
			return self
		end
		if self.object:get_velocity().y==0 and not self.catch then
			self.catch=1
			if self.type==2 then self.rego=1 end
			if self.rego then return end
			local pos=self.object:get_pos()
			local ob1
			local d1=10
			local d2=10
			local en1
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 5)) do
			local en=ob:get_luaentity()
			local pos2=ob:get_pos()
			d2=vector.distance(pos,pos2)
			if en and d2<d1 and en.type and en.type~="" and not en.catchball and en.itemstring==nil then
				ob1=ob
				en1=en
				d1=d2
			end
		end
		if not ob1 then
			if self.type==3 then
				self.object:set_properties({physical=false})
				self.retur=1
				self.rego=1
				self.object:set_acceleration({x =0, y =0, z =0})
				return
			end
			minetest.add_item(pos,self.item)
			self.kill(self)
			return self
		end
		local item=ItemStack(self.item):to_table()
		item.wear=1
		local data=""
		if en1.get_staticdata then
			data=en1.get_staticdata(en1)
		end
		if type(data)~="string" then data="" end
		item.meta.data=data
		item.meta.name=en1.name
		item.meta.description=en1.name


		en1.on_step=nil
		ob1:remove()
		if self.type==3 then
			self.object:set_properties({physical=false})
			self.retur=1
			self.rego=1
			self.item=item
			self.object:set_acceleration({x =0, y =0, z =0})
			return self
		end
		minetest.add_item(pos,item)
		self.kill(self)
		return self
	end
	end,
	time=0.2,
	timer=15,
	type="",
	catchball=1,
})

minetest.register_tool("catchballs:catchball1", {
	description = "Catch ball",
	range=1,
	inventory_image = "catchballs_catchball.png",
		on_use = function(itemstack, user, pointed_thing)
			if user.fakeplayer then return end
			local dir
			local pos
			if user:get_luaentity() then
				user=user:get_luaentity():get_luaentity()
				pos=user.object:get_pos()
				dir=catchballs.get_dir(pos,catchballs.pointat(user))
			else
				dir=user:get_look_dir()
				pos=user:get_pos()
			end
			local item=itemstack:to_table()
			catchballs.user=user
			if item.meta and item.meta.data then
				catchballs.type=2
				catchballs.meta=item.meta
			else
				catchballs.type=1
			end
			catchballs.item="catchballs:catchball1"
			pos.y=pos.y+1
			local v={x=dir.x*15,y=dir.y*15,z=dir.z*15}
			local e=minetest.add_entity(pos, "catchballs:catchball")
			e:set_velocity(v)
			itemstack:take_item()
			if user.inv and user.inv["catchballs:catchball1"] and type(user.inv["catchballs:catchball1"])=="number" then
				user.inv["catchballs:catchball1"]=user.inv["catchballs:catchball1"]-1
				if user.inv["catchballs:catchball1"]<=0 then user.inv["catchballs:catchball1"]=nil end
			end
			return itemstack
		end
})

minetest.register_tool("catchballs:catchball2", {
	description = "Master catch ball",
	inventory_image = "catchballs_catchball2.png",
		on_use = function(itemstack, user, pointed_thing)
			if user.fakeplayer then return end
			local dir
			local pos
			local item=itemstack:to_table()
			catchballs.user=user
			catchballs.item="catchballs:catchball2"
			if item.meta and item.meta.data then
				catchballs.type=2
				catchballs.meta=item.meta
			else
				catchballs.type=3
			end

			if user:get_luaentity() then
				catchballs.type=1
				user=user:get_luaentity():get_luaentity()
				pos=user.object:get_pos()
				dir=catchballs.get_dir(pos,catchballs.pointat(user))
			else
				dir=user:get_look_dir()
				pos=user:get_pos()
			end

			pos.y=pos.y+1
			local v={x=dir.x*15,y=dir.y*15,z=dir.z*15}
			local e=minetest.add_entity(pos, "catchballs:catchball")
			e:set_velocity(v)
			itemstack:take_item()
			if user.inv and user.inv["catchballs:catchball2"] and type(user.inv["catchballs:catchball2"])=="number" then
				user.inv["catchballs:catchball2"]=user.inv["catchballs:catchball2"]-1
				if user.inv["catchballs:catchball2"]<=0 then user.inv["catchballs:catchball2"]=nil end
			end
			return itemstack
		end
})

catchballs.pointat=function(self)
	local pos=self.object:get_pos()
	local yaw=self.object:get_yaw()
	if yaw ~= yaw or type(yaw)~="number" then
		yaw=0
	end
	local x =math.sin(yaw) * -1
	local z =math.cos(yaw) * 1
	return {x=pos.x+x,y=pos.y,z=pos.z+z}
end

catchballs.get_dir=function(pos1,pos2)
	local d=math.floor(vector.distance(pos1,pos2)+0.5)
	return {x=(pos1.x-pos2.x)/-d,y=(pos1.y-pos2.y)/-d,z=(pos1.z-pos2.z)/-d}
end

