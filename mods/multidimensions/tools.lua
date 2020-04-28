minetest.register_privilege("dimensions", {
	description = "Can use dimensions teleport tool",
	give_to_singleplayer= false,
})

multidimensions.clear_dimensions=function()
	multidimensions.registered_dimensions = {}
end

minetest.register_alias("dim", "multidimensions:teleporttool")

multidimensions.setrespawn=function(object,pos)
	if true or not object:is_player() then return false end
	local name=object:get_player_name()
	if minetest.check_player_privs(name, {dimensions=true}) then return false end
	if multidimensions.remake_bed and minetest.get_modpath("beds")~=nil then
		beds.spawn[name]=pos
		beds.save_spawns()
	end
	if multidimensions.remake_home and minetest.get_modpath("sethome")~=nil then
		sethome.set(name, pos)
	end
end

multidimensions.form=function(player,object)
	local name=player:get_player_name()
	local info=""
	multidimensions.user[name]={}
	multidimensions.user[name].pos=object:get_pos()
	multidimensions.user[name].object=object
	if object:is_player() and object:get_player_name()==name then
		info="Teleport you"
	elseif object:is_player() and object:get_player_name()~=name then
		info="Teleport "..object:get_player_name()
	else
		info="Teleport object"
	end
	local list = "earth"
	local d = {"earth"}
	for i, but in pairs(multidimensions.registered_dimensions) do
		list = list .. ","..i
		table.insert(d,i)
	end
	multidimensions.user[name].dims = d
	local gui="size[3.5,5.5]"..
	"label[0,-0.2;" .. info .."]"..
	"textlist[0,0.5;3,5;list;" .. list .."]"
	minetest.after(0.1, function(gui)
		return minetest.show_formspec(player:get_player_name(), "multidimensions.form",gui)
	end, gui)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="multidimensions.form" then
		local name=player:get_player_name()
		if pressed.quit then
			multidimensions.user[name]=nil
			return
		end
		local pos=multidimensions.user[name].pos
		local object=multidimensions.user[name].object
		local dims = multidimensions.user[name].dims
		local dim = pressed.list and tonumber(pressed.list:sub(5,-1)) or 0
		local pos=object:get_pos()
		local d = multidimensions.registered_dimensions[dims[dim]]
		if not d then
			multidimensions.move(object,{x=pos.x,y=0,z=pos.z})
			if object:is_player() then
				multidimensions.apply_dimension(object)
			end
		else
			local pos2={x=pos.x,y=d.dirt_start+d.dirt_depth+1,z=pos.z}
			if d and minetest.is_protected(pos2, name)==false then
				multidimensions.move(object,pos2)
				if object:is_player() then
					multidimensions.apply_dimension(object)
				end
			end
		end
		multidimensions.user[name]=nil
		minetest.close_formspec(name,"multidimensions.form")
	end
end)

minetest.register_tool("multidimensions:teleporttool", {
	description = "Dimensions teleport tool",
	inventory_image = "default_stick.png^[colorize:#e9ff00ff",
on_use = function(itemstack, user, pointed_thing)
	local pos=user:get_pos()
	local name=user:get_player_name()

	if minetest.check_player_privs(name, {dimensions=true})==false then
		itemstack:replace(nil)
		minetest.chat_send_player(name,"You need the dimensions privilege to use this tool")
		return itemstack
	end

	local object={}
	if pointed_thing.type=="object" then
		object=pointed_thing.ref
	else
		object=user
	end
	multidimensions.form(user,object)
	return itemstack
end
})

minetest.register_on_respawnplayer(function(player)
	multidimensions.apply_dimension(player)
end)
minetest.register_on_joinplayer(function(player)
	multidimensions.apply_dimension(player)
end)
minetest.register_on_leaveplayer(function(player)
	multidimensions.player_pos[player:get_player_name()] = nil
end)

