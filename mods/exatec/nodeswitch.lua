exatec.nodeswitch_user={}

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local name=placer:get_player_name()
	if exatec.nodeswitch_user[name] then
		if minetest.get_item_group(newnode.name,"liquid")>0 then
			return
		elseif exatec.nodeswitch_user[name].p1 then
			minetest.add_entity(pos, "exatec:pos2"):get_luaentity().user=name
			exatec.nodeswitch_user[name].p2=pos
			exatec.nodeswitch_user[name].node2=newnode.name
			exatec.consnodeswitch(name)
		else
			minetest.add_entity(pos, "exatec:pos1"):get_luaentity().user=name
			minetest.add_entity(pos, "exatec:pos1")
			exatec.nodeswitch_user[name].p1=pos
			exatec.nodeswitch_user[name].node1=newnode.name
		end
	end
end)

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	local name=puncher:get_player_name()
	if exatec.nodeswitch_user[name] then
		if minetest.get_node(pointed_thing.above).name~="air" then
			return
		elseif exatec.nodeswitch_user[name].p1 then
			if exatec.nodeswitch_user[name].pun then
				minetest.chat_send_player(name, "A node is already punched")
			end
			minetest.add_entity(pointed_thing.above, "exatec:pos2"):get_luaentity().user=name
			exatec.nodeswitch_user[name].p2=pointed_thing.above
			exatec.nodeswitch_user[name].node2=minetest.get_node(pointed_thing.above).name
			exatec.consnodeswitch(name)
		else
			minetest.add_entity(pointed_thing.above, "exatec:pos1"):get_luaentity().user=name
			exatec.nodeswitch_user[name].p1=pointed_thing.above
			exatec.nodeswitch_user[name].pun=1
			exatec.nodeswitch_user[name].node1=minetest.get_node(pointed_thing.above).name
		end
	end
end)

exatec.consnodeswitch=function(name)
	local p = exatec.nodeswitch_user[name]


	if p.p1 and p.p2 then
		local meta=minetest.get_meta(p.pos)
--		local npos1=p.p1
--		local npos2=p.p2
		minetest.get_meta(p.p1):set_string("exatec_nodeswitch",name)
		minetest.get_meta(p.p2):set_string("exatec_nodeswitch",name)
		meta:set_string("node1",p.node1)
		meta:set_string("node2",p.node2)

		meta:set_string("pos1",minetest.pos_to_string(vector.subtract(p.p1,p.pos)))
		meta:set_string("pos2",minetest.pos_to_string(vector.subtract(p.p2,p.pos)))


--		meta:set_string("pos1",minetest.pos_to_string(p.p1))
--		meta:set_string("pos2",minetest.pos_to_string(p.p2))
		meta:set_int("able",1)
		exatec.nodeswitch_user[name]=nil
	end
end

exatec.consnodeswitch_switch=function(pos,state)
		local meta=minetest.get_meta(pos)
		if meta:get_int("able")==0 then return end
		local pos1 = vector.add(pos,minetest.string_to_pos(meta:get_string("pos1")))
		local pos2 = vector.add(pos,minetest.string_to_pos(meta:get_string("pos2")))
--		local pos1=minetest.string_to_pos(meta:get_string("pos1"))
--		local pos2=minetest.string_to_pos(meta:get_string("pos2"))
		local node1=meta:get_string("node1")
		local node2=meta:get_string("node2")
		local owner=meta:get_string("owner")
		local meta1=minetest.get_meta(pos1)
		local meta2=minetest.get_meta(pos2)
		if minetest.is_protected(pos1, owner)
		or minetest.is_protected(pos2, owner)
		or meta1:get_string("exatec_nodeswitch")~=owner
		or meta2:get_string("exatec_nodeswitch")~=owner then
			meta:set_int("able",0)
			return
		end
		meta1=meta1:to_table()
		meta2=meta2:to_table()
		local n1=minetest.get_node(pos1)
		local n2=minetest.get_node(pos2)
		if not ((state==1 and node1==n1.name and node2==n2.name) or (state==2 and node1==n2.name and node2==n1.name)) then
			meta:set_int("able",0)
			return
		end
		minetest.set_node(pos2,n1)
		minetest.get_meta(pos2):from_table(meta1)
		minetest.set_node(pos1,n2)
		minetest.get_meta(pos1):from_table(meta2)
end
minetest.register_node("exatec:nodeswitch", {
	description = "Node switch",
	tiles = {
		"default_steelblock.png",
		"default_steelblock.png",
		"default_steelblock.png^default_crafting_arrowright.png^exatec_wirecon.png",
	},
	groups = {exatec_wire_connected=1,snappy = 3,store=500},
	sounds = default.node_sound_stone_defaults(),

	after_place_node = function(pos, placer)
		local meta=minetest.get_meta(pos)
		local p=placer:get_player_name()
		local id=math.random(1,9999)
		meta:set_string("owner",p)
		minetest.chat_send_player(p, "Place the 1 or 2 nodes to replace with each other")
		minetest.chat_send_player(p, "Or punch somwehere to move the node to there")
		minetest.after(0.1, function(p,id,pos)
			exatec.nodeswitch_user[p]={pos=pos,name=p,id=id}
		end, p,id,pos)
		minetest.after(60, function(p,id)
			if exatec.nodeswitch_user[p] and exatec.nodeswitch_user[p].id==id then
				exatec.nodeswitch_user[p]=nil
			end
		end, p,id)
	end,
	exatec={
		on_wire=function(pos)
			local m = minetest.get_meta(pos)
			local t = m:get_int("t") == 1 and 2 or 1
			m:set_int("t",t)
			exatec.consnodeswitch_switch(pos,t)
		end,
	},
})

minetest.register_entity("exatec:pos1",{
	hp_max = 1,
	physical = false,
	collisionbox = {-0.52,-0.52,-0.52, 0.52,0.52,0.52},
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"exatec_pos1.png","exatec_pos1.png","exatec_pos1.png","exatec_pos1.png","exatec_pos1.png","exatec_pos1.png"}, 
	is_visible = true,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<1 then return self end
		self.timer=0
		self.timer2=self.timer2+dtime
		if self.timer2>2 or not (exatec.nodeswitch_user and exatec.nodeswitch_user[self.user]) then
			self.object:remove()
			return self
		end
	end,
	timer=0,
	timer2=0,
	user=""
})

minetest.register_entity("exatec:pos2",{
	hp_max = 1,
	physical = false,
	collisionbox = {-0.52,-0.52,-0.52, 0.52,0.52,0.52},
	visual_size = {x=1.05, y=1.05},
	visual = "cube",
	textures = {"exatec_pos2.png","exatec_pos2.png","exatec_pos2.png","exatec_pos2.png","exatec_pos2.png","exatec_pos2.png"}, 
	is_visible = true,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		if self.timer<1 then return self end
		self.timer=0
		self.timer2=self.timer2+dtime
		if self.timer2>2 or not (exatec.nodeswitch_user and exatec.nodeswitch_user[self.user]) then
			self.object:remove()
			return self
		end
	end,
	timer=0,
	timer2=0,
	user=""
})