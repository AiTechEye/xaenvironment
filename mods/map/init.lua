map = {
	user={},
	regimgs={},
	shortcut_textures = {
		["allfaces_optional"] = "map_l.png",
		["default_water.png"] = "map_w.png",
		["default_stone.png"] = "map_s.png",
		["default_grass.png"] = "map_g.png",
		["default_dirt.png"] = "map_d.png",
		["default_cloud.png"] = "map_c.png",
		["default_sand.png"] = "map_a.png",
		["default_snow.png"] = "map_a.png",
		["default_dry_grass.png"] = "map_a.png",
	}
}

--minetest.register_craft({
--	output="map:workbench",
--	recipe={
--		{"group:stick","default:coal_lump","default:gold_ingot"},
--		{"group:wood","group:wood","group:wood"},
--		{"group:wood","group:metalstick","group:wood"},
--	},
--})

minetest.register_node("map:workbench", {
	description = "Map workbench",
	tiles={"default_wood.png^map_map.png","default_wood.png","default_wood.png",},
	groups = {choppy=3,oddly_breakable_by_hand=3,flammable=2,not_in_creative_inventory=1}, --,used_by_npc=1
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.125, -0.5, 0.5, 0.1875, 0.5},
			{-0.5, -0.5, -0.5, -0.4375, 0.125, -0.4375},
			{0.4375, -0.5, -0.5, 0.5, 0.125, -0.4375},
			{0.4375, -0.5, 0.4375, 0.5, 0.125, 0.5},
			{-0.5, -0.5, 0.4375, -0.4375, 0.125, 0.5},
		}
	},
	on_construct=function(pos,but)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input_dye", 1)
		inv:set_size("input_paper", 1)
		inv:set_size("output", 1)
		meta:set_string("formspec",
			"size[8,5]" ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"item_image[2,0;1,1;default:dye]" ..
			"item_image[3,0;1,1;default:paper]" ..
			"list[context;input_dye;2,0;1,1;]" ..
			"list[current_player;main;0,1.3;8,4;]" ..
			"list[context;input_paper;3,0;1,1;]" ..
			"list[context;output;5,0;1,1;]" ..
			"listring[current_player;main]" ..
			"listring[current_name;input_paper]"

			 ..(but and "item_image_button[4,0;1,1;map:map;gen;]" or "")
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname=="input_paper" and stack:get_name() == "default:paper" or listname=="input_dye" and stack:get_name() == "default:dye" then
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local m = minetest.get_meta(pos)
		if m:get_int("running") == 0 then
			local inv = m:get_inventory()
			local ab = inv:get_stack("input_paper",1):get_name() == "default:paper" and inv:get_stack("input_dye",1):get_name() == "default:dye" and inv:get_stack("output",1):get_count() == 0
			minetest.registered_items["map:workbench"].on_construct(pos,ab)
		end
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local m = minetest.get_meta(pos)
		if m:get_int("running") == 0 then
			local inv = m:get_inventory()
			if listname == "output" then
				m:set_string("infotext","")
			end
			local ab = inv:get_stack("input_paper",1):get_name() == "default:paper" and inv:get_stack("input_dye",1):get_name() == "default:dye" and inv:get_stack("output",1):get_count() == 0
			minetest.registered_items["map:workbench"].on_construct(pos,ab)
		end
	end,
	can_dig = function(pos, player)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		return m:get_int("running") == 0 and inv:is_empty("input_paper") and inv:is_empty("input_dye") and inv:is_empty("output")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		local meta = minetest.get_meta(pos)
		if pressed.gen then
			local m = minetest.get_meta(pos)
			local inv = m:get_inventory()
			local paper = inv:get_stack("input_paper",1)
			local dye = inv:get_stack("input_dye",1)
			paper:take_item()
			dye:take_item()
			inv:set_stack("input_paper",1,paper)
			inv:set_stack("input_dye",1,dye)
			minetest.registered_items["map:workbench"].on_construct(pos)

			m:set_string("parts","")
			m:set_int("index",1)
			m:set_int("running",1)
			minetest.get_node_timer(pos):start(0.1)
		end
	end,
	on_timer = function (pos, elapsed)
		local rad = 10
		local ds = rad*2
		local s = 0.4

		local m = minetest.get_meta(pos)
		local parts
		if m:get_string("parts") == "" then
			parts = {}
			for x=-rad,rad do
			for z=-rad,rad do
				table.insert(parts,{lpos={x=-x*s,y=-z*s,z=-0.01},pos={x=pos.x+(x*ds),y=pos.y,z=pos.z+(z*ds)}})
			end
			end
			m:set_string("parts",minetest.serialize(parts))
		else
			parts = minetest.deserialize(m:get_string("parts"))
		end

		local n = #parts
		local stat = m:get_int("running")
		local index = m:get_int("index")
		m:set_string("infotext",(math.floor((100/n * index)*10)*0.1).."% ("..index.."/"..n.." images)")

		if index < n then

			local p = parts[index]
			local t = map.generate_texture(rad,p.pos)
			if t then
				m:set_string("texture"..index,t)
				m:set_int("index",index+1)
			end
		else
			local inv = m:get_inventory()
			if stat == 1 then
				local textures = {}
				for i=1,n do
					table.insert(textures,m:get_string("texture"..i))
				end
				local pp = minetest.pos_to_string(pos)
				local item = ItemStack("map:map")
				local meta = item:get_meta()
				meta:set_string("pos",pp)
				meta:set_string("textures",minetest.serialize(textures))
				meta:set_int("index",1)
				meta:set_string("description","Map "..pp)

				inv:set_stack("output",1,item)
				m:set_int("running",2)
			else
				m:set_string("infotext","100%")
				for i=1,n do
					m:set_string("texture"..i,"")
				end
				m:set_int("running",0)
				return false
			end
		end
		return true
	end
})

