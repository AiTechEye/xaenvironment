nodeextractor.max_marking_nodes_count = 5000

minetest.register_craft({
	output="nodeextractor:movetool",
	recipe={
		{"materials:gear_metal","materials:tube_metal","materials:diode"},
		{"materials:aluminium_sheet","default:atom_core","materials:aluminium_sheet"},
		{"default:ruby","exatec:pcb","default:uraniumactive_ingot"}
	}
})

nodeextractor.marking_message=function(username)
	local u = nodeextractor.user[username]

	local rndid = math.random(1,9999)
	local u = nodeextractor.user[username]
	u.rndid = rndid

	minetest.after(60,function()
		local u = nodeextractor.user[username]
		if not u or u.rndid == rndid then
			nodeextractor.user[username] = nil
		end
	end)

	if u and u.pos1 and u.pos2 then
		local size = vector.new(math.abs(u.pos2.x-u.pos1.x)+1,math.abs(u.pos2.y-u.pos1.y)+1,math.abs(u.pos2.z-u.pos1.z)+1)
		local count = size.x*size.y*size.z
		if count <= nodeextractor.max_marking_nodes_count then
			minetest.chat_send_player(username, count .. " nodes is marked")
		else
			if count >= nodeextractor.max_marking_nodes_count*10 then
				nodeextractor.user[username] = nil
				minetest.chat_send_player(username,minetest.colorize("#f00","The marking is way too big") .. " (" .. count .. " nodes marked), Max " .. nodeextractor.max_marking_nodes_count*10 .. "\nMarking deleted")
			else
				minetest.chat_send_player(username,minetest.colorize("#ff0","The marking is too big") .. " (" .. count .. " nodes marked), Max " .. nodeextractor.max_marking_nodes_count)
			end
		end
	end
end

nodeextractor.movetoolstage=function(username,itemstack)
	local m = itemstack:get_meta()
	local u = nodeextractor.user[username]
	if u then
		m:set_string("inventory_image","nodeextractor_movetool" .. u.p .. ".png")
	end
	return itemstack
end

