minetest.register_on_punchnode(function(pos,node,puncher,pointed_thing)
	if exatec.temp.teleport_tube then
		local n = puncher:get_player_name()
		local d = exatec.temp.teleport_tube[n]
		if d then
			if exatec.test_input(pos,ItemStack("default:unknown"),d,d) then
				minetest.registered_nodes["exatec:tube_teleport"].on_teleporttube_set(d,pos)
			end
			exatec.temp.teleport_tube[n] = nil
			if #exatec.temp.teleport_tube <= 0 then
				exatec.temp.teleport_tube = nil
			end
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local n = player:get_player_name()
	if exatec.temp.teleport_tube then
		exatec.temp.teleport_tube[n] = nil
		if exatec.temp.teleport_tube and #exatec.temp.teleport_tube <= 0 then
			exatec.temp.teleport_tube = nil
		end
	end
end)


exatec.def=function(pos)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	return def and def.exatec or {}
end

exatec.getnodedefpos=function(pos)
	local no = minetest.registered_nodes[minetest.get_node(pos).name]
	return no or {}
end

exatec.samepos=function(p1,p2)
	return p1.x == p2.x and p1.y == p2.y and p1.z == p2.z
end

exatec.is_pos=function(p)
	return type(p) == "table" and type(p.x) == "number" and type(p.y) == "number" and type(p.z) == "number"
end

exatec.test_input=function(pos,stack,opos,cpos)
	local a = exatec.def(pos)
	local def = exatec.getnodedefpos(pos)
	if a.test_input then
		return a.test_input(pos,stack,opos,cpos)
	--elseif def.allow_metadata_inventory_put then --mess
	--	return ItemStack(stack:get_name() .. " " ..allow_metadata_inventory_put(pos, a.input_list,1, stack, ""))
	elseif a.input_list then
		return minetest.get_meta(pos):get_inventory():room_for_item(a.input_list,stack)
	else
		return false
	end
end

exatec.test_output=function(pos,stack,opos)
	local a = exatec.def(pos)
	if a.test_output then
		return a.test_output(pos,stack,opos)
	--elseif def.allow_metadata_inventory_take then --mess
	--	return ItemStack(stack:get_name() .. " " ..allow_metadata_inventory_take(pos, a.input_list,1, stack, ""))
	elseif a.output_list then
		return minetest.get_meta(pos):get_inventory():contains_item(a.output_list,stack)
	else
		return false
	end
end

exatec.input=function(pos,stack,opos,cpos)
	local a = exatec.def(pos)
	local re
	stack = a.input_max and stack:get_count() > a.input_max and ItemStack(stack:get_name() .." " .. a.input_max) or stack
	if a.input_list then
		local inv = minetest.get_meta(pos):get_inventory()
		if not inv:room_for_item(a.input_list,stack) then
			return false
		end
		inv:add_item(a.input_list,stack)
		re = true
	end
	if a.on_input then
		a.on_input(pos,stack,opos,cpos)
	end
	local def = exatec.getnodedefpos(pos)
	if def.on_metadata_inventory_put then
		def.on_metadata_inventory_put(pos, a.input_list, 1, stack, "")
	end

	return re					
end

exatec.output=function(pos,stack,opos)
	local a = exatec.def(pos)
	stack = a.output_max and stack:get_count() > a.output_max and ItemStack(stack:get_name() .." " .. a.output_max) or stack
	local new_stack
	if a.output_list then
		local inv = minetest.get_meta(pos):get_inventory()
		new_stack = inv:remove_item(a.output_list,stack)
	end
	if a.on_input then
		a.on_input(pos,new_stack,opos)
	end
	local def = exatec.getnodedefpos(pos)
	if def.on_metadata_inventory_take then
		def.on_metadata_inventory_take(pos, a.output_list, 1, stack, "")
	end
	return new_stack
end

