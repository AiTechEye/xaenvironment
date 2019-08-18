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

exatec.input=function(pos,stack,opos)
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
		a.on_input(pos,stack,opos)
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
		a.on_input(f,new_stack,opos)
	end
	local def = exatec.getnodedefpos(pos)
	if def.on_metadata_inventory_take then
		def.on_metadata_inventory_take(pos, a.output_list, 1, stack, "")
	end
	return new_stack					
end

exatec.send=function(pos, ignore)
	local na=pos.x .."." .. pos.y .."." ..pos.z
	if not exatec.wire_signals[na] or ignore then
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
		minetest.after(0, function()
			exatec.wire_leading()
		end)
	end
end

exatec.get_node=function(pos,wire)
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