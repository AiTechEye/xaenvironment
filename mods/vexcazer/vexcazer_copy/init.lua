--1=copy, 2=check, 3=place

local vexcazer_copy={user={}}


vexcazer_copy.form=function(input,d)
	local text=""
	vexcazer_copy.user=input
	if d.export then
		local text1=vexcazer.load(input,"copy")
		local text2=vexcazer.load(vexcazer_copy.user,"count")
		if text1==nil or text2==nil then text="Error" end
		text=text2 .."*" .. text1
	end
	local gui="" ..
	"size[8,8]" ..
	"background[-0.2,-0.2;8.4,8.8;vexcazer_background.png]"..
	"textarea[0,1;8.6,8.6;text;;" .. text .."]" 
	if d.export==false  then
		gui=gui ..
		"button_exit[2,0;1.5,1;load;Save]" ..
		"button_exit[4,0;1.5,1;export;Export]"
	end
	minetest.after(0.1, function(gui)
		return minetest.show_formspec(vexcazer_copy.user.user_name, "vexcazer_copy_gui",gui)
	end, gui)
end


minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="vexcazer_copy_gui" then
		if pressed.export and vexcazer_copy.user.user and vexcazer_copy.user.user_name==player:get_player_name() then
			return vexcazer_copy.form(vexcazer_copy.user,{export=true,load=false})
		end
		if pressed.export then
			minetest.chat_send_player(vexcazer_copy.user.user_name, "<vexcazer> Error: handling timed out")
		end

		if pressed.load and pressed.text~="" and vexcazer_copy.user.user and vexcazer_copy.user.user_name==player:get_player_name() then
			local split0=pressed.text.split(pressed.text,"*")
			if split0[2]==nil then return end
			local stack_count=tonumber(split0[1])
			if stack_count==nil then return end
			local split1=split0[2].split(split0[2],"?")
			local split2={}
			local num=0
			local info={}
			for i,inf in pairs(split1) do
				num=num+1
				split2=inf.split(inf,"=")
				info[num]={}
				info[num].num=tonumber(split2[1])
				info[num].node=split2[2]
				if info[num].num==nil or minetest.registered_nodes[info[num].node]==nil or info[num].node=="ignore" then 
					minetest.chat_send_player(vexcazer_copy.user.user_name, "<vexcazer> Error: none-working code")
					return
				end
			end
			vexcazer.save(vexcazer_copy.user,"count",split0[1],true)
			vexcazer.save(vexcazer_copy.user,"copy",split0[2],true)
			minetest.chat_send_player(vexcazer_copy.user.user_name, "<vexcazer> The code is successfully saved in the tool")
			return true
		end
		if pressed.load then
			minetest.chat_send_player(vexcazer_copy.user.user_name, "<vexcazer> Error: handling timed out")
		end
	end
end)



vexcazer_copy.nvpa=function(a,p,def)
	local meta=minetest.get_meta({x=p.x,y=p.y,z=p.z})
	if meta and meta:get_string("infotext")~="" then return "air" end
	if a:find("door",1) or a:find("beds",1) or a=="ignore" then return "air" end
	if def==true and minetest.registered_nodes[a] and minetest.registered_nodes[a].drop=="" then return "air" end
	return a
end

vexcazer_copy.copying=function(to_do,pos,input,stack_count,nodes2place,stack_count2)

	if stack_count==nil then
	minetest.chat_send_player(input.user_name, "<vexcazer> Error")
	return false
	end

	if to_do==2 then
		pos.y=pos.y+1
	end

	local info={{node=minetest.get_node(pos)
.name,num=0}}
	local pos3={x=pos.x,y=pos.y,z=pos.z}
	local pos2={x=pos.x,y=pos.y,z=pos.z}
	local pos1={x=pos.x,y=pos.y,z=pos.z}
	local plus=1
	local minus=-1
	local num2=1
	local num3=1
	local dir=minetest.dir_to_facedir(input.user:get_look_dir())
	local tnode=""
	local nodes=0
	
	for i1=1,stack_count,1 do					 --level
		for i2=1,stack_count,1 do				 --front
			for i3=1,stack_count,1 do			 --side
					if to_do==1 then
						if i1<=stack_count2 then
							if minetest.is_protected(pos3, input.user_name) then
								return nil
							end
							tnode=minetest.get_node({x=pos3.x, y=pos3.y, z=pos3.z})
