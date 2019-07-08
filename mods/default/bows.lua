bows={
	cluser=true,
	pvp=minetest.settings:get_bool("enable_pvp") or nil,
	nitroglycerin=minetest.get_modpath("nitroglycerin")~=nil,
	creative=minetest.settings:get_bool("creative_mode"),
	mesecons=minetest.get_modpath("mesecons"),
	registed_arrows={},
	registed_bows={},
}

bows.register_arrow=function(name,def)
	if name==nil or name=="" then return false end

	def.damage = def.damage or 0
	def.name = minetest.get_current_modname() ..":arrow_".. name
	def.level = def.level or 1
	def.on_hit_object = def.on_hit_object or bows.nothing
	def.on_hit_node = def.on_hit_node or bows.on_hit_node
	def.on_hit_sound= def.on_hit_sound or "default_dig_dig_immediate"
	def.on_step = def.on_step or bows.nothing

	bows.registed_arrows[def.name]=def

	minetest.register_craftitem(def.name, {
		description = def.description or name,
		inventory_image = (def.texture or "default_wood.png") .. "^default_arrow.png^[makealpha:0,255,0",
		groups = {arrow=1}
	})
	if def.craft then
		def.craft_count= def.craft_count or 4
		minetest.register_craft({
			output = def.name .." " .. def.craft_count,
			recipe = def.craft
		})
	end
end

bows.register_bow=function(name,def)
	if name==nil or name=="" then return false end

	def.replace = minetest.get_current_modname()..":bow_" .. name .."_loaded"
	def.name = minetest.get_current_modname()..":bow_".. name
	def.uses = def.uses-1 or 49
	def.shots = def.shots or 1
	def.texture = def.texture or "default_wood.png"
	def.groups = def.groups or {}

	def.groups.bow=1

	bows.registed_bows[def.replace]=def

	minetest.register_tool(def.name, {
		description = def.description or name,
		inventory_image = def.texture .. "^default_bow.png^[makealpha:0,255,0",
		on_use =bows.load,
		groups = def.groups,
		wield_scale={x=2,y=2,z=1}
	})
	minetest.register_tool(def.replace, {
		description = def.description or name,
		inventory_image = def.texture .. (def.shots == 1 and "^default_bow_loaded.png" or "^default_bow_loaded_multi.png") .. "^[makealpha:0,255,0",
		on_use =bows.shoot,
		groups = {bow=1,not_in_creative_inventory=1},
		wield_scale={x=2,y=2,z=1}
	})
	if def.craft then
		minetest.register_craft({output = def.name,recipe = def.craft})
	end
	def.craft=nil
end

bows.load=function(itemstack, user, pointed_thing)
	local inv=user:get_inventory()
	local index=user:get_wield_index()-1
	local arrow=inv:get_stack("main", index)
	if minetest.get_item_group(arrow:get_name(), "arrow")==0 then return itemstack end
	local item=itemstack:to_table()
	local meta=minetest.deserialize(item.metadata)
	local shots=bows.registed_bows[item.name .. "_loaded"].shots
	if bows.creative==false then
		local c=arrow:get_count()-shots
		if c<0 then
			shots=arrow:get_count()
			c=0
		end
		inv:set_stack("main",index,ItemStack(arrow:get_name() .. " " .. c))
	end
	meta={arrow=arrow:get_name(),shots=shots}
	item.metadata=minetest.serialize(meta)
	item.name=item.name .. "_loaded"
	itemstack:replace(item)
	return itemstack
end