exatec.send=function(pos, force_ignored_pos,forcepos,ignore_pos)
	local na=pos.x .."." .. pos.y .."." ..pos.z
	if ignore_pos then
		exatec.wire_signals[ignore_pos.x .."." .. ignore_pos.y .."." ..ignore_pos.z] = {pos=pos,ignore=true}
	end
	if not exatec.wire_signals[na] or force_ignored_pos then
		local t=os.time()
		if os.difftime(t, exatec.wire_sends.last)>1 then
			exatec.wire_sends.last=t
			exatec.wire_sends.times=0
		else
			exatec.wire_sends.times=exatec.wire_sends.times+1
			if exatec.wire_sends.times>50 then
				return
			end
		end
		exatec.wire_signals[na]={pos=pos}
		local n=exatec.get_node(pos)
		if forcepos then
			if minetest.get_item_group(n,"exatec_wire") > 0 then
				exatec.wire_signals[na]={pos=pos}
				minetest.swap_node(pos,{name=n,param2=105})
				minetest.get_node_timer(pos):start(0.1)
			end
			if minetest.get_item_group(n,"exatec_wire_connected") > 0 then
				exatec.wire_signals[na]={pos=pos,ignore=true}
				local e = exatec.def(pos)
				if e.on_wire then
					e.on_wire(pos,pos)
				end
			end
		end
		minetest.after(0, function()
			exatec.wire_leading()
		end)
	end
end

exatec.get_node=function(pos)
	local n=minetest.get_node(pos).name
	if n=="ignore" then
		local vox=minetest.get_voxel_manip()
		local min, max=vox:read_from_map(pos, pos)
		local area=VoxelArea:new({MinEdge = min, MaxEdge = max})
		local data=vox:get_data()
		local i=area:indexp(pos)
		n=minetest.get_name_from_content_id(data[i])
	end
	return n
end

exatec.wire_leading=function()
	local c=0
	for i, v in pairs(exatec.wire_signals) do
		if not v.ignore then
			for ii, p in pairs(exatec.wire_rules) do
				local n={x=v.pos.x+p.x,y=v.pos.y+p.y,z=v.pos.z+p.z}
				local s=n.x .. "." .. n.y .."." ..n.z
				local na=exatec.get_node(n)
				if not exatec.wire_signals[s] then
					if minetest.get_item_group(na,"exatec_wire") > 0 then
						exatec.wire_signals[s]={pos=n}
						minetest.swap_node(n,{name=na,param2=105})
						minetest.get_node_timer(n):start(0.1)
						c=c+1
					end
					if minetest.get_item_group(na,"exatec_wire_connected") > 0 then
						exatec.wire_signals[s]={pos=n,ignore=true}
						local e = exatec.def(n)
						if e.on_wire then
							e.on_wire(n,v.pos)
						end
					end
				end
			end
		end
	end
	if c > 0 then
		minetest.after(0, function()
			exatec.wire_leading()
		end)
	else
		exatec.wire_signals={}
	end
end

exatec.data_send=function(pos,channel,from_channel,data)
	local na=pos.x .."." .. pos.y .."." ..pos.z
	if not exatec.wire_data_signals[na] then
		local t=os.time()
		if os.difftime(t, exatec.wire_data_sends.last)>1 then
			exatec.wire_data_sends.last=t
			exatec.wire_data_sends.times=0
		else
			exatec.wire_data_sends.times=exatec.wire_data_sends.times+1
			if exatec.wire_data_sends.times>50 then
				return
			end
		end
		data = data or {}
		data.channel = channel
		data.from_channel = from_channel
		data.from_pos = pos
		data.owner = minetest.get_meta(pos):get_string("owner")
		exatec.wire_data_signals[na]={jobs={[na]=pos},data=data}
		minetest.after(0, function()
			exatec.wire_data_leading()
		end)
	end
end

