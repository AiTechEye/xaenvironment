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
			minetest.chat_send_player(name, "Home set at " .. math.floor(pos.x) .." " .. math.floor(pos.y) .." " .. math.floor(pos.z))
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