vexcazer.bot_use=function(itemstack, user, pos,dir,input)
		local plus=1
		local minus=-1
		local param=0
		dir = minetest.dir_to_facedir(dir)
		if dir==1 then param=minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z}).param2 end
		if dir==3 then param=minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z}).param2 end
		if dir==0 then param=minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1}).param2 end
		if dir==2 then param=minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1}).param2 end
		local node={name=input.lazer,param2=param}
		local p=pos
		minetest.sound_play("vexcazer_lazer", {pos=p, gain=1.0, max_hear_distance=5})
		for i=1,input.max_amount,1 do
			vexcazer.lazer_damage(p,input)	
			if vexcazer.place({pos=p,node=node},input)==true then
				if dir==1 then p.x=p.x+plus end
				if dir==3 then p.x=p.x+minus end
				if dir==0 then p.z=p.z+plus end
				if dir==2 then p.z=p.z+minus end
			else
				return false
			end
		end
		return itemstack
	end

vexcazer.registry_mode({
	wear_on_use=1,
	wear_on_place=3,
	name="PlaceDig xz",
	info="Both using the stack and count on left\n\nUSE with blocks = place blocks\nUSE with blocks on a wall = place blocks backwards\nUSE without blocks = shoot lazer\nPLACE blocks or items = dig\nUSE with blocks, and a block\nis backside the pointed = use same rotation",
	info_admin="\nAdmin/mod info, works in other modes\nPLACE when the left stack is empty = lazerwave",
	info_mod="\nAdmin/mod info, works in other modes\nPLACE when the left stack is empty = lazerwave",

	on_place=function(itemstack, user, pointed_thing,input)
		if pointed_thing.type~="node" then return itemstack end
		local pos=pointed_thing.under
		local dir = minetest.dir_to_facedir(user:get_look_dir())
		local count=user:get_inventory():get_stack("main", input.index-1):get_count()
		if count==0 then return false end
		minetest.sound_play("vexcazer_dig", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 5,})
		for i=1,input.max_amount,1 do
			if count>0 then	
				if vexcazer.dig(pos,input)==false then
					return itemstack
				end
				count=count-1
			else
				return itemstack
			end
			if dir==1 then pos.x=pos.x+1 end
			if dir==3 then pos.x=pos.x-1 end
			if dir==0 then pos.z=pos.z+1 end
			if dir==2 then pos.z=pos.z-1 end
		end
		return itemstack
	end,

	on_use = function(itemstack, user, pointed_thing,input)
		if pointed_thing.type~="node" then return itemstack end
		local pos=pointed_thing.above
		local plus=1
		local minus=-1
		local dir = minetest.dir_to_facedir(user:get_look_dir())

		local n=minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]

		if n and n.buildable_to then
			pos=pointed_thing.under
		end
		if pointed_thing.above.y==pointed_thing.under.y then
			plus=-1 minus=1 
		end
		local param=0
		local lazer=false
		if dir==1 then param=minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z}).param2 end
		if dir==3 then param=minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z}).param2 end
		if dir==0 then param=minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1}).param2 end
		if dir==2 then param=minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1}).param2 end
		local name=user:get_inventory():get_stack("main", input.index-1):get_name()
		local count=user:get_inventory():get_stack("main", input.index-1):get_count()
		local node={name=name,param2=param}
		local lazercount=0
		if minetest.registered_nodes[name]==nil then
			node.name=input.lazer
			count=input.max_amount
			lazer=true
			minetest.sound_play("vexcazer_lazer", {pos =user:get_pos(), gain = 1.0, max_hear_distance = 5,})
		else
			minetest.sound_play("vexcazer_place", {pos =user:get_pos(), gain = 1.0, max_hear_distance = 5,})
		end
		for i=1,input.max_amount,1 do
			if lazer then
				vexcazer.lazer_damage(pos,input)
			end
			if count<=0 then return false end
			if vexcazer.place({pos=pos,node=node},input)==true then
				count=count-1
				if dir==1 then pos.x=pos.x+plus end
				if dir==3 then pos.x=pos.x+minus end
				if dir==0 then pos.z=pos.z+plus end
				if dir==2 then pos.z=pos.z+minus end
			else
				if lazer then minetest.chat_send_player(input.user:get_player_name(),"<vexcazer> " ..lazercount) end
				return false
			end
			lazercount=lazercount+1
		end
		if lazer then minetest.chat_send_player(input.user:get_player_name(),"<vexcazer> " ..lazercount) end
		return itemstack
	end
})

