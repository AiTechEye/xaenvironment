if 1 then return end -- coming nowhere, working on it later

minetest.register_node("exacarts:rail", {
	description = "Rail",
	drawtype="raillike",
	walkable=false,
	inventory_iamge="exacarts_straight.png",
	tiles={"exacarts_straight.png","exacarts_curve.png","exacarts_junction.png","exacarts_cross.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,treasure=1,flammable=3,rail=1},
	sounds =  default.node_sound_metal_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.49, 0.5},
		}
	}
})

minetest.register_tool("exacarts:cart", {
	description = "Cart",
	inventory_image = "default_wood.png",
	on_place=function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" and minetest.get_item_group(minetest.get_node(pointed_thing.under).name,"rail") > 0 then
			local en=minetest.add_entity(pointed_thing.under,"exacarts:cart")
			itemstack:take_item()
		end
		return itemstack	
	end,
})

minetest.register_entity("exacarts:dotb",{
	physical = false,
	pointable=false,
	visual_size = {x=0,y=0,z=0},
	textures = {"player_style_coin.png^[colorize:#00f"},
	use_texture_alpha=true,
	t=0.5,
	on_step=function(self, dtime)
		self.t = self.t -dtime
		if self.t < 0 then
			self.object:remove()
		end
	end,
})

minetest.register_entity("exacarts:dotr",{
	physical = false,
	pointable=false,
	visual_size = {x=0,y=0,z=0},
	textures = {"player_style_coin.png^[colorize:#00f"},
	use_texture_alpha=true,
	t=0.5,
	on_step=function(self, dtime)
		self.t = self.t -dtime
		if self.t < 0 then
			self.object:remove()
		end
	end,
})

minetest.register_entity("exacarts:dotg",{
	physical = false,
	pointable=false,
	visual_size = {x=0,y=0,z=0},
	textures = {"player_style_coin.png^[colorize:#0f0"},
	use_texture_alpha=true,
	t=0.5,
	on_step=function(self, dtime)
		self.t = self.t -dtime
		if self.t < 0 then
			self.object:remove()
		end
	end,
})


