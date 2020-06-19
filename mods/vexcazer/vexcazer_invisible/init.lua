invisible={time=0,user={}}

local fun=function(itemstack, user, pointed_thing,input)
	local name=user:get_player_name()
	if not invisible.user[name] then
		user:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
		invisible.user[name]={}
		invisible.user[name].collisionbox=user:get_properties().collisionbox
		invisible.user[name].visual_size=user:get_properties().visual_size
		invisible.user[name].textures=user:get_properties().textures
		user:set_properties({
			visual = "mesh",
			textures={"vexcazer_invisible.png"},
			visual_size = {x=0, y=0},
			collisionbox = {-0.1,0,-0.1,0.1,0,0.1},
		})
		minetest.chat_send_player(name, "invisible on")			
	else
		user:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
		user:set_properties({
			visual = "mesh",
			textures=invisible.user[name].textures,
			visual_size = invisible.user[name].visual_size,
			collisionbox=invisible.user[name].collisionbox
		})
		invisible.user[name]=nil
		minetest.chat_send_player(name, "invisible off")
	end
end

vexcazer.registry_mode({
	name="Invisible",
	info="USE to active/inactive",
	hide_mode_default=true,
	info_admin="Type /vex_unhide to unhide someone",
	disallow_damage_on_use=true,
	wear_on_use=0,
	on_use=fun
})

minetest.register_chatcommand("vex_unhide", {
	privs = {vexcazer_ad=true},
	param="<player>",
	description = "Unhide player",
	func = function(name, param)
		local p=minetest.get_player_by_name(param)
		if not p then
			return false, "not a connected player"
		elseif not invisible.user[param] then
			return false, "not invisible"
		else
			fun(0,p)
		end
	end
})