vexcazer.registry_mode({
	name="Undo",
	info="USE to Undo the last change",
	disallow_damage_on_use=true,
	hide_mode_default=true,
	hide_mode_mod=true,
	on_button=function(user,input)
		if vexcazer.undo[input.user_name] then
			for pos,n in pairs(vexcazer.undo[input.user_name]) do
				if not minetest.is_protected(pos,input.user_name) then
					minetest.set_node(minetest.string_to_pos(pos),{name=n})
				end
			end
		end
		vexcazer.undo[input.user_name] = nil
	end
})

local replace=function(itemstack, user, pointed_thing,input)
			if pointed_thing.type~="node" then return itemstack end
			local pos=pointed_thing.under
			local stack=user:get_inventory():get_stack("main", input.index-1):get_name()
			local stack_count=user:get_inventory():get_stack("main",input.index-1):get_count()
			local replace=user:get_inventory():get_stack("main", input.index+1):get_name()
			local replace_count=user:get_inventory():get_stack("main", input.index+1):get_count()
			local dir = minetest.dir_to_facedir(user:get_look_dir())
			local lazer=false
			local invert=false

			if minetest.registered_nodes[stack]==nil then
				stack="air"
				stack_count=input.max_amount
			end
			if minetest.registered_nodes[replace]==nil then
				replace=input.lazer
				replace_count=input.max_amount
				lazer=true
				minetest.sound_play("vexcazer_lazer", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 5,})
			end



			if input.on_place then
				invert=true
				if lazer==false then minetest.sound_play("vexcazer_dig", {pos = user:get_pos(), gain = 1.0, max_hear_distance =5,}) end
			else
				if lazer==false then minetest.sound_play("vexcazer_place", {pos = user:get_pos(), gain = 1.0, max_hear_distance =5,}) end
			end
			if ((replace_count<stack_count and replace_count<input.max_amount)) and input.admin==false then
				minetest.chat_send_player(input.user:get_player_name(),"You need more to repalce with (or empty slot = air)")
				return false
			end
			for i=1,input.max_amount,1 do
				if stack_count<=0 then return false end
				if lazer then
					vexcazer.lazer_damage(pos,input)
				end
				if vexcazer.replace({pos=pos, stack=stack,replace=replace,invert=invert},input)==true then
					stack_count=stack_count-1
					if dir==1 then pos.x=pos.x+1 end
					if dir==3 then pos.x=pos.x-1 end
					if dir==0 then pos.z=pos.z+1 end
					if dir==2 then pos.z=pos.z-1 end
				else
					return false
				end
			end
			return true
		end
vexcazer.registry_mode({
	wear_on_use=1,
	wear_on_place=2,
	name="Replace xz",
	info="USE using the stack and count on left and right\nPLACE using the stack and count on left\n\nUSE replace the left stack with the right\nPLACE dig evyerthing without the left stack",
		on_use=replace,
		on_place=replace
})




vexcazer.registry_mode({
	wear_on_use=1,
	wear_on_place=2,
	name="PlaceDig y",
	info="Both using the stack and count on left\n\nUSE with blocks = place upwards\nUSE with block on a celling = place downwards\nPLACE with blocks or items = dig downwards\nPLACE with blocks or items on a celling = dig upwards",

	on_place=function(itemstack, user, pointed_thing,input)
		if pointed_thing.type~="node" then return itemstack end
		local pos=pointed_thing.under
		minetest.sound_play("diplazer_dig", {pos = input.user:get_pos(), gain = 1.0, max_hear_distance = 5,})
		local stack_count=user:get_inventory():get_stack("main",input.index-1):get_count()
		local plus=-1
		if pointed_thing.above.y<pointed_thing.under.y then
			plus=1
		end
		minetest.sound_play("vexcazer_dig", {pos = user:get_pos(), gain = 1.0, max_hear_distance =5,})
		for i=1,input.max_amount,1 do
			if stack_count<=0 then return false end
			if vexcazer.dig(pos,input)==true then
				stack_count=stack_count-1
				pos.y=pos.y+plus
			else
				return false
			end
		end
		return true
	end,


	on_use = function(itemstack, user, pointed_thing,input)
		if pointed_thing.type~="node" then return itemstack end
		local pos=pointed_thing.above
		if vexcazer.def(pointed_thing.under,"walkable")==false and minetest.get_node(pointed_thing.under).name~="air" then
			pos=pointed_thing.under
		end
		local stack=user:get_inventory():get_stack("main", input.index-1):get_name()
		local stack_count=user:get_inventory():get_stack("main",input.index-1):get_count()
		local plus=1
		local lazer=false
		local lazercount=0
		if minetest.registered_nodes[stack]==nil then
			stack=input.lazer
			stack_count=input.max_amount
			lazer=true
			minetest.sound_play("vexcazer_lazer", {pos =user:get_pos(), gain = 1.0, max_hear_distance = 5,})
		else
			minetest.sound_play("vexcazer_place", {pos = user:get_pos(), gain = 1.0, max_hear_distance =5,})
		end
		if pointed_thing.under.y>pointed_thing.above.y then
			plus=-1
		end
		for i=1,input.max_amount,1 do
			if stack_count<=0 then return false end
			if lazer then
				vexcazer.lazer_damage(pos,input)
			end
			if vexcazer.place({pos=pos,node={name=stack}},input)==true then
				stack_count=stack_count-1
				pos.y=pos.y+plus
			else
				if lazer then minetest.chat_send_player(input.user:get_player_name(),"<vexcazer> " ..lazercount) end
				return false
			end
			lazercount=lazercount+1
		end
		if lazer then minetest.chat_send_player(input.user:get_player_name(),"<vexcazer> " ..lazercount) end
		return true
	end
})

