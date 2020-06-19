local nuke=function(itemstack, user, pointed_thing,input,a,g)
	local name=user:get_player_name()
	local pos
	local c=0
	local c2=0
	if pointed_thing.type=="node" then
		pos=pointed_thing.under
	elseif pointed_thing.type=="object" then
		pos=pointed_thing.ref:get_pos()
	else
		pos=user:get_pos()
	end

	if input.world then
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 500)) do
			if not (ob:is_player() and ob:get_player_name()==name) then

				if ob:is_player() then
					ob:set_hp(0)
				else
					ob:remove()
				end
					c=c+1
			end
		end
		minetest.chat_send_player(name, "<Vexcazer> removed objects: " .. c)
	else

		for i, ob in pairs(minetest.get_objects_inside_radius(pos, a)) do
			if not (ob:is_player() and ob:get_player_name()==name) then
				ob:set_hp(0)
				ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=9000}})
				c=c+1
			end
		end
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, a)) do
			if not (ob:is_player() and ob:get_player_name()==name) then
				local pos2=ob:get_pos()
				local d=math.max(1,vector.distance(pos,pos2))
				local dmg=(8/d)*a
				if ob:get_luaentity() then
					ob:set_velocity({x=(pos2.x-pos.x)*dmg, y=(pos2.y-pos.y)*dmg, z=(pos2.z-pos.z)*dmg})
				elseif ob:is_player() then
					local d=dmg/4
					local pos3={x=(pos2.x-pos.x)*d, y=(pos2.y-pos.y)*d, z=(pos2.z-pos.z)*d}
					ob:set_pos({x=pos.x+pos3.x,y=pos.y+pos3.y,z=pos.z+pos3.z,})
				end
				c2=c2+1
			end
		end
		if c<0 then c=0 end
		minetest.chat_send_player(name, "<Vexcazer> punched objects: " .. c .." pushed objects: " .. c2)
	end
	minetest.sound_play("vexcazer_nuke", {pos=pos, gain = g, max_hear_distance = a})

end



vexcazer.registry_mode({
	name="Nuke",
	info="PLACE = damage area: 50\nUSE =damage area: 25",
	disallow_damage_on_use=true,
	hide_mode_default=true,
	hide_mode_mod=true,
	on_place=function(itemstack, user, pointed_thing,input)
		nuke(itemstack, user, pointed_thing,input,50,1)
	end,
	on_use=function(itemstack, user, pointed_thing,input)
		nuke(itemstack, user, pointed_thing,input,25,0.5)
	end,
})
