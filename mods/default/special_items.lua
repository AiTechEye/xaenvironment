-- Shredder ============

minetest.register_node("default:shredder", {
	description="Shredder",
	drop = "default:shredder",
	inventory_image = "materials_gear_metal.png",
	tiles={"default_steelblock.png^materials_gear_metal.png"},
	groups = {cracky=2,level=2,store=10000,on_load=1,on_update=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype="light",
	paramtype2="facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.3, 0.5},
		}
	},
	on_load = function(pos)
		minetest.add_entity(pos,"default:shredder")
	end,
	on_place=function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local name = placer:get_player_name()
		if default.defpos(pointed_thing.under,"buildable_to") then
			pos = pointed_thing.under
		end
		local p = minetest.dir_to_facedir(placer:get_look_dir())
		local xp = vector.offset(pos,1,0,0)
		local xm = vector.offset(pos,-1,0,0)
		local zp = vector.offset(pos,0,0,1)
		local zm = vector.offset(pos,0,0,-1)
		local f = {{0,2,zp},{1,3,xp},{2,0,zm},{3,1,xm}}
		local t = f[p+1]

		if t and default.defpos(t[3],"buildable_to") and not minetest.is_protected(t[3], name) then
			minetest.set_node(pos,{name="default:shredder",param2=t[1]})
			minetest.set_node(t[3],{name="default:shredder",param2=t[2]})
			minetest.add_entity(pos,"default:shredder"):get_luaentity():update()
			minetest.add_entity(t[3],"default:shredder"):get_luaentity():update()
			itemstack:take_item()
			return itemstack
		end
	end,
	after_destruct=function(pos,oldnode)
		local p = oldnode.param2
		local f = {vector.offset(pos,0,0,1),vector.offset(pos,1,0,0),vector.offset(pos,0,0,-1),vector.offset(pos,-1,0,0)}
		local t = f[p+1]
		if minetest.get_node(t).name == "default:shredder" then
			minetest.remove_node(t)
		end
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, 0.2)) do
			local en = ob:get_luaentity()
			if en and en.name == "default:shredder" then
				ob:remove()
			end
		end
	end,
	on_update = function(pos)
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en = ob:get_luaentity()
			if en and en.name == "default:shredder" then
				ob:get_luaentity():update()
			end
		end
	end
})