minetest.register_entity("exacarts:cart",{
	physical = false,
	hp_max = 100000,
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	visual = "cube",
	--visual_size = {x=0.3,y=0.3},
	textures = {"default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png"},
	on_activate=function(self, staticdata)
		--self.storage = minetest.deserialize(staticdata) or {}
		--if self.storage.itemframe then
		--	self.itemframe(self)
		--end
		--self.object:set_acceleration({x=0, y=-10, z =0})
		self.map = {}
		self.explores = {vector.round(self.object:get_pos())}
		--self.get_rails_loop(self)



		self.index = {}
		self.index_list={}
		self.index_cur=""
		self.next_pos = {x=0,y=0,z=0}
		self.dir = {x=0,y=0,z=0}
		self.olddir = {x=0,y=0,z=0}
		self.v = 0
	end,
	get_staticdata = function(self)
		return minetest.serialize(self.storage)
	end,
	get_rail=function(p)
		return minetest.get_item_group(minetest.get_node(p).name,"rail") > 0
	end,
	get_rails_loop=function(self)
		local explores = {}
		for i,v in pairs(self.explores) do
			for x=-1,1 do
			for y=-1,1 do
			for z=-1,1 do
				local p = {x=v.x+x,y=v.y+y,z=v.z+z}
				local s = minetest.pos_to_string(p)
				if not self.map[s] and self.get_rail(p) then
					table.insert(explores,p)
					self.map[s] = p


--minetest.add_entity(p,"exacarts:dotr")
				end
			end
			end
			end
		end
		self.explores = explores
	end,
	move=function(self,pos2)
		local pos1 = self.object:get_pos()
		local v = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local yaw = num(math.atan(v.z/v.x)-math.pi/2)
		if pos1.x >= pos2.x then yaw = yaw+math.pi end
		self.object:set_yaw(yaw)
		local x = (math.sin(yaw) * -1) * self.v
		local z = math.cos(yaw) * self.v
		self.object:set_velocity({x=x,y= v.y*-1,z=z})
	end,




	pointat=function(self,d)
		local pos = self.object:get_pos()
		local yaw = num(self.object:get_yaw())
		d=d or 1
		local x = math.sin(yaw) * -d
		local z = math.cos(yaw) * d
		return {x=pos.x+x,y=pos.y,z=pos.z+z}
	end,
	on_rightclick=function(self, clicker,name)
		if self.user then
			local n = self.user:is_player() and self.user:get_player_name() or ""
			if self.user:is_player() and self.user:get_player_name() == n then
				self.user:set_detach()
				self.user = nil
			end
		elseif clicker:is_player() then
			self.user = clicker
			self.user:set_attach(self.object, "",{x = 0, y = -5, z = 0}, {x = 0, y = 0, z = 0})
		end
	end,
	a=function(a)
		return a ~= 0 and a/math.abs(a) or 0
	end,
	in_map=function(self,pos)
--print(minetest.pos_to_string(pos))
--print(dump(self.map))
		return self.map[minetest.pos_to_string(pos)] ~= nil
	end,
	contrast=function(a,x,y,z)
		return a.x*-1==x and a.y*-1==y and a.z*-1==z
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if self.user then
			local d = puncher:get_look_dir()
			local v = math.abs(d.x) > math.abs(d.z) and {x=self.a(d.x),y=0,z=0} or {x=0,y=0,z=self.a(d.z)}
			local p =  vector.round(self.object:get_pos())
			local dmg = tool_capabilities.damage_groups.fleshy or 1
			if v.x == self.dir.x and v.z == self.dir.z then
				self.v = self.v + dmg
			elseif self.v == 0 and self:in_map({x=p.x+v.x,y=p.y,z=p.z+v.z}) or self:in_map({x=p.x+v.x,y=p.y-1,z=p.z+v.z}) or self:in_map({x=p.x+v.x,y=p.y+1,z=p.z+v.z}) then
				self.dir = v
				self.v = dmg
				self.next_pos = {x=p.x+self.dir.x,y=p.y+self.dir.y,z=p.z+self.dir.z}
			else
				self.v = self.v - dmg
				self.v = self.v > 0 and self.v or 0
			end
		elseif puncher:is_player() then
			puncher:get_inventory():add_item("main",ItemStack("exacarts:cart"))
			self.object:remove()
			return self
		end
	end,
t=0,
	on_step = function(self,dtime,moveresult)
		if #self.explores > 0 then
			self.get_rails_loop(self)
		end

		if self.v == 0 then
			return self
		end

		local pos = self.object:get_pos()
		local p = vector.round(pos)

		if #self.index_list < 10 then
			local i = self.index[self.index_list[#self.index_list]]
			local dir = i and i.dir or self.dir
			local ip = i and i.pos or p
--print(i,#self.index_list,dir.x,dir.y,dir.z)		
--print(dump(ip))
			local nip = {x=ip.x+dir.x,y=ip.y+dir.y,z=ip.z+dir.z}
			local s = minetest.pos_to_string(nip)


			if #self.index_list == 0 then
				local s2 = minetest.pos_to_string(ip)
				self.index[s2] = {dir={x=dir.x,y=dir.y,z=dir.z},pos=ip}
				table.insert(self.index_list,s2)
			end

			if self:in_map(nip) and not self.index[s] then
				self.index[s] = {dir={x=dir.x,y=dir.y,z=dir.z},pos=nip}
				table.insert(self.index_list,s)
minetest.add_entity(nip,"exacarts:dotg")
				goto setv
			end

			for y=-1,1 do
			for x=-1,1 do
			for z=-1,1 do
				local mp = {x=ip.x+x,y=ip.y+y,z=ip.z+z}
				s = minetest.pos_to_string(mp)
				if self:in_map(mp) and not self.index[s] then
					table.insert(self.index_list,s)
					self.index[s] = {dir={x=x,y=y,z=z},pos=mp}
--print(s,x,y,z)
						--self.dir = {x=x,y=y,z=z}
						--if self.v >= 10 then
						--	self.object:set_pos({x=p.x+self.dir.x,y=p.y+self.dir.y,z=p.z+self.dir.z})
						--end
	minetest.add_entity(mp,"exacarts:dotr")
					goto setv
				end
			end
			end
			end
		end
		::setv::

		local s = minetest.pos_to_string(p)


		if self.v <= 10 then
			local d = self.nextpos and vector.distance(self.nextpos,pos) or 0
			if d < 0.5 then
				local inx = self.index_list[2]
				if inx then
					self.nextpos = self.index[inx].pos
				end
				local oinx = self.index_list[1]
				self.index[oinx] = nil
				table.remove(self.index_list,1)
			end
			if self.nextpos then
				self:move(self.nextpos)
			end
			return self
		elseif self.index_cur ~= s and 1==2 then
			self.index_cur = s
			for n=1,#self.index_list do
				local inx = self.index_list[1]
				if inx == s then
					inx = self.index_list[2]
					local i = self.index[inx]
					if i then
						self.dir = i.dir
						self.nextpos = i.pos
						minetest.add_entity(i.pos,"exacarts:dotb")
						self.object:set_velocity({x=self.dir.x*self.v,y=self.dir.y*self.v,z=self.dir.z*self.v})
					end
					break
				elseif inx then
					self.index[inx] = nil
					table.remove(self.index_list,1)
				end
			end
		end


self.t = self.t + dtime
		if self.t < 0.1 then
			return self
		end
self.t = 0

		local a = self.index_list[1]
		local b = self.index_list[2]
if a and b then
		print(vector.distance(self.index[a].pos,pos),vector.distance(self.index[b].pos,pos))
end

		if false and not self.nextpos or vector.distance(self.index[a].pos,pos) > 1 then
print(s)
			self.index_cur = s
			for n=1,#self.index_list do
				local inx = self.index_list[1]
				if inx == s then

					inx = self.index_list[2]
					local i = self.index[inx]
					if i then
						self.nextpos = i.pos
						self.dir = i.dir
						minetest.add_entity(i.pos,"exacarts:dotb")
						self.object:set_velocity({x=self.dir.x*self.v,y=self.dir.y*self.v,z=self.dir.z*self.v})
					end
					break
				elseif inx then

					self.index[inx] = nil
					table.remove(self.index_list,1)
				end
			end
		end




if true then return end




		local in_map = self:in_map(p)

		if not in_map and not self.derail then
			self.derail = true
			self.object:set_properties({physical = true})
			self.object:set_acceleration({x=0, y=-10, z =0})
		elseif self.derail and in_map then
			self.derail = nil
			self.object:set_properties({physical = false})
			self.object:set_acceleration({x=0, y=0, z =0})
			self.object:set_pos({x=pos.x,y=p.y,z=pos.z})
			local v = self.object:get_velocity()
			if v.x == 0 and v.z == 0 and v.y ~= 0 then
				self.object:set_velocity({x=0,y=0,z=0})
			end
		elseif self.derail then
			if self.v > 0 and default.defpos({x=p.x,y=p.y-1,z=p.z},"walkable") then
				self.v = self.v-dtime*10
				self.v = self.v > 0 and self.v or 0
				--if not self.user and self.v == 0 then
				--	minetest.add_item(pos,ItemStack("exacarts:cart"))
				--	self.object:remove()
				--	return self
				--end
			end
		end
	end,
})