bows.shoot=function(itemstack, user, pointed_thing)
	local item=itemstack:to_table()
	local meta=minetest.deserialize(item.metadata)

	if (not (meta and meta.arrow)) or (not bows.registed_arrows[meta.arrow]) then
		return itemstack
	end
	local name=itemstack:get_name()
	local replace=bows.registed_bows[name].name
	local ar=bows.registed_bows[name].uses
	local wear=bows.registed_bows[name].uses
	local level=19 + bows.registed_bows[name].level
	local shots=meta.shots or 1

	item.arrow=""
	item.metadata=minetest.serialize(meta)
	item.name=replace
	itemstack:replace(item)
	if bows.creative==false then
		itemstack:add_wear(65535/wear)
	end
	for i=0,shots-1,1 do
		minetest.after(0.05*i, function(level,user,meta)
			bows.tmp = {}
			bows.tmp.arrow = meta.arrow
			bows.tmp.user = user
			bows.tmp.name=meta.arrow
			bows.tmp.shots=shots

			local pos = user:get_pos()
			local dir = user:get_look_dir()

			local x=math.random(-1,1)*0.1
			local y=math.random(-1,1)*0.1
			local z=math.random(-1,1)*0.1

			local e=minetest.add_entity({x=pos.x+x,y=pos.y+1.5+y,z=pos.z+z}, "default:arrow")
			e:set_velocity({x=dir.x*level, y=dir.y*level, z=dir.z*level})
			e:set_acceleration({x=dir.x*-3, y=-10, z=dir.z*-3})
			e:set_yaw(user:get_look_yaw()+math.pi)
			minetest.sound_play("default_bow_shoot", {pos=pos})
		end,level,user,meta)
	end

	return itemstack
end













bows.nothing=function(self,target,hp,user,lastpos)
	return self
end

bows.on_hit_object=function(self,target,hp,user,lastpos)
	local hp2=target:get_hp()-hp
	default.punch(target,target,1)
	if hp2>0 then
		local pos=self.object:get_pos()
		local opos=target:get_pos()
		local dir = user:get_look_dir()
		self.object:set_attach(target, "", {x=(opos.x-pos.x)*4,y=(pos.y-opos.y)*4,z=(pos.z-opos.z)*4},{x=0,y=-90,z=0})
	end
	return self
end

bows.on_hit_node=function(self,pos,user,lastpos)
	if not default.defpos(pos,"node_box") then
		local mpos={x=(pos.x-lastpos.x),y=(pos.y-lastpos.y),z=(pos.z-lastpos.z)}
		local npos={x=bows.rnd(pos.x),y=bows.rnd(pos.y),z=bows.rnd(pos.z)}
		local m={x=-0.6,y=-0.6,z=-0.6}
		local bigest={x=mpos.x,y=mpos.y,z=mpos.z}
		if bigest.x<0 then bigest.x=bigest.x*-1 m.x=0.6 end
		if bigest.y<0 then bigest.y=bigest.y*-1 m.y=0.6 end
		if bigest.z<0 then bigest.z=bigest.z*-1 m.z=0.6 end
		local b=math.max(bigest.x,bigest.y,bigest.z)
		if b==bigest.x then
			pos.x=npos.x+m.x
		elseif b==bigest.y then
			pos.y=npos.y+m.y
		else
			pos.z=npos.z+m.z
		end
		self.object:set_pos(pos)
	end
	return self
end

bows.rnd=function(r)
	return math.floor(r+ 0.5)
end

bows.arrow_remove=function(self)
	if self.object:get_attach() then self.object:set_detach() end
	if self.target then default.punch(self.target,self.object,1) end
	self.object:remove()
	return self
end