minetest.register_entity("default:shredder",{
	visual="mesh",
	physical=false,
	pointable=false,
	mesh = "default_shredder.obj",
	static_save = false,
	textures={"default_steelblock.png"},
	on_activate=function(self)
		local pos = self.object:get_pos()
		local n = minetest.get_node(pos).param2
		self.dir = vector.new(0,0,0)
		local d = {math.pi/2,0,-math.pi/2,math.pi}
		self.dir.y = d[n+1]
		self.destroy = default.defpos(vector.offset(pos,0,-1,0),"walkable")
		if n == 0 or n == 1 then
			self.dir.z = math.pi/4
		end
	end,
	update=function(self)
		local pos = self.object:get_pos()
		local p = minetest.get_node(pos).param2
		self.destroy = default.defpos(vector.offset(pos,0,-1,0),"walkable")
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
			local en = ob:get_luaentity()
			if en and en.name == "default:shredder" and minetest.get_node(ob:get_pos()).param2 == p then
				self.dir.z = en.dir.z
				return
			end
		end
	end,
	shredding=function(self,ob)
		self.limit = self.limit + 1

		if os.time()-self.limit_timeout > 0.1 then
			self.limit_timeout = os.time()
			self.limit = 0
		end
		if self.limit > 10 then
			return
		end
	
		local img
		local en = ob:get_luaentity()
		local pos = ob:get_pos()

		if en and en.name == "__builtin:item" and en.itemstring then
			local item = ItemStack(en.itemstring)
			local def = minetest.registered_items[item:get_name()]
			if def.type == "node" then
				local tiles = def.tiles or def.special_tiles or {}
				if type(tiles[1]) == "table" and tiles[1].name then
					img = tiles[1].name
				elseif type(tiles[1]) == "string" then
					img = tiles[math.random(1,#tiles)]
				end
			else
				img = def.wield_image ~= "" and def.wield_image or def.inventory_image
			end

			local craft = minetest.get_craft_recipe(item:get_name())
			if craft.items and craft.type == "normal" and ItemStack(craft.output):get_count() == 1 then
				local same_items = false
				for i,v in pairs(craft.items) do
					if v == item then
						if same_items == false then
							same_items = true
						else
							ob:remove()
						end
					end
				end
				for i,v in pairs(craft.items) do
					local a,b = minetest.get_craft_result({method = "normal",width = 3, items = {v}})
					if a.item:get_name() == item:get_name() or minetest.get_item_group(v,"not_recycle_return") > 0 then
						ob:remove()
					elseif v:sub(1,6) == "group:" then
						local g = v:sub(7,-1)
						for i2,v2 in pairs(minetest.registered_items) do
							if v2.groups and (v2.groups[g] or 0) > 0 and not v2.groups.not_recycle_return then
								craft.items[i]=i2
								break
							end

						end
					end
				end

				local w = item:get_wear()
				for i,v in pairs(craft.items) do
					if v == item:get_name() or not minetest.registered_items[v] or w > 0 and math.random(1,3) > 1 then
						craft.items[i] = ""
					end
				end

				if #craft.items > 0 then
					for i,v in pairs(craft.items) do
						if v ~= "" then
							minetest.add_item(pos,v):set_velocity(vector.new(math.random(-0.5,0.5),math.random(1,3),math.random(-0.5,0.5)))
						end
					end
				end
			elseif not self.destroy then
				local spos = self.object:get_pos()
				minetest.add_item(vector.offset(spos,0,-0.5,0),item:get_name()):set_velocity(vector.new(math.random(-0.5,0.5),math.random(-3,0),math.random(-0.5,0.5)))
			end
			local c = item:get_count()-1
			if c > 0 and not self.destroy then
				en.itemstring = item:get_name() .. " " .. c
			else
				ob:remove()
			end
		else
			img = ob:get_properties().textures[1]
		end

		if type(img) == "string" then
			minetest.sound_play("default_radioactivity_meter", {object=self.object, gain = 4,max_hear_distance = 10,pitch=math.random(0.8,2)})
			minetest.add_particle({
				pos=vector.offset(pos,math.random(-0.5,0.5),math.random(-0.5,0.5),math.random(-0.5,0.5)),
				acceleration={x=0,y=-10,z=0},
				velocity=vector.new(math.random(-2,2),math.random(0,2),math.random(-2,2)),
				expirationtime=5,
				size=math.random(0.5,3),
				collisiondetection=true,
				collision_removal=true,
				texture="[combine:16x16:"..math.random(-16,0)..","..math.random(-16,0).."="..img,
			})
		end
		if ob and ob:is_player() and ob:get_hp() <= 0 then
			ob:respawn()
		elseif ob and not (en and en.name == "__builtin:item") then
			default.punch(ob,ob,2)
		end
	end,
	on_step=function(self,dtime,moveresult)
		self.dir.z = self.dir.z + dtime
		self.object:set_rotation(self.dir)
		self.time = self.time + dtime

		if os.time() - self.soundt >= 1 then
			self.soundt = os.time()
			minetest.sound_play("default_engine_electric2", {object=self.object, gain = 4,max_hear_distance = 10,pitch=1})
		end

		if self.time > self.timer then
			self.time = 0
			local pos = self.object:get_pos()
			local d = 100
			for _, ob in pairs(minetest.get_objects_inside_radius(pos, self.rad)) do
				local en = ob:get_luaentity()
				if not (en and en.decoration) then
					local obp = ob:get_pos()
					local y = ob:get_velocity().y
					if obp.y > pos.y then
						d = math.min(d,vector.distance(pos,obp))
						self.nearest = d
						if d <= 3 then
							self.rad = 3
							self.timer = 0.1
						elseif d <= 5 then
							self.rad = 5
							self.timer = 0.3
						elseif d <= 12 then
							self.rad = 10
							self.timer = 0.7
						elseif d <= 20 then
							self.rad = 1
							self.timer = 1
						end
						if d < 1.5 and obp.y > pos.y and y < 0.01 and y > -0.01 then
							self:shredding(ob)
						end
					end
				end
			end
			if d == 100 and self.rad ~= 20 then
				self.rad = 20
				self.timer = 2
			end
		end
	end,
	decoration = true,
	rad = 20,
	time = 0,
	timer = 2,
	soundt = os.time()+2,
	limit=0,
	limit_timeout=os.time(),
})

-- Trashbag ============
for i,v in ipairs({{scale=0.5,box={-0.25,-0.5,-0.25,0.25,-0.1,0.25},bag=1}, {scale=0.75,box={-0.35,-0.5,-0.35,0.35,0.1,0.35},bag=2}, {scale=0.9,box={-0.4,-0.5,-0.4,0.4,0.1,0.4},bag=2}, {scale=1.1,box={-0.5,-0.5,-0.5,0.5,0.35,0.5},bag=3}}) do
minetest.register_node("default:trashbag"..i, {
	description = "Trash bag",
	drawtype = "mesh",
	drop = "materials:plasticbag",
	visual_scale = v.scale,
	mesh = "default_trashbag"..v.bag..".obj",
	tiles={"default_trash.png"},
	groups = {dig_immediate=2,oddly_breakable_by_hand=3,used_by_npc=1,falling_node=1,flammable=3,trashbag=1,treasure=1},
	sounds = default.node_sound_leaves_defaults(),
	paramtype = "light",
	selection_box = {type = "fixed",fixed=v.box},
	collision_box = {type = "fixed",fixed=v.box},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 4)
		m:set_string("formspec",
			"size[8,5]" ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"list[context;main;2,0;4,1;]" ..
			"list[current_player;main;0,1.3;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[current_name;main]"
		)
	end,
	update=function(pos, player)
		local p = 0
		local m = minetest.get_meta(pos)
		local main = m:get_inventory():get_list("main")
		for i,v in ipairs(main) do
			if v:get_count() > 0 then
				p = p + 1
			end
		end
		if p == 0 then
			minetest.remove_node(pos)
		else
			minetest.swap_node(pos,{name="default:trashbag"..p})
		end
	end,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return 0
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local m = minetest.get_meta(pos)
		if m:get_inventory():is_empty("main") then
			local pinv = player:get_inventory()
			if pinv:room_for_item("main","materials:plasticbag") then
				pinv:add_item("main","materials:plasticbag")
			else
				minetest.item_drop(ItemStack("materials:plasticbag"),player,pos)
			end
			minetest.remove_node(pos)
		else
			minetest.registered_items["default:trashbag1"].update(pos)
		end
	end,
	on_punch=function(pos, node, player, pointed_thing)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		local pinv = player:get_inventory()
		local main = inv:get_list("main")
		local owner = m:get_string("owner")
		if not main then
			return
		end
		for i,v in pairs(main) do
			if pinv:room_for_item("main",v) then
				pinv:add_item("main",v)
				inv:remove_item("main",v)
			elseif pinv:room_for_item("craft",v) then
				pinv:add_item("craft",v)
				inv:remove_item("main",v)
			else
				return
			end
		end
		if inv:is_empty("main") then
			if pinv:room_for_item("main","materials:plasticbag") then
				pinv:add_item("main","materials:plasticbag")
			else
				minetest.item_drop(ItemStack("materials:plasticbag"),player,pos)
			end
			minetest.remove_node(pos)
		end
	end
})
end

-- XE ============
local ncinv
for i=1,6 do
minetest.register_node("default:xe"..i, {
	description = "XE",
	drop = "default:xe1",
	tiles= {"default_xe.png"},
	groups = {cracky=3,xe=1, not_in_creative_inventory= ncinv,radioactive=15},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	paramtype = "light",
	damage_per_second = 5,
	light_source = i+8,
	sounds = default.node_sound_stone_defaults(),
	manual_page = not ncinv and "default:xe1 Please don't carry this alien ore home." or nil,
	on_timer = function(pos, elapsed)
		local m = minetest.get_meta(pos)
		local s = m:get_int("state") 
		local l = m:get_int("level")

		if s == 0 and l > 1 then
			l = l - 1
		elseif s == 1 and l < 5 then
			
			l = l + 1
		else
			s = s == 0 and 1 or 0
		end

		minetest.swap_node(pos,{name="default:xe"..l+1}) 
		m:set_int("state",s) 
		m:set_int("level",l)
		return true
	end,
	on_punch = function(pos, node, player, itemstack, pointed_0thing)
		local dir = {[0]={y=-1},[1]={y=1},[2]={x=-1},[3]={x=1},[4]={z=-1},[5]={z=1}}
		for i,v in pairs(dir) do
			local p = vector.offset(pos,v.x or 0,v.y or 0, v.z or 0)
			if default.defpos(p,"buildable_to") then
				minetest.set_node(p,{name="default:xe_spike",param2=i}) 
				minetest.get_node_timer(p):start(math.random(2,5))
			end
		end
		default.punch(player,player,3)
		minetest.get_node_timer(pos):start(0.5)
	end,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.5)
		default.set_radioactivity(pos,15)
	end,
	on_destruct = function(pos)
		default.remove_radioactivity(pos)
	end,
})
ncinv = 1
end

