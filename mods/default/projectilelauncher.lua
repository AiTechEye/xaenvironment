projectilelauncher={
	registed_bullets={},
	user = {},
}

minetest.register_craft({
	output = "default:projectile_launcher",
	recipe = {
		{"default:uraniumactive_ingot","default:diamond","default:taaffeiteblock"},
		{"default:bucket","exatec:bow","exatec:pcb"},
		{"materials:diode","materials:tube_metal","materials:plastic_sheet"}
	}
})

projectilelauncher.register_bullet=function(name,def)
	if name==nil or name=="" then return false end
	local defname = minetest.get_current_modname() ..":"..name.."_bullet"
	def.damage = def.damage or 1

	def.launch_sound = def.launch_sound or "default_projectilelauncher_shot13"
	def.hit_sound = def.hit_sound or "default_projectilelauncher_shot11"

	def.groups = def.groups or {}
	def.groups.bullet = 1
	def.groups.treasure = def.groups.treasure or 1
	def.bullettexture = def.bullettexture or (def.texture .. "^default_alpha_gem_"..(def.bullet_alpha or "round")..".png^[makealpha:0,255,0")
	def.textures={def.bullettexture}

	--def.on_hit_object
	--def.on_hit_node
	--def.on_step
	--def.on_trigger
	--def.on_bullet_used
	--def.on_shoot

	projectilelauncher.registed_bullets[defname]=def

	minetest.register_craftitem(defname, {
		description = def.description or name,
		inventory_image = (def.texture and def.texture .. "^default_alpha_gem_"..(def.magazine_alpha or "emeald")..".png^[makealpha:0,255,0") or def.inventory_image or "default_wood.png^default_alpha_gem_emeald.png^[makealpha:0,255,0",
		groups = def.groups,
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
	on_use =function(itemstack, user, pointed_thing)
		projectilelauncher.shoot(itemstack, user)
	end,
	on_place = function(itemstack, user, pointed_thing)
		projectilelauncher.show_inventory(itemstack, user)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		projectilelauncher.new_inventory(itemstack, user)
		local p = projectilelauncher.user[user:get_player_name()]
		local index = p.index
		for i=1,15 do
			index = index +1
			if index > 8 then
				index = 1
			end
			local item = p.inv:get_stack("main",index):get_name()
			if item ~= "" then
				p.index = index
				projectilelauncher.update_inventory(itemstack, user,true)

				local image = minetest.registered_items[item].inventory_image .."^(default_chest_top.png^[colorize:#0f0)"

				if p.bulletpreview then
					user:hud_change(p.bulletpreview, "text", image)
				else
					p.bulletpreview = user:hud_add({
						hud_elem_type="image",
						scale = {x=5,y=5},
						position={x=1,y=0},
						text=image,
						offset={x=-50,y=50},
					})
				end

				minetest.after(2,function(user,p,index)
					if p and p.bulletpreview and p.index == index then
						user:hud_remove(p.bulletpreview)
						p.bulletpreview = nil
					end
				end,user,p,index)

				return itemstack
			end
		end
		minetest.sound_play("default_projectilelauncher_out", {object=user})
	end,
})