minetest.register_entity("default:arrow",{
	hp_max = 10,
	visual="wielditem",
	visual_size={x=0.20,y=0.20},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not self.target then return self end
		if not self.hp then self.hp=self.object:get_hp() end
		local hp=self.object:get_hp()
		local hurt=self.hp-self.object:get_hp()
		self.hp=self.object:get_hp()
		self.target:set_hp(self.target:get_hp()-hurt)
		default.punch(target,self.object,hurt)
		if hurt>100 or hp<=hurt then
			self.target:set_detach()
			self.target:set_velocity({x=0, y=4, z=0})
			self.target:set_acceleration({x=0, y=-10, z=0})
			self.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
			bows.arrow_remove(self)
		end
		return self
	end,
	on_activate = function(self, staticdata)
		if bows.tmp and bows.tmp.arrow ~= nil then
			self.arrow=bows.tmp.arrow
			self.user=bows.tmp.user
			self.name=bows.tmp.name
			self.dmg=bows.registed_arrows[self.name].damage
			bows.tmp=nil
			self.object:set_properties({textures={self.arrow}})
		else
			self.object:remove()
		end
	end,
	stuck=false,
	bow_arrow=true,
	timer=20,
	timer2=0,
	timer3=0,
	x=0,
	y=0,
	z=0,
	on_step=	function(self, dtime)
		self.timer=self.timer-dtime
		self.timer3=self.timer3+dtime
		if self.timer3<self.timer2 then return self end
		self.timer3=0
		if self.stuck then
			if self.node and minetest.get_node(self.node_pos).name~=self.node then
				minetest.add_item(self.object:get_pos(),self.name .." 1"):set_velocity({x = math.random(-0.5, 0.5),y=0.5,z = math.random(-0.5, 0.5)})
				self.timer=-1
			elseif self.node==nil and not self.object:get_attach() then
				minetest.add_item(self.object:get_pos(),self.name .." 1"):set_velocity({x = math.random(-0.5, 0.5),y=0.5,z = math.random(-0.5, 0.5)})
				self.timer=-1
			end
			if self.timer<0 then
				bows.arrow_remove(self)
			end
			return self
		end
		local pos=self.object:get_pos()
		local no=minetest.registered_nodes[minetest.get_node(pos).name]
		if not no then bows.arrow_remove(self) return self end
		if (self.user==nil or self.timer<16 ) or no.walkable then
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=0, z=0})
			self.stuck=true
			self.timer2=0.2
			bows.registed_arrows[self.name].on_hit_node(self,pos,self.user,{x=self.x,y=self.y,z=self.z})
			minetest.sound_play(bows.registed_arrows[self.name].on_hit_sound, {pos=pos, gain = 1.0, max_hear_distance = 7})
			return self
		end
		self.x=pos.x
		self.y=pos.y
		self.z=pos.z
		bows.registed_arrows[self.name].on_step(self,dtime,self.user,pos,{x=self.x,y=self.y,z=self.z})
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if ob and ((bows.pvp and ob:is_player() and ob:get_player_name()~=self.user:get_player_name()) or (ob:get_luaentity() and ob:get_luaentity().physical and ob:get_luaentity().bow_arrow==nil and ob:get_luaentity().name~="__builtin:item" )) then
				self.object:set_velocity({x=0, y=0, z=0})
				self.object:set_acceleration({x=0, y=0, z=0})
				self.stuck=true
				self.timer2=0.2
				bows.on_hit_object(self,ob,self.dmg,self.user,{x=self.x,y=self.y,z=self.z})
				bows.registed_arrows[self.name].on_hit_object(self,ob,self.dmg,self.user,{x=self.x,y=self.y,z=self.z})
				minetest.sound_play(bows.registed_arrows[self.name].on_hit_sound, {pos=pos, gain = 1.0, max_hear_distance = 7})
				return self
			end
		end
	return self
	end,
})





bows.register_bow("wood",{
	description="Wooden bow",
	uses=50,
	level=1,
	craft={
		{"","group:stick","materials:string"},
		{"group:stick","","materials:string"},
		{"","group:stick","materials:string"}
	},
})

bows.register_arrow("arrow",{
	description="Arrow",
	texture="default_wood.png",
	damage=5,
	craft_count=8,
	craft={{"default:flint","group:stick","examobs:feather"},}
})

bows.register_arrow("fire",{
	description="Fire arrow",
	texture="default_wood.png^[colorize:#ffb400cc",
	damage=10,
	craft_count=1,
	on_hit_node=function(self,pos,user,lastpos)
		if not minetest.is_protected(lastpos, user:get_player_name()) and default.defpos(lastpos,"buildable_to") then
			minetest.set_node(lastpos,{name="fire:basic_flame"})
		end
		bows.arrow_remove(self)
		return self
	end,
	on_hit_object=function(self,target,hp,user,lastpos)
		bows.registed_arrows["default:arrow_fire"].on_hit_node(self,lastpos,user,target:get_pos())
		bows.arrow_remove(self)

	end,
	craft={
		{"group:arrow","default:torch"},
	}
})