minetest.register_node("default:xe_spike", {
	description = "XE Spike",
	drop = "",
	tiles = {"default_xe.png"},
	groups = {cracky=1,level=3,not_in_creative_inventory=1,igniter=3,radioactive=5},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	damage_per_second = 5,
	walkable = false,
	light_source = 8,
	on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
	end,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.25, 0.1875},
			{-0.125, -0.25, -0.125, 0.125, 0.0625, 0.125},
			{-0.0625, 0.0625, -0.0625, 0.0625, 0.3125, 0.0625},
			{-0.025, 0.3125, -0.025, 0.025, 0.5, 0.025},
		}
	},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		default.set_radioactivity(pos,5)
	end,
	on_destruct = function(pos)
		default.remove_radioactivity(pos)
	end,
})

minetest.register_node("default:xe_crystal", {
	description = "XE Crystal",
	tiles = {"default_xe.png"},
	groups = {cracky=1,level=3,igniter=3,radioactive=10},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	damage_per_second = 5,
	light_source = 8,
	drawtype = "mesh",
	mesh="default_crystal.obj",
	visual_scale = 0.3,
	collision_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0, 0.3}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}
	},
	sounds = default.node_sound_glass_defaults(),
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.5)
		default.set_radioactivity(pos,15)
	end,
	on_destruct = function(pos)
		default.remove_radioactivity(pos)
	end,
})

