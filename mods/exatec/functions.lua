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
				minetest.swap_node(pos,{name=n,param2=91})
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
						minetest.swap_node(n,{name=na,param2=91})
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
							minetest.swap_node(n,{name=na,param2=91})
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
	local m = minetest.get_meta(A.pos)
	local g={count = 0,pos=vector.new(A.pos),storage=minetest.deserialize(m:get_string("storage")) or {}}
	--local id = g.pos and minetest.pos_to_string(g.pos) or ""
	local F=function()
		local f,err = loadstring(text)
		if f then
			setfenv(f,exatec.create_env(A,g))
			if rawget(_G,"jit") then
				jit.off(f,true)
			end
			debug.sethook(
				function()
					g.count = g.count + 1
					if g.count >= 10000 then
						debug.sethook()
						--print(id.." Overheated (event limit) ("..g.count.."/10000)")
						error(" Overheated (event limit) ("..g.count.."/10000)",1)
					end
				end,"",2
			)
			f()
			debug.sethook()
			m:set_string("storage",minetest.serialize(g.storage) or {})
		end
		if err then
			local e1,e2 = err:find(":")
			if type(e2) == "number" then
				err = err:sub(e2-1,-1)
			end
		end
		return (err or ""),g.count
	end
	local s,err = pcall(F)
	debug.sethook()
	if err then
		local e1,e2 = err:find(":")
		if type(e2) == "number" then
			err = err:sub(e2-1,-1)
		end
	end
	return err,g.count
end

exatec.create_env=function(A,g)
	local id = g and g.pos and (g.pos.x..",".. g.pos.y..",".. g.pos.z) or ""
	return {
		storage=g and g.storage or nil,
		apos=apos,
		event=A,
		exatec = {
			send=function(x,y,z)
				x = x and (x == 0 or math.abs(x) == 1) and x or error("(x,y,z) x: number 0, 1 or -1 expected")
				y = y and (y == 0 or math.abs(y) == 1) and y or error("(x,y,z) y: number 0, 1 or -1 expected")
				z = z and (z == 0 or math.abs(z) == 1) and z or error("(x,y,z) z: number 0, 1 or -1 expected")
				exatec.send(apos(g.pos,x,y,z),nil,true,g.pos)
			end,
			data_send=function(to_channel,data)
				if type(to_channel) ~= "string" and type(to_channel) ~="number" then
					error("(to_channel,data_table) string or number expected")
				elseif type(data) ~= "table" then
					data = {data}
				end
				exatec.data_send(g.pos,to_channel,"",data)
			end,
		},
		timeout=function(n)
			if type(n) ~="number" and n <= 0 then
				error("Positive number value expected")
			end
			minetest.get_meta(g.pos):set_int("interval",0)
			minetest.get_node_timer(g.pos):start(n)
		end,
		interval=function(n)
			if type(n) ~="number" and n <= 0 then
				error("Positive number value expected")
			end
			minetest.get_meta(g.pos):set_int("interval",1)
			minetest.get_node_timer(g.pos):start(n)
		end,
		stop=function()
			minetest.get_node_timer(g.pos):stop()
			minetest.get_meta(g.pos):set_int("interval",0)
		end,
		print=function(b)
			b = b or ""
			minetest.chat_send_player(A.user,"(PCB"..id..") "..b)
			g.count = g.count + 500
		end,
		dump=function(p)
			p = p or ""
			minetest.chat_send_player(A.user,"(PCB"..id..") (dump) ========== ")
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
		}
	}
end