bows.register_arrow("build",{
	description="Build arrow",
	texture="default_wood.png^[colorize:#33336677",
	on_hit_node=function(self,pos,user,lastpos)
		local name=user:get_player_name()
		local node=minetest.get_node(lastpos).name
		local index=user:get_wield_index()+1
		local inv=user:get_inventory()
		local stack=inv:get_stack("main", index)
		if minetest.is_protected(lastpos, name) then
			minetest.chat_send_player(name, minetest.pos_to_string(lastpos) .." is protected")
		elseif default.def(node,"buildable_to") and minetest.registered_nodes[stack:get_name()] then
			minetest.set_node(lastpos,{name=stack:get_name()})
			if bows.creative==false then
				inv:set_stack("main",index,ItemStack(stack:get_name() .. " " .. (stack:get_count()-1)))
			end
		end
		bows.arrow_remove(self)
		return self
	end,
	craft_count=8,
	damage=8,
	craft={
		{"group:arrow","group:arrow","group:arrow"},
		{"group:arrow","default:obsidian","group:arrow"},
		{"group:arrow","group:arrow","group:arrow"}
	}
})

bows.register_arrow("dig",{
	description="Dig arrow",
	texture="default_wood.png^[colorize:#333333aa",
	on_hit_node=function(self,pos,user,lastpos)
		minetest.node_dig(pos, minetest.get_node(pos), user)
		bows.arrow_remove(self)
		return self
	end,
	craft_count=16,
	damage=8,
	craft={
		{"group:arrow","group:arrow","group:arrow"},
		{"group:arrow","default:steel_lump","group:arrow"},
		{"group:arrow","group:arrow","group:arrow"}
	}
})

bows.register_arrow("toxic",{
	description="Toxic arrow",
	texture="default_wood.png^[colorize:#66aa11aa",
	on_hit_object=function(self,target,hp,user,lastpos)
		if self then
			bows.arrow_remove(self)
		end
		default.punch(target,target,3)
		if math.random(1,5) == 1 or target:get_hp() == 0 or not target:get_pos() then
			return
		end
		minetest.after(math.random(0.5,2),function(target)
			bows.registed_arrows["default:arrow_toxic"].on_hit_object(nil,target)
		end,target)
	end,
	craft_count=1,
	damage=0,
	craft={
		{"group:arrow","plants:dolls_eyes_berries"},
	}
})

bows.register_arrow("tetanus",{
	description="Tetanus arrow (currently affects mobs only)",
	texture="default_wood.png^[colorize:#aa5500aa",
	on_hit_object=function(self,target,hp,user,lastpos)
		bows.arrow_remove(self)
		local en =  target:get_luaentity()
		if en and en.hp_max < 100 then
			local step = en.on_step
			en.on_step=function(self,dtime)
				self.Tetanus_timer = (self.Tetanus_timer or 0) + dtime
				if self.Tetanus_timer > 10 then
					self.on_step=step
					self.Tetanus_timer = nil
				end
				return self
			end
		end
	end,
	craft_count=4,
	damage=1,
	craft={
		{"","group:arrow",""},
		{"group:arrow","plants:cow_parsnip_big","group:stick"},
		{"","group:arrow",""}
	}
})

bows.register_arrow("exposive",{
	description="Exposive arrow",
	texture="default_wood.png^[colorize:#aa0000aa",
	on_hit_object=function(self,target,hp,user,lastpos)
		bows.registed_arrows["default:arrow_exposive"].on_hit_node(self,target:get_pos(),user)
	end,
	on_hit_node=function(self,pos,user)
		bows.arrow_remove(self)
		local name = user:get_player_name()
		if not minetest.is_protected(pos, name) then
			nitroglycerin.explode(pos,{
				place_chance=1,
				user_name=name,
			})
		end
	end,
	craft_count=2,
	damage=15,
	craft={
		{"","default:coal_lump",""},
		{"default:coal_lump","group:arrow","default:coal_lump"},
		{"","default:coal_lump",""}
	}
})

bows.register_arrow("nitrogen",{
	description="Nitrogen arrow",
	texture="default_wood.png^[colorize:#00c482aa",
	on_hit_object=function(self,target,hp,user,lastpos)
		bows.arrow_remove(self)
		if target:get_hp() <= 13 then
			nitroglycerin.freeze(target)
		else
			default.punch(target,target,10)
		end
	end,
	craft_count=4,
	damage=0,
	craft={
		{"","default:ice",""},
		{"default:ice","group:arrow","default:ice"},
		{"","default:ice",""}
	}
})