vexcazer.registry_mode({
	wear_on_use=1,
	name="Autoswith",
	info="USE using all stacks and counts on\nthe hotbar until it hits a tool: from left to right",
	on_use = function(itemstack, user, pointed_thing,input)
		if pointed_thing.type~="node" then return itemstack end
		local pos=pointed_thing.above
		local max_amount=input.max_amount
		local dir = minetest.dir_to_facedir(user:get_look_dir())
		local plus=1
		local minus=-1
		minetest.sound_play("vexcazer_place", {pos = user:get_pos(), gain = 1.0, max_hear_distance =5,})
		if vexcazer.def(pointed_thing.under,"walkable")==false and minetest.get_node(pointed_thing.under).name~="air" then
			pos=pointed_thing.under
		end
		if pointed_thing.under.y==pointed_thing.above.y then
			plus=-1
			minus=1
		end
		for i=1,8,1 do
			if max_amount<=0 then return false end
			local stack=user:get_inventory():get_stack("main", i):get_name()
			local stack_count=user:get_inventory():get_stack("main",i):get_count()
			if stack=="" and i>1 then
				stack=input.lazer
				stack_count=1
			elseif (i==1 and stack=="") or (stack~="" and minetest.registered_nodes[stack]==nil) then

				return false
			end
			for i=1,stack_count,1 do
				if max_amount<=0 then return false end
				if vexcazer.place({pos=pos,node={name=stack}},input)==true then
					if dir==1 then pos.x=pos.x+plus end
					if dir==3 then pos.x=pos.x+minus end
					if dir==0 then pos.z=pos.z+plus end
					if dir==2 then pos.z=pos.z+minus end
				else
					max_amount=0
					stack_count=0
				end
				max_amount=max_amount-1
			end
		end
		return true
	end
})

vexcazer.placedigxyz=function(itemstack, user, pointed_thing,input,typ)
	local pos2=vexcazer.load(input,"PlaceDigxyz")
	if not pos2 then
		minetest.chat_send_player(input.user:get_player_name(),"<vexcazer> you have to place first (set a start position)") 
		return itemstack
	end
	local pos1
	if pointed_thing.type=="node" then
		pos1=pointed_thing.above
	else
		pos1=user:get_pos()
	end
	local d=math.floor(vector.distance(pos1,pos2)+0.5)

	minetest.chat_send_player(user:get_player_name(),d) 
	if d>input.max_amount*3 then
		minetest.chat_send_player(user:get_player_name(),"<vexcazer> too far, max " .. (input.max_amount*3)) 
		return itemstack
	end

	local inv=user:get_inventory()
	local stack=inv:get_stack("main", input.index-1):get_name()
	local count=inv:get_stack("main", input.index-1):get_count()
	local dis=inv:get_stack("main", input.index+1):get_count()

	if count==0 or (typ==1 and (not minetest.registered_nodes[stack] or (not input.admin and not inv:contains_item("main", stack)))) then
		return
	end

	if typ==1 then
		minetest.sound_play("vexcazer_place", {pos = user:get_pos(), gain = 1.0, max_hear_distance =5,})
	else
		minetest.sound_play("diplazer_dig", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 5,})
	end

	local v = {x = pos1.x - pos2.x, y = pos1.y - pos2.y-1, z = pos1.z - pos2.z}
	local amount = (v.x ^ 2 + v.y ^ 2 + v.z ^ 2) ^ 0.5
	local d=math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x) + (pos1.y-pos2.y)*(pos1.y-pos2.y)+(pos1.z-pos2.z)*(pos1.z-pos2.z))
	v.x = (v.x  / amount)*-1
	v.y = (v.y  / amount)*-1
	v.z = (v.z  / amount)*-1
	for i=0,d,1+dis do
		local posn={x=pos1.x+(v.x*i),y=pos1.y+(v.y*i),z=pos1.z+(v.z*i)}
		if typ==1 then
			vexcazer.place({pos=posn,node={name=stack}},input)
		elseif typ==2 then
			vexcazer.dig(posn,input)
		end
	end