minetest.register_tool("nodeextractor:movetool", {
	description = "Move tool\nUse to mark\nPlace to switsh 1-2\nDrop for finish",
	inventory_image = "nodeextractor_movetool.png",
	range=30,
	on_use=function(itemstack, user, pointed_thing)
		local m = itemstack:get_meta()
		local username = user:get_player_name()

		if m:get_int("storage") == 1 and pointed_thing.type == "node" then
			nodeextractor.user[username] = nodeextractor.user[username] or {p=1}
			local u = nodeextractor.user[username]
			local size = minetest.string_to_pos(m:get_string("size"))
			local size2 = vector.floor(vector.divide(size,2))
			local pos = pointed_thing.above
			pos.y = pos.y + math.floor(size.y/2)
			local pos1 = vector.add(pos,size2)
			local pos2 = vector.subtract(pos,size2)

			if u.spawn_at and vector.equals(u.spawn_at,pointed_thing.above) then

				local p,nam = protect.test(pos1,pos2,username)
				if p == false then
					minetest.chat_send_player(username,"This area is interacting in a protected area by " .. nam)
					return
				end

				local interact_points = false
				local max = 50
				for x=-size2.x,size2.x do
				for y=-size2.y,size2.y do
				for z=-size2.z,size2.z do

					local ib2ipos = vector.add(pos,vector.new(x,y,z))
					if not default.def(minetest.get_node(ib2ipos).name).buildable_to then
						max = max -1
						if max <= 0 then
							break
						end
						interact_points = true
						local m = minetest.add_entity(ib2ipos, "nodeextractor:mark")
						local t = "nodeextractor_mark.png^[colorize:#f00"
						m:set_properties({textures = {t,t,t,t,t,t}})
						m:get_luaentity().on_step = function(self, dtime)
							self.timer = self.timer + dtime
							if self.timer > 3 then
								self.object:remove()
								return self
							end
						end
					end
				end
				end
				end
				if interact_points then
					minetest.chat_send_player(username,"Please make sure the area is free (empty) from solid nodes/blocks")
					return
				end
				local text = m:get_string("text")

				nodeextractor.set(pos1,"none",false,nil,text)

				m:set_string("inventory_image","nodeextractor_movetool.png")
				m:set_string("text","")
				m:set_string("size","")
				m:set_int("storage",0)
				user:set_wielded_item(itemstack)

				nodeextractor.user[username] = nil
				return
			end

			u.spawn_at = vector.new(pointed_thing.above)
			u.ob1 = math.random(1,9999)
			u.ob2 = math.random(1,9999)

			local x = math.abs(pos1.x-pos2.x) + 1
			local y = math.abs(pos1.y-pos2.y) + 1
			local z = math.abs(pos1.z-pos2.z) + 1
			local m = minetest.add_entity({x=pos1.x+(pos2.x-pos1.x)/2,y=pos1.y+(pos2.y-pos1.y)/2,z=pos1.z+(pos2.z-pos1.z)/2}, "nodeextractor:mark")
			m:set_properties({visual_size = {x=x, y=y, z=z}})
			m:get_luaentity().user = username 
			m:get_luaentity().num1 = u.ob1
			m:get_luaentity().num2 = u.ob2

			minetest.chat_send_player(username,"Point at same place again to place the building")

			local rndid = math.random(1,9999)
			u.rndid = rndid
			minetest.after(15,function()
				local u = nodeextractor.user[username]
				if not u or u.rndid == rndid then
					nodeextractor.user[username] = nil
				end
			end)
			return
		end
		nodeextractor.mark(itemstack, user, pointed_thing,1)
		nodeextractor.marking_message(username)
		itemstack = nodeextractor.movetoolstage(username,itemstack)
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		local m = itemstack:get_meta()
		local username = user:get_player_name()
		if m:get_int("storage") == 1 then
			minetest.chat_send_player(user:get_player_name(),"The item is full, please use the current building first")
			return
		end
		nodeextractor.mark(itemstack, user, pointed_thing,2)
		nodeextractor.marking_message(username)
		itemstack = nodeextractor.movetoolstage(username,itemstack)
		return itemstack
	end,
	on_secondary_use=function(itemstack, user, pointed_thing)
		local m = itemstack:get_meta()
		local username = user:get_player_name()

		if m:get_int("storage") == 1 then
			minetest.chat_send_player(user:get_player_name(),"The item is full, please use the current building first")
			return
		end
		nodeextractor.mark(itemstack, user, pointed_thing,2)

		nodeextractor.marking_message(username)
		itemstack = nodeextractor.movetoolstage(username,itemstack)

		return itemstack
	end,
	on_drop=function(itemstack, user, pos)
		local username = user:get_player_name()
		local u = nodeextractor.user[username]
		local m = itemstack:get_meta()
		if u and u.pos1 and u.pos2 then
			local p,nam = protect.test(u.pos1,u.pos2,user:get_player_name())
			if p == false then
				minetest.chat_send_player(username,"The marking is interacting in a protected area by " .. nam)
				return
			end

			local pos1 = vector.round(u.pos1)
			local pos2 = vector.round(u.pos2)
			protect.sort(pos1,pos2)
			local size = vector.new(math.abs(pos2.x-pos1.x)+1,math.abs(pos2.y-pos1.y)+1,math.abs(pos2.z-pos1.z)+1)

			local count = size.x*size.y*size.z
			if count >= nodeextractor.max_marking_nodes_count then
				minetest.chat_send_player(username,minetest.colorize("#ff0","The marking is too big") .. " (" .. count .. " nodes marked), Max " .. nodeextractor.max_marking_nodes_count)
				return
			end

			m:set_string("inventory_image","nodeextractor_movetool3.png")
			m:set_string("text",nodeextractor.create(u.pos1,u.pos2,""))
			m:set_string("size",minetest.pos_to_string(size))
			m:set_int("storage",1)

			local size2 = vector.floor(vector.divide(size,2))
			local poss = {}
			
			for x=pos1.x,pos2.x do
			for y=pos1.y,pos2.y do
			for z=pos1.z,pos2.z do
				table.insert(poss,vector.new(x,y,z))
			end
			end
			end

			minetest.bulk_set_node(poss,{name="air"})

			nodeextractor.user[username] = nil
			user:set_wielded_item(itemstack)
			minetest.chat_send_player(username, count .. minetest.colorize("#0f0"," nodes is captured"))
		else
			nodeextractor.user[username] = nil
			if m:get_int("storage") == 0 then
				m:set_string("inventory_image","nodeextractor_movetool.png")
				user:set_wielded_item(itemstack)
			end
		end
	end
})