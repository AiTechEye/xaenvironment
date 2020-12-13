exacarts={
	storage = minetest.get_mod_storage(),
	map = {},
	add_to_map=function(pos)
		exacarts.map = exacarts.map or minetest.deserialize(exacarts.storage:get_string("map")) or {}
		local p = exacarts.map[minetest.pos_to_string(pos)]
		if not p then
			exacarts.map[minetest.pos_to_string(pos)] = pos
			exacarts.storage:set_string("map",minetest.serialize(exacarts.map))
		end
	end,
	remove_from_map=function(pos)
		exacarts.map = exacarts.map or minetest.deserialize(exacarts.storage:get_string("map")) or {}
		exacarts.map[minetest.pos_to_string(pos)] = nil
		exacarts.storage:set_string("map",minetest.serialize(exacarts.map))
	end,
}

minetest.register_craft({
	output="exacarts:rail 24",
	recipe={
		{"group:metalstick","group:stick","group:metalstick"},
		{"group:metalstick","group:stick","group:metalstick"},
		{"group:metalstick","group:stick","group:metalstick"}
	},
})

minetest.register_craft({
	output="exacarts:cart",
	recipe={
		{"default:iron_ingot","","default:iron_ingot"},
		{"group:wood","group:wood","group:wood"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"}
	},
})

minetest.register_node("exacarts:rail", {
	description = "Rail",
	drawtype="raillike",
	walkable=false,
	inventory_image="exacarts_straight.png",
	tiles={"exacarts_straight.png","exacarts_curve.png","exacarts_junction.png","exacarts_cross.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,treasure=1,flammable=3,rail=1,on_load=1},
	sounds =  default.node_sound_metal_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.49, 0.5},
		}
	},
	on_load=function(pos)
		exacarts.add_to_map(pos)
	end,
	on_construct=function(pos)
		exacarts.add_to_map(pos)
	end,
	on_destruct=function(pos)
		exacarts.remove_from_map(pos)
	end
})