end


vexcazer.registry_mode({
	wear_on_use=1,
	name="Place xyz",
	wear_on_use=10,
	wear_on_place=0,
	info="USE using all stacks and counts on\nthe hotbar until it hits a tool: from left to right",
	on_place = function(itemstack, user, pointed_thing,input)
		if pointed_thing.type=="node" then
			vexcazer.save(input,"PlaceDigxyz",pointed_thing.above,false)
			return itemstack
		end
	end,
	on_use = function(itemstack, user, pointed_thing,input)
		vexcazer.placedigxyz(itemstack, user, pointed_thing,input,1)
	end,
})

vexcazer.registry_mode({
	wear_on_use=1,
	name="Dig xyz",
	wear_on_use=10,
	wear_on_place=0,
	info="PLACE to set position\nUSE to dig line withing the distance\nSTACK to left: nodes to place\nSTACK to right, distance bewteen nodes to place",
	on_place = function(itemstack, user, pointed_thing,input)
		if pointed_thing.type=="node" then
			vexcazer.save(input,"PlaceDigxyz",pointed_thing.above,false)
			return itemstack
		end
	end,
	on_use = function(itemstack, user, pointed_thing,input)
		vexcazer.placedigxyz(itemstack, user, pointed_thing,input,2)
	end,
})

vexcazer.dp3x3=function(user,pos,input,typ)
	local dir=user:get_look_dir()
	local fd=minetest.dir_to_facedir(dir)
	local stack=user:get_inventory():get_stack("main", input.index-1):get_name()
	if typ==1 and stack=="" then
		typ=0
	end

	if typ==1 then
		minetest.sound_play("vexcazer_place", {pos =pos, gain = 1.0, max_hear_distance = 5})
	elseif typ==2 then
		minetest.sound_play("vexcazer_dig", {pos = pos, gain = 1.0, max_hear_distance = 5,})
	else
		minetest.sound_play("vexcazer_lazer", {pos = pos, gain = 1.0, max_hear_distance = 5,})
	end
	local x,z,p=0,0,nil

	if fd==0 or fd==2 then
		x=1
		y=1
	else
		z=1
		y=1
	end

	for a=-1,1,1 do
	for b=-1,1,1 do
		if math.abs(dir.y)<0.5 then
			p={x=pos.x+(x*a),y=pos.y+b,z=pos.z+(z*a)}
		else
			p={x=pos.x+a,y=pos.y,z=pos.z+b}
		end
		if typ==0 then
			if vexcazer.def(p,"buildable_to") and not minetest.is_protected(p,input.user_name) then
				minetest.add_node(p,{name=input.lazer})
				vexcazer.lazer_damage(p,input)
			end
		elseif (typ==1 and vexcazer.place({pos=p,node={name=stack}},input)==false) or (typ==2 and vexcazer.dig(p,input)==false) then
			return false
		end
	end
	end
end


vexcazer.registry_mode({
	wear_on_use=1,
	name="PlaceDig 3x3",
	wear_on_use=1,
	wear_on_place=1,
	disallow_damage_on_use=true,
	info="USE to place\nPlace to dig",
	on_use = function(itemstack, user, pointed_thing,input)
		if pointed_thing.type~="node" then
			return false
		end
		vexcazer.dp3x3(user,pointed_thing.above,input,1)
		return itemstack
	end,
	on_place = function(itemstack, user, pointed_thing,input)
		if  pointed_thing.type~="node" then
			return false
		end
		vexcazer.dp3x3(user,pointed_thing.under,input,2)
		return itemstack
	end
})