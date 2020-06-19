local massive=function(itemstack, user, pointed_thing,input)		
			if pointed_thing.type~="node" then return itemstack end
			local pos=pointed_thing.above
			local dig=input.on_place
			local plus=1
			local minus=-1
			local stack=user:get_inventory():get_stack("main", input.index-1):get_name()
			local stack_left=user:get_inventory():get_stack("main", input.index+1):get_name()
			local stack_count=user:get_inventory():get_stack("main", input.index-1):get_count()
			local stack_count_left=user:get_inventory():get_stack("main", input.index+1):get_count()

			if vexcazer.def(pointed_thing.under,"walkable")==false and minetest.get_node(pointed_thing.under).name~="air" then
				pos=pointed_thing.under
			end

			local y=1
			local dir = minetest.dir_to_facedir(user:get_look_dir())
			local nolazer=false
			if dig==false and minetest.registered_nodes[stack]==nil or stack_count==0 then return false end
			if stack_count_left==0 then stack_count_left=stack_count end
			if dig then pos=pointed_thing.under end

			input.max_amount=vexcazer.round(input.max_amount/2)
			if stack_count_left>input.max_amount then
				stack_count_left=input.max_amount
			end

			if stack_count>input.max_amount then 
				stack_count=input.max_amount
				--minetest.sound_play("vexcazer_error", {pos = user:get_pos(), gain = 1.0, max_hear_distance = 10,})
				minetest.chat_send_player(input.user_name, "<vexcazer> Maximum count: " .. input.max_amount)
				--return false
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
			local pos1=pos
			local pos2={x=pos1.x,y=pos1.y,z=pos1.z}
			local pos3={x=pos2.x,y=pos2.y,z=pos2.z}
			if dig then y=-1 end
			for i1=1,stack_count_left,1 do				 --y
				for i2=1,stack_count,1 do				 --front
					for i3=1,stack_count,1 do			 --side
						if dig==false then
							if vexcazer.place({pos=pos3,node={name=stack}},input)==false then
								break
							end
						else
							if vexcazer.dig(pos3,input,nolazer)==false then
								break
							end
						end
						if dir==1 then pos3.z=pos3.z+plus end
						if dir==3 then pos3.z=pos3.z+minus end
						if dir==0 then pos3.x=pos3.x+minus end
						if dir==2 then pos3.x=pos3.x+plus end
					end
					if dir==1 then pos3.z=pos2.z		pos3.x=pos3.x+1		pos2.x=pos2.x+1 end
					if dir==3 then pos3.z=pos2.z		pos3.x=pos3.x-1		pos2.x=pos2.x-1 end
					if dir==0 then pos3.x=pos2.x		pos3.z=pos3.z+1		pos2.z=pos2.z+1 end
					if dir==2 then pos3.x=pos2.x		pos3.z=pos3.z-1		pos2.z=pos2.z-1 end
				end
				pos1.y=pos1.y+y
				pos2={x=pos1.x,y=pos1.y,z=pos1.z}
				pos3={x=pos2.x,y=pos2.y,z=pos2.z}
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
	name="MassPlaceDig",
	info="Both using the stack and count on left and right\nif right is empty: right count = left count\n\nUSE to place, with stack on left=xz right=y\nPLACE to dig, with stack on left=xz right=y\n",
	on_use=function(itemstack, user, pointed_thing,input)
		massive(itemstack, user, pointed_thing,input)
	end,
	on_place=function(itemstack, user, pointed_thing,input)
		massive(itemstack, user, pointed_thing,input)
	end
})