exatec.wire_data_leading=function()
	local counts=0
	for i, a in pairs(exatec.wire_data_signals) do
		local c=0
		for xyz, pos in pairs(a.jobs) do
			if not pos.ignore then
				for ii, p in pairs(exatec.wire_rules) do
					local n={x=pos.x+p.x,y=pos.y+p.y,z=pos.z+p.z}
					local s=n.x .. "." .. n.y .."." ..n.z
					local na=exatec.get_node(n)
					if not a.jobs[s] then
						if minetest.get_item_group(na,"exatec_data_wire")>0 then
							a.jobs[s]=n
							c=c+1
							minetest.swap_node(n,{name=na,param2=105})
							minetest.get_node_timer(n):start(0.1)
						elseif minetest.get_item_group(na,"exatec_data_wire_connected")>0 then
							local e = exatec.def(n)

							if e.on_data_wire and minetest.get_meta(n):get_string("channel") == a.data.channel then
								e.on_data_wire(n,a.data)
							end
							a.jobs[s] = {ignore=true}
							c=c+1
						end
					end
				end
			end
		end
		if c==0 then
			exatec.wire_data_signals[i]=nil
		else
			counts=counts+c
		end
	end
	if counts>0 then
		minetest.after(0, function()
			exatec.wire_data_leading()
		end)
	else
		exatec.wire_data_signals={}
	end
end

exatec.run_code=function(text,A)
	A = A or {}
	local s
	local m
	local ccp
	local findc

	if not A.mob then
		m = minetest.get_meta(A.pos)
		ccp = m:get_string("connected_constructor")
		findc = string.find(string.lower(text),"node.")
	end

	if ccp ~= "" and findc then
		local cc = minetest.string_to_pos(ccp)
		if minetest.get_node(cc).name == "exatec:node_constructor" then
			local cccp = minetest.get_meta(cc):get_string("connection")
			if cccp ~= "" and exatec.samepos(minetest.string_to_pos(cccp),A.pos) then
				if exatec.temp.constructor then
					return
				end
				exatec.temp.constructor = {constructor=cc,pcb=A.pos}
			else
				minetest.get_meta(cc):get_string("connection","")
			end
		else
			m:set_string("connected_constructor","")
		end
	elseif findc then
		return "Connect a ''Node constructor'' to use the node functions"
	end

	local g={user=A.name,count = 0,pos=vector.new(A.pos),storage=A.mob and A.self and (A.self.storage and A.self.storage.exatec or {}) or minetest.deserialize(m:get_string("storage")) or {}}

	local F=function()
		local f,err = loadstring(text)
		if f then
			local br,br2,br3 = setfenv(f,exatec.create_env(A,g,A.self))
			if rawget(_G,"jit") then
				jit.off(f,true)
			end
			debug.sethook(
				function()
					g.count = g.count + 1
					if g.count >= 100000 then
						debug.sethook()
						error(" Overheated (event limit) ("..g.count.."/100000)",1)
					end
				end,"",2
			)
			f()
			debug.sethook()

			if A.mob then
				A.self.storage.exatec = g.storage
			else
				m:set_string("storage",minetest.serialize(g.storage) or {})
			end
		end
		return (err or ""),g.count
	end
	local s,err = pcall(F)
	debug.sethook()
	exatec.temp.constructor = nil

	if err then
		local e1,e2 = err:find(": ")
		if type(e2) == "number" then
			err = err:sub(e2,-1)
		end
	end
	return err,g.count
end

