--if 1 then return end -- coming nowhere, working on it later

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
	physical = true,
	hp_max = 100000,
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	visual = "cube",
	--visual_size = {x=0.3,y=0.3},
	textures = {"default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png"},
	on_activate=function(self, staticdata)
		--self.storage = minetest.deserialize(staticdata) or {}
		self.map = {}
		self.explores = {vector.round(self.object:get_pos())}
		--self.get_rails_loop(self)

		self.derail = true
		self.object:set_acceleration({x=0, y=-10, z =0})

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
				end
			end
			end
			end
		end
		self.explores = explores
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
	on_step = function(self,dtime,moveresult)
		if #self.explores > 0 then
			self.get_rails_loop(self)
		end

		if self.v == 0 then
			return self
		end

		local pos = self.object:get_pos()
		local p = vector.round(pos)
print(self.v)
		if not self.derail and #self.index_list < 10+(math.ceil(self.v)) then
			for i=#self.index_list, 10+(math.ceil(self.v)) do
				local i = self.index[self.index_list[#self.index_list]]
				local dir = i and i.dir or self.dir
				local ip = i and i.pos or p
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
					goto br
				end

				for y=-1,1 do
				for x=-1,1 do
				for z=-1,1 do
					local mp = {x=ip.x+x,y=ip.y+y,z=ip.z+z}
					s = minetest.pos_to_string(mp)
					if self:in_map(mp) and not self.index[s] then
						table.insert(self.index_list,s)
						self.index[s] = {dir={x=x,y=y,z=z},pos=mp}
						minetest.add_entity(mp,"exacarts:dotr")
						goto br
					end
				end
				end
				end
			::br::
			end
		end

		if not self.derail then
			local skip
			local target = self.currpos and not vector.equals(self.currpos,p) and not vector.equals(self.nextpos,p)
-- speed < 15
			if self.v < 15 and not self.rerail and target and self.currpos then
				self.object:set_pos(self.currpos)
-- speed > 15: super speed
			elseif target then
				self.rerail = nil
				self.object:set_velocity({x=0,y=0,z=0})
				skip = true
				local list = {}
				local ilist = {}
				for n=1,#self.index_list do
					local inx = self.index_list[n]
					if inx then
						local i = self.index[inx]
						local d = vector.distance(i.pos,pos)
						list[d] = {pos=i.pos,i=inx,n=n}
						table.insert(ilist,d)
					end
				end
				local min = math.min(unpack(ilist))
				local a = list[min]
				self.object:set_pos(a.pos)
				for n=1,a.n-1 do
					local inx = self.index_list[1]
					self.index[inx] = nil
					table.remove(self.index_list,1)
				end
			end
-- next path step
			if skip or not self.nextpos or vector.equals(self.nextpos,p) then
				local inx = self.index_list[2]
				if inx then
					local i = self.index[inx]
					if self.dir.y == 0 and i.dir.y > 0 then
						self.object:set_pos({x=pos.x,y=p.y,z=pos.z})
					elseif self.dir.y > 0 and i.dir.y == 0 then
						self.object:set_pos({x=pos.x,y=p.y,z=pos.z})
					elseif self.dir.y == 0 and i.dir.y < 0 then
						self.object:set_pos({x=p.x,y=p.y,z=p.z})
					elseif self.dir.y < 0 and i.dir.y == 0 then
						self.object:set_pos({x=pos.x,y=p.y,z=pos.z})
					elseif self.dir.y == 0 and (self.dir.x ~= 0 or self.dir.z ~= 0) then
						self.object:move_to(p)
					end
					self.dir = i.dir
					self.object:set_velocity({x=self.dir.x*self.v,y=self.dir.y*self.v,z=self.dir.z*self.v})
					local oinx = self.index_list[1]
					self.index[oinx] = nil
					table.remove(self.index_list,1)
					self.nextpos = i.pos
-- derail
					local key = self.user and self.user:get_player_control() or {}

					if i.pos.y > p.y and (key.jump or not self.index_list[3]) then
						self.derail = true
						self.object:move_to(apos(p,0,1))
						self.object:set_properties({physical = true})
						self.object:set_acceleration({x=0, y=-10, z =0})
						return self
					elseif not self.index_list[2] then
						self.derail = true
						self.object:set_properties({physical = true})
						self.object:set_acceleration({x=0, y=-10, z =0})
					end
					self.currpos = p
				end
			end
			return self
		else
			if self:in_map(p) and not (self.currpos and (vector.equals(self.currpos,p) or vector.equals(self.nextpos,p))) then
				self.derail = nil
				self.rerail = true
				self.object:set_properties({physical = false})
				self.object:set_acceleration({x=0, y=0, z =0})
				self.object:set_pos({x=pos.x,y=p.y,z=pos.z})
				local v = self.object:get_velocity()
				if v.x == 0 and v.z == 0 and v.y ~= 0 then
					self.object:set_velocity({x=0,y=0,z=0})
				end
			end

			local def = default.def(minetest.get_node({x=p.x,y=p.y-1,z=p.z}).name)

			if self.v > 0 and def.walkable then
				local g = def.groups or {}
				self.v = self.v - dtime*((g.snowy or g.sand and 8) or 2)
				self.v = self.v > 0 and self.v or 0
				local v = self.object:get_velocity()
				self.object:set_velocity({x=self.dir.x*self.v,y=v.y,z=self.dir.z*self.v})
			end
		end
	end,
})