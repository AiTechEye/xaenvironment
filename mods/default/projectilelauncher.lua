--projectilelauncher.register_bullet("bullet",{
--	description="Bullet",
--	texture="default_wood.png^[colorize:#050",
--	itemtexture = "",
--	bullettexture="",
--	damage=3,
--	craft_count=16,
--	groups={treasure=2,store=2},
--	damage_by_bullet = false,				--object punched by bullet, not user
--	on_trigger=function(itemstack, user) then
--		return true to cancel
--	end,
--	before_bullet_released=function(itemstack, user,pos, dir)
--		return cancel=false,take_bullet=nil (true to take)
--	end,
--	on_shoot=function(itemstack, user,bullet)
--	end,
--	on_hit_node=function(self,user,pos)
--	end,
--	on_hit_object=function(self,user,target,pos)
--	end,
--	craft={
--		{"default:ruby","default:iron_ingot"},
--	}
--})


projectilelauncher={
	registed_bullets={},
	user = {},
	zoom_check=function(user,index)
		minetest.after(0.1,function(user)
			if user and user:get_pos() and user:get_wield_index() ~= index then
				user:set_fov(0,false,0.01)
			else
				projectilelauncher.zoom_check(user,index)
			end
		end,user)
	end,
}

minetest.register_craft({
	output = "default:projectile_launcher",
	recipe = {
		{"default:uraniumactive_ingot","default:diamond","default:taaffeiteblock"},
		{"default:bucket","exatec:bow","exatec:pcb"},
		{"materials:diode","materials:tube_metal","materials:plastic_sheet"}
	}
})
minetest.register_craft({
	output = "default:lazer_automatic_bullet",
	recipe = {{"default:lazer_bullet"}}
})

projectilelauncher.register_bullet=function(name,def)
	if name==nil or name=="" then return false end
	local defname = minetest.get_current_modname() ..":"..name.."_bullet"
	def.damage = def.damage or 1

	def.launch_sound = def.launch_sound or "default_projectilelauncher_shot13"
	def.hit_sound = def.hit_sound or "default_projectilelauncher_shot11"
	def.texture = def.texture or "default_ironblock.png"
	def.groups = def.groups or {}
	def.groups.bullet = 1
	def.groups.treasure = def.groups.treasure or 1
	def.bullettexture = def.bullettexture or (def.texture .. "^default_alpha_gem_round.png^[makealpha:0,255,0")
	def.textures={def.bullettexture}

	projectilelauncher.registed_bullets[defname]=def

	minetest.register_craftitem(defname, {
		stack_max = def.stack_max or 99,
		description = def.description or name,
		inventory_image = (def.itemtexture or def.texture and def.texture .. "^armor_alpha_hand.png^[makealpha:0,255,0") or def.inventory_image or "default_wood.png^armor_alpha_hand.png^[makealpha:0,255,0",
		groups = def.groups,
		damage = def.damage,
	})
	if def.craft then
		def.craft_count= def.craft_count or 4
		minetest.register_craft({
			output = defname .." " .. def.craft_count,
			recipe = def.craft
		})
	end
end

