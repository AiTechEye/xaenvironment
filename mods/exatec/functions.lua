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

exatec.test_input=function(pos,stack,opos)
	local a = exatec.def(pos)
	local def = exatec.getnodedefpos(pos)
	if a.test_input then
		return a.test_input(pos,stack,opos)
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
	elseif a.on_input then
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
	elseif a.on_input then
		a.on_input(f,new_stack,opos)
	end
	local def = exatec.getnodedefpos(pos)
	if def.on_metadata_inventory_take then
		def.on_metadata_inventory_take(pos, a.output_list, 1, stack, "")
	end
	return new_stack					
end