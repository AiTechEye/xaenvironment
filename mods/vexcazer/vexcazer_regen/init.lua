vexcazer.registry_mode({
	name="Regen",
	info="USE to re generate area\nstack count to left, is area size",
	hide_mode_default=true,
	hide_mode_mod=true,
	on_use = function(itemstack, user, pointed_thing,input)
		if pointed_thing.type~="node" then return itemstack end
		local count=user:get_inventory():get_stack("main", input.index-1):get_count()
		if count>input.max_amount then
			count=vexcazer.round(input.max_amount/2)
		end
		local p1=vector.add(pointed_thing.under,-count)
		local p2=vector.add(pointed_thing.under,count)
		minetest.chat_send_player(input.user_name, "<Vexcazer> regeneration area")
		minetest.delete_area(p1, p2)
		minetest.chat_send_player(input.user_name, "<Vexcazer> done")
		return itemstack
	end
})