exatec.create_env=function(A,g,self)
	local id = g and g.pos and (g.pos.x..",".. g.pos.y..",".. g.pos.z) or ""
	return {
		storage=g and g.storage or nil,
		apos=apos,
		apos_text = "apos(pos,x,y,z) add to pos/vector",
		event=g,
		mob= self and {
			get_pos_text = "(id/nil) get pos from object",
			get_pos=function(n)
				if not n then
					return self.object:get_pos()
				end
				self.objects = self.objects or {}
				local ob = self.objects[n]
				return ob and ob:get_pos() or nil
			end,
			self_text = "() get self object id",
			self=function()
				self.objects = self.objects or {}
				self.objects[self.examob] = self.object
				return self.examob
			end,
			exists_text = "(id) returns true if object exists in object list",
			exists=function(id)
				self.objects = self.objects or {}
				local ob = self.objects[id]
				if ob and not ob:get_pos() then
					self.objects[id] = nil
					return false
				end
				return ob ~= nil
			end,
			walk_text = "(nil/true) walk/run",
			walk=function(run)
				examobs.walk(self,run)
			end,
			jump_text = "() jump",
			jump=function()
				examobs.jump(self)
			end,
			stand_text = "(id/pos) look at object or pos",
			stand=function()
				examobs.stand(self)
			end,
			lookat_text = "(id/pos/nil) look at object/pos/random",
			lookat=function(n)
				local ob = self.objects and self.objects[n] or n
				if ob then
					examobs.lookat(self,ob)
				else
					self.object:set_yaw(math.random(0,6.28))
				end
			end,
			visiable_text = "(pos) if pos is visiable (not blocked)",
			visiable=function(pos)
				examobs.visiable(self,pos)
			end,
			team_text = "(id/nil) get object/self team",
			team=function(n)
				local ob = self.objects and self.objects[n] or self.object
				examobs.team(ob)
			end,
			gethp_text = "(id/nil) get object/self health",
			gethp=function(n)
				local ob = self.objects and self.objects[n] or self.objects
				examobs.gethp(ob)
			end,
			viewfield_text = "(id) if object is in viewfield",
			viewfield=function(n)
				local ob = self.objects and self.objects[n]
				examobs.viewfield(self,ob)
			end,
			dropall_text = "() drop all items",
			dropall=function()
				examobs.dropall(self)
			end,
			dying_text = "(n) 1 = dying, 2 = dead, 3 = relive",
			dying=function(n)
				examobs.dying(self,n)
			end,
			distance_text = "(object1/pos1,object2/pos2)",
			distance=function(pos1,pos2)
				self.objects = self.objects or {}
				local p1 = type(pos1) ~= "table" and self.objects[pos1] or pos1 == nil and self.object or pos1
				local p2 = type(pos2) ~= "table" and self.objects[pos2] or pos2
				if not p1 then
					error("mob.distance: pos1/object1 is nil")
				elseif not p2 then
					error("mob.distance: pos2/object2 is nil")
				end
				return examobs.distance(p1,p2)
			end,
			pointat_text = "(n) pos front of self",
			pointat=function(d)
				examobs.pointat(self,d)
			end,
			punch_text = "(id)",
			punch=function(n)
				local ob = self.objects and self.objects[n] or self.object
				if examobs.distance(self.object,ob) <= self.reach  then
					examobs.punch(self.object,ob,self.dmg)
				end
			end,
			showtext_text = "(text,nil/hexcolor) temporary change the nametag, do not add # to the color code",
			showtext=function(text,color)
				examobs.showtext(self,text,color)
			end,
			get_object_text = "(type) get object id from fight, flee, folow, target",
			get_object=function(typ)
				local types = {fight=true,flee=true,folow=true,target=true}
				if types[typ] then
					local id = ob_id(self[typ])
					if id then
						self.objects = self.objects or {}
						local ob = self.objects[id]
						if ob and examobs.gethp(ob) <= 0 then
							self.objects[id] = nil
							return
						end
						ob = self[typ]
					end
					return id
				else
					error("mob.get_object(fight/flee/folow/target)")
				end
			end,
			set_object_text = "(type,id) set object as fight, flee, folow, target",
			set_object=function(typ,n)
				local types = {fight=true,flee=true,folow=true,target=true}
				if types[typ] and n then
					self.objects = self.objects or {}
					local o = self.objects[n]
					self[typ] = o
					if not o then
						self.objects[n] = nil
					end
				else
					error("mob.set_object(fight/flee/folow/target,object) ("..type(typ)..","..type(n)..")")
				end
			end,
			remove_object_text = "(id/nil,type/nil) remove object from list, and or from fight, flee, folow, target",
			remove_object=function(typ,n)
				local types = {fight=true,flee=true,folow=true,target=true}
				if types[typ] then
					self[typ] = nil
				end
				if n then
					self.objects = self.objects or {}
					self.objects[n] = nil
				end
			end,
			collect_objects_inside_radius_text = "(rad/nil) adds object in radius to list",
			collect_objects_inside_radius=function(d)
				local obs = {}
				for _, ob in pairs(minetest.get_objects_inside_radius(g.pos, d or self.range)) do
					local en = ob:get_luaentity()
					if not en or en and en.examob and examobs.gethp(ob) > 0 and examobs.visiable(self,ob) then
						obs[ob_id(ob)] = ob
					end
				end
				self.objects = obs
			end,
			get_objects_text = "(rad/nil) return object in list",
			get_objects=function(d)
				local p1 = self.object:get_pos()
				local l = {}
				self.objects = self.objects or {}
				for i, v in pairs(self.objects or {}) do
					local p2 = v:get_pos()
					if d then
						if p2 and examobs.distance(p1,p2) <= d then
							table.insert(l,i)
						end
					elseif p2 then
						table.insert(l,i)
					end
				end
				return l
			end,
			say_text = "(text) send chat text",
			say=function(t)
				self:say(t)
			end,
			standby_text = "(true/false) waiting mode",
			standby=function(toggle)
				self.standby = toggle
			end,
			dig_text = "(pos) dig",
			dig=function(pos)
				local n = minetest.get_node(pos).name
				local sp = self:pos()
				local def = minetest.registered_nodes[n] or {}
				local owner = minetest.get_meta(pos):get_string("owner")
				local can_dig = def and (def.can_dig and def.can_dig(pos, {get_player_name=function() return owner end}))
				if vector.distance(sp,pos) <= self.reach and (can_dig == nil or can_dig == true) and not minetest.is_protected(pos,A.user) and minetest.get_item_group(n,"unbreakable") == 0 then
					local d = minetest.get_node_drops(n)
					for i,v in pairs(d) do
						self.inv[v] = (self.inv[v] or 0)+1
					end
					minetest.remove_node(pos)
					return true
				end
				return false
			end,
			place_text = "(pos,node_name) place",
			place=function(pos,item)
				local n = minetest.get_node(pos).name
				local sp = self:pos()
				local inv = self.inv[item]
				if self.inv[item] and minetest.registered_nodes[item] and vector.distance(sp,pos) <= self.reach and not minetest.is_protected(pos,A.user) and default.defpos(pos,"buildable_to") then
					minetest.set_node(pos,{name=item})
					self.inv[item] = self.inv[item] -1
					if self.inv[item] <= 0 then
						self.inv[item] = nil
					end
					return true
				end
				return false
			end,
			new_path_text = "(pos) create new path to pos",
			new_path=function(pos)
				if default.defpos(pos,"walkable") then
					for y=-1,1 do
					for x=-1,1 do
					for z=-1,1 do
						local p2 = apos(pos,x,y,z)
						if not default.defpos(p2,"walkable") then
							pos = p2
							goto path
						end
					end
					end
					end
				end
				::path::
				self.lifetimer = self.lifetime*2

				self.path = minetest.find_path(vector.round(self:pos()),pos, 50, 1, 1,"Dijkstra")
				self.path_index = 1
				self.path_attempts = 100

				if not self.path then
					self.object:set_yaw(math.random(0,6.28))
					examobs.walk(self)
					examobs.jump(self)
					self.path_create_attempt = (self.path_create_attempt or 0) +1
					if self.path_create_attempt >= 10 then
						self.path_create_attempt = nil
						error("mob.new_path: 10 attempts to create paths to "..minetest.pos_to_string(pos))
					end
				end
				return self.path ~= nil
			end,
			get_path_text = "() return path/nil",
			get_path=function(pos)
				return self.path
			end,
			folow_path_text = "(rad/nil) folow created path, finish when inside rad or near it",
			folow_path=function(rad)
				if self.path then
					local p = self:pos()
					local c = self.path[self.path_index]
					self.timer2 = self.updatetime -0.1
					if vector.distance(c,p) <= (rad or 1) then
						if not self.path[self.path_index+1] then
							self.path = nil
							self.path_index = nil
							self.path_attempts = nil
							self.path_create_attempt = nil
							return true
						else
							self.path_index = self.path_index +1
							self.path_attempts = 100
						end
					else
						examobs.lookat(self,c)
						examobs.walk(self)
						self.path_attempts = self.path_attempts -1
						if self.path_attempts < 0 then
							self.path_index = self.path_index +1
						end
					end
				end
				return false
			end,
			get_item_count_text = "(item_name) return item count",
			get_item_count=function(item)
				return self.inv[item] or 0
			end,
			add_item_text = "(pos,item,count/nil) add as much as possible from mob inventory to node inventory",
			add_item=function(pos,item,c)
				local def = minetest.registered_items[item]
				local inv = self.inv[item]
				if not (def and inv) or (c and type(c) ~= "number") or vector.distance(self:pos(),pos) > self.reach  then
					return false
				end
				local added = false
				local add = c or 99999
				for i=0,32 do
					c = c and c <= inv and c or def.stack_max <= self.inv[item] and def.stack_max or self.inv[item]
					local stack=ItemStack(item.." "..c)
					if exatec.test_input(pos,stack,pos,pos) then
						exatec.input(pos,stack,pos,pos)
						added = true
						self.inv[item] = self.inv[item] - c
						add = add - c
						if self.inv[item] <= 0 then
							self.inv[item] = nil
							break
						elseif add <= 0 then
							break
						end
					else
						break
					end
				end
				return added
			end,
			add_all_items_text = "(pos,item,count/nil) add as much items as possible from mob inventory to node inventory",
			add_all_items=function(pos)
				local added = false
				if vector.distance(self:pos(),pos) > self.reach then
					return false
				end
				for i,v in pairs(self.inv) do
					local stack=ItemStack(i.." "..v)
					if minetest.registered_items[i] and exatec.test_input(pos,stack,pos,pos) then
						exatec.input(pos,stack,pos,pos)
						self.inv[i] = self.inv[i] - v
						added = true
						if self.inv[i] <= 0 then
							self.inv[i] = nil
						end
					else
						break
					end
				end
				return added
			end,
			take_item_text = "(pos,item,count/nil) take as much as possible from the node inventory",
			take_item=function(pos,item,c)
				local def = minetest.registered_items[item]
				if not def or (c and type(c) ~= "number") or vector.distance(self:pos(),pos) > self.reach then
					return false
				end
				self.inv[item] = self.inv[item] or 0
				local taken = false
				local take = c or 99
				for i=0,32 do
					local stack=ItemStack(item.." "..c)
					local test = exatec.test_output(pos,stack,pos,pos)
					if test then
						local nstack = exatec.output(pos,stack,pos,pos)
						taken = true
						self.inv[item] = self.inv[item] + nstack:get_count()
						take = take - c
						if take <= 0 then
							break
						end
					else
						break
					end
				end
				return taken
			end,
			take_all_items_text = "(pos) take all items from the node inventory",
			take_all_items=function(pos,item,c)
				local can_take
				local a = exatec.def(pos)
				if not a.output_list or vector.distance(self:pos(),pos) > self.reach then
					return false
				end
				for i,stack in pairs(minetest.get_meta(pos):get_inventory():get_list(a.output_list)) do
					if not can_take then
						if exatec.test_output(pos,stack,pos,pos) then
							can_take = true
						else
							return false
						end
					end
					local n = stack:get_name()
					self.inv[n] = (self.inv[n] or 0) + stack:get_count()
					exatec.output(pos,stack,pos,pos)
				end
				return true
			end,
			pick_up_items_text = "() pick up items around the mob",
			pick_up_items=function()
				for _, ob in ipairs(minetest.get_objects_inside_radius(self:pos(), self.reach)) do
					local en = ob:get_luaentity()
					if en and en.name == "__builtin:item" then
						local st = en.itemstring.split(en.itemstring," ")
						local item = st[1]
						local count = st[2] and tonumber(st[2]) or 0
						self.inv[item] = (self.inv[item] or 0) + count
						ob:remove()
					end
				end
			end,
			give_text = "(id,item,count/nil) give items to object and player",
			give=function(id,item,c)
				self.objects = self.objects or {}
				local ob = self.objects[id]
				c = c or 1

				if type(c) ~= "number" or not self.inv[item] then
					return false
				end
				c = c <= self.inv[item] and c or self.inv[item]

				if ob and vector.distance(self:pos(),ob:get_pos()) <= self.reach then
					local en = ob:get_luaentity()
					if en and en.examob then
						en.inv[item] = (en.inv[item] or 0) + c
						self.inv[item] = self.inv[item] -c
						if self.inv[item] <= 0 then
							self.inv[item] = nil
						end
						return true
					elseif ob:is_player() then
						local stack = ItemStack(item.." "..c)
						if ob:get_inventory():room_for_item("main",stack) then
							ob:get_inventory():add_item("main",stack)
							self.inv[item] = self.inv[item] -c
							if self.inv[item] <= 0 then
								self.inv[item] = nil
							end
							return true
						end
					end
				end
				return false
			end,
			get_nodes_in_area_text = "(pos,nodes,rad/nil) return list of positions of nodes in area, rad max is 20",
			get_nodes_in_area=function(pos,nodes,rad)
				rad = math.abs(rad or 5)
				rad = rad <= 20 and rad or 20
				return minetest.find_nodes_in_area(vector.add(pos,rad),vector.subtract(pos,rad),nodes)
			end,
			rightclick_text = "(pos) rightclick",
			rightclick=function(pos)
				if vector.distance(self:pos(),pos) <= self.reach then
					local n = minetest.get_node(pos).name
					local def = default.def(n)
					if def and def.on_rightclick then
						local user = minetest.get_player_by_name(self.storage.code_execute_interval_user)
						if user then
							def.on_rightclick(pos, n, user, user:get_wielded_item(), {type="node",under=pos,above=pos})
						end
					end
				end
			end,
		} or nil,
		exatec=(self and {}) or {
			send_text = "(x,y,z) send signal",
			send=function(x,y,z)
				x = x and (x == 0 or math.abs(x) == 1) and x or error("(x,y,z) x: number 0, 1 or -1 expected")
				y = y and (y == 0 or math.abs(y) == 1) and y or error("(x,y,z) y: number 0, 1 or -1 expected")
				z = z and (z == 0 or math.abs(z) == 1) and z or error("(x,y,z) z: number 0, 1 or -1 expected")
				exatec.send(apos(g.pos,x,y,z),nil,true,g.pos)
			end,
			data_send_text = "(channel,data) data can be string number and table, eg: {connect=true}",
			data_send=function(to_channel,data)
				if type(to_channel) ~= "string" and type(to_channel) ~="number" then
					error("(to_channel,data_table) string or number expected")
				elseif type(data) ~= "table" then
					data = {data}
				end
				exatec.data_send(g.pos,to_channel,minetest.get_meta(g.pos):get_string("channel"),data)
			end,
		},
		timeout_text = "(n)",
		timeout=(self and {}) or function(n)
			if type(n) ~="number" and n <= 0 then
				error("Positive number value expected")
			end
			minetest.get_meta(g.pos):set_int("interval",0)
			minetest.get_node_timer(g.pos):start(n)
		end,
		interval_text = "(n)",
		interval=(self and {}) or function(n)
			if type(n) ~="number" and n <= 0 then
				error("Positive number value expected")
			end
			minetest.get_meta(g.pos):set_int("interval",1)
			minetest.get_node_timer(g.pos):start(n)
		end,
		stop_text = "(n) stop interval/timeout",
		stop=(self and {}) or function()
			minetest.get_node_timer(g.pos):stop()
			minetest.get_meta(g.pos):set_int("interval",0)
		end,
		print_text = "print(var) print to chat",
		print=function(b)
			b = b or ""
			if type(b) == "table" then
				b = dump(b)
			end
			minetest.chat_send_player(A.user,"(PCB "..id..") "..b)
			g.count = g.count + 500
		end,
		dump_text = "(var) print to chat",
		dump=function(p)
			p = p or ""
			minetest.chat_send_player(A.user,"(PCB "..id..") (dump) ========== ")
			minetest.chat_send_player(A.user,dump(p))
			g.count = g.count + 4000
		end,
		tonumber=tonumber,
		tostring=tostring,
		type=type,
		pairs=pairs,
		ipairs=ipairs,
		next=next,
		unpack=unpack,
		string = {
			byte=string.byte,
			char=string.char,
			len=string.len,
			lower=string.lower,
			upper=string.upper,
			rep=string.rep,
			sub=string.sub,
			find=string.find,
			format=string.format,
			split=function(a,b)
				return a.split(a,b)
			end,
			replace=function(a,b,c)
				return a:gsub(b,c)
			end
		},
		math = {
			abs=math.abs,
			cos=math.cos,
			acos=math.acos,
			atan=math.atan,
			atan2=math.atan2,
			asin=math.asin,
			ceil=math.ceil,
			floor=math.floor,
			gsub=math.gsub,
			deg=math.deg,
			huge=math.huge,
			log=math.log,
			max=math.max,
			min=math.min,
			rad=math.rad,
			pi=math.pi,
			random=math.random,
			sqrt=math.sqrt,
			sin=math.sin,
			tan=math.tan,
		},
		table = {
			insert=table.insert,
			remove=table.remove,
			concat=table.concat,
			maxn=table.maxn,
			sort=table.sort,
		},
		os = {
			difftime=os.difftime,
			clock=os.clock,
			time=os.time,
		},
		node=(self and {}) or {
			dig_text = "to use node functions, do exatec.data_send(''channel'',{connect=true}) to a ''Node constructor'' once\n(pos) dig node",
			dig=exatec.dig_node,
			place_text = "to use node functions, do exatec.data_send(''channel'',{connect=true}) to a ''Node constructor'' once\n(pos,name) place node",
			place=exatec.place_node,
		},
	}