minetest.register_tool("default:projectile_launcher", {
	description = "Projectile launcher (shoots bullets)",
	inventory_image = "projectile_launcher.png",
	wield_scale={x=1.5,y=1.5,z=2},
	range = 2,
	groups = {store=5000},
	manual_page = "default:projectile_launcher default:lazer_bullet default:lazer_automatic_bullet default:lightning__bullet default:flash__bullet default:build__bullet default:activate__bullet default:blob__bullet default:torch_bullet default:hookshot_bullet \nThe projectile launcher is a hybrid of a tool and weapon,\nthat you can load with bullets in its inventory instead of carrying it in the inventory like the bows.\nRight click/place it to open its inventory and add items that looks like those above.\nYou can also add a telescope, hold aux1 (run) to zoom in/out.\nAnd you can enable autoaim.",
	on_use =function(itemstack, user, pointed_thing)
		projectilelauncher.new_inventory(itemstack, user)
		local p = projectilelauncher.user[user:get_player_name()]
		local z = user:get_fov()
		local key=user:get_player_control()
		if key.aux1 and p.zoom == 1 then
			if z == 0 then
				z = 30
			elseif z <= 5 then
				z = 5
			else
				z = z - 5
			end
			user:set_fov(z,false,0.1)
			projectilelauncher.zoom_check(user,user:get_wield_index())
			p.bulletpreview_started = true
			return itemstack
		end

		projectilelauncher.shoot(itemstack, user)
	end,
	on_place = function(itemstack, user, pointed_thing)
		projectilelauncher.show_inventory(itemstack, user)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		projectilelauncher.new_inventory(itemstack, user)
		local p = projectilelauncher.user[user:get_player_name()]
		local z = user:get_fov()
		local key=user:get_player_control()
		if key.aux1 and p.zoom == 1 then

			if z >= 30 then
				z = 0
			elseif z > 0 then
				z = z + 5
			end

			user:set_fov(z,false,0.1)
			projectilelauncher.zoom_check(user,user:get_wield_index())
			return itemstack
		end

		local index = p.index
		for i=1,15 do
			index = index +1
			if index > 8 then
				index = 1
			end
			local item = p.inv:get_stack("main",index):get_name()
			if item ~= "" then
				p.index = index
				projectilelauncher.update_inventory(itemstack, user, true)
				p.bulletpreview_time = 1
				return itemstack
			end
		end
		minetest.sound_play("default_projectilelauncher_out", {pos=user:get_pos()})
	end,
	on_just_selected=function(itemstack, user)
		projectilelauncher.new_inventory(itemstack, user)

		local p = projectilelauncher.user[user:get_player_name()]
		local pos1 = user:get_pos()
		local stack = p.inv:get_stack("main",p.index)
		local def = projectilelauncher.registed_bullets[stack:get_name()]
		if def and def.on_just_selected then
			def.on_just_selected(itemstack, user, pos1)
		end
	end,
	on_previous=function(itemstack, user)
		projectilelauncher.new_inventory(itemstack, user)

		local p = projectilelauncher.user[user:get_player_name()]
		local pos1 = user:get_pos()
		local stack = p.inv:get_stack("main",p.index)
		local def = projectilelauncher.registed_bullets[stack:get_name()]
		if def and def.on_previous then
			def.on_previous(itemstack, user, pos1)
		end
	end,
	on_step=function(itemstack, user, dtime)
		local p = projectilelauncher.user[user:get_player_name()]
		if not p then
			projectilelauncher.new_inventory(itemstack, user)
			p = projectilelauncher.user[user:get_player_name()]
		elseif p.time < 0.1 or user:get_player_control().aux1 and p.zoom == 1 then
			p.time = p.time + dtime
			return
		end

		p.time = 0

		local pos1 = user:get_pos()
		local stack = p.inv:get_stack("main",p.index)
		local def = projectilelauncher.registed_bullets[stack:get_name()]
		if def and def.on_step then
			def.on_step(itemstack, user, pos1, dtime)
		end

		if p.bulletpreview_started then
			local image = minetest.registered_items[stack:get_name()].inventory_image .."^(default_chest_top.png^[colorize:#0ff)"
			p.bulletpreview_started = nil
			p.bulletpreview_time = 1

			if p.bulletpreview then
				user:hud_change(p.bulletpreview, "text", image)
				user:hud_change(p.bulletpreview_text, "text", stack:get_count())
			else
				p.bulletpreview_text = user:hud_add({
					hud_elem_type="text",
					scale = {x=2,y=2},
					text = stack:get_count(),
					number=0xFFFFFF,
					offset={x=-50,y=110},
					position={x=1,y=0},
					alignment=-1,
				})
				p.bulletpreview = user:hud_add({
					hud_elem_type="image",
					scale = {x=5,y=5},
					position={x=1,y=0},
					text=image,
					offset={x=-50,y=50},
				})
			end
		elseif p.bulletpreview_time and p.bulletpreview_time > 0 then
			p.bulletpreview_time = p.bulletpreview_time - dtime*5
			if p.bulletpreview_time <= 0 then
				p.bulletpreview_index = nil
				user:hud_remove(p.bulletpreview)
				user:hud_remove(p.bulletpreview_text)
				p.bulletpreview = nil
			end
		end

		if p.autoaim == 1 then
			local dir, target = projectilelauncher.autoaim(user)
			if target then
				if not p.cross_hud then
					p.cross_hud = user:hud_add({
						hud_elem_type="image_waypoint",
						scale = {x=2, y=2},
						name="aim",
						text="default_cross.png^[invert:rgb"
					})
				end
				user:hud_change(p.cross_hud, "world_pos", target)
			elseif p.cross_hud then
				user:hud_remove(p.cross_hud)
				p.cross_hud = nill
			end
		end
	end
})

projectilelauncher.user_height=function(user)
	local pos = user:get_pos()
	return (user:get_player_control().sneak or minetest.get_item_group(minetest.get_node(pos).name,"liquid") > 0) and 0.6 or 1.5
end

projectilelauncher.bulletpos=function(user)
	local pos = user:get_pos()
	local height = projectilelauncher.user_height(user)
	local pos2 = vector.offset(pos, 0, height, 0)
	local dir = user:get_look_dir()
	return vector.add(pos2,vector.multiply(dir,height == 1.5 and 0.1 or 0.5))
end

projectilelauncher.autoaim=function(user)
	local dir = user:get_look_dir()
	local pos1 = projectilelauncher.bulletpos(user)
	local height = projectilelauncher.user_height(user)
	local target
	local d = 100

	for _, ob in pairs(minetest.get_objects_inside_radius(pos1, 100)) do
		local en = ob:get_luaentity()
		if ob ~= user and (en and en.examob and en.dead == nil or ob:is_player()) then
			local pos2 = ob:get_pos()
			local d2 = vector.distance(pos1,pos2)
			local pos3 = vector.normalize(vector.subtract(pos2, pos1))
			local deg = math.acos((pos3.x*dir.x)+(pos3.y*dir.y)+(pos3.z*dir.z)) * (180 / math.pi)

			if d2 < d and not (deg < 0 or deg > 50) then		
				for v in minetest.raycast(pos1,pos2) do
					if v and v.type == "node" then
						break
					elseif v and v.type == "object" and v.ref == ob then
						d = d2
						target = pos2
						break
					end
				end
			end
		end
	end
	if target then
		return vector.new((target.x-pos1.x)/d,(target.y-pos1.y)/d,(target.z-pos1.z)/d), target
	end
end


