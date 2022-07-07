minetest.register_chatcommand("killme", {
	params = "",
	description = "Die",
	privs = {home=true},
	func = function(name, param)
		local p = minetest.get_player_by_name(name)
		if p then
			p:set_hp(0)
		end
	end
})

minetest.register_chatcommand("kill", {
	params = "<player>",
	description = "Kill",
	privs = {ban=true},
	func = function(name, param)
		local p = minetest.get_player_by_name(param)
		if p then
			p:set_hp(0)
		end
	end
})

minetest.register_privilege("home", {
	description = "Can set/go home",
	give_to_singleplayer = true,
})

minetest.register_chatcommand("sethome", {
	params = "",
	description = "Set home position",
	privs = {home=true},
	func = function(name, param)
		local player=minetest.get_player_by_name(name)
		if player then
			local meta = player:get_meta()
			local pos = player:get_pos()
			meta:set_string("home",minetest.pos_to_string(pos))
			minetest.chat_send_player(name, "Home set!")
		end
	end
})

minetest.register_chatcommand("home", {
	params = "",
	description = "Go home",
	privs = {home=true},
	func = function(name, param)
		local player=minetest.get_player_by_name(name)
		if player then
			local meta = player:get_meta()
			local s = meta:get_string("home")
			if s ~="" then
				local pos = minetest.string_to_pos(s)
				player:set_pos(pos)
				minetest.chat_send_player(name, "Teleported to home")
			end
		end
	end
})

player_style.register_button({
	exit=true,
	type="image",
	image="commands_sethome.png",
	name="sethome",
	info="Set home",
	action=function(player)
		local name = player:get_player_name()
		local meta = player:get_meta()
		local pos = player:get_pos()
		meta:set_string("home",minetest.pos_to_string(pos))
		minetest.chat_send_player(name, "Home set!")
	end
})

player_style.register_button({
	exit=true,
	type="image",
	image="commands_gohome.png",
	name="gohome",
	info="Go home",
	action=function(player)
		local meta = player:get_meta()
		local name = player:get_player_name()
		local s = meta:get_string("home")
		if s ~="" then
			local pos = minetest.string_to_pos(s)
			player:set_pos(pos)
			minetest.chat_send_player(name, "Teleported to home")
		end
	end
})

minetest.register_chatcommand("setnodes", {
	params = "<node> <pos1> <pos2>",
	description = "Set nodes in area (max size: 50) eg: default:stone,x y z, x y z",
	privs = {server=true},
	func = function(name, param)
		local s = param:gsub(", ",","):gsub("  "," "):split(",")

		if #s < 3 then
			return false, "To less params, do eg: default:stone, x y z, x y z"
		end
		local node = s[1]:gsub(" ","")
		local a = minetest.string_to_pos("("..s[2]:gsub(" ",",")..")")
		local b = minetest.string_to_pos("("..s[3]:gsub(" ",",")..")")

		if not a then
			return false, "position 1 is invalid"
		elseif not b then
			return false, "position 2 is invalid"
		elseif not minetest.registered_nodes[node] then
			return false, node.. " is not a registered node"
		elseif vector.distance(a,b) > 50 then
			return false, "area is too big ("..vector.distance(a,b).." > max 50)"
		end
		a = vector.round(a)
		b = vector.round(b)
		if a.x > b.x then
			b.x,a.x = a.x,b.x
		end
		if a.y > b.y then
			b.y,a.y = a.y,b.y
		end
		if a.z > b.z then
			b.z,a.z = a.z,b.z
		end
		local p = {}
		for x=a.x,b.x do
		for z=a.z,b.z do
		for y=a.y,b.y do
			table.insert(p,vector.new(x,y,z))
		end
		end
		end
		minetest.bulk_set_node(p,{name=node})
	end
})

minetest.register_chatcommand("setnode", {
	params = "<node> <param2/rotation> <pos2>",
	description = "Set a node (rotation can be empty) eg: default:stone, 2, x y z",
	privs = {server=true},
	func = function(name, param)
		local s = param:gsub(", ",","):gsub("  "," "):split(",",true)

		if #s < 3 then
			return false, "To less params, do eg: default:stone, 2, x y z"
		end
		local node = s[1]:gsub(" ","")
		local p2 = tonumber(s[2])
		local a = minetest.string_to_pos("("..s[3]:gsub(" ",",")..")")

		if not a then
			return false, "position is invalid"
		elseif not minetest.registered_nodes[node] then
			return false, node.. " is not a registered node"
		elseif not p2 then
			p2 = 0
		end
		minetest.set_node(a,{name=node,param2=p2})
	end
})

--/setnodes default:stone, 10 28520 10,0 28503 0
--/setnode default:dirt, 3 28532 -1