end

exatec.power_node=function(pos)
	local p = exatec.temp.constructor.constructor
	if minetest.is_singleplayer() == false and vector.distance(pos,p) > 50 then
		error("Max distance is 50 in online")
	end
	local m = minetest.get_meta(p)
	local power = m:get_int("power")
	if power > 0 then
		m:set_int("power",power-1)
		return true
	else
		local a = {["default:iron_ingot"]=120,["default:bronze_ingot"]=100,["default:copper_ingot"]=70,["default:flint"]=50,["default:cloud"]=170,["default:steel_ingot"]=150,["default:diamond"]=200}
		for i,v in pairs(a) do
			if exatec.test_output(p,ItemStack(i),p,p) then
				m:set_int("power",v)
				exatec.output(p,ItemStack(i),p)
				return true
			end
		end
	end
	return false
end

exatec.place_node=function(pos,name)
	if exatec.temp.constructor.constructor
	and minetest.registered_nodes[name]
	and not minetest.is_protected(pos, minetest.get_meta(exatec.temp.constructor.pcb):get_string("owner"))
	and (minetest.registered_nodes[minetest.get_node(pos).name] or {}).buildable_to
	and exatec.power_node(pos)
	and exatec.test_output(exatec.temp.constructor.constructor,ItemStack(name),pos) then
		minetest.add_node(pos,{name=name})
		exatec.output(exatec.temp.constructor.constructor,ItemStack(name),pos)

	end
end

exatec.dig_node=function(pos)
	if exatec.temp.constructor.constructor
	and minetest.get_node_drops(pos)[1] ~= ""
	and not minetest.is_protected(pos, minetest.get_meta(exatec.temp.constructor.pcb):get_string("owner"))
	and exatec.power_node(pos)
	and exatec.test_input(exatec.temp.constructor.constructor,ItemStack(name),pos,pos) then
		local name = minetest.get_node(pos).name
		minetest.remove_node(pos)
		exatec.input(exatec.temp.constructor.constructor,ItemStack(name),pos,pos)
	end
end