minetest.register_tool("map:map", {
	description = "Map",
	groups = {flammable=3,not_in_creative_inventory=1},
	inventory_image = "map_map.png",
	on_use=function(itemstack, user, pointed_thing)
		map.user[user] = map.user[user] or {}
		local p = map.user[user]
		if p.ob and p.ob:get_luaentity() then
			p.ob:remove()
			p.ob = nil
			return
		end

		local m = itemstack:get_meta()
		local index = m:get_int("index")
		if index == 0 then
			minetest.chat_send_player(user:get_player_name(),"The map is corrupted")
			return
		end

		local pos = user:get_pos()
		p.ob = minetest.add_entity(pos,"map:map")
		local en = p.ob:get_luaentity()
		en.user = user
		en.posid = m:get_string("pos")
		en.pos = minetest.string_to_pos(m:get_string("pos"))
		en.textures = minetest.deserialize(m:get_string("textures"))
		en.item = itemstack
		en.index = index

		p.ob:set_attach(user, "",{x=0, y=15, z=5}, {x=0, y=0,z=0},true)
	end
})

minetest.register_entity("map:part",{
	physical = false,
	pointable=false,
	visual="mesh",
	mesh="map_map.obj",
	backface_culling=false,
	textures = {"default_air.png"},
	static_save = false,
	use_texture_alpha=true,
	decoration=true,
	time = 5,
	on_step=function(self, dtime)
		if not self.object:get_attach() then
			self.object:remove()
		end
	end,
})

