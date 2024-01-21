minetest.register_on_dignode(function(pos, oldnode, digger)
	if digger and digger:get_wielded_item():get_name() == "default:quantum_pick" then
		local inv = digger:get_inventory()
		if inv:room_for_item("main",oldnode.name) then
			local name = digger:get_player_name()
			local n = 0
			local r = math.random(1,10)
			for i, p in pairs(minetest.find_nodes_in_area(vector.subtract(pos, 10),vector.add(pos,10),{oldnode.name})) do
				if not minetest.is_protected(p,name) then
					inv:add_item("main",minetest.get_node_drops(minetest.get_node(p).name)[1])
					minetest.remove_node(p)
					minetest.check_for_falling(p)
					n = n + 1
					if n > 9+r then
						break
					end
				end
			end
		end
	end
	default.update_nodes(pos)
end)

minetest.register_on_placenode(function(pos, newnode, placer)
	default.update_nodes(pos)
end)

default.update_nodes=function(pos)
	if minetest.find_node_near(pos,1,"group:on_update") then
		for i, p in pairs(minetest.find_nodes_in_area(vector.subtract(pos, 1),vector.add(pos,1),{"group:on_update"})) do
			local def=default.def(minetest.get_node(p).name)
			if def.on_update then
				def.on_update(p)
			end
		end
	end
end

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
		if not minetest.find_node_near(pos,minetest.get_item_group(node.name,"leafdecay"),{"group:tree"}) then
			if math.random(1,5) == 1 then
				minetest.add_item(pos,minetest.get_node_drops(node.name)[1])
			end
			minetest.remove_node(pos)
			minetest.check_for_falling(pos)
		end
	end
})

minetest.register_abm({
	nodenames={"default:dirt"},
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
	nodenames={"default:wet_soil"},
	interval=10,
	chance=20,
	action=function(pos,node,active_object_count,active_object_count_wider)
		if not minetest.find_node_near(pos,7,{"group:water"}) then
			minetest.set_node(pos,{name="default:dirt"})
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
			if math.random(1,4) == 1 and minetest.get_node({x=pos.x+x,y=pos.y,z=pos.z+z}).name == "air" and minetest.get_item_group(minetest.get_node({x=pos.x+x,y=pos.y-1,z=pos.z+z}).name,"dirt") > 0 and minetest.get_meta(pos):get_int("placed") == 0 then
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

minetest.register_lbm({
	name="default:itemframe",
	nodenames={"default:itemframe"},
	run_at_every_load = true,
	action=function(pos,node)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en = ob:get_luaentity()
			if en and en.name == "default:item" then
				return
			end
		end
		local meta=minetest.get_meta(pos)
		local item = meta:get_string("item")
		if item ~= "" then
			local en = minetest.add_entity(pos, "default:item"):get_luaentity()
			en.new_itemframe(en)
		end
	end
})

minetest.register_lbm({
	name="default:on_load",
	nodenames={"group:on_load"},
	run_at_every_load = true,
	action=function(pos,node)
		local n = minetest.registered_items[node.name]
		if n and n.on_load then
			n.on_load(pos,node)
		end
	end
})
minetest.register_lbm({
	name="default:radioactive",
	nodenames={"group:radioactive"},
	run_at_every_load = true,
	action=function(pos,node)
		local r = minetest.get_item_group(node.name,"radioactive")
		default.set_radioactivity(pos,r)
	end
})