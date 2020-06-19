-- let you travel to 2 set positions, like /sethome but with the tool
vexcazer.registry_mode({
	name="Travel1",
	info="PLACE = set travelpoint 1\nUSE = teleport to travelpoint 1",
	wear_on_use=10,
	wear_on_place=0,
	disallow_damage_on_use=true,
	on_place=function(itemstack, user, pointed_thing,input)
		local pos=user:get_pos()
		if minetest.is_protected(pos, input.user_name) then
			minetest.chat_send_player(input.user_name, "<vexcazer> Travel: this position is protected")
			return
		end
		pos={x=vexcazer.round(pos.x),y=vexcazer.round(pos.y),z=vexcazer.round(pos.z)}
		pos=minetest.pos_to_string(pos)
		vexcazer.save(input,"travel1",pos,false)
		minetest.chat_send_player(input.user_name, "<vexcazer> Travel: position 1 ".. pos .." saved")
	end,
	on_use=function(itemstack, user, pointed_thing,input)
		local spos=vexcazer.load(input,"travel1")
		if not spos then return end
		local pos=minetest.string_to_pos(spos)
		if minetest.is_protected(pos, input.user_name) then
			minetest.chat_send_player(input.user_name, "<vexcazer> Travel: this position ".. spos .." is protected")
			return
		end
		user:move_to(pos)
	end,
})

vexcazer.registry_mode({
	name="Travel2",
	info="PLACE = set travelpoint 2\nUSE = teleport to travelpoint 2",
	wear_on_use=10,
	wear_on_place=0,
	disallow_damage_on_use=true,
	on_place=function(itemstack, user, pointed_thing,input)
		local pos=user:get_pos()
		if minetest.is_protected(pos, input.user_name) then
			minetest.chat_send_player(input.user_name, "<vexcazer> Travel: this position is protected")
			return
		end
		pos={x=vexcazer.round(pos.x),y=vexcazer.round(pos.y),z=vexcazer.round(pos.z)}
		pos=minetest.pos_to_string(pos)
		vexcazer.save(input,"travel2",pos,false)
		minetest.chat_send_player(input.user_name, "<vexcazer> Travel: position 2 ".. pos .." saved")
	end,
	on_use=function(itemstack, user, pointed_thing,input)
		local spos=vexcazer.load(input,"travel2")
		if not spos then return end
		local pos=minetest.string_to_pos(spos)
		if minetest.is_protected(pos, input.user_name) then
			minetest.chat_send_player(input.user_name, "<vexcazer> Travel: this position ".. spos .." is protected")
			return
		end
		user:move_to(pos)
	end,
})
