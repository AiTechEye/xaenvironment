minetest.register_lbm({
	name="default:2tree",
	nodenames={"default:apple_tree"},
	run_at_every_load = true,
	action=function(p,node)
		minetest.set_node(p,{name="plants:apple_tree"})
	end
})
minetest.register_lbm({
	name="default:2wood",
	nodenames={"default:apple_wood"},
	run_at_every_load = true,
	action=function(p,node)
		minetest.set_node(p,{name="plants:apple_wood"})
	end
})
minetest.register_lbm({
	name="default:2leaves",
	nodenames={"default:apple_leaves"},
	run_at_every_load = true,
	action=function(p,node)
		minetest.set_node(p,{name="plants:apple_leaves"})
	end
})
minetest.register_lbm({
	name="default:2sapling",
	nodenames={"default:apple_treesapling"},
	run_at_every_load = true,
	action=function(p,node)
		minetest.set_node(p,{name="plants:apple_treesapling"})
	end
})
minetest.register_lbm({
	name="default:2apple",
	nodenames={"default:apple"},
	run_at_every_load = true,
	action=function(p,node)
		minetest.set_node(p,{name="plants:apple"})
	end
})

minetest.register_lbm({
	name="default:2chair",
	nodenames={"default:apple_wood_chair"},
	run_at_every_load = true,
	action=function(p,node)
		minetest.set_node(p,{name="plants:apple_wood_chair"})
	end
})
minetest.register_lbm({
	name="default:2door",
	nodenames={"default:apple_wood_door"},
	run_at_every_load = true,
	action=function(p,node)
		minetest.set_node(p,{name="plants:apple_wood_door"})
	end
})



minetest.register_abm({
	nodenames={"group:igniter"},
	neighbors={"group:cools_lava"},
	interval=2,
	chance=1,
	action=function(pos,node,active_object_count,active_object_count_wider)
		if node.name == "default:lava_flowing" then
			minetest.set_node(pos,{name="default:cooledlava"})

--[[ maybe testing more later
			local p = minetest.find_nodes_in_area_under_air(vector.add(pos, 1),vector.subtract(pos, 1),{"group:cools_lava"})
			if #p > 0 then
				for i,p1 in pairs(p) do
					local up1 = {x=p1.x,y=p1.y+1,z=p1.z}
					local up2 = {x=p1.x,y=p1.y+2,z=p1.z}
					if p1.y <= pos.y then
						print(111)
						minetest.set_node(p1,{name="default:cooledlava"})
						minetest.set_node(up1,{name="default:cooledlava"})
						if minetest.get_node(up2).name == "air" then
							minetest.set_node(up2,{name="default:cooledlava"})
						end
					end
				end
			end
--]]
		elseif node.name == "default:lava_source" then
			minetest.set_node(pos,{name="default:obsidian"})
		elseif node.name == "default:lava_source" then
			minetest.set_node(pos,{name="default:obsidian"})
		else
			minetest.remove_node(pos)
		end
	end
})



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
	nodenames={"group:tree"},
	neighbors={"group:spreading_dirt_type"},
	interval=10,
	chance=50,
	action=function(pos,node,active_object_count,active_object_count_wider)
		for x=-1,1,1 do
		for z=-1,1,1 do
			if math.random(1,4) == 1 and minetest.get_node({x=pos.x+x,y=pos.y,z=pos.z+z}).name == "air" and minetest.get_meta(pos):get_int("placed") == 0 then
				minetest.set_node({x=pos.x+x,y=pos.y,z=pos.z+z},{name="default:stick_on_ground"})
			end
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
		if (minetest.get_node_light(u,0.5) or 0) < 10 or minetest.get_item_group(minetest.get_node(u).name,"liquid") > 0 then
			minetest.set_node(pos,{name="default:dirt"})
		end
	end
})