multidimensions.apply_dimension=function(player)
	local p = player:get_pos()
	local name = player:get_player_name()
	local pp = multidimensions.player_pos[name]
	if pp and p.y > pp.y1 and p.y < pp.y2 then
		return
	elseif pp then
		local od = multidimensions.registered_dimensions[pp.name]
		if od and od.on_leave then
			od.on_leave(player)
		end
	end
	for i, v in pairs(multidimensions.registered_dimensions) do
		if p.y > v.dim_y and p.y < v.dim_y+v.dim_height then
			multidimensions.player_pos[name] = {y1 = v.dim_y, y2 = v.dim_y+v.dim_height, name=i}
			player:set_physics_override({gravity=v.gravity})
			if v.sky then
				player:set_sky(v.sky[1],v.sky[2],v.sky[3])
			else
				player:set_sky(nil,"regular",nil)
			end
			if v.on_enter then
				v.on_enter(player)
			end
			return
		end
	end
	player:set_physics_override({gravity=1})
	player:set_sky(nil,"regular",nil)
	multidimensions.player_pos[name] = {
		y1 = multidimensions.earth.under,
		y2 = multidimensions.earth.above,
		name=""
	}
end

multidimensions.move=function(object,pos,set_re)
	local move=false
	object:set_pos(pos)
	multidimensions.setrespawn(object,pos)

	if set_re == nil then
		return
	end

	minetest.set_node({x=pos.x,y=pos.y-2,z=pos.z},{name="default:cobble"})
	minetest.after(1, function(pos,object,move,set_re)
		for i=1,100,1 do
			local nname=minetest.get_node(pos).name
			if nname~="air" and nname~="ignore" and nname ~= "multidimensions:teleporterre" then
				pos.y=pos.y+1
				move=true
			elseif move then
				minetest.set_node(pos,{name="multidimensions:teleporterre"})
				minetest.get_meta(pos):set_string("pos",minetest.pos_to_string({x=set_re.x,y=set_re.y+1,z=set_re.z}))
				pos.y = pos.y + 1
				minetest.get_meta(set_re):set_string("pos",minetest.pos_to_string(pos))
				object:set_pos({x=pos.x,y=pos.y+1,z=pos.z})
				multidimensions.setrespawn(object,{x=pos.x,y=pos.y+1,z=pos.z})
				return
			end
		end
		pos.y = pos.y - 2
		local reg = minetest.registered_nodes[minetest.get_node(pos).name]
		if reg == nil or reg.walkable == false or reg.name == "default:cobble" then
			for x = -2,2,1 do
			for z = -2,2,1 do
				minetest.set_node({x=pos.x+x,y=pos.y,z=pos.z+z},{name="default:cobble"})
			end
			end
		end
	end, pos,object,move,set_re)
	minetest.after(5, function(pos,object,move,set_re)
		for i=1,100,1 do
			local nname=minetest.get_node(pos).name
			if nname~="air" and nname~="ignore" and nname ~= "multidimensions:teleporterre" then
				pos.y=pos.y+1
				move=true
			elseif move then
				minetest.set_node(pos,{name="multidimensions:teleporterre"})
				minetest.get_meta(pos):set_string("pos",minetest.pos_to_string({x=set_re.x,y=set_re.y+1,z=set_re.z}))
				pos.y = pos.y + 1
				minetest.get_meta(set_re):set_string("pos",minetest.pos_to_string(pos))
				object:set_pos({x=pos.x,y=pos.y+1,z=pos.z})
				multidimensions.setrespawn(object,{x=pos.x,y=pos.y+1,z=pos.z})
				return
			end
		end
		pos.y = pos.y - 2
		local reg = minetest.registered_nodes[minetest.get_node(pos).name]
		if reg == nil or reg.walkable == false or reg.name == "default:cobble" then
			for x = -2,2,1 do
			for z = -2,2,1 do
				minetest.set_node({x=pos.x+x,y=pos.y,z=pos.z+z},{name="default:cobble"})
			end
			end
		end
	end, pos,object,move,set_re)
	return true
end

local capg = 0
minetest.register_globalstep(function(dtime)
	capg=capg+dtime
	if capg > 2 then
		capg=0
		for _, player in pairs(minetest.get_connected_players()) do
			multidimensions.apply_dimension(player)
		end
	end
end)