projectilelauncher.new_inventory=function(itemstack, user)
	local name = user:get_player_name()
	if not projectilelauncher.user[name] then
		projectilelauncher.user[name] = {
			time = 0,
			index = 0,
			autoaim = 0,
			zoom = 0,
			inv = minetest.create_detached_inventory("projectilelauncher_"..name, {
				allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
					return (to_index ~= 9 and from_index ~= 9) and count or 0
				end,
				allow_put = function(inv, listname, index, stack, player)
					return (index < 9 and minetest.get_item_group(stack:get_name(),"bullet") > 0 and stack:get_count()) or (index == 9 and stack:get_name() == "default:telescopic" and stack:get_count()) or 0
				end,
				allow_take = function(inv, listname, index, stack, player)
					if index == 9 then
						local p = projectilelauncher.user[player:get_player_name()]
						player:set_fov(0,false,0.01)
						p.zoom = 0
						projectilelauncher.update_inventory(p.itemstack, user,true)
						minetest.after(0.1, function(user,p)
							projectilelauncher.show_inventory(p.itemstack, user)
						end,user,p)
					end
					return stack:get_count()
				end,
				on_put = function(inv, listname, index, stack, player)
					local p = projectilelauncher.user[user:get_player_name()]
					projectilelauncher.update_inventory(p.itemstack, user,true)
				end,
				on_take = function(inv, listname, index, stack, player)
					local p = projectilelauncher.user[user:get_player_name()]
					projectilelauncher.update_inventory(p.itemstack, user,true)
				end,
				on_move = function(inv, listname, index, stack, player)
					local p = projectilelauncher.user[user:get_player_name()]
					projectilelauncher.update_inventory(p.itemstack, user,true)
				end,
			}
		)}
		projectilelauncher.user[name].inv:set_size("main", 9)
	end
	local p = projectilelauncher.user[name]
	local list = {}
	local m = itemstack:get_meta()

	for i,v in pairs(minetest.deserialize(m:get_string("inv")) or {}) do
		if minetest.get_item_group(v.name,"bullet") > 0 or v.name == "default:telescopic" then
			list[i] = ItemStack(v)
		end
	end

	projectilelauncher.user[name].inv:set_list("main", list)

	p.index = m:get_int("index") > 0 and m:get_int("index") or 1
	p.zoom = p.inv:get_stack("main",9):get_name() ~= "" and m:get_int("zoom") or 0
	p.autoaim = m:get_int("autoaim")


end

projectilelauncher.show_inventory=function(itemstack, user)
	projectilelauncher.new_inventory(itemstack, user)
	local name = user:get_player_name()
	local p = projectilelauncher.user[name]
	local index = p.index
	local m = itemstack:get_meta()
	local list = {}

	for i,v in pairs(minetest.deserialize(m:get_string("inv")) or {}) do
		list[i] = ItemStack(v)
	end

	p.inv:set_list("main", list)
	p.itemstack = itemstack

	minetest.after(0.1, function(name,p)
		local butt = ""
		for i=1,8 do
			butt = butt .. "button[" .. (i-1) .. ",-0.1;1,0.5;setindex#" .. i .. ";"..i.."]"..
			"item_image[" .. (i-1) .. ",0.4;1,1;default:lazer_bullet]"
		end

		return minetest.show_formspec(name, "projectilelauncher",
			"size[9,5]" ..
			butt ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"list[detached:projectilelauncher_"..name..";main;0,0.4;9,1;]" ..
			"list[current_player;main;0,1.5;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[detached:projectilelauncher_"..name..";main]" ..
			"image["..(p.index-1)..",0.4;1,1;default_chest_top.png^[colorize:#0f0]" ..
			"image_button[8,1.5;1,1;default_cross.png"..(p.autoaim == 0 and "" or "^[invert:rgb")..";autoaim;]" ..
			"tooltip[autoaim;Auto aim ("..(p.autoaim == 0 and "OFF" or "ON")..")]"..
			"image_button[8,4;1,1;default_unknown.png;help;]"..
			"image[8,0.4;1,1;default_telescopic.png"..(p.zoom == 0 and "^default_cross.png" or "").."]button[8,-0.1;1,0.5;zoom;"..(p.zoom == 0 and "OFF" or "ON").."]"
		)
	end, name,p)
	return itemstack
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "projectilelauncher" then
		local name = player:get_player_name()
		local p = projectilelauncher.user[name]
		if pressed.autoaim then
			p.autoaim = p.autoaim == 0 and 1 or 0
			p.itemstack:get_meta():set_int("autoaim",p.autoaim)
			player:set_wielded_item(p.itemstack)
			projectilelauncher.show_inventory(p.itemstack, player)
			return
		elseif pressed.zoom then
			p.zoom = p.zoom == 0 and 1 or 0
			p.zoom = p.inv:get_stack("main",9):get_name() ~= "" and p.zoom or 0
			p.itemstack:get_meta():set_int("zoom",p.zoom)
			if p.zoom == 0 then
				player:set_fov(0,false,0.01)
			end
			player:set_wielded_item(p.itemstack)
			projectilelauncher.show_inventory(p.itemstack, player)
			return
		elseif pressed.help then
			local c = 0
			local butt = "size[8,5]listcolors[#77777777;#777777aa;#000000ff]"
			.."label[0,1;This tool/weapon uses bullets."
			.."\nItems that looks like those above."
			.."\nPut those in the tool's inventory."
			.."\nOr put a telescopic in the right slot,"
			.."\nand enable on the button above,"
			.."\nhold aux/use and left click to zoom,"
			.."\nright for the opposite."
			.."\nClick right in air to change bullets"
			.."\n"
			.."]"

			for i,v in pairs(projectilelauncher.registed_bullets) do
				butt = butt  .. "item_image["..c..",0;1,1;"..i.."]"
				c = c + 1
				if c == 8 then
					break
				end
			end
			minetest.after(0.1, function(name,butt)
				return minetest.show_formspec(name, "projectilelauncher",butt)
			end,name,butt)
			return
		end

		for i,v in pairs(pressed) do
			if i:sub(1,9) == "setindex#" then
				p.index = tonumber(i:sub(10,-1))
				local m = p.itemstack:get_meta()
				m:set_int("index",p.index)
				player:set_wielded_item(p.itemstack)
				projectilelauncher.show_inventory(p.itemstack, player)
				break
			end
		end
	end
