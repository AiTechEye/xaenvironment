exacarts={
	storage = minetest.get_mod_storage(),
	map = {},
	add_to_map=function(pos,on_rail)
		exacarts.map = exacarts.map or minetest.deserialize(exacarts.storage:get_string("map")) or {}
		local p = exacarts.map[minetest.pos_to_string(pos)]
		if not p then
			exacarts.map[minetest.pos_to_string(pos)] = {on_rail=on_rail}
			exacarts.storage:set_string("map",minetest.serialize(exacarts.map))
		end
	end,
	remove_from_map=function(pos)
		exacarts.map = exacarts.map or minetest.deserialize(exacarts.storage:get_string("map")) or {}
		exacarts.map[minetest.pos_to_string(pos)] = nil
		exacarts.storage:set_string("map",minetest.serialize(exacarts.map))
	end,
	in_map=function(pos)
		return exacarts.map[minetest.pos_to_string(pos)] ~= nil
	end,
	on_rail=function(pos,self)
		local n = exacarts.map[minetest.pos_to_string(pos)] 
		if n and n.on_rail then
			local on_rail = default.def(n.on_rail).on_rail
			if on_rail then
				on_rail(pos,self,self.v)
			end
		end
	end,
	register_rail=function(def)
		def = def or {}

		local texture = def.texture or "default_ironblock.png"
		local overlay = def.overlay and "^"..def.overlay or ""
		local name = minetest.get_current_modname()..":"..(def.name or "rail")
		local craft_recipe = def.craft_recipe and table.copy(def.craft_recipe) or nil
		local wood = def.craft_wood
		local item = def.craft_item
		local count = def.craft_count
		local alpha = def.wood_modifer and "exacarts_rails_alpha2.png" or "exacarts_rails_alpha.png"
		local add_groups = def.add_groups and table.copy(def.add_groups) or nil

		def.overlay = nil
		def.texture = nil
		def.craft_count = nil
		def.craft_wood = nil
		def.craft_item = nil
		def.name = nil
		def.texture = nil
		def.craft = nil
		def.wood_modifer = nil
		def.add_groups = nil

		def.on_rail = def.on_rail -- function(pos,self,v)

		def.description = def.description or "Rail"
		def.drawtype = def.drawtype or "raillike"
		def.inventory_image = def.inventory_image or texture.."^[combine:16x16:0,0="..alpha.."^[makealpha:0,255,0"..overlay
		def.tiles = def.tiles or {
			texture.."^[combine:16x16:0,0="..alpha.."^[makealpha:0,255,0"..overlay,
			texture.."^[combine:16x16:0,-16="..alpha.."^[makealpha:0,255,0"..overlay,
			texture.."^[combine:16x16:-16,-16="..alpha.."^[makealpha:0,255,0"..overlay,
			texture.."^[combine:16x16:-16,0="..alpha.."^[makealpha:0,255,0"..overlay
		}
		def.groups = def.groups or {choppy=3,oddly_breakable_by_hand=3,treasure=1,rail=1,on_load=1}
		def.sounds = def.sounds or default.node_sound_metal_defaults()
		def.paramtype = def.paramtype or "light"
		def.sunlight_propagates = def.sunlight_propagates == nil
		def.selection_box = def.selection_box or {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
			}
		}
		def.collision_box = def.collision_box or {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.49, 0.5},
			}
		}
		def.on_load = def.on_load or function(pos)
			exacarts.add_to_map(pos,def.on_rail ~= nil and name or nil)
		end
		def.on_construct = def.on_construct or function(pos)
			exacarts.add_to_map(pos,def.on_rail ~= nil and name or nil)
		end
		def.on_destruct = def.on_destruct or function(pos)
			exacarts.remove_from_map(pos)
		end

		if add_groups then
			for i,v in pairs(add_groups) do
				def.groups[i]=v
			end
		end

		minetest.register_node(name,def)

		if craft_recipe then
			minetest.register_craft(craft_recipe)
		else
			item = item or "group:metalstick"
			wood = wood or "group:stick"
			minetest.register_craft({
				output = name .." " .. (count or 16),
				recipe={
					{item,wood,item},
					{item,wood,item},
					{item,wood,item}
				}
			})
		end
	end
}

