exacarts={
	storage=minetest.get_mod_storage(),
	map = {},
	add_to_map=function(pos,on_rail)
		if not exacarts.map[minetest.pos_to_string(pos)] then
			exacarts.map[minetest.pos_to_string(pos)] = {on_rail=on_rail}
			exacarts.storage:set_string("map",minetest.serialize(exacarts.map))
		end
	end,
	remove_from_map=function(pos)
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
				return on_rail(pos,self,self.v)
			end
		end
	end,
	register_rail=function(def)
		def = def or {}

		local mod = minetest.get_current_modname()
		local texture = def.texture or "default_ironblock.png"
		local overlay = def.overlay and "^"..def.overlay or ""
		local name = minetest.get_current_modname()..":".. (def.full_custom_name or def.name .. "_rail")
		local craft_recipe = def.craft_recipe and table.copy(def.craft_recipe) or nil
		local wood = def.craft_wood
		local item = def.craft_item
		local count = def.craft_count
		local alpha = def.wood_modifer and "exacarts_rails_alpha2.png" or def.all_modifer and "exacarts_rails_alpha3.png" or "exacarts_rails_alpha.png"
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
		def.all_modifer = nil
		def.add_groups = nil
		def.name = nil
		def.full_custom_name = nil

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
		def.on_blast = def.on_blast or function(pos)
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

minetest.register_on_mods_loaded(function()
	exacarts.map = minetest.deserialize(exacarts.storage:get_string("map")) or {}
end)

player_style.register_manual_page({
	name = "Carts",
	itemstyle = "exacarts:cart",
	text = "The industryal vehicle is used to transport players and items. It is also made to be an extremly stunt vehicle then can reach its top speed 1000 blocks/s.\n\nHow to use:\nRighclick to enter/exit a cart\nPunch speed it up / pick up\nHold right/left to turn right/left\n\nYou can throw items into a cart to add them, the carts have a 100 slots inventory.\nYou can sit in a cart with items, punch it to move it away, right click it drop the items.]item_image[1,0.5;1,1;exacarts:rail]item_image[2,0.5;1,1;exacarts:derail_rail]item_image[3,0.5;1,1;exacarts:detector_rail]item_image[4,0.5;1,1;exacarts:dir_rail]item_image[5,0.5;1,1;exacarts:stop_start_rail]item_image[6,0.5;1,1;exacarts:exit_rail]item_image[7,0.5;1,1;exacarts:max_rail]",
	tags = {"exacarts:cart","rail"},
})

minetest.register_craft({
	output="exacarts:cart",
	recipe={
		{"default:iron_ingot","","default:iron_ingot"},
		{"group:wood","group:wood","group:wood"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"}
	},
})

exacarts.register_rail({full_custom_name="rail",add_groups={store=100}})

exacarts.register_rail({
	name="derail",
	description="Derail rail",
	texture="default_stone.png",
	add_groups = {store=200},
	on_rail=function(pos,self,v)
		self.derail = true
		self.object:set_properties({physical = true})
		self.object:set_acceleration({x=0, y=-10, z =0})
		self.index_list = {}
		self.index = {}
		self.derailpos = pos
		self.dir = self.olddir
		self:lookat(self.olddir)
		return self
	end,
	craft_recipe = {
		output="exacarts:derail_rail",
		recipe={{"exacarts:rail","group:stone"}}}
})

exacarts.register_rail({
	name="dir",
	description="Direction rail",
	inventory_image="(default_ironblock.png^[combine:16x16:0,0=exacarts_rails_alpha.png^[makealpha:0,255,0)^default_crafting_arrowup.png",
	tiles = {"(default_ironblock.png^[combine:16x16:0,0=exacarts_rails_alpha.png^[makealpha:0,255,0)^default_crafting_arrowup.png"},
	add_groups = {exatec_wire_connected=1,store=200},
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	node_box={
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
		}
	},
	on_rail=function(pos,self,v)
		local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		if not vector.equals(self.dir,dir) then
			self.object:move_to(pos)
			self.dir = {x=dir.x,y=0,z=dir.z}
			self.nextpos = nil
			self.lastpos = nil
			self.currpos = nil
			self.index_list = {}
			self.index = {}
			return self
		end

	end,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext","On")
		exacarts.add_to_map(pos,"exacarts:dir_rail")
	end,
	exatec={
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local on = m:get_int("on") == 1 and 0 or 1
			m:set_int("on",on)
			m:set_string("infotext",on == 0 and "On" or "Off")

			if on == 1 then
				exacarts.remove_from_map(pos)
			else
				exacarts.add_to_map(pos,"exacarts:dir_rail")
			end
		end,
	},
	craft_recipe = {
		output="exacarts:dir_rail",
		recipe={{"exacarts:rail","materials:gear_metal","group:metalstick"}}}
})

exacarts.register_rail({
	name="detector",
	description="Detector rail",
	texture="default_steelblock.png^[invert:b",
	add_groups = {exatec_wire=1,exatec_wire_connected=1,store=200},
	on_rail=function(pos,self,v)
		exatec.send(pos)
	end,
	craft_recipe = {
		output="exacarts:detector_rail",
		recipe={{"exacarts:rail","exatec:wire","group:stick"}}}
})

exacarts.register_rail({
	name="drop_items",
	description="Drop items rail",
	texture="default_steelblock.png^[invert:rb",
	add_groups = {store=200},
	on_rail=function(pos,self,v)
		if #self.items > 0 then
			for i,v in pairs(self.items) do
				minetest.add_item(pos,ItemStack(v))
			end
			for i,v in pairs(self.childs) do
				v:set_detach()
			end
			self.childs = {}
			self.items = {}
			self.itemtimer = 2
		end
	end,
	craft_recipe = {
		output="exacarts:drop_items_rail",
		recipe={{"exacarts:rail","materials:tube_metal"}}}
})

exacarts.register_rail({
	name="pickup_items",
	description="Pick up items rail",
	texture="default_silverblock.png",
	add_groups = {store=800},
	on_rail=function(pos,self,v)
		for _, ob in pairs(minetest.get_objects_inside_radius(pos,2)) do
			local en = ob:get_luaentity()
			if en and en.name == "__builtin:item" then
				self:add_item(en.itemstring,ob)
			end
		end
	end,
	craft_recipe = {
		output="exacarts:drop_items_rail",
		recipe={{"exacarts:rail","default:silver_ingot"}}}
})

exacarts.register_rail({
	name="stop_start",
	description="Toggle stop start rail",
	texture="default_copperblock.png^[invert:b",
	add_groups = {exatec_wire_connected=1,store=600},
	on_rail=function(pos,self,v)
		if minetest.get_meta(pos):get_int("on") == 0 then
			self.v = 0
			self.object:set_velocity({x=0,y=0,z=0})
			minetest.after(0,function(self,pos)
				self.object:set_velocity({x=0,y=0,z=0})
				self.object:set_pos(pos)
			end,self,pos)
		end
	end,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext","Stop")
		exacarts.add_to_map(pos,"exacarts:stop_start_rail")
	end,
	craft_recipe = {
		output="exacarts:stop_start_rail",
		recipe={{"exacarts:rail","default:copper_ingot","group:stick"}}},
	exatec={
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local on = m:get_int("on") == 1 and 0 or 1
			m:set_int("on",on)
			m:set_string("infotext",on == 0 and "Stop" or "Start")
			if on == 1 then
				for _, ob in pairs(minetest.get_objects_inside_radius(pos,1)) do
					local en = ob:get_luaentity()
					if en and en.exacart then
						en.v = 1
						ob:set_velocity({x=en.dir.x*en.v,y=en.dir.y*en.v,z=en.dir.z*en.v})
					end
				end
			end
		end,
	}
})

exacarts.register_rail({
	name="toggle",
	description="Toggleable rail",
	texture="default_steelblock.png^[invert:rg",
	add_groups = {exatec_wire_connected=1,store=200},
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext","On")
		exacarts.add_to_map(pos,"exacarts:toggle_rail")
	end,
	craft_recipe = {
		output="exacarts:toggle_rail",
		recipe={{"exacarts:rail","materials:diode","group:stick"}}},
	exatec={
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local on = m:get_int("on") == 1 and 0 or 1
			m:set_int("on",on)
			m:set_string("infotext",on == 0 and "On" or "Off")

			if on == 1 then
				exacarts.remove_from_map(pos)
			else
				exacarts.add_to_map(pos,"exacarts:toggle_rail")
			end
		end,
	}
})

exacarts.register_rail({
	name="exit",
	description="Exit rail",
	texture="default_steelblock.png^[invert:bg",
	add_groups = {store=200},
	craft_wood = "group:sand",
	on_rail=function(pos,self,v)
		if self.user then
			self:on_rightclick(self.user)
		end
		if #self.items > 0 then
			for i,v in pairs(self.items) do
				minetest.add_item(pos,ItemStack(v))
			end
			for i,v in pairs(self.childs) do
				v:set_detach()
			end
		end
		minetest.add_item(pos,"exacarts:cart")
		self.object:remove()
		return self
	end,
})

exacarts.register_rail({
	name="wood",
	description="Wooden rail (breaks if faster then 50)",
	craft_item = "group:wood",
	texture = "default_wood.png",
	add_groups = {store=200},
	sounds = default.node_sound_wood_defaults(),
	on_rail=function(pos,self,v)
		if v > 50 then
			minetest.add_item(pos,"exacarts:wood_rail")
			minetest.remove_node(pos)
		end
	end,
})

exacarts.register_rail({
	name="copper",
	description="Copper rail",
	add_groups = {store=3000},
	craft_item = "default:copper_ingot",
	texture = "default_copperblock.png",
	sounds = default.node_sound_metal_defaults(),
})

exacarts.register_rail({
	name="ice",
	add_groups = {store=200,slippery=10},
	description="Ice rail",
	craft_item = "default:ice",
	texture = "default_ice.png",
	all_modifer = true,
	sounds = default.node_sound_glass_defaults(),
})

exacarts.register_rail({
	name="max",
	description="Max speed rail",
	craft_item = "default:diamond",
	texture="default_diamondblock.png^[invert:g",
	add_groups = {store=5400},
	on_rail=function(pos,self,v)
		self.v = minetest.get_meta(pos):get_int("v")
	end,
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:set_string("formspec","size[1,0.5]button_exit[0,0;1,1;go;Setup]")
		m:set_string("infotext","0")
		exacarts.add_to_map(pos,"exacarts:max_rail")
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
	add_groups = {store=1000},
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
		output="exacarts:acceleration_rail",
		recipe={{"exacarts:rail","default:electric_lump"}}},
	on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:set_string("formspec","size[1,0.5]button_exit[0,0;1,1;go;Setup]")
		m:set_string("type","+")
		m:set_string("infotext","+ 1")
		exacarts.add_to_map(pos,"exacarts:acceleration_rail")
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

			m:set_string("formspec","size[5,0.5]field[0,0;3,1;text;;"..n.."]dropdown[3,0;1,1;type;+,-,Min,Max,None;"..types[t].."]button_exit[4,-0.3;1,1;go;Go]")
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

minetest.register_entity("exacarts:item",{
	physical = false,
	pointable=false,
	visual="wielditem",
	visual_size = {x=0.1,y=0.1,z=0.1},
	textures = {"default:stick"},
	on_step=function(self, dtime)
		if not self.object:get_attach() then
			self.object:remove()
		end
	end,
})

minetest.register_entity("exacarts:cart",{
	physical = true,
	hp_max = 1,
	stepheight = 0.3,
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	visual = "mesh",
	mesh = "exacarts_minecart.obj",
	textures = {"exacarts_minecart.png"},
	backface_culling = false,
	get_staticdata = function(self)
		local items = {}
		for i,v in pairs(self.items) do
			table.insert(items,v:to_table())
		end
		return minetest.serialize({dir=self.dir,v=self.v,derail=self.derail,lastpos=self.lastpos,items=items})
	end,
	on_activate=function(self, staticdata,dtime)
		local save = minetest.deserialize(staticdata) or {}

		self.derail = save.derail
		self.lastpos = save.lastpos
		self.items = save.items or {}
		self.itemtimer = 0
		self.index = {}
		self.index_list={}
		self.dir = save.dir or {x=0,y=0,z=0}
		self.v = save.v or 0
		self.rot = 0
		self.exacart = true
		self.hill = 0
		self.childs = {}

		self.object:set_armor_groups({immortal=1})

		if #self.items > 0 then
			local items = {}
			for i,v in pairs(self.items) do
				local item = ItemStack(v)
				table.insert(items,item)
				self:spawn_item(item:get_name())
			end
			self.items = items
		end

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
		local pos = vector.round(self.object:get_pos())
		d=d or 1
		return {x=pos.x+self.dir.x*d,y=pos.y+self.dir.y*d,z=pos.z+self.dir.z*d}
	end,
	hit=function(self,ob,dir)
		ob:add_velocity({x=dir.x*self.v,y=dir.y*self.v,z=dir.z*self.v})
		default.punch(ob,self.object,self.v)	
	end,
	on_rightclick=function(self, clicker)
		if self.user then
			local n = self.user:is_player() and self.user:get_player_name() or ""
			if self.user:is_player() and self.user:get_player_name() == n then
				local name = self.user:get_player_name()
				default.set_on_player_death(name,"exacarts",nil)
				default.player_attached[name] = nil
				default.player_set_animation(self.user, "stand")
				self.user:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
				self.user:set_detach()
				self.user = nil
			end
		elseif clicker:is_player() then
			if #self.items > 0 then
				local p = self.object:get_pos()
				for i,v in pairs(self.items) do
					minetest.add_item(p,ItemStack(v))
				end
				for i,v in pairs(self.childs) do
					v:set_detach()
				end
				self.childs = {}
				self.itemtimer = 2
				self.items = {}
				return self
			end
			self.user = clicker
			local name = clicker:get_player_name()
			self.username = name
			self.user:set_attach(self.object, "",{x = 0, y = -4, z = -3}, {x = 0, y = 0, z = 0})
			clicker:set_eye_offset({x=0,y=-7,z=0}, {x=0,y=0,z=0})
			default.player_attached[name]=true
			default.player_set_animation(clicker, "sit")

			local sobject = self.object
			default.set_on_player_death(name,"exacarts",function(player)
				default.player_attached[player:get_player_name()] = nil
				default.player_set_animation(player, "stand")
				player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
				if sobject and sobject:get_luaentity() then
					sobject:get_luaentity().user = nil
				end
			end)
		end
	end,
	lookat=function(self,d)
		self.rot = (d.x*(-math.pi/2)) + (d.z < 0 and math.pi or 0)
		self.object:set_rotation({x=d.y,y=self.rot,z=0})
	end,
	a=function(a)
		return a ~= 0 and a/math.abs(a) or 0
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if (self.user or #self.items > 0) and puncher:is_player() then
			local d = puncher:get_look_dir()
			local v = math.abs(d.x) > math.abs(d.z) and {x=self.a(d.x),y=0,z=0} or {x=0,y=0,z=self.a(d.z)}
			local p =  vector.round(self.object:get_pos())
			local dmg = tool_capabilities.damage_groups.fleshy or 1
			if v.x == self.dir.x and v.z == self.dir.z then -- add
				self.v = self.v + dmg
			elseif self.v == 0 and exacarts.in_map({x=p.x+v.x,y=p.y,z=p.z+v.z}) or exacarts.in_map({x=p.x+v.x,y=p.y-1,z=p.z+v.z}) or exacarts.in_map({x=p.x+v.x,y=p.y+1,z=p.z+v.z}) then --start
				self.dir = v
				self.v = dmg
			elseif v.x == self.dir.x*-1 and v.z == self.dir.z*-1 then-- sub
				self.v = self.v - dmg
				if self.v < 0 then
					self.v = self.v *-1
					self.dir = {x=self.dir.x*-1,y=self.dir.y*-1,z=self.dir.z*-1}
					self.index = {}
					self.index_list = {}
					self.currpos = nil
					self.nextpos = nil
					self.object:set_velocity({x=0,y=0,z=0})
				elseif self.v <= 0 then
					self.v = 0
					self.dir = {x=0,y=0,z=0}
					self.index = {}
					self.index_list = {}
					self.currpos = nil
					self.nextpos = nil
					self.object:set_velocity({x=0,y=0,z=0})
				end
			end
		elseif puncher:is_player() then
			puncher:get_inventory():add_item("main",ItemStack("exacarts:cart"))
			self.object:remove()
			return self
		end
		return false
	end,
	spawn_item=function(self,item)
		local ob = minetest.add_entity(self.object:get_pos(),"exacarts:item")
		ob:set_attach(self.object, "",{x = math.random(-2,2), y = math.random(0,2), z = math.random(-2,2)}, {x = 0, y = 0, z = 0})
		ob:set_properties({textures={item}})
		table.insert(self.childs,ob)
	end,
	add_item=function(self,itemstring,ob)
		local stack = ItemStack(itemstring)
		local na = stack:get_name()
		ob:remove()
		for i,v in pairs(self.items) do
			if v:get_name() == na then
				stack = v:add_item(stack)
				if stack:get_count() == 0 then
					return
				end
				break
			end
		end
		if #self.items < 100 then
			table.insert(self.items,stack)
			self:spawn_item(na)
		else
			minetest.add_item(apos(self.object:get_pos(),0,-0.5),stack)
		end
	end,
	on_step = function(self,dtime)
		local pos = self.object:get_pos()
		if self.v == 0 and not self.derail then
			if self.itemtimer < 0 then
				self.itemtimer = 0.1
				for _, ob in pairs(minetest.get_objects_inside_radius(apos(pos,0,1),1)) do
					local en = ob:get_luaentity()
					if en and en.name == "__builtin:item" then
						self:add_item(en.itemstring,ob)
					end
				end
			elseif not self.user then
				self.itemtimer = self.itemtimer -dtime
			end
			return self
		elseif self.v >= 300 and not self.derail then
			self.fxitimer = self.fxitimer or 0
			self.fxitimer = self.fxitimer > -7 and self.fxitimer -dtime*30 or 0
			self.object:set_properties({textures = {"exacarts_minecart.png^[combine:16x16:0,"..math.ceil(self.fxitimer*16).."=exacarts_superspeed.png"}})
		elseif self.fxitimer then
			self.fxitimer = nil
			self.object:set_properties({textures = {"exacarts_minecart.png"}})
		end

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

		if not self.derail then
			local target = self.currpos and not vector.equals(self.currpos,p) and not vector.equals(self.nextpos,p)
			local skip

-- speed < 15

			if self.v < 15 and not self.rerail and target and self.currpos then
				skip = self.dir.y == 0
				self.object:move_to(self.nextpos)
-- speed > 15: super speed, return to path
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


				local i1 = self.index[self.index_list[1]]
				local d = vector.distance(a.pos,i1.pos)
				local dpos = {x=(i1.pos.x+(a.pos.x-i1.pos.x)/2), y=(i1.pos.y+(a.pos.y-i1.pos.y)/2), z=(i1.pos.z+(a.pos.z-i1.pos.z)/2)}
				local obs = {}
				for _, ob in pairs(minetest.get_objects_inside_radius(dpos, d)) do
					local en = ob:get_luaentity()
					local obpos = ob:get_pos()
					if not (en and (en.exacart or en.name == "__builtin:item")) and not (self.user and ob:get_attach()) then
						local op = minetest.pos_to_string(vector.round(obpos))
						obs[op] = obs[op] or {}
						table.insert(obs[op],ob)
					end
				end

				for n=1,a.n-1 do
					local inx = self.index_list[1]
					if exacarts.on_rail(self.index[inx].pos,self) then
						return
					end
					local obp = minetest.pos_to_string(self.index[inx].pos)
					if obs[obp] then
						for _,v in pairs(obs[obp]) do
							self:hit(v,self.index[inx].dir)
						end
					end
				
					self.index[inx] = nil
					table.remove(self.index_list,1)
				end
				self.v = self.v-(min*0.1)
			end

-- hill
			self.v = self.v + dtime*self.hill
			if self.v < 0 then
				self.v = self.v > -1 and 1 or self.v*-1
				self.hill = -1
				self.dir = {x=self.dir.x*-1,y=self.dir.y*-1,z=self.dir.z*-1}
				self.index = {}
				self.index_list = {}
				self.currpos = nil
				self.nextpos = nil
				return
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

					self.hill = i.dir.y*-10


					self.olddir = {x=self.dir.x,y=self.dir.y,z=self.dir.z}
					self.dir = i.dir
					self:lookat(i.dir)
					self.object:set_velocity({x=self.dir.x*self.v,y=self.dir.y*self.v,z=self.dir.z*self.v})
					local oinx = self.index_list[1]
					local opos = self.index[oinx].pos
					self.index[oinx] = nil
					table.remove(self.index_list,1)
					self.nextpos = i.pos
					self.lastpos = i.pos
					self.currpos = p

-- derail
					if i.pos.y > p.y and (key.jump or not self.index_list[3]) then
						self.derail = true
						self.object:move_to(apos(p,0,1))
						self.object:set_properties({physical = true})
						self.object:set_acceleration({x=0, y=-10, z =0})
						self.index_list = {}
						self.index = {}
						self.derailpos = pos
						self.dir = self.olddir
						self:lookat(self.olddir)
					elseif not self.index_list[2] then
						if default.def(minetest.get_node(self:pointat(2)).name).walkable then
							self.v = 0
							self.object:set_velocity({x=0,y=0,z=0})
							self.object:set_pos(self.lastpos)
						else
							self.derail = true
							self.object:set_properties({physical = true})
							self.object:set_acceleration({x=0, y=-10, z =0})
							self.derailpos = pos
							self.dir = self.olddir
							self:lookat(self.olddir)
						end
						self.index_list = {}
						self.index = {}
					end

					if exacarts.on_rail(opos,self) then
						return
					end

					for _, ob in pairs(minetest.get_objects_inside_radius(opos, 1)) do
						local en = ob:get_luaentity()
						if not (en and (en.exacart or en.name == "__builtin:item")) and not (self.user and ob:get_attach()) then
							self:hit(ob,i.dir)
						end
					end
				end
			end
			return self
		else
-- derail
			local in_map = exacarts.in_map(p)
			if in_map and not (self.derailpos and vector.equals(self.derailpos,p)) and not ((self.currpos and (vector.equals(self.currpos,p) or vector.equals(self.nextpos,p)))) then
				self.derail = nil
				self.rerail = true
				self.nextpos = nil
				self.currpos = nil
				self.derailpos = nil
				self.object:set_properties({physical = false})
				self.object:set_acceleration({x=0, y=0, z =0})
				self.object:set_pos({x=p.x,y=p.y,z=p.z})
				local v = self.object:get_velocity()
				if v.x == 0 and v.z == 0 and v.y ~= 0 then
					self.object:set_velocity({x=0,y=0,z=0})
				end
			elseif in_map then
				self.derail_timer = (self.derail_timer or 0.5) -dtime
				if self.derail_timer < 0 then
					self.derail_timer = 0
					if not self.derail_lastpos or not vector.equals(self.derail_lastpos,pos) then
						self.derail_lastpos = pos
					else
						self.v = 0
						self.nextpos = nil
						self.currpos = nil
					end
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