end)

projectilelauncher.update_inventory=function(itemstack, user, add)
	local name = user:get_player_name()
	local m = itemstack:get_meta()
	local list = {}
	local p = projectilelauncher.user[name]
	for i,v in pairs(p.inv:get_list("main")) do
		list[i] = ItemStack(v):to_table()
	end
	m:set_string("inv",minetest.serialize(list))
	m:set_int("index",p.index)
	m:set_int("autoaim",p.autoaim)
	m:set_int("zoom",p.zoom)
	user:set_wielded_item(itemstack)

	if add then
		minetest.sound_play("default_projectilelauncher_load", {object=user})
	end
	p.bulletpreview_started = true
end

minetest.register_on_leaveplayer(function(player)
	projectilelauncher.user[player:get_player_name()] = nil
end)

projectilelauncher.shoot=function(itemstack, user)
	projectilelauncher.new_inventory(itemstack, user)
	local name = user:get_player_name()
	local p = projectilelauncher.user[name]
	local stack = p.inv:get_stack("main",p.index)
	local def

	if stack:get_name() == "" then
		minetest.sound_play("default_projectilelauncher_out", {object=user})
		return
	else
		def = projectilelauncher.registed_bullets[stack:get_name()]
		if def.on_trigger and def.on_trigger(itemstack, user) or def.on_step then
			return
		end
		minetest.sound_play(def.launch_sound, {object=user})
	end

	local pos = user:get_pos()
	local dir = p.autoaim == 1 and projectilelauncher.autoaim(user) or user:get_look_dir()
	local bulletpos = projectilelauncher.bulletpos(user)

	if def.before_bullet_released then
		local cancel,takebullet = def.before_bullet_released(itemstack, user, bulletpos, dir)
		if takebullet == nil then
			stack:set_count(stack:get_count()-1)
			p.inv:set_stack("main",p.index,stack)
			projectilelauncher.update_inventory(itemstack, user)
		end
		if cancel then
			return
		end
	else
		stack:set_count(stack:get_count()-1)
		p.inv:set_stack("main",p.index,stack)
		projectilelauncher.update_inventory(itemstack, user)
	end

	local e = minetest.add_entity(bulletpos, "default:bullet")
	local self = e:get_luaentity()

	self.bullet_activate(self,def,user)
	self.dir = dir
	e:set_yaw(user:get_look_horizontal()-math.pi/2)
	e:set_velocity({x=num(dir.x*20), y=num(dir.y*20), z=num(dir.z*20)})

	if def.on_shoot then
		def.on_shoot(itemstack, user,e)
	end
end

minetest.register_entity("default:bullet",{
	hp_max = 1,
	visual="sprite",
	visual_size={x=0.20,y=0.20},
	collisionbox = {-0.01,-0.01,-0.01,0.01,0.01,0.01},
	physical=true,
	textures={"default_stone.png"},
	static_save = false,
	damage = 1,
	bullet_activate=function(self,def,user)
		local prop = self.object:get_properties()
		local setp = {}
		self.def = def
		self.user = user
		for i,v in pairs(def) do
			if prop[i] then
				setp[i]=v
			else
				self[i] = v
			end
		end
		self.object:set_properties(setp)
	end,
	on_step=function(self, dtime, moveresult)
		local pos=self.object:get_pos()
		if not self.def then
			return
		elseif not self.user then

			self.object:remove()
			return
		elseif self.def.on_step and self.def.on_step(self, dtime, moveresult) then
			return
		elseif moveresult and moveresult.collides then
			for i,v in pairs(moveresult.collisions) do
				if v.type == "node" then
					minetest.sound_play(self.def.hit_sound, {pos=pos, gain = 1.0, max_hear_distance = 20})
					minetest.check_for_falling(pos)
					if self.def.on_hit_node then
						self.def.on_hit_node(self,self.user,pos)
					end
					self.object:remove()
					return
				elseif v.type == "object" and not default.is_decoration(v.object,true) then
					local en = v.object:get_luaentity()
					if not (en and en.user and en.user == self.user) then
						minetest.sound_play(self.def.hit_sound, {pos=pos, gain = 1.0, max_hear_distance = 20})
						default.punch(v.object,self.damage_by_bullet and self.object or self.user,self.damage)
						if self.def.on_hit_object then
							self.def.on_hit_object(self,self.user,v.object,pos)
						end
						self.object:remove()
						return
					end
				end
			end
		end
		return self
	end
})