minetest.register_tool("exacarts:cart", {
	description = "Cart",
	inventory_image = "exacarts_minecart.png",
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
	textures = {"player_style_coin.png^[colorize:#f00"},
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
	hp_max = 1,
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	visual = "mesh",
	mesh = "exacarts_minecart.obj",
	textures = {"exacarts_minecart.png"},
	backface_culling = false,
	get_staticdata = function(self)
		return minetest.serialize({dir=self.dir,v=self.v,derail=self.derail,lastpos=self.lastpos})
	end,
	on_activate=function(self, staticdata,dtime)
		local save = minetest.deserialize(staticdata) or {}

		self.derail = save.derail
		self.lastpos = save.lastpos
		self.index = {}
		self.index_list={}
		self.next_pos = {x=0,y=0,z=0}
		self.dir = save.dir or {x=0,y=0,z=0}
		self.v = save.v or 0
		self.rot = 0

		self.trackout_timer = 0
		self.trackout = 0

		self.object:set_armor_groups({immortal=1})

		if self.derail then
			self.object:set_acceleration({x=0, y=-10, z =0})
		else
			if not self:in_map(self.object:get_pos()) and self.lastpos then
				self.object:set_pos(self.lastpos)
			end
			self.object:set_velocity({x=0,y=0,z=0})
			self.object:set_properties({physical = false})
		end

		if dtime == 0 then
			local pos = self.object:get_pos()
			for i=-1,1,2 do
				if self.get_rail(apos(pos,i)) then
					self:lookat({x=i,y=0,z=0})
					break
				end
			end
		end
	end,
	get_rail=function(p)
		return minetest.get_item_group(minetest.get_node(p).name,"rail") > 0
	end,
	pointat=function(self,d)
		local pos = self.object:get_pos()
		local yaw = num(self.object:get_yaw())
		d=d or 1
		local x = math.sin(yaw) * -d
		local z = math.cos(yaw) * d
		return {x=pos.x+x,y=pos.y,z=pos.z+z}
	end,
	on_rightclick=function(self, clicker)
		if self.user then
			local n = self.user:is_player() and self.user:get_player_name() or ""
			if self.user:is_player() and self.user:get_player_name() == n then
				default.player_attached[self.user:get_player_name()] = nil
				default.player_set_animation(self.user, "stand")
				self.user:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
				self.user:set_detach()
				self.user = nil

			end
		elseif clicker:is_player() then
			self.user = clicker
			self.user:set_attach(self.object, "",{x = 0, y = -4, z = -3}, {x = 0, y = 0, z = 0})
			clicker:set_eye_offset({x=0,y=-7,z=0}, {x=0,y=0,z=0})
			local name = clicker:get_player_name()
			default.player_attached[name]=true
			default.player_set_animation(clicker, "sit")
		end
	end,
	lookat=function(self,d)
		self.rot = (d.x*(-math.pi/2)) + (d.z < 0 and math.pi or 0)
		self.object:set_rotation({x=d.y,y=self.rot,z=0})
	end,
	on_death=function(self)
		if self.user then
			self.on_rightclick(self)
		end
	end,
	a=function(a)
		return a ~= 0 and a/math.abs(a) or 0
	end,
	in_map=function(self,pos)
		return exacarts.map[minetest.pos_to_string(pos)] ~= nil
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
		return false
	end,
	on_step = function(self,dtime,moveresult)
		if self.v == 0 then
			return self
		--elseif self.v > 100 then
		--	self.v = 100
		end

		local pos = self.object:get_pos()
		local p = vector.round(pos)

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

			self.trackout_timer = self.trackout_timer + dtime
			if self.trackout_timer > 0.01 then
				self.trackout_timer = 0
				self.v = self.v-(self.trackout*0.1)
				self.trackout = 0
			end

-- speed < 15
			if self.v < 15 and not self.rerail and target and self.currpos then-- and self.dir.y == 0 then
				self.object:move_to(self.nextpos)	
-- speed > 15: super speed
			elseif self.v >= 15 and target then
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
				self.trackout = self.trackout +min
			end
-- next path step
			if skip or not self.nextpos or vector.equals(self.nextpos,p) then
				local inx = self.index_list[2]
				if inx then
					local i = self.index[inx]
					if self.dir.y == 0 and i.dir.y > 0 then
						self.object:move_to({x=pos.x,y=p.y,z=pos.z})
					elseif self.dir.y > 0 and i.dir.y == 0 then
						self.object:move_to({x=pos.x,y=p.y,z=pos.z})
					elseif self.dir.y == 0 and i.dir.y < 0 then
						self.object:move_to({x=p.x,y=p.y,z=p.z})
					elseif self.dir.y < 0 and i.dir.y == 0 then
						self.object:move_to({x=i.pos.x,y=p.y,z=i.pos.z})
					elseif self.dir.y == 0 and (self.dir.x ~= i.dir.x or self.dir.z ~= i.dir.z) then
						self.object:move_to(p)
					end

					local key = self.user and self.user:get_player_control() or {}

					if key.right or key.left then
						local pi = math.pi/2*(key.left and 1 or -1)
						local x = math.sin(self.rot+pi) * -1
						local z = math.cos(self.rot+pi) * 1
						if self:in_map({x=p.x+x,y=p.y,z=p.z+z}) and not vector.equals({x=x,y=0,z=z},self.dir) then
							self.object:set_velocity({x=0,y=0,z=0})
							self.object:move_to(p)
							self.dir = {x=x,y=0,z=z}
							self.index_list = {}
							self.index = {}
							return
						end
					end

					self.dir = i.dir
					self:lookat(i.dir)
					self.object:set_velocity({x=self.dir.x*self.v,y=self.dir.y*self.v,z=self.dir.z*self.v})
					local oinx = self.index_list[1]
					self.index[oinx] = nil
					table.remove(self.index_list,1)
					self.nextpos = i.pos
					self.lastpos = i.pos
-- derail
					if i.pos.y > p.y and (key.jump or not self.index_list[3]) then
						self.derail = true
						self.object:move_to(apos(p,0,1))
						self.object:set_properties({physical = true})
						self.object:set_acceleration({x=0, y=-10, z =0})
						return self
					elseif not self.index_list[2] then
						if default.def(minetest.get_node(p).name).walkable then
							self.v = 0
							self.object:set_velocity({x=0,y=0,z=0})
							self.set_pos(self.lastpos)
						end
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