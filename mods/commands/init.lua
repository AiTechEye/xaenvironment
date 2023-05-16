commands = {}

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
	on_revoke=function(name)
		commands.update_waypoint(name)
	end
})

commands.update_waypoint=function(name,pos)
	local p = player_style.players[name]
	local user = minetest.get_player_by_name(name)
	p.home = p.home or {}
	if not user then
		return
	elseif not pos then
		user:hud_remove(p.home.waypoint)
	elseif not p.home.waypoint then
		p.home.waypoint = user:hud_add({
			hud_elem_type="image_waypoint",
			scale = {x=1, y=1},
			name="aim",
			text="commands_home.png",
			world_pos = pos,
		})
	else
		user:hud_change(p.home.waypoint, "world_pos", pos)
	end
end

minetest.register_on_joinplayer(function(player)
	local s = player:get_meta():get_string("home")
	if s ~="" then
		local pos = minetest.string_to_pos(s)
		commands.update_waypoint(player:get_player_name(),pos)
	end
end)

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
				commands.update_waypoint(name,pos)
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
			commands.update_waypoint(name,pos)
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

player_style.register_button({
	exit=true,
	type="image",
	image="commands_sun.png",
	name="day",
	info="Day",
	lower_priority = true,
	privs = {settime=true},
	action=function(player)
		minetest.set_timeofday(0.3)
	end
})

player_style.register_button({
	exit=true,
	type="image",
	image="commands_moon.png",
	name="night",
	info="Night",
	lower_priority = true,
	privs = {settime=true},
	action=function(player)
		minetest.set_timeofday(0.8)
	end
})