minetest.register_entity("map:map",{
	physical = false,
	pointable=false,
	visual="mesh",
	visual_size = {x=0.75,y=0.75,z=1},
	mesh="map_map.obj",
	backface_culling=false,
	textures = {"map_map.png"},
	static_save = false,
	decoration=true,
	on_activate=function(self,staticdata,dtime_s)
		self.timer = 1
		self.timer2 = 0
		self.time = 0
		self.saver = 0
		self.parts ={}
	end,
	load=function(self)
		self.time = 1000
		local pos = self.user:get_pos()
		local rad = 10
		local s = 0.4
		local ds = rad*2

		local i = 0
		for x=-rad,rad do
		for z=-rad,rad do
			table.insert(self.parts,{lpos={x=-x*s,y=-z*s,z=-0.01},pos={x=self.pos.x+(x*ds),y=self.pos.y,z=self.pos.z+(z*ds)}})
		end
		end
		for i=1,#self.parts do
			local t = self.textures[i]
			local p = self.parts[i]
			p.ob = minetest.add_entity(pos,"map:part")
			p.ob:set_properties({visual_size = {x=0.1*s,y=0.1*s,z=1}})
			p.ob:set_attach(self.object, "",p.lpos, {x=0, y=0,z=0},true)
			p.ob:set_properties({textures={t}})
		end
		self.time = 0.1
		self.loaded = true
	end,
	on_step=function(self, dtime)
		self.timer = self.timer +dtime
		if self.timer > self.time then
			self.timer = 0
			if not self.loaded then
				self:load()
			else
				self:update(self)
			end
		end
	end,
	update=function(self,load)
		if not (self.object:get_attach() and self.user and self.pos) then
			self.object:remove()
		else

			local pos = self.user:get_pos()

--cursor

			if not self.cursor then
				self.cursor = minetest.add_entity(pos,"map:part")
				self.cursor:set_properties({visual_size = {x=0.04,y=0.04,z=1},textures={"map_cursor.png"}})
			end
			local x = self.pos.x-pos.x
			local z = self.pos.z-pos.z
			local ux = math.abs(x) < 210 and x*0.0199 or (210*x/math.abs(x))*0.0199
			local uz = math.abs(z) < 210 and z*0.0199 or (210*z/math.abs(z))*0.0199
			self.cursor:set_attach(self.object, "",{x=ux,y=uz,z=-0.011}, {x=0, y=0,z=(self.user:get_look_horizontal() * 180 / math.pi)+180},true)
--map update

			self.timer2 = self.timer2 + 0.1
			if self.timer2 < 1 then
				return
			end

			self.timer2 = 0
			local rad = 10

			if self.index > #self.parts then
				self.index = 1
			end

			local p = self.parts[self.index]
			local t = map.generate_texture(rad,p.pos)
			if not t then
				return
			end
			self.saver = self.saver +1
			self.textures[self.index] = t
			local itname = self.user:get_wielded_item():get_name()
			if itname == "map:map" then
				if self.saver > 100 then
					local item = self.user:get_wielded_item()
					local meta = item:get_meta()
					if meta:get_string("pos") == self.posid then
						self.saver = 0
						meta:set_string("textures",minetest.serialize(self.textures))
						meta:set_int("index",self.index)
						self.user:set_wielded_item(item)
					else
						self.user = nil
						return
					end
				end
			elseif itname ~= "default:telescopic" then
				self.user = nil
				return
			end
			p.ob:set_properties({textures={t}})
			self.index = self.index +1

		end
	end
})

--minetest.register_chatcommand("t", {	--using while testing
--	func = function(name, param)
--		map.t=tonumber(param)
--	end
--})


map.generate_texture=function(rad,pos,maxram)
	pos=vector.round(pos)

	local image_resolution = 16
	local map_size = ((rad*2)*image_resolution)+1
	maxram = maxram or 20

	local air=minetest.get_content_id("air")
	local pos1 = vector.subtract(pos, rad)
	local pos2 = vector.add(pos, rad)
	local vox = minetest.get_voxel_manip()
	local min, max = vox:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vox:get_data()
	local imgmap = {}
	local texture = "[combine:"..map_size.."x"..map_size
	local accepted_drawtypes = {
		allfaces_optional=true,
		glasslike=true,
		normal=true,
		liquid=true,
	}

	for x = -rad,rad do
	for z = -rad,rad do
	for y = rad,-rad,-1 do
		local v = area:index(pos.x+x,pos.y+y,pos.z+z)
		local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		local i = x..","..z
		local id = data[v]
		if not imgmap[i] and id ~= air then
			if maxram < tonumber(memory_mb()) then
				print(memory_mb())
				goto out
			end

			local def = default.def(minetest.get_name_from_content_id(id))
			local img = ""
			local tiles = def.tiles or def.special_tiles or {}
			local reg = map.regimgs[def.name]

			if reg then
				img = reg
			elseif def.drawtype == "allfaces_optional" then
				img = map.shortcut_textures["allfaces_optional"]
			elseif type(tiles[1]) == "string" then
				img = tiles[1]
			elseif type(tiles) == "table" and type(tiles.tile) == "string" then
				img = tiles.tile
			end

			if img and accepted_drawtypes[def.drawtype] then
				img = map.shortcut_textures[img] or img

				if not reg then
					if img:find("%(") then
						img = img:sub(1,img:find("%(")-1)
					end
					if img:find("%[") then
						img = img:sub(1,img:find("%^")-1)
						if img:find("%[") then
							img = ""
						end
					elseif img:find("%^") then
						img = img:gsub("%^","\\%^"):gsub(":","\\:")
					end
				end

				if img ~= "" then
					map.regimgs[def.name] = img
					imgmap[i] = true
					local X = (-rad+x)*image_resolution
					local Z = (rad+z)*image_resolution
					texture = texture .. ":"..-X..","..Z.."="..img
				end
			end
		end
	end
	end
	end
	::out::

	if #texture > 65000 then
		texture = texture:sub(1,65000)
		for i=#texture,1,-1 do
			if texture:sub(i-3,i) == ".png" then
				texture = texture:sub(1,i)
				break
			end
		end
	end
	return texture
end

minetest.register_on_leaveplayer(function(player)
	map.user[player] = nil
end)