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

minetest.register_chatcommand("revokeme", {
	params = "<priv> or <all>",
	description = "Revoke privs from yourself",
	privs = {privs=true},
	func = function(name, param)
		minetest.registered_chatcommands["revoke"].func(name,name.." "..param)
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