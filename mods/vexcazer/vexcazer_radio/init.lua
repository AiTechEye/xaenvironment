local radio=function(itemstack, user, pointed_thing,input,selective)		
			if pointed_thing.type~="node" then return itemstack end
			local pos=pointed_thing.under
			local dig=input.on_place
			local plus=1
			local minus=-1
			local stack=user:get_inventory():get_stack("main", input.index-1):get_name()
			local stack_left=user:get_inventory():get_stack("main", input.index+1):get_name()
			local stack_count=user:get_inventory():get_stack("main", input.index-1):get_count()
			local stack_count_left=user:get_inventory():get_stack("main", input.index+1):get_count()

			if selective then
				selective=minetest.get_node(pos).name
			end

			local y=1
			local dir = minetest.dir_to_facedir(user:get_look_dir())
			local nolazer=false
			if dig==false and minetest.registered_nodes[stack]==nil or stack_count==0 then return false end
			if stack_count_left==0 then stack_count_left=stack_count end
			if dig then pos=pointed_thing.under end
			input.max_amount=vexcazer.round(input.max_amount/2)
			if stack_count_left>input.max_amount*2 then stack_count_left=stack_count end

			if stack_count>input.max_amount*2 then
				stack_count=input.max_amount*2
			end

			local allblocks=(stack_count*stack_count)*stack_count_left
			if allblocks>125 then nolazer=true end	-- makes lazer after dig wont make lags

			if dig==false and input.admin==false then
				local stackcount=0
				for i=0,32,1 do
					local st=user:get_inventory():get_stack("main",i)
					if st:get_name()==stack then
						stackcount=stackcount+st:get_count()
					end
					if stackcount>=allblocks then
						break
					end
					if i==32 then
						minetest.sound_play("vexcazer_error", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 10,})
						minetest.chat_send_player(input.user_name, "You need more blocks to place (will place: ".. allblocks .. " missing: " .. allblocks-stackcount .. ")")
						return false
					end
				end
			end

			if dig and input.admin==false then
				local stackcount=allblocks+99
				for i=0,32,1 do
					local st=user:get_inventory():get_stack("main",i)
					if st:get_name()=="" then
						stackcount=stackcount-99
					end
					if stackcount<=0 then
						break
					end
					if i==32 then
						local tmpnfree=stackcount
						local nfree=0
						for i2=0,stackcount,1 do
							tmpnfree=tmpnfree-99
							nfree=nfree+1
							if tmpnfree<=0 then break end
						end
						minetest.sound_play("vexcazer_error", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 10,})
						minetest.chat_send_player(input.user_name, "You need a more empty inventory to dig (will dig: ".. allblocks .. " need empty slots: " .. nfree .. ")")
						return false
					end
				end
			end
			local p1=pointed_thing.under
			stack_count=math.floor(stack_count/2)
			for y=-stack_count,stack_count,1 do
			for x=-stack_count,stack_count,1 do
			for z=-stack_count,stack_count,1 do
				local p={x=p1.x+x,y=p1.y+y,z=p1.z+z}
				local cc=vector.length(vector.new({x=x,y=y,z=z}))/stack_count
				if cc<=1 and (not selective or (selective and minetest.get_node(p).name==selective)) then
					if dig==false and vexcazer.place({pos=p,node={name=stack}},input)==false then
						break
					elseif dig and vexcazer.dig(p,input,nolazer)==false then
						break
					end
				end
			end
			end
			end

			if dig then
				if allblocks<1000 then
					minetest.sound_play("vexcazer_massivedig", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 10,})
				else
					minetest.sound_play("vexcazer_massive3ddig", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 15,})
				end
			else
				if allblocks<1000 then
					minetest.sound_play("vexcazer_massiveplace", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 10,})
				else
					minetest.sound_play("vexcazer_massive3dplace", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 15,})
				end
			end
end



vexcazer.registry_mode({
	wear_on_use=3,
	wear_on_place=5,
	name="RadioPlaceDig",
	info="Both using the stack and count on left and right\nif right is empty: right count = left count\n\nUSE to place, with stack on left=xz right=y\nPLACE to dig, with stack on left=xz right=y\n",
	on_use=function(itemstack, user, pointed_thing,input)
		radio(itemstack, user, pointed_thing,input)
	end,
	on_place=function(itemstack, user, pointed_thing,input)
		radio(itemstack, user, pointed_thing,input)
	end
})

vexcazer.registry_mode({
	wear_on_use=2,
	wear_on_place=4,
	name="SelectiveRadio",
	info="Dig/Place pointed node only\nBoth using the stack and count on left and right\nif right is empty: right count = left count\n\nUSE to place, with stack on left=xz right=y\nPLACE to dig, with stack on left=xz right=y\n",
	on_use=function(itemstack, user, pointed_thing,input)
		radio(itemstack, user, pointed_thing,input,"a")
	end,
	on_place=function(itemstack, user, pointed_thing,input)
		radio(itemstack, user, pointed_thing,input,"a")
	end
})