.name
							if tnode~="air" then
								tnode=vexcazer_copy.nvpa(tnode,pos3,input.default)
							end
						else
							tnode="air"
						end
						if tnode~=info[num2].node then
							num2=num2+1
							info[num2]={}
							info[num2].node=tnode
							info[num2].num=0
						end
						info[num2].num=info[num2].num+1
						if tnode=="air" then nodes=nodes+1 end
					elseif to_do==3 then
						tnode=nodes2place[num2].node
						num3=num3+1
						if num3>nodes2place[num2].num then num3=1 num2=num2+1 end
						if tnode~="air" then
							minetest.set_node(pos3, {name=tnode})
						else
							nodes=nodes+1
						end
					elseif to_do==2 then
						if minetest.is_protected(pos3, input.user_name) then
							minetest.chat_send_player(input.user_name, "<vexcazer> (".. pos3.x ..",".. pos3.y ..",".. pos3.z ..") is protected ")
							return false
						end
						if nodes2place[num2]==nil then
							minetest.chat_send_player(input.user_name, "<vexcazer> Error: none-working code")
							return false
						end
						tnode=nodes2place[num2].node
						num3=num3+1
						if num3>nodes2place[num2].num then num3=1 num2=num2+1 end
						local fn=minetest.registered_nodes[minetest.get_node(pos3).name]

						if not fn then
							vexcazer.unknown_remove(pos3)
							return false
						end

						if (fn.walkable==true and tnode~="air") or (tnode~="air" and fn.walkable==false and (minetest.get_node_group(fn.name, "unbreakable")==nil or minetest.get_node_group(fn.name, "unbreakable")>0)) then 
							minetest.chat_send_player(input.user_name, "<vexcazer> You have to clear the area before you can place here (".. stack_count .."x".. stack_count .. "x" .. stack_count .. ")  Found: " .. fn.name)
							return false
						end
					end
					if dir==1 then pos3.z=pos3.z+plus  end
					if dir==3 then pos3.z=pos3.z+minus end
					if dir==0 then pos3.x=pos3.x+minus end
					if dir==2 then pos3.x=pos3.x+plus end
			end
				if dir==1 then pos3.z=pos2.z		pos3.x=pos3.x+1		pos2.x=pos2.x+1 end
				if dir==3 then pos3.z=pos2.z		pos3.x=pos3.x-1		pos2.x=pos2.x-1 end
				if dir==0 then pos3.x=pos2.x		pos3.z=pos3.z+1		pos2.z=pos2.z+1 end
				if dir==2 then pos3.x=pos2.x		pos3.z=pos3.z-1		pos2.z=pos2.z-1 end
		end
	pos1.y=pos1.y+1
	pos2={x=pos1.x,y=pos1.y,z=pos1.z}
	pos3={x=pos2.x,y=pos2.y,z=pos2.z}
	end

	if to_do==3 then
		local c=((stack_count*stack_count)*stack_count)-nodes
		minetest.chat_send_player(input.user_name,"<vexcazer> " .. c.. " nodes successfully placed")
		if c<500 then
			minetest.sound_play("vexcazer_massiveplace", {pos = input.user:get_pos(), gain = 1.0, max_hear_distance = 10,})
		else
			minetest.sound_play("vexcazer_massive3dplace", {pos = input.user:get_pos(), gain = 1.0, max_hear_distance = 10,})
		end
		return true
	end
	if to_do==1 then
		local c=((stack_count*stack_count)*stack_count)-nodes
		minetest.chat_send_player(input.user_name,"<vexcazer> " .. c.. " nodes successfully saved in the tool")
		if c<500 then
			minetest.sound_play("vexcazer_massivedig", {pos = input.user:get_pos(), gain = 1.0, max_hear_distance = 10,})
		else
			minetest.sound_play("vexcazer_massive3ddig", {pos = input.user:get_pos(), gain = 1.0, max_hear_distance = 10,})
		end
		return info
	end
	if to_do==2  then
		if input.creative then return true end
		local need=""
		local missing={}
		for i,inf in pairs(nodes2place) do
			if inf.node~="air" and input.user:get_inventory():contains_item("main", inf.node .. " ".. inf.num)==false then
				need=" "
				if missing[inf.node]==nil then missing[inf.node]={node="",num=0} end
				missing[inf.node].node=inf.node
				missing[inf.node].num=missing[inf.node].num+inf.num
			end
		end
		if need=="" then
			for i,inf in pairs(nodes2place) do
				if inf.node~="air" then
					input.user:get_inventory():remove_item("main", inf.node .. " ".. inf.num)
				end
			end
			return true
		else

			for i,stuff in pairs(missing) do
				need=need .. stuff.node .. " " .. stuff.num .. " "
			end
			minetest.chat_send_player(input.user_name, "<vexcazer> Needed stuff to place:" .. need )
			return false
		end
	end
	return true