-- atom core ============

minetest.register_node("default:core_orbit", {
	tiles = {"default_xe.png"},
	groups = {not_in_creative_inventory=1},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.05, -0.05, 0.5, 0.05, 0.05, 0.6},
		}
	},
})

minetest.register_entity("default:core_orbit",{
	physical = false,
	pointable = false,
	glow=1,
	visual = "wielditem",
	textures = {"default:core_orbit"},
	static_save = false,
	decoration=true,
	on_activate=function(self, staticdata)
		self.dir = vector.new()
		self.dim = 1
	end,
	on_step=function(self,dtime)
		if self.dim == 1 then
			self.dir.x = self.dir.x + dtime*10
		elseif self.dim == 2 then
			self.dir.y = self.dir.y + dtime*9
		else
			self.dir.x = self.dir.x + dtime*8
			self.dir.y = self.dir.y + dtime*7
		end
		self.object:set_rotation(self.dir)
	end
})

minetest.register_node("default:atom_core", {
	description = "Atom core",
	tiles= {
		{
			name = "default_xe.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 1,
				length = 1,
			}
		}
	},
	drawtype="mesh",
	mesh = "default_atomcore.obj",
	groups = {cracky=3,on_load=1,radioactive=20},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 14,
	sounds = default.node_sound_stone_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.31, -0.31, -0.31, 0.31, 0.31, 0.31}
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3}
	},
	on_construct=function(pos)
		minetest.registered_nodes["default:atom_core"].on_load(pos)
		default.set_radioactivity(pos,20)
	end,
	on_destruct = function(pos)
		default.remove_radioactivity(pos)
	end,
	on_load = function(pos)
		minetest.add_entity(pos,"default:core_orbit")
		local y = minetest.add_entity(pos,"default:core_orbit")
		local z = minetest.add_entity(pos,"default:core_orbit")
		y:get_luaentity().dim = 2
		z:get_luaentity().dim = 3
	end,
	after_destruct=function(pos)
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en = ob:get_luaentity()
			if en and en.name == "default:core_orbit" then
				ob:remove()
			end
		end
	end
})

-- chest spawner ============