projectilelauncher.register_bullet("lazer",{
	description="Lazer bullet",
	texture="default_wood.png^[colorize:#ff0000",
	damage=3,
	craft_count=16,
	groups={treasure=2,store=2},
	craft={
		{"default:ruby","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("lazer_automatic",{
	description="Automatic lazer bullet",
	texture="default_wood.png^[colorize:#00f",
	damage=3,
	craft_count=16,
	groups={treasure=1,store=2},
	on_trigger=function(itemstack, user)
		local p = projectilelauncher.user[user:get_player_name()]
		if not p.auto then
			p.auto = true
			projectilelauncher.registed_bullets["default:lazer_automatic_bullet"].shooting(itemstack,user)
			return true
		end
	end,
	shooting=function(itemstack,user)
		if user:get_player_control().LMB then
			projectilelauncher.shoot(itemstack, user)
			minetest.after(0.1, function(itemstack,user)
				if user and user:get_pos() then
					projectilelauncher.registed_bullets["default:lazer_automatic_bullet"].shooting(itemstack,user)
				end
			end,itemstack,user)
		else
			local p = projectilelauncher.user[user:get_player_name()]
			if p then
				projectilelauncher.user[user:get_player_name()].auto = nil
			end
		end
	end,
	craft={
		{"default:electric_lump","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("lightning_",{
	description="Lightning bullet",
	texture="default_amethystblock.png",
	bullettexture = "default_amethystblock.png^default_alpha_gem_crystal.png^[makealpha:0,255,0",
	damage=7,
	craft_count=8,
	launch_sound = "default_projectilelauncher_shot12",
	groups={treasure=1,store=8},
	on_shoot=function(itemstack, user,bullet)
		local dir = bullet:get_luaentity().dir
		dir.y = 0
		user:add_velocity(vector.multiply(dir,-5))
	end,
	on_hit_object=function(self,user,target,pos)
		target:add_velocity(vector.multiply(self.dir,5))
	end,
	craft={
		{"default:amethyst","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("flash_",{
	description="Flash bullet (Digg)",
	texture="default_ironblock.png^[colorize:#005",
	itemtexture = "default_ironblock.png^[colorize:#00f^armor_alpha_hand.png^[makealpha:0,255,0^(default_ironblock.png^[colorize:#00a^default_alpha_stick.png^[makealpha:0,255,0)",
	damage=0,
	craft_count=10,
	launch_sound = "default_projectilelauncher_shot8",
	groups={treasure=1,store=15},
	before_bullet_released=function(itemstack, user,pos1, dir)
		local pos2,pos3 = vector.add(pos1,vector.multiply(dir,100))
		local c = minetest.raycast(pos1,pos2)
		local ob = c:next()
		while ob do
			if ob.type == "node" and default.defpos(ob.under,"walkable") then
				pos2 = ob.intersection_point
				pos3 = ob.under
				minetest.check_for_falling(ob.under)
				break
			elseif ob.type == "object" and ob.ref ~= user and not default.is_decoration(ob.ref,true) then
				default.punch(ob.ref,user,8)
			end
			ob = c:next()
		end

		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
		local t = "default_cloud.png^[colorize:#00f"
		if pos1.x >= pos2.x then y = y+math.pi end
		local lightning = minetest.add_entity(pos1, "default:arrow_lightning")
		lightning:set_rotation({x=0,y=y,z=z})
		lightning:set_pos({x=pos1.x+(pos2.x-pos1.x)/2,y=pos1.y+(pos2.y-pos1.y)/2,z=pos1.z+(pos2.z-pos1.z)/2})
		lightning:set_properties({
			visual_size={x=vector.distance(pos1,pos2),y=0.03,z=0.03},
			textures = {t,t,t,t,t,t},
			glow = 1
		})

		if pos3 and not minetest.is_protected(pos3, user:get_player_name()) then
			local n = minetest.get_node(pos3)
			if minetest.get_item_group(n.name,"unbreakable") == 0 then
				minetest.node_dig(pos3, n, user)
			end
		end
		return true
	end,
	craft={
		{"default:diamond","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("build_",{
	description="Build bullet (places items from inventory (index))",
	itemtexture = "default_ironblock.png^[colorize:#0ff^armor_alpha_hand.png^[makealpha:0,255,0^(default_ironblock.png^[colorize:#0aa^default_alpha_stick.png^[makealpha:0,255,0)",
	damage=0,
	craft_count=10,
	launch_sound = "default_projectilelauncher_shot8",
	groups={treasure=1,store=15},
	before_bullet_released=function(itemstack, user,pos1, dir)
		local pos2,pos3 = vector.add(pos1,vector.multiply(dir,100))
		local c = minetest.raycast(pos1,pos2)
		local ob = c:next()
		while ob do
			if ob.type == "node" and default.defpos(ob.under,"walkable") then
				pos2 = ob.intersection_point
				pos3 = ob.above
				minetest.check_for_falling(ob.under)
				break
			end
			ob = c:next()
		end

		if not pos3 then
			return true, true
		end

		projectilelauncher.new_inventory(itemstack, user)
		local name = user:get_player_name()
		local p = projectilelauncher.user[name]

		local inv=user:get_inventory()
		local stackplace = inv:get_stack("main",p.index)

		if not (minetest.registered_nodes[stackplace:get_name()] and pos3 and not minetest.is_protected(pos3, name) and default.defpos(pos3,"buildable_to")) then
			return true,true
		end

		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
		local t = "default_cloud.png^[colorize:#055"
		if pos1.x >= pos2.x then y = y+math.pi end
		local lightning = minetest.add_entity(pos1, "default:arrow_lightning")
		lightning:set_rotation({x=0,y=y,z=z})
		lightning:set_pos({x=pos1.x+(pos2.x-pos1.x)/2,y=pos1.y+(pos2.y-pos1.y)/2,z=pos1.z+(pos2.z-pos1.z)/2})
		lightning:set_properties({
			visual_size={x=vector.distance(pos1,pos2),y=0.03,z=0.03},
			textures = {t,t,t,t,t,t},
			glow = 1
		})

		if bows.creative == false then
			local stackcount = inv:set_stack("main",p.index,ItemStack(stackplace:get_name() .. " " .. (stackplace:get_count() -1)))
		end

		minetest.set_node(pos3, {name=stackplace:get_name()})

		return true
	end,
	craft={
		{"default:opal","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("activate_",{
	description="Activate/rightclick bullet",
	itemtexture = "default_ironblock.png^[colorize:#ff0^armor_alpha_hand.png^[makealpha:0,255,0^(default_ironblock.png^[colorize:#aa0^default_alpha_stick.png^[makealpha:0,255,0)",
	damage=0,
	craft_count=10,
	launch_sound = "default_projectilelauncher_shot8",
	groups={treasure=1,store=2},
	before_bullet_released=function(itemstack, user,pos1, dir)
		local pos2,pos3 = vector.add(pos1,vector.multiply(dir,100))
		local c = minetest.raycast(pos1,pos2)
		local ob = c:next()
		while ob do
			if ob.type == "node" and default.defpos(ob.under,"walkable") then
				pos2 = ob.intersection_point
				pos3 = ob.under
				minetest.check_for_falling(ob.under)
				break
			end
			ob = c:next()
		end

		if not pos3 then
			return true, true
		end

		local name = user:get_player_name()
		local node = minetest.get_node(pos3)
		local def = minetest.registered_nodes[node.name]

		if not (def and def.on_rightclick and not minetest.is_protected(pos3, name)) then
			return true, true
		end

		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
		local t = "default_cloud.png^[colorize:#550"
		if pos1.x >= pos2.x then y = y+math.pi end
		local lightning = minetest.add_entity(pos1, "default:arrow_lightning")
		lightning:set_rotation({x=0,y=y,z=z})
		lightning:set_pos({x=pos1.x+(pos2.x-pos1.x)/2,y=pos1.y+(pos2.y-pos1.y)/2,z=pos1.z+(pos2.z-pos1.z)/2})
		lightning:set_properties({
			visual_size={x=vector.distance(pos1,pos2),y=0.03,z=0.03},
			textures = {t,t,t,t,t,t},
			glow = 1
		})

		def.on_rightclick(pos3, node, user, itemstack, {under=pos3,above=pos2})

		return true
	end,
	craft={
		{"exatec:wire","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("blob_",{
	description="Blob bullet",
	texture="default_wood.png^[colorize:#00ff80",
	bullettexture = "default_wood.png^[colorize:#00ff80^default_alpha_gem_flint.png^[makealpha:0,255,0",
	damage=5,
	craft_count=8,
	bullet_alpha = "flint",
	magazine_alpha = "flint",
	launch_sound = "default_projectilelauncher_shot4",
	hit_sound = "default_projectilelauncher_shot12",
	groups={treasure=1,store=15},
	damage_by_bullet = true,
	on_shoot=function(itemstack, user,bullet)
		local self = bullet:get_luaentity()
		self.dir.y = 0
		user:add_velocity(vector.multiply(self.dir,-10))
	end,
	on_hit_object=function(self,user,target,pos)
		self.dir.y = self.dir.y + 0.05
		target:add_velocity(vector.multiply(self.dir,target:get_luaentity() and 100 or 20))
	end,
	craft={
		{"materials:slime","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("torch",{
	description="Torch bullet",
	damage=5,
	craft_count=6,
	groups={treasure=1,store=4},
	itemtexture = "default_ironblock.png^armor_alpha_hand.png^[makealpha:0,255,0^(default_torch.png^default_alpha_stick.png^[makealpha:0,255,0)",
	bullettexture="default:torch",
	visual = "wielditem",
	visual_size = {x=0.3,y=0.3},
	launch_sound = "default_projectilelauncher_shot9",
	on_shoot=function(itemstack, user, bullet)
		local pos1=bullet:get_pos()
		local pos2=vector.add(pos1,bullet:get_velocity())
		local v = {x=pos1.x-pos2.x, y=(pos1.y+1.4)-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(v.z/v.x)
		local z = math.atan(v.y/math.sqrt(v.x^2+v.z^2))
		if pos1.x >= pos2.x then y = y+math.pi end
		bullet:set_rotation({x=0,y=y,z=z+(math.pi/2)})
	end,
	on_hit_node=function(self,user,pos)
		local player = minetest.is_player(user)
		if not minetest.is_protected(pos, player and user:get_player_name() or "") and default.defpos(pos,"buildable_to") then
			minetest.place_node(pos,{name="default:torch"})
			if player then
				default.def("default:torch").on_place(ItemStack("default:torch"), user, {above=pos,under=vector.add(pos,self.dir)})
			end
		end
	end,
	on_hit_object=function(self,user,target,pos)
		local player = minetest.is_player(user)
		if not minetest.is_protected(pos, player and user:get_player_name() or "") and default.defpos(pos,"buildable_to") then
			minetest.set_node(pos,{name="fire:basic_flame"})
		end
	end,
	craft={
		{"default:torch","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("hookshot",{
	description="Hookshot bullet",
	itemtexture = "default_ironblock.png^armor_alpha_hand.png^[makealpha:0,255,0^(default_ironblock.png^default_arrow.png^[makealpha:0,255,0)",
	craft_count=4,
	launch_sound = "default_projectilelauncher_shot10",
	groups={treasure=1,store=15},
	before_bullet_released=function(itemstack, user,pos1, dir)
		local pos2 
		local c = minetest.raycast(pos1,vector.add(pos1, vector.multiply(dir,30)))
		local ob = c:next()
		while ob do
			if ob.type == "node" and default.defpos(ob.under,"walkable") then
				pos2 = ob.intersection_point
				break
			elseif ob.type == "object" and ob.ref ~= user and not default.is_decoration(ob.ref,true) then
				default.punch(ob.ref,user,5)
				pos2 = ob.ref:get_pos()
				break
			end
			ob = c:next()
		end

		if not pos2 then
			return true,true
		end

		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
		local t = "default_cloud.png^[colorize:#555"
		if pos1.x >= pos2.x then y = y+math.pi end
		local hook = minetest.add_entity(pos1, "default:arrow_lightning")
		hook:get_luaentity().t = 10
		hook:set_rotation({x=0,y=y,z=z})
		hook:set_pos({x=pos1.x+(pos2.x-pos1.x)/2,y=pos1.y+(pos2.y-pos1.y)/2,z=pos1.z+(pos2.z-pos1.z)/2})
		hook:set_properties({
			visual_size={x=vector.distance(pos1,pos2),y=0.03,z=0.03},
			textures = {t,t,t,t,t,t},
			glow = 1
		})

		local cart = minetest.add_entity(pos1, "default:arrow_lightning")
		user:set_attach(cart, "",{x=0, y=0, z=0}, {x=0, y=0,z=0})
		cart:get_luaentity().t = 10
		cart:set_properties({
			physical = true,
			textures = {"default_air.png","default_air.png","default_air.png","default_air.png","default_air.png","default_air.png"},
			collisionbox = {-0.5,-0.5,-0.5,0.5,2,0.5},
		})
		cart:get_luaentity().on_step=function(self,dtime)
			local pos = self.object:get_pos()
			local d = vector.distance(pos,pos2)
			local grab = user:get_player_control().LMB

			local vec = vector.subtract(pos2,pos)
			self.object:set_velocity(vector.multiply(vec,vector.distance(pos1,pos2)/10))
			local y = math.atan(vec.z/vec.x)
			local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
			hook:set_rotation({x=0,y=y,z=z})
			hook:set_pos({x=pos.x+(pos2.x-pos.x)/2,y=pos.y+(pos2.y-pos.y)/2,z=pos.z+(pos2.z-pos.z)/2})
			hook:set_properties({visual_size={x=d,y=0.03,z=0.03}})

			if self.grab or grab == false  or d <= 1 then
				if not self.grab and hook:get_pos() then
					hook:remove()
				end

				if user and user:get_pos() then
					if d <= 1 and grab then
						self.grab = true
						self.object:set_velocity(vector.new())
						return
					else
						user:set_detach()
						user:set_pos(self.object:get_pos())
					end
				end
				self.object:remove()
			end
		end
		return true
	end,
	craft={
		{"default:steel_ingot","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("uranium",{
	description="Uranium bullet (Explosive)",
	itemtexture = "default_uraniumblock.png^armor_alpha_hand.png^[makealpha:0,255,0^(default_uraniumactiveblock.png^default_alpha_stick.png^[makealpha:0,255,0)",
	damage=0,
	craft_count=2,
	launch_sound = "default_projectilelauncher_shot4",
	groups={treasure=1},
	before_bullet_released=function(itemstack, user,pos1, dir)
		local pos2,pos3 = vector.add(pos1,vector.multiply(dir,100))
		local c = minetest.raycast(pos1,pos2)
		local ob = c:next()
		while ob do
			if ob.type == "node" and default.defpos(ob.under,"walkable") then
				pos3 = ob.intersection_point
				minetest.check_for_falling(ob.under)
				break
			elseif ob.type == "object" and ob.ref ~= user then
				pos3 = ob.ref:get_pos()
				break
			end
			ob = c:next()
		end

		if not pos3 then
			return true, true
		end

		projectilelauncher.new_inventory(itemstack, user)
		local name = user:get_player_name()
		local p = projectilelauncher.user[name]

		local vec = {x=pos1.x-pos3.x, y=pos1.y-pos3.y, z=pos1.z-pos3.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
		local t = "default_uraniumblock.png"
		if pos1.x >= pos3.x then y = y+math.pi end
		local lightning = minetest.add_entity(pos1, "default:arrow_lightning")
		lightning:set_rotation({x=0,y=y,z=z})
		lightning:set_pos({x=pos1.x+(pos3.x-pos1.x)/2,y=pos1.y+(pos3.y-pos1.y)/2,z=pos1.z+(pos3.z-pos1.z)/2})
		lightning:set_properties({
			visual_size={x=vector.distance(pos1,pos2),y=0.03,z=0.03},
			textures = {t,t,t,t,t,t},
			glow = 1
		})

		for _, ob in ipairs(minetest.get_objects_inside_radius(pos3,5)) do
			local en = ob:get_luaentity()
			local p = ob:get_pos()
			if ob ~= user and not default.is_decoration(ob,true) and not (en and en.name == "default:arrow_lightning") then
				default.punch(ob,user,200)
			end
		end
		minetest.sound_play("plasma_shoot", {pos=pos1, gain = 4,max_hear_distance = 10})

		nitroglycerin.explode(pos3,{
			radius=4,
			set="air",
			user_name=name,
		})

		return true
	end,
	craft={
		{"default:uraniumactive_ingot","default:titanium_ingot","default:emerald"},
	}
})

projectilelauncher.register_bullet("bubbelgum",{
	description="Bubbelgum bullet",
	texture="default_cloud.png^[colorize:#ed75ff",
	damage=0,
	craft_count=4,
	groups={treasure=1},
	on_hit_node=function(self,user,pos)
		local self = minetest.add_entity(pos,"plasma:impulse"):get_luaentity()
		self.object:set_properties({physical = true, object_use_texture_alpha = "blend"})
		self.object:set_acceleration({x=math.random(-0.1,0.1), y=0.1, z=math.random(-0.1,0.1)})
		self.end_scale = 1
		self.scale = 0
		self.on_step=function(self,dtime)
			if self.timer > 5 then
				self.object:remove()
				return
			elseif self.scale < self.end_scale then
				self.scale = self.scale + dtime * self.end_scale
				self.object:set_properties({visual_size = {x=self.scale,y=self.scale,z=self.scale}})
				return
			end
			self.timer = self.timer + dtime
		end
	end,
	on_hit_object=function(self,user,target,pos)
		local en = target:get_luaentity()
		if en and en.name == "plasma:impulse" then
			return
		end

		local c = target:get_properties().collisionbox
		local b = {}
		b[1] = math.max(c[1],c[4]) - math.min(c[1],c[4])
		b[2] = math.max(c[2],c[5]) - math.min(c[2],c[5])
		b[3] = math.max(c[3],c[6]) - math.min(c[3],c[6])
		local size = math.max(unpack(b))

		local self = minetest.add_entity(pos,"plasma:impulse"):get_luaentity()
		local bubble = self.object

		bubble:set_properties({physical = true, object_use_texture_alpha = "blend"})
		bubble:set_acceleration({x=math.random(-1,1), y=1, z=math.random(-1,1)})
		self.end_scale = size*10
		self.scale = 0
		self.on_step=function(self,dtime,moveresult)
			if self.timer > 10 or (moveresult and moveresult.collides and not moveresult.touching_ground) then
				self.object:remove()
				return
			elseif self.scale < self.end_scale then
				self.scale = self.scale + dtime * self.end_scale
				self.object:set_properties({visual_size = {x=self.scale,y=self.scale,z=self.scale}})
				return
			end
			self.timer = self.timer + dtime
		end

		local cart = minetest.add_entity(pos, "default:arrow_lightning")
		target:set_attach(cart, "",{x=0, y=0, z=0}, {x=0, y=0,z=0})
		cart:set_properties({
			physical = true,
			textures = {"default_air.png","default_air.png","default_air.png","default_air.png","default_air.png","default_air.png"},
			collisionbox = {-0.5,-0.5,-0.5,0.5,2,0.5},
		})
		cart:get_luaentity().on_step=function(self)
			local pos1 = self.object:get_pos()
			local pos2 = bubble:get_pos()
			if not (pos2 and pos.x and bubble:get_luaentity()) then
				self.object:remove()
				return
			end 
			local v = vector.multiply(vector.subtract(pos2,pos1),10)
			self.object:set_velocity(v)
		end
	end,
	craft={
		{"default:taaffeite","default:steel_ingot","materials:marzipan_rose"},
	}
})

projectilelauncher.register_bullet("ray",{
	description="Ray bullet",
	texture="default_rubyblock.png",
	itemtexture = "default_ironblock.png^[colorize:#f00^armor_alpha_hand.png^[makealpha:0,255,0^(default_rubyblock.png^[colorize:#a00^default_alpha_stick.png^[makealpha:0,255,0)",
	damage=0,
	craft_count=50,
	launch_sound = "default_projectilelauncher_shot8",
	groups={treasure=1,store=15},
	on_step=function(itemstack, user, pos1)
		if user:get_player_control().LMB == false then
			return
		end
		projectilelauncher.new_inventory(itemstack, user)
		local p = projectilelauncher.user[user:get_player_name()]
		local height = projectilelauncher.user_height(user)
		local dir = p.autoaim == 1 and projectilelauncher.autoaim(user) or user:get_look_dir()

		pos1 = projectilelauncher.bulletpos(user)

		local pos2,pos3 = vector.add(pos1,vector.multiply(dir,100))

		for v in minetest.raycast(pos1,pos2) do
			if v and v.type == "node" and default.defpos(v.under,"walkable") then
				pos2 = v.intersection_point
				pos3 = v.under
				minetest.check_for_falling(v.under)
				break
			elseif v and v.type == "object" and v.ref ~= user and not default.is_decoration(v.ref,true) then
				default.punch(v.ref,user,5)
			end
		end

		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
		local t = "default_cloud.png^[colorize:#f00"
		if pos1.x >= pos2.x then y = y+math.pi end

		local p = projectilelauncher.user[user:get_player_name()]
		local ray = p.raybullet and p.raybullet:get_luaentity() and p.raybullet or minetest.add_entity(pos1, "default:arrow_lightning")

		ray:set_rotation({x=0,y=y,z=z})
		ray:set_pos({x=pos1.x+(pos2.x-pos1.x)/2,y=pos1.y+(pos2.y-pos1.y)/2,z=pos1.z+(pos2.z-pos1.z)/2})
		p.raybullet = ray

		ray:set_properties({
			visual_size={x=vector.distance(pos1,pos2),y=0.03,z=0.03},
			textures = {t,t,t,t,t,t},
			glow = 1
		})
		minetest.sound_play("default_projectilelauncher_shot5", {pos=pos1, gain = 4,max_hear_distance = 10})

		local stack = p.inv:get_stack("main",p.index)
		stack:set_count(stack:get_count()-1)
		p.inv:set_stack("main",p.index,stack)
		projectilelauncher.update_inventory(itemstack, user)
	end,
	craft={
		{"default:ruby","default:steel_ingot"},
	}
})