end





vexcazer_copy.copy=function(itemstack, user, pointed_thing,input)
	if pointed_thing.type~="node" then return end
	local pos=pointed_thing.under
	local node=minetest.get_node(pos)

	local stack_count=user:get_inventory():get_stack("main", input.index-1):get_count()
	local stack_count2=user:get_inventory():get_stack("main", input.index+1):get_count()
	local nodes2place={}
	local info={}
	local info2=""
	local tmp
	local num=0

	if stack_count>input.max_amount then stack_count=input.max_amount end
	if stack_count==0 then return end
	if stack_count2==0 then stack_count2=stack_count end
	if stack_count2>input.max_amount then stack_count2=input.max_amount end

	if input.on_place then
		info=vexcazer_copy.copying(1,pos,input,stack_count,nodes2place,stack_count2)
		if not info then
			minetest.sound_play("vexcazer_error", {pos = input.user:get_pos(), gain = 1.0, max_hear_distance = 10,})
			return
		end
		local info2=""
		for i,inf in pairs(info) do
			info2=info2 .. inf.num .."=" .. inf.node .. "?"
		end
		vexcazer.save(input,"copy",info2)
		vexcazer.save(input,"count",stack_count)
		return
	end
	if input.on_use then
		info2=vexcazer.load(input,"copy")
		stack_count=tonumber(vexcazer.load(input,"count"))
		if stack_count==nil then return end
		local split1=info2.split(info2,"?")
		local split2={}
		local num=1
		for i,inf in pairs(split1) do
			split2=inf.split(inf,"=")
			info[num]={}
			info[num].num=tonumber(split2[1])
			info[num].node=split2[2]
			num=num+1
		end
		if not vexcazer_copy.copying(2,pos,input,stack_count,info) then
			minetest.sound_play("vexcazer_error", {pos = input.user:get_pos(), gain = 1.0, max_hear_distance = 10,})
			return false
		end
		vexcazer_copy.copying(3,pos,input,stack_count,info)
	end

end

vexcazer.registry_mode({
	name="Copy",
	info="The mode using the stack and count on lef and right\nLeft = xz, Right = y\nPLACE = copy\nUSE = place\nPOINT IN AIR = open the export / load form",
	wear_on_use=1,
	wear_on_place=2,
	on_place=function(itemstack, user, pointed_thing,input)
		vexcazer_copy.copy(itemstack, user, pointed_thing,input)
	end,
	on_use=function(itemstack, user, pointed_thing,input)
		if pointed_thing.type=="nothing" then
			vexcazer_copy.form(input,{export=false,load=false})
		else
			vexcazer_copy.copy(itemstack, user, pointed_thing,input)
		end
	end,
})
