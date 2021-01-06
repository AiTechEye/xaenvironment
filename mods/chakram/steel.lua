minetest.register_tool("chakram:chakram", {
	description = "Chakram (Too outdated, use this tool in a later update)",
	range = 1,
	inventory_image = "chakram_chakram.png",
on_use=function(itemstack, user, pointed_thing)

	if true then
		minetest.chat_send_player(user:get_player_name(), "Too outdated, use this tool in a later update")
		return
	end

	if chakram_max()==false or type(user)=="table" then
		minetest.chat_send_player(user:get_player_name(), "Too many chakrams: (max " .. chakram_max_number .. ")")
		return itemstack
	end
	local pos=user:get_pos()
	for i, ob in pairs(minetest.get_objects_inside_radius(pos, 5)) do
		if ob:get_luaentity() and ob:get_luaentity().name=="chakram:chakr" then
			return itemstack
		end
	end
	chakramshot_user=user
	chakramshot_user_name=user:get_player_name()
	local dir = user:get_look_dir()
	local veloc=15
	pos.y=pos.y+1.5
	local m=minetest.add_entity(pos, "chakram:chakr")
	chakram_max(m)
	m:set_velocity({x=dir.x*veloc, y=dir.y*veloc, z=dir.z*veloc})
	itemstack:take_item()
	minetest.sound_play("chakram_throw", {pos=pos, gain = 1.0, max_hear_distance = 5,})
	return itemstack
end,
})

minetest.register_entity("chakram:chakr",{
	hp_max = 999,
	physical = false,
	weight = 0,
	visual="cube",
	visual_size = {x=1, y=0.04},
	textures = {"chakram_chakram.png","chakram_chakram.png","chakram_light.png","chakram_light.png","chakram_light.png","chakram_light.png"},
	colors = {}, 
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=1, y=1},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = math.pi * 4,
	timer = 0,
	timer2 = 0,
	timer3 = 0,
	stuck = 0,
	user={},
	user_name="",
	chakram_s=1,
on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
	if puncher:get_luaentity() or (puncher:get_player_name()~=self.user_name) then
		self.timer3=-2
		self.stuck=1
	end	
	end,
	on_activate=function(self, staticdata)
		if chakramshot_user=="" then
			minetest.add_item(self.object:get_pos(), "chakram:chakram")
			self.object:remove()
			return false
		end
		self.user=chakramshot_user
		self.user_name=chakramshot_user_name
		chakramshot_user_name=""
		chakramshot_user=""
	end,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<0.05 then return self end
		self.timer3=self.timer3+self.timer

		if self.user==nil then
			self.timer3=10
			self.stuck=1
		end


		if self.timer3>=2 then
			if self.stuck==1 then 
				minetest.add_item(self.object:get_pos(), "chakram:chakram")
				if self.ob then self.ob:set_detach() self.ob:set_acceleration({x=0,y=-8,z=0}) end
				self.object:set_hp(0)
				default.punch(self.user,ob,4)
				return
			else
				self.timer3=-2
				self.stuck=1
			end
		end
		self.timer=0
		self.timer2=self.timer2+dtime
		self.object:set_hp(999)
		local pos=self.object:get_pos()
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			if not ob:get_attach() and ob ~= self.object and ob ~= self.user then
				default.punch(self.user,ob,5)
				minetest.sound_play("chakram_hard_punch", {pos=ob:get_pos(), gain = 1.0, max_hear_distance = 5,})
			end
		end

		if self.stuck==0 then
			local name=minetest.get_node(pos).name
			if name~="air" and (minetest.get_item_group(name, "snappy")>0 or minetest.get_item_group(name, "dig_immediate")>0 or minetest.get_item_group(name, "oddly_breakable_by_hand")>0) and minetest.is_protected(pos,self.user:get_player_name())==false then

				local meta=minetest.get_meta(pos)
				if meta and meta:get_string("infotext")~="" then return self end
				minetest.add_item(pos, chakram_drops(name))
				minetest.set_node(pos, {name="air"})
			elseif chakram_def(pos,"walkable") then
				self.timer3=-2
				self.stuck=1
			end

		else

			if self.user==nil or self.user:get_pos()==nil then
				self.timer3=10
				self.stuck=1
				return
			end


			local ta=self.user:get_pos()
			ta.y=ta.y+1
			local vec = {x = pos.x - ta.x, y = pos.y - ta.y, z = pos.z - ta.z}
			local amount = (vec.x ^ 2 + vec.y ^ 2 + vec.z ^ 2) ^ 0.5
			local v = -15
			vec.x = vec.x * v / amount
			vec.y = vec.y * v / amount
			vec.z = vec.z * v / amount
			self.object:set_velocity(vec)

			for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
				local en = ob:get_luaentity()


				if not ob:get_attach() and not (en and en.itemstring) and ob ~= self.object and ob ~= self.user then
					default.punch(self.user,ob,4)
					minetest.sound_play("chakram_hard_punch", {pos=ob:get_pos(), gain = 1.0, max_hear_distance = 5,})
				end

				if (not ob:get_luaentity()) and ob:get_player_name()==self.user_name then

					if self.user==nil or self.user:get_pos()==nil  then
						self.timer3=10
						self.stuck=1
						return
					end

					if self.ob and self.ob:get_attach() and self.ob:get_hp()>0 then
						self.ob:set_detach()
						self.ob:set_hp(0)
						default.punch(self.user,ob,4)
					end
					if self.object:get_attach() then self.object:set_detach() return false end
					self.user:get_inventory():add_item("main", ItemStack("chakram:chakram"))
					self.object:remove()
				end
			end
			for i, ob in pairs(minetest.get_objects_inside_radius(pos, 3)) do
				if ob:get_luaentity() and (not ob:get_attach()) and ob:get_luaentity().itemstring and ob:get_luaentity().itemstring~="chakram:chakram" then
					self.object:remove()
					return
				end
			end
		end
	end,
})