minetest.register_craft({
	output="exacarts:cart",
	recipe={
		{"default:iron_ingot","","default:iron_ingot"},
		{"group:wood","group:wood","group:wood"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"}
	},
})

exacarts.register_rail()

exacarts.register_rail({
	name="detector",
	description="Detector rail",
	overlay="default_chest_top.png^[invert:rg",
	add_groups = {exatec_wire=1,exatec_wire_connected=1,store=200},
	on_rail=function(pos,self,v)
		exatec.send(pos)
	end,
	craft_recipe = {
		output="exacarts:detector",
		recipe={{"exacarts:rail","exatec:wire","group:stick"}}}
})

exacarts.register_rail({
	name="max",
	description="Max speed rail",
	craft_item = "default:diamond",
	texture="default_diamondblock.png^[invert:g",
	add_groups = {store=2000},
	on_rail=function(pos,self,v)
		local mv = minetest.get_meta(pos):get_int("v")
		if v == mv then
			return
		end
		self.timeout = 0.1
		self.nextpos = nil
		self.currpos = nil
		self.v = mv
		self.object:set_velocity({x=0,y=0,z=0})
		minetest.after(0,function(self,pos)
			self.object:set_velocity({x=0,y=0,z=0})
			self.object:set_pos(pos)
		end,self,pos)
	end,
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:set_string("formspec","size[1,0.5]button_exit[0,0;1,1;go;Setup]")
		m:set_string("infotext","0")
		exacarts.add_to_map(pos,"exacarts:acceleration")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.go and minetest.is_protected(pos, sender:get_player_name()) == false then
			local m = minetest.get_meta(pos)
			local n = tonumber(pressed.text) or m:get_int("v")
			n = math.abs(n)
			n = n <= 1000 and n or 1000
			m:set_string("formspec","size[5,0.5]field[0,0;3,1;text;;"..n.."]button_exit[4,-0.3;1,1;go;Go]")
			m:set_int("v",n)
			m:set_string("infotext",n)
		end
	end
})

exacarts.register_rail({
	name="acceleration",
	description="Acceleration rail",
	texture="default_electricblock.png",
	add_groups = {store=400},
	on_rail=function(pos,self,v)
		local m = minetest.get_meta(pos)
		local t = m:get_string("type")
		local av = m:get_int("v")
		if t == "+" then
			if v+1 <= 1000 then
				self.v = v + 1
			end
		elseif t == "-" then
			self.v = v-1 > 0 and (v-1) or 0
		elseif t == "Max" then
			 if v+1 < av then
				self.v = v + 1
			else
				self.v = av
			end
		elseif t == "Min" then
			 if v-1 < av then
				self.v = v + 1
			end
		end
		m:set_string("infotext",t.." "..av.." (Last speed test: "..math.floor(self.v)..")")
	end,
	craft_recipe = {
		output="exacarts:acceleration",
		recipe={{"exacarts:rail","default:electric_lump"}}},
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:set_string("formspec","size[1,0.5]button_exit[0,0;1,1;go;Setup]")
		m:set_string("type","+")
		m:set_string("infotext","+ 1")
		exacarts.add_to_map(pos,"exacarts:acceleration")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if pressed.go and minetest.is_protected(pos, sender:get_player_name()) == false then
			local m = minetest.get_meta(pos)
			local n = tonumber(pressed.text) or m:get_int("v")
			local t = pressed.type or m:get_string("type") ~= "" and m:get_string("type") or "+"
			local types = {["+"]="1",["-"]="2",["Min"]="3",["Max"]="4",["None"]="5"}

			n = t ~= "+" and t ~= "-" and n or 1
			n = math.abs(n)
			n = n <= 1000 and n or 1000

			m:set_string("formspec","size[5,0.5]field[0,0;3,1;text;;"..n.."]dropdown[3,0;1,1;type;+,-,Min,Max;None;"..types[t].."]button_exit[4,-0.3;1,1;go;Go]")
			m:set_int("v",n)
			m:set_string("type",t)
			m:set_string("infotext",t.." "..n)
		end
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
	on_step=function(self, dtime)
		self.object:remove()
	end,
})

minetest.register_entity("exacarts:dotr",{
	physical = false,
	pointable=false,
	textures = {"player_style_coin.png^[colorize:#f00"},
	use_texture_alpha=true,
	t=0,
	on_step=function(self, dtime)
		self.object:remove()
	end,
})

minetest.register_entity("exacarts:dotg",{
	physical = false,
	pointable=false,
	textures = {"player_style_coin.png^[colorize:#0f0"},
	use_texture_alpha=true,
	on_step=function(self, dtime)
		self.object:remove()
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
		self.timeout = 0

		self.trackout_timer = 0
		self.trackout = 0

		self.object:set_armor_groups({immortal=1})

		if self.derail then
			self.object:set_acceleration({x=0, y=-10, z =0})
		else
			if not exacarts.in_map(self.object:get_pos()) and self.lastpos then
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
			elseif self.v == 0 and exacarts.in_map({x=p.x+v.x,y=p.y,z=p.z+v.z}) or exacarts.in_map({x=p.x+v.x,y=p.y-1,z=p.z+v.z}) or exacarts.in_map({x=p.x+v.x,y=p.y+1,z=p.z+v.z}) then
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
		if self.v == 0 and not self.derail then
			return self
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

				if exacarts.in_map(nip) and not self.index[s] then
					self.index[s] = {dir={x=dir.x,y=dir.y,z=dir.z},pos=nip}
					table.insert(self.index_list,s)
					goto br
				end

				for y=-1,1 do
				for x=-1,1 do
				for z=-1,1 do
					local mp = {x=ip.x+x,y=ip.y+y,z=ip.z+z}
					s = minetest.pos_to_string(mp)
					if exacarts.in_map(mp) and not self.index[s] then
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

		if self.timeout > 0 then
			self.timeout = self.timeout -dtime
			return self
		elseif not self.derail then
			local target = self.currpos and not vector.equals(self.currpos,p) and not vector.equals(self.nextpos,p)
			local skip
			self.trackout_timer = self.trackout_timer + dtime
			if self.trackout_timer > 0.01 then
				self.trackout_timer = 0
				self.v = self.v-(self.trackout*0.1)
				self.trackout = 0
			end

-- speed < 15
			if self.v < 15 and not self.rerail and target and self.currpos then
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
					exacarts.on_rail(self.index[inx].pos,self)
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
						if exacarts.in_map({x=p.x+x,y=p.y,z=p.z+z}) and not vector.equals({x=x,y=0,z=z},self.dir) then
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
							self.object:set_pos(self.lastpos)
						end
						self.derail = true
						self.object:set_properties({physical = true})
						self.object:set_acceleration({x=0, y=-10, z =0})
						
					end
					self.currpos = p
					exacarts.on_rail(p,self)
				end
			end
			return self
		else
			if exacarts.in_map(p) and not (self.currpos and (vector.equals(self.currpos,p) or vector.equals(self.nextpos,p))) then
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