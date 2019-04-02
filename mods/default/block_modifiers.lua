minetest.register_abm({
	nodenames={"group:leafdecay"},
	neighbors={"air"},
	interval=5,
	chance=10,
	action=function(pos,node,active_object_count,active_object_count_wider)
		if not minetest.find_node_near(pos,5,{"group:tree"}) then
			minetest.add_item(pos,minetest.get_node_drops(node.name)[1])
			minetest.remove_node(pos)
			minetest.check_for_falling(pos)
		end
	end
})

minetest.register_abm({
	nodenames={"group:dirt"},
	neighbors={"group:spreading_dirt_type"},
	interval=10,
	chance=50,
	action=function(pos,node,active_object_count,active_object_count_wider)
		if (minetest.get_node_light({x=pos.x,y=pos.y+1,z=pos.z},0.5) or 0) > 13 then
			local p = minetest.find_node_near(pos,1,{"group:spreading_dirt_type"})
			if p then
				minetest.set_node(pos,{name=minetest.get_node(p).name})
			end
		end
	end
})

minetest.register_abm({
	nodenames={"group:spreading_dirt_type"},
	interval=10,
	chance=50,
	action=function(pos,node,active_object_count,active_object_count_wider)
		local u = {x=pos.x,y=pos.y+1,z=pos.z}
		if (minetest.get_node_light(u,0.5) or 0) < 13 or minetest.get_item_group(minetest.get_node(u).name,"liquid") > 0 then
			minetest.set_node(pos,{name="default:dirt"})
		end
	end
})