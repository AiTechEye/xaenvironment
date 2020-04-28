livetools={tmp={},pvp=minetest.settings:get("enable_pvp")}

minetest.register_craftitem("livetools:obsidian_mix", {description = "Obsidian mix",inventory_image = "default_lump_iron.png^[colorize:#45770099",})
minetest.register_craftitem("livetools:liveobsidian", {description = "Living obsidian crystal",inventory_image = "default_lump_iron.png^[colorize:#458833ff",})

minetest.register_craft({
	output = "livetools:hand",
	recipe = {
		{"default:stick", "livetools:liveobsidian", "default:stick"},
		{"", "default:stick", ""},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "livetools:sword",
	recipe = {
		{"", "livetools:liveobsidian", ""},
		{"", "livetools:liveobsidian", ""},
		{"", "default:stick", ""},
	}
})

minetest.register_craft({
	output = "livetools:pick",
	recipe = {
		{"livetools:liveobsidian", "livetools:liveobsidian", "livetools:liveobsidian"},
		{"", "default:stick", ""},
		{"", "default:stick", ""},
	}
})


minetest.register_craft({
	output = "livetools:obsidian_mix",
	recipe = {
		{"default:electric_lump", "default:obsidian", "default:electric_lump"},
		{"default:obsidian", "default:diamond", "default:obsidian"},
		{"default:electric_lump", "default:obsidian", "default:electric_lump"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "livetools:liveobsidian",
	recipe = "livetools:obsidian_mix",
})


livetools.def=function(pos,def)
	local n=minetest.registered_nodes[minetest.get_node(pos).name]
	return n and n[def]
end

livetools.set_target=function(user,pointed_thing)
	local p=user:get_pos()
	p={x=p.x,y=p.y+1.5,z=p.z}
	local dir = user:get_look_dir()
	local tar=1
	local pos
	local opos
	if pointed_thing.type=="nothing" then
	for i=1,15,1 do
		opos=pos
		pos={x=p.x+(dir.x*i), y=p.y+(dir.y*i), z=p.z+(dir.z*i)}
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			if not (ob:is_player() and ob:get_player_name()==user:get_player_name()) then
				if livetools.pvp==false and ob:is_player() then return true end
				livetools.tmp.target=ob
				livetools.tmp.type="attack"
				tar=nil
				break
			end
		end
		if minetest.get_node(pos).name~="air" and livetools.def(pos,"drop") and minetest.registered_nodes[minetest.get_node(pos).name].drop~="" then
			if livetools.tmp.type=="attack" then return true end
			if livetools.tmp.type=="dig"then
				livetools.tmp.target=pos
				tar=nil
				break
			end

			if livetools.tmp.type=="place" then
				if opos and livetools.def(pos,walkable) and livetools.def(pos,"buildable_to")
				and minetest.is_protected(opos,user:get_player_name())==false then
					livetools.tmp.target=opos
					tar=nil
					break
				end
			end
		end
	end
	if tar then return true end
	end
	local e = minetest.add_entity({x=p.x+(dir.x*0.5),y=p.y+(dir.y*0.5)-0.5,z=p.z+(dir.z*0.5)},"livetools:tool")
	e:set_velocity({x=dir.x*2, y=dir.y*2, z=dir.z*2})
	e:set_acceleration({x=0, y=-5, z=0})
	return false
end

--minetest.register_tool("livetools:sword", {
--	description = "Liveing Sword",
--	range = 13,
--	inventory_image = "default_tool_diamondsword.png^[colorize:#8aff0055",
--	on_use = function(itemstack, user, pointed_thing)
--		if pointed_thing.type~="nothing" and pointed_thing.type~="object" then return itemstack end
--		if livetools.pvp==false and pointed_thing.type=="object" and pointed_thing.ref:is_player() then return itemstack end
--		livetools.tmp.target=pointed_thing.ref
--		livetools.tmp.item="livetools:sword"
--		livetools.tmp.user=user
--		livetools.tmp.type="attack"
--		livetools.tmp.dmg=4
--		livetools.tmp.hp=20
--		if livetools.set_target(user,pointed_thing) then return itemstack end
--		itemstack:take_item()
--		return itemstack
--	end
--})

minetest.register_tool("livetools:hand", {
	description = "Liveing Hand",
	range = 13,
	inventory_image = "wieldhand.png^[colorize:#458833ff",
	on_use = function(itemstack, user, pointed_thing)
		if livetools.pvp==false and pointed_thing.type=="object" and pointed_thing.ref:is_player() then return itemstack end
		livetools.tmp.item="livetools:hand"
		livetools.tmp.user=user
		if pointed_thing.type=="object" then
			livetools.tmp.type="attack"
			livetools.tmp.target=pointed_thing.ref
		else
			local index=user:get_wield_index()-1
			local inv=user:get_inventory()
			local stack=inv:get_stack("main", index)
			if minetest.is_protected(pointed_thing.above,user:get_player_name()) or (not minetest.registered_nodes[stack:get_name()]) then return itemstack end
			livetools.tmp.type="place"
			livetools.tmp.target=pointed_thing.above
			if livetools.def(pointed_thing.under,"buildable_to") and minetest.is_protected(pointed_thing.under,user:get_player_name())==false then
				livetools.tmp.target=pointed_thing.under
			elseif livetools.def(pointed_thing.above,"buildable_to ") and minetest.is_protected(pointed_thing.above,user:get_player_name())==false then
				livetools.tmp.target=pointed_thing.above
			end
		end

		livetools.tmp.dmg=1
		livetools.tmp.hp=5
		if livetools.set_target(user,pointed_thing) then return itemstack end
		itemstack:take_item()
		return itemstack
	end
})

minetest.register_tool("livetools:pick", {
	description = "Liveing Pick",
	range = 13,
	inventory_image = "default_stone.png^default_alpha_pick.png^[makealpha:0,255,0^[colorize:#8aff0055",
	on_use = function(itemstack, user, pointed_thing)
		if livetools.pvp==false and pointed_thing.type=="object" and pointed_thing.ref:is_player() then return itemstack end

		livetools.tmp.item="livetools:pick"
		livetools.tmp.user=user
		livetools.tmp.dmg=2
		livetools.tmp.hp=10

		if pointed_thing.type=="object" then
			livetools.tmp.type="attack"
			livetools.tmp.target=pointed_thing.ref
		else
			livetools.tmp.type="dig"
			livetools.tmp.target=pointed_thing.under
		end

		if livetools.set_target(user,pointed_thing) then return itemstack end
		itemstack:take_item()
		return itemstack
	end
})

minetest.register_entity("livetools:tool",{
	hp_max = 20,
	visual="wielditem",
	visual_size={x=.50,y=.50},
	collisionbox = {-0.2,-0.4,-0.2,0.2,0.4,0.2},
	physical=true,
	textures={"air"},
	makes_footstep_sound=true,
	on_activate = function(self, staticdata)
		if livetools.tmp.item ~= nil then
			self.item=livetools.tmp.item
			self.user=livetools.tmp.user
			self.type=livetools.tmp.type
			self.dmg=livetools.tmp.dmg
			self.target=livetools.tmp.target
			self.hp_max=livetools.tmp.hp
			self.new=1
			livetools.tmp={}
			self.object:set_properties({textures={self.item}})
		else
			if staticdata~="" then
				minetest.add_item(self.object:get_pos(), staticdata)

			end
			self.object:remove()
		end
	end,
	get_staticdata = function(self)
		return self.item
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if self.destry then return self end
		if dir~=nil then self.object:set_velocity({x = dir.x*3,y = self.object:get_velocity().y,z = dir.z*3}) end
		local inv=(self.user and self.user:get_inventory())

		if puncher:is_player() and self.user and self.user:is_player() and puncher:get_player_name()==self.user:get_player_name() then
			livetools.punch(self,self.object,1000)
			self.destry=true
			return self
		else
			if self.returnback then self.returnback=false end
			self.target=puncher
		end

		if self.object:get_hp()<=0 and self.item and inv then
			self.destry=true
			self.user:get_inventory():add_item("main", self.item)
			return self
		end
		if self.object:get_hp()<=0 and self.item and inv==false then
			self.destry=true
			minetest.add_item(self.object:get_pos(), self.item):set_velocity({x = math.random(-1, 1),y=5,z = math.random(-1, 1)})
			return self
		end
	end,
on_step=function(self, dtime)
	self.time=self.time+dtime
	if self.time<0.5 then return self end
		self.time=0
		local inv=(self.user and self.user:get_inventory())

		if not (self.user and self.user:get_pos()) then
			minetest.add_item(self.object:get_pos(), self.item)
			self.object:remove()
			return self
		end
		local ud=livetools.get_distance(self,self.user:get_pos())
		if self.target==nil and inv==false or self.user:get_hp()<=0 or (ud and ud>25) then
			livetools.punch(self,self.object,1000)
			return self
		end

		local target=self.target
		if self.type=="attack" then target=self.target:get_pos() end

		local d=livetools.get_distance(self,target)
		if not d or (self.type=="attack" and self.target:get_hp()<=0) then
			self.target=self.user
			self.returnback=true
			self.type="attack"
			d=livetools.get_distance(self,self.target:get_pos())
			
			if not d then
				livetools.punch(self,self.object,1000)
				return self
			end

		end
		local see=livetools.get_visiable(self.object:get_pos(),target)
		if see then
			self.able_to_see=true
		end
		if inv and ((d>15 or see==false) or (d<1.5 and self.returnback)) then
			if self.returnback and (d<1.5 or self.able_to_see==false) then
				livetools.punch(self,self.object,1000)
				return self
			elseif self.able_to_see and d<15 then
				local v=self.object:get_velocity()
				self.object:set_velocity({x = v.x,y = 5,z =v.z})
				self.able_to_see=false
				return self
			else
				self.target=self.user
				self.returnback=true
				self.able_to_see=true
				self.type="attack"
			end
		end
		local pos=self.object:get_pos()
		if self.type=="attack" and d<2  and (not self.returnback) then
			livetools.punch(self,self.target,self.dmg)
		end
		if self.type=="dig" and d<2  and (not self.returnback) then
			minetest.node_dig(target, minetest.get_node(target), self.user)
			self.target=self.user
			self.returnback=true
		end
		if self.type=="place" and d<2  and (not self.returnback) then
			local index=self.user:get_wield_index()-1
			local inv=self.user:get_inventory()
			local stack=inv:get_stack("main", index)
			if minetest.registered_nodes[stack:get_name()] then
				minetest.set_node(target,{name=stack:get_name()})
				inv:set_stack("main",index,ItemStack(stack:get_name() .. " " .. (stack:get_count()-1)))
			end
			self.target=self.user
			self.returnback=true
		end
		livetools.set_lookat(self,target)
		livetools.set_walk(self)
		self.object:set_acceleration({x=0, y=-8, z=0})
		if (livetools.def({x=pos.x+self.mx,y=pos.y,z=pos.z+self.mz},"walkable")
		and livetools.def({x=pos.x+self.mx,y=pos.y+1,z=pos.z+self.mz},"walkable")==false)
		or (livetools.def({x=pos.x+self.mx,y=pos.y-1,z=pos.z+self.mz},"walkable")==false
		and livetools.def({x=pos.x,y=pos.y-1,z=pos.z},"walkable")) then
			local v=self.object:get_velocity()
			self.object:set_velocity({x = v.x,y = 5,z =v.z})
		end

end,
destry=false,
time=0,
mx=0,
mz=0,
able_to_see=true,
type="npc",
dmg=4,
})

livetools.get_distance=function(self,pos)
	if pos==nil or pos.x==nil then return nil end
	local p=self.object:get_pos()
	return math.sqrt((p.x-pos.x)*(p.x-pos.x) + (p.y-pos.y)*(p.y-pos.y)+(p.z-pos.z)*(p.z-pos.z))
end

livetools.get_visiable=function(pos,ta)
	if not (ta and ta.x and ta.y and ta.z) then
		return nil
	end
	local v = {x = pos.x - ta.x, y = pos.y - ta.y-1, z = pos.z - ta.z}
	v.y=v.y-1
	local amount = (v.x ^ 2 + v.y ^ 2 + v.z ^ 2) ^ 0.5
	local d=math.sqrt((pos.x-ta.x)*(pos.x-ta.x) + (pos.y-ta.y)*(pos.y-ta.y)+(pos.z-ta.z)*(pos.z-ta.z))
	v.x = (v.x  / amount)*-1
	v.y = (v.y  / amount)*-1
	v.z = (v.z  / amount)*-1
	for i=1,d,1 do
		if livetools.def({x=pos.x+(v.x*i),y=pos.y+(v.y*i),z=pos.z+(v.z*i)},"walkable") then
			return false
		end
	end
	return true
end

livetools.punch=function(self,ob,hp)
	if hp>=999 then
		if self and self.object then
			self.object:set_hp(0) 
			self.object:punch(self.object, hp,{full_punch_interval=1.0,damage_groups={fleshy=4}})
		end
	elseif self.user and self.user:is_player() then 
		ob:punch(self.user, hp,{full_punch_interval=1.0,damage_groups={fleshy=4}})
	else
		ob:punch(self.object, hp,{full_punch_interval=1.0,damage_groups={fleshy=4}})
	end
	return self
end

livetools.set_walk=function(self)
	local pos=self.object:get_pos()
	local yaw=self.object:getyaw()
	if yaw ~= yaw then
		return false
	end
	local x =math.sin(yaw) * -1
	local z =math.cos(yaw) * 1
	self.mx=x
	self.mz=z
	self.object:set_velocity({x = x*4,y = self.object:get_velocity().y,z = z*4})
	return self
end

livetools.set_lookat=function(self,goto)
	if not (goto and goto.x and goto.y and goto.z) then
		return self
	end
	local pos=self.object:get_pos()
	local vec = {x=pos.x-goto.x, y=pos.y-goto.y, z=pos.z-goto.z}
	local yaw = math.atan(vec.z/vec.x)-math.pi/2
	if pos.x > goto.x then yaw = yaw+math.pi end
	self.object:setyaw(yaw)
	return self
end