projectilelauncher.new_inventory=function(itemstack, user)
	local name = user:get_player_name()

	if not projectilelauncher.user[name] then
		projectilelauncher.user[name] = {
			index = 0,
			autoaim = 0,
			inv = minetest.create_detached_inventory("projectilelauncher_"..name, {
				allow_put = function(inv, listname, index, stack, player)
					return minetest.get_item_group(stack:get_name(),"bullet") > 0 and stack:get_count() or 0
				end,
				allow_take = function(inv, listname, index, stack, player)
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
		projectilelauncher.user[name].inv:set_size("main", 8)
	end
	local p = projectilelauncher.user[name]
	local list = {}
	local m = itemstack:get_meta()
	p.index = m:get_int("index") > 0 and m:get_int("index") or 1
	p.autoaim = m:get_int("autoaim")

	for i,v in pairs(minetest.deserialize(m:get_string("inv")) or {}) do
		if minetest.get_item_group(v.name,"bullet") > 0 then
			list[i] = ItemStack(v)
		end
	end
	projectilelauncher.user[name].inv:set_list("main", list)
end

projectilelauncher.show_inventory=function(itemstack, user)
	projectilelauncher.new_inventory(itemstack, user)
	local name = user:get_player_name()
	local p = projectilelauncher.user[name]
	local index = p.index
	local m = itemstack:get_meta()
	local list = {}

	for i,v in pairs(minetest.deserialize(m:get_string("inv")) or {}) do
		if minetest.get_item_group(v.name,"bullet") > 0 then
			list[i] = ItemStack(v)
		end
	end

	p.inv:set_list("main", list)
	p.itemstack = itemstack

	minetest.after(0.1, function(name,p)
		local butt = ""
		for i=1,8 do
			butt = butt .. "button[" .. (i-1) .. ",-0.1;1,0.5;setindex#" .. i .. ";]"..
			"item_image[" .. (i-1) .. ",0.4;1,1;default:lazer_bullet]"
		end

		return minetest.show_formspec(name, "projectilelauncher",
			"size[9,5]" ..
			butt ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"list[detached:projectilelauncher_"..name..";main;0,0.4;8,1;]" ..
			"list[current_player;main;0,1.5;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[detached:projectilelauncher_"..name..";main]" ..
			"image["..(p.index-1)..",0.4;1,1;default_chest_top.png^[colorize:#0f0]" ..
			"image_button[8,0;1,1;default_watersplash_ring.png"..(p.autoaim == 0 and "^default_cross.png" or "")..";autoaim;]" ..
			"tooltip[autoaim;Auto aim ("..(p.autoaim == 0 and "OFF" or "ON")..")]"
		)
	end, name,p)
	return itemstack
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "projectilelauncher" then
		local p = projectilelauncher.user[player:get_player_name()]
		if pressed.autoaim then
			p.autoaim = p.autoaim == 0 and 1 or 0
			p.itemstack:get_meta():set_int("autoaim",p.autoaim)
			player:set_wielded_item(p.itemstack)
			projectilelauncher.show_inventory(p.itemstack, player)
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
	user:set_wielded_item(itemstack)

	if add then
		minetest.sound_play("default_projectilelauncher_load", {object=user})
	end
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
		if def.on_trigger and def.on_trigger(itemstack, user) then
			return
		end
		minetest.sound_play(def.launch_sound, {object=user})
	end
	local pos = user:get_pos()
	local dir = user:get_look_dir()
	local height = (user:get_player_control().sneak or minetest.get_item_group(minetest.get_node(pos).name,"liquid") > 0) and 0.6 or 1.5
	local bulletpos = vector.add(vector.new(pos.x, pos.y+height, pos.z),vector.multiply(dir,height == 1.5 and 0.1 or 0.5))

	stack:set_count(stack:get_count()-1)
	p.inv:set_stack("main",p.index,stack)
	projectilelauncher.update_inventory(itemstack, user)

	if p.autoaim > 0 then
		local obpos2,autodis = nil,100
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, 100)) do
			local en = ob:get_luaentity()
			if ob ~= user and (en and en.examob and en.dead == nil or ob:is_player()) then
				local obpos = ob:get_pos()
				local ob2 = vector.normalize(vector.subtract(obpos, pos))
				local deg = math.acos((ob2.x*dir.x)+(ob2.y*dir.y)+(ob2.z*dir.z)) * (180 / math.pi)
				local d = vector.distance(pos,obpos)
				if d < autodis and not (deg < 0 or deg > 50) then -- and minetest.line_of_sight(vector.new(pos.x,pos.y+height,pos.z),obpos)
					local c = minetest.raycast(vector.new(pos.x,pos.y+height,pos.z),obpos)
					local ob2 = c:next()
					local ex = true
					while (ob2 and ex) do
						if ob2 and ob2.type == "node" and default.defpos(ob2.under,"walkable") then
							ex = nil
						elseif ob2 and ob2.type == "object" and ob2.ref ~= user and not default.is_decoration(ob2.ref,true) then
							autodis = d
							obpos2 = obpos
						end
						ob2 = c:next()
					end
				end
			end
		end
		if obpos2 then
			dir = vector.new((obpos2.x-pos.x)/autodis,((obpos2.y-pos.y)-height)/autodis,(obpos2.z-pos.z)/autodis)
		end
	end
	if def.before_bullet_released and def.before_bullet_released(itemstack, user, bulletpos, dir) then
		return
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
					if def.on_hit_node then
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
	--damage_by_bullet = true,
	--bullet_alpha = "round",
	--magazine_alpha = "emeald",
	--on_trigger(itemstack, user) then
	--end
	--before_bullet_released(itemstack, user,pos, dir)
	--end,
	--on_shoot(itemstack, user,bullet)
	--end
	--on_hit_node=function(self,user,pos)
	--end,
	--on_hit_object=function(self,user,target,pos)
	--end,
	craft={
		{"default:ruby","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("lazer_automatic",{
	description="Automatic lazer bullet",
	texture="default_wood.png^[colorize:#00f",
	damage=3,
	craft_count=16,
	groups={treasure=2,store=2},
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
	texture="default_wood.png^[colorize:#8000ff",
	damage=7,
	craft_count=8,
	bullet_alpha = "quartz",
	launch_sound = "default_projectilelauncher_shot12",
	groups={treasure=2,store=8},
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
	description="Flash bullet",
	texture="default_wood.png^[colorize:#00f",
	damage=0,
	craft_count=8,
	magazine_alpha = "longcrystal",
	launch_sound = "default_projectilelauncher_shot8",
	groups={treasure=2,store=15},
	before_bullet_released=function(itemstack, user,pos1, dir)
		local pos2 = vector.add(pos1,vector.multiply(dir,100))
		local c = minetest.raycast(pos1,pos2)
		local ob = c:next()
		while ob do
			if ob.type == "node" and default.defpos(ob.under,"walkable") then
				pos2 = ob.intersection_point
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
		return true
	end,
	craft={
		{"default:diamond","default:iron_ingot"},
	}
})

projectilelauncher.register_bullet("blob_",{
	description="Blob bullet",
	texture="default_wood.png^[colorize:#00ff80",
	damage=5,
	craft_count=8,
	bullet_alpha = "flint",
	magazine_alpha = "flint",
	launch_sound = "default_projectilelauncher_shot4",
	hit_sound = "default_projectilelauncher_shot12",
	groups={treasure=2,store=15},
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
		{"default:opal","default:iron_ingot"},
	}
})