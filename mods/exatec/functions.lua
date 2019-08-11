exatec.def=function(pos)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	return def and def.exatec or {}
end

exatec.test_input=function(pos,stack)
	local a = exatec.def(pos)
	return minetest.get_meta(pos):get_inventory():room_for_item(a.input_list,stack)
end

exatec.test_output=function(pos,stack)
	local a = exatec.def(pos)
	return minetest.get_meta(pos):get_inventory():contains_item(a.output_list,stack)
end

exatec.input=function(pos,stack)
	local a = exatec.def(pos)
	local re
	stack = a.input_max and stack:get_count() > a.input_max and ItemStack(stack:get_name() .." " .. a.input_max) or stack
	if a.input_list then
		local inv = minetest.get_meta(pos):get_inventory()
		if not inv:room_for_item(a.input_list,stack) then
			return false
		end
		inv:add_item(a.input_list,stack)
	elseif a.input then
		re = a.input(pos,stack)
	--else
	--	minetest.add_item(pos,stack)
	end
	if a.on_input then
		f.on_input(f,stack)
	end
	return re					
end

exatec.output=function(pos,stack)
	local a = exatec.def(pos)
	stack = a.output_max and stack:get_count() > a.output_max and ItemStack(stack:get_name() .." " .. a.output_max) or stack
	local new_stack
	if a.output_list then
		local inv = minetest.get_meta(pos):get_inventory()
		new_stack = inv:remove_item(a.output_list,stack)
	elseif a.input then
		new_stack = a.input(pos,stack)
	end
	if a.on_input then
		f.on_input(f,new_stack)
	end
	return new_stack					
end