minetest.register_node("default:treasure_chest_spawner", {
	description = "Treasure chest spawner",
	tiles = {
		"default_goldblock.png^default_chest_top.png",
		"default_goldblock.png^default_chest_top.png",
		"default_goldblock.png^default_chest_side.png",
		"default_goldblock.png^default_chest_side.png",
		"default_goldblock.png^default_chest_side.png",
		"default_goldblock.png^default_chest_front.png",
	},
	paramtype2 = "facedir",
	groups = {choppy=3,on_load=1,not_in_craftguide=1},
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("level",1)
		m:set_int("chance",8)
		m:set_string("formspec","size[2,1]button[0,0;2,1;setup;Setup]")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if formname == "" then
			local m = minetest.get_meta(pos)

			if not pressed.set then
				local level = pressed.level or m:get_int("level")
				local chance = pressed.chance or m:get_int("chance")

				m:set_int("level",level)
				m:set_int("chance",chance)
				m:get_inventory():set_size("main", 32)
				m:get_inventory():set_size("setchest", 1)
				m:set_string("infotext","Setup")
				m:set_string("formspec",
					"size[8,9]listcolors[#77777777;#777777aa;#000000ff]"
					.. "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";setchest;0,0;1,1;]"
					.. "dropdown[1,0;1,1;level;1,2,3;"..level.."]"
					.. "dropdown[2,0;1,1;chance;1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32;"..chance.."]"
					.. "button_exit[3,0;2,1;set;Set]"
					.. "list[current_player;main;0,5;8,4;]"
					.. "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,1;8,4;]"
					.. "tooltip[level;Treasure level]"
					.. "tooltip[set;Ready for spawning on next load]"
					.. "tooltip[0,0;1,1;Chest to place]"
					.. "tooltip[chance;Chance to spawn items]"
					.. "tooltip[1,5;8,4;Items to set or leave empty for random items]"
					.. "listring[current_player;main]"
					.. "listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
				)
			else
				local n = minetest.get_node(pos)
				local item = m:get_inventory():get_stack("setchest",1)
				local level = m:get_int("level")
				local chance = m:get_int("chance")
				local items = ""

				if not m:get_inventory():is_empty("main") then
					for i,v in ipairs(m:get_inventory():get_list("main")) do
						items = items .. v:get_name() .. ","
					end
				end

				minetest.set_node(pos, n)
				minetest.after(0.1,function()
					local m = minetest.get_meta(pos)
					m:set_string("formspec","")
					m:set_int("set",1)
					m:set_int("level",level)
					m:set_int("chance",chance)
					m:set_string("item",item:get_name())
					m:set_string("items",items)
				end)
			end
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return minetest.registered_nodes[stack:get_name()] and 1 or 0
	end,
	on_load = function(pos)
		local m = minetest.get_meta(pos)
		local item = m:get_string("item")
		local items = m:get_string("items")
		local level = m:get_int("level")
		local chance = m:get_int("chance")
		local node = minetest.get_node(pos)
		if m:get_int("set") == 1 then
			node.name = item
			default.treasure({
				pos = pos,
				node = item ~= "" and minetest.registered_nodes[item] and node or nil,
				level = level,
				chance = chance,
				items = items ~= "" and items:split(",") or nil
			})
			local node2 = minetest.get_node(pos)
			node2.param2 = node.param2
			minetest.after(0,function()
				minetest.swap_node(pos, node2)
			end)

		end
	end
})

-- qblock ============

local qblock = function(def)
	minetest.register_node(minetest.get_current_modname() ..":qblock_".. (def.name or def.color), {
		description = def.description or "!",
		manual_page = def.manual_page,
		on_load=def.on_load,
		after_place_node = def.after_place_node,
		tiles={
			"[combine:1x1:0,0=default_cloud.png^[colorize:#"..def.color.."FF^[resize:21x21^([combine:21x21:0,-21=default_qblock.png)",
			"[combine:1x1:0,0=default_cloud.png^[colorize:#"..def.color.."FF^[resize:21x21^([combine:21x21:0,-21=default_qblock.png)",
			"[combine:1x1:0,0=default_cloud.png^[colorize:#"..def.color.."FF^[resize:21x21^([combine:21x21:0,0=default_qblock.png)",
		},
		groups = def.groups or {dig_immediate = 2,not_in_creative_inventory=1, store=def.store},
		sounds = default.node_sound_wood_defaults(),
	})
end

qblock({color="FF0000",store=20000,description="No hunger",manual_page="default:qblock_FF0000 default:qblock_1c7800 default:qblock_e29f00 default:qblock_800080 default:qblock_0000FF default:qblock_FFFFFF This kind of special blocks gives you abilities.\nPut in the abilities manu, and pay as you go\n\nThe abilities is:\n\n- No hunger/thirst.\n- Fly as a bird: transform you to a bird, look up & jump to transform, release jump to transform back, press up to speed up.\n- Fire resistance: resistance to fire/lava.\n- Immortal: immortal to to everything except fire/lava.\n- No drowning in water.\n- Light in darkness: gives you some light in darkness."})
qblock({color="1c7800",store=50000,description="Fly as a bird"})
qblock({color="e29f00",store=30000,description="Fire resistance"})
qblock({color="800080",store=50000,description="Immortal"})
qblock({color="0000FF",store=20000,description="No water drowning"})
qblock({color="FFFFFF",store=10000,description="Light in darkness"})