minetest.register_chatcommand("killme", {
	params = "",
	description = "Die",
	privs = {home=true},
	func = function(name, param)
		local p = minetest.get_player_by_name(name)
		if p then
			if p:get_meta():get_int("killme_disabled") == 1 then
				minetest.chat_send_player(name,"Suiciding is disallowed in this case")
			else
				p:set_hp(0)
			end
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
			local m = player:get_meta()
			local pos = player:get_pos()
			if m:get_int("respawn_disallowed") == 1 then
				minetest.chat_send_player(name,"Homes is disallowed in this case")
			else
				m:set_string("home",minetest.pos_to_string(pos))
				minetest.chat_send_player(name, "Home set!")
			end
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
			local m = player:get_meta()
			local s = m:get_string("home")
			if s ~="" then
				if m:get_int("respawn_disallowed") == 1 then
					minetest.chat_send_player(name,"Homes is disallowed in this case")
				else
					local pos = minetest.string_to_pos(s)
					player:set_pos(pos)
					minetest.chat_send_player(name, "Teleported to home")
				end
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
		local m = player:get_meta()
		if m:get_int("respawn_disallowed") == 1 then
			minetest.chat_send_player(name,"Homes is disallowed in this case")
		else
			local pos = player:get_pos()
			m:set_string("home",minetest.pos_to_string(pos))
			minetest.chat_send_player(name, "Home set!")
		end
	end
})

player_style.register_button({
	exit=true,
	type="image",
	image="commands_gohome.png",
	name="gohome",
	info="Go home",
	action=function(player)
		local m = player:get_meta()
		local name = player:get_player_name()
		if m:get_int("respawn_disallowed") == 1 then
			minetest.chat_send_player(name,"Homes is disallowed in this case")
		else
			local s = m:get_string("home")
			if s ~="" then
				local pos = minetest.string_to_pos(s)
				player:set_pos(pos)
				minetest.chat_send_player(name, "Teleported to home")
			end
		end
	end
})