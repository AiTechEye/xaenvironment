places.rentpanel = {}

places.rentpanel.update_waypoint=function(user,pos)
	local name = user:get_player_name()
	local p = player_style.players[name]
	p.rent = p.rent or {}

	if not user then
		return
	elseif not pos then
		if p.rent.waypoint then
			user:hud_remove(p.rent.waypoint)
			p.rent.waypoint = nil
		end
	elseif not p.rent.waypoint then
		p.rent.waypoint = user:hud_add({
			hud_elem_type="image_waypoint",
			scale = {x=1, y=1},
			name="aim",
			text="places_rentalpanel.png",
			world_pos = pos
		})
	else
		user:hud_change(p.rent.waypoint, "world_pos", pos)
	end
end

minetest.register_on_joinplayer(function(player)
	local s = player:get_meta():get_string("places_rentpanel_pos")
	if s ~="" then
		local pos = minetest.string_to_pos(s)
		places.rentpanel.update_waypoint(player,pos)
	end
end)

minetest.register_craft({
	output="places:rental",
	recipe={
		{"default:locked_chest","materials:plastic_sheet","materials:gear_metal"},
		{"materials:diode","materials:wood_table","default:iron_ingot"},
		{"default:sign","group:wood","group:wood"},
	},
})

minetest.register_craft({
	output="places:selling",
	recipe={
		{"default:chest","materials:plastic_sheet","player_style:coin"},
		{"materials:diode","materials:wood_table","default:iron_ingot"},
		{"default:sign","group:wood","group:wood"},
	},
})

minetest.register_craft({
	output="places:rentpanel_copycard",
	recipe={
		{"materials:plastic_sheet","materials:plastic_sheet","materials:plastic_sheet"},
		{"materials:diode","materials:diode","default:copper_ingot"},
	},
})

	places.rentpanel.on_load = function(pos)
		local m = minetest.get_meta(pos)
		if m:get_int("npc_randomly") == 1 then
			if math.random(1,10) > 1 then
				m:set_string("renter","*Someone")
			else
				local p1 = vector.add(pos,minetest.string_to_pos(m:get_string("pos1")))
				local p2 = vector.add(pos,minetest.string_to_pos(m:get_string("pos2")))
				local nodes = minetest.find_nodes_in_area(p1,p2,"places:npc_furniture_spawner")
				for i,v in pairs(nodes) do
					minetest.remove_node(v)
				end
			end
			m:set_int("npc_randomly",2)

		elseif minetest.get_node(pos).name == "places:rental" and m:get_string("renter") == "" and m:get_string("pos1") ~= "" then
			local p2 = minetest.get_node(pos).param2
			minetest.swap_node(pos,{name="places:rental_free",param2=p2})
		end
	end
	places.rentpanel.after_place_node = function(pos, placer, itemstack, pointed_thing)
		minetest.get_meta(pos):set_string("owner",placer:get_player_name())
	end
	places.rentpanel.on_construct = function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("amount",1)
		m:set_int("price",1)
		m:set_int("list",3)
		m:set_int("npc_randomly",0)
	end
	places.rentpanel.panel = function(pos,user,preview)
		local m = minetest.get_meta(pos)
		local name = user and user:is_player() and user:get_player_name() or ""
		local form = "size[3,3.6]listcolors[#77777777;#777777aa;#000000ff]"
		local t = m:get_int("list")
		local tt = {"Second","Minute","Hour","Day"}
		if not preview and (name ~= "" and (m:get_string("owner") == name or minetest.check_player_privs(name, {protection_bypass=true}))) then
			form = form
			.."label[0,-0.3;"..(m:get_string("pos1") == "" and "No area is setup" or "Area is setup").."]"
			.. (m:get_string("renter") == "" and "button[0,0;2.2,1;setup;Setup area]" or "button[0,0;2.2,1;cancelrenting;Cancel]tooltip[cancelrenting;Cancel renting]")
			.."button[2,0;1,1;set;Set]tooltip[set;Set values]"
			.."button[-0.2,3.4;3.5,0.6;cp;Customer Preview]"
			.."textlist[0,0.8;2,2.5;list;Second,Minute,Hour,Day;"..m:get_int("list").."]"
			.."field[2.5,1;1,1;price;;"..m:get_int("price").."]tooltip[price;Price/"..tt[t].."]"
			.."field[2.5,2;1,1;amount;;"..m:get_int("amount").."]tooltip[amount;"..tt[t].."s]"
		else
			local renter = m:get_string("renter")
			if m:get_string("pos1") == "" then
				form = form .."label[0,-0.3;The panel is not setup]"
			elseif renter ~= "" and renter ~= name then
				form = form .."label[0,-0.3;Occupied by\n"..renter.."]"
			else
				form = form
				.. (m:get_string("owner") ~= "" and "label[-0.2,0.3;Owner: "..m:get_string("owner").."]" or "")
				..(user and "label[2,-0.20;"..minetest.colorize("#FFFF00",Getcoin(user)).."]" or "")
				.."button_exit[0.5,1;2.2,1;"..(renter == name and "cancel;Cancel" or "rent;Rent").."]"
				.."label[-0.2,2;Price: "..m:get_int("price").."\n"..m:get_int("amount").."'th "..tt[t].."]"
			end

		end
		m:set_string("formspec",form)
	end
	places.rentpanel.on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		places.rentpanel.panel(pos, player)
	end
	places.rentpanel.counts = function(pos)
		local m = minetest.get_meta(pos)
		local l = m:get_int("list")
		local a = m:get_int("amount")
		local p = m:get_int("price")
		if a < 1 then
			a = 1
		elseif (l == 1 or l == 2) and a > 300 then
			a = 300
		elseif l == 3 and a > 24 then
			a = 24
		elseif l == 4 and a > 30 then
			a = 30
		end
		if p < 0 then
			p = 0
		elseif p > 100000 then
			p = 100000
		end
		m:set_int("amount",a)
		m:set_int("price",p)
	end
	places.rentpanel.on_receive_fields = function(pos, formname, pressed, sender)
		local m = minetest.get_meta(pos)
		local name = sender and sender:get_player_name() or m:get_string("renter")

		if pressed.rent then
			local c = Getcoin(sender)
			local p = m:get_int("price")
			local pm = sender:get_meta()
			if c < p then
				minetest.chat_send_player(name,"You can't afford "..p.." (cons: ".. c ..")")
				return
			elseif pm:get_string("places_rentpanel_pos") ~= "" then
				minetest.chat_send_player(name,"You are already renting")
				return
			end
			local p1 = vector.add(pos,minetest.string_to_pos(m:get_string("pos1")))
			local p2 = vector.add(pos,minetest.string_to_pos(m:get_string("pos2")))
			local id = protect.add_game_rule_area(p1,p2,"Renting",name)
			local l = m:get_int("list")
			m:set_int("id",id)
			m:set_string("renter",name)
			m:set_int("date",default.date("get"))
			m:set_int("cancel",0)
			minetest.get_node_timer(pos):start((l== 1 or l == 2) and 1 or 10)
			Coin(sender,-p)
			local p2 = minetest.get_node(pos).param2
			minetest.swap_node(pos,{name="places:rental",param2=p2})
			pm:set_string("places_rentpanel_pos",minetest.pos_to_string(pos))
			pm:set_string("places_rentpanel_node",minetest.get_node(pos).name)
			places.rentpanel.panel(pos, sender)
			places.rentpanel.update_waypoint(sender,pos)
		elseif pressed.cancelrenting then
			m:set_int("cancel",1)
			minetest.chat_send_player(m:get_string("owner"),"The renting is canceling")
			minetest.chat_send_player(m:get_string("renter"),"The renting is canceling")
			places.rentpanel.panel(pos, sender)
		elseif pressed.cancel then
			local pm = sender:get_meta()
			pm:set_string("places_rentpanel_pos","")
			pm:set_string("places_rentpanel_node","")
			places.rentpanel.update_waypoint(sender)
			local renter = m:get_string("renter")
			minetest.chat_send_player(name,name == renter and "You as renter is terminated" or "The renter is terminated")
			local c = Getcoin(renter)
			local p = m:get_int("price")
			if c < p then
				minetest.chat_send_player(name,"Could not afford "..p.." cons"..(name == renter and " (have: ".. c ..")" or ""))
			end
			protect.remove_game_rule_area(m:get_int("id"))
			m:set_string("renter","")
			m:set_int("cancel",0)
			minetest.get_node_timer(pos):stop()
			local p2 = minetest.get_node(pos).param2
			minetest.swap_node(pos,{name="places:rental_free",param2=p2})
		elseif pressed.cp then
			places.rentpanel.panel(pos, sender,true)
		elseif pressed.set then
			m:set_int("amount",pressed.amount or m:get_int("amount"))
			m:set_int("price",pressed.price or m:get_int("price"))
			places.rentpanel.counts(pos)
			places.rentpanel.panel(pos, sender)
		elseif pressed.setup then
			local p = protect.user[name]
			if not (p and p.pos1 and p.pos2) then
				minetest.chat_send_player(name,'Mark with "/protect 1 /protect 2" to select the area to rent out\nYou do not need to protect, just mark it\nThen Press the setup button again')
			else
				local pr,o = protect.test(p.pos1,p.pos2,name)
				if pr == false then
					minetest.chat_send_player(name,"The area is protected by "..o)
				else
					m:set_string("pos1",minetest.pos_to_string(vector.subtract(p.pos1,pos)))
					m:set_string("pos2",minetest.pos_to_string(vector.subtract(p.pos2,pos)))
					protect.clear(name)
					minetest.chat_send_player(name,"The area is confirmed")
					places.rentpanel.on_receive_fields(pos, formname, {cancel=true}, sender)
					places.rentpanel.panel(pos, sender)
				end
			end
		elseif pressed.list then
			m:set_int("list",minetest.explode_textlist_event(pressed.list).index)
			m:set_int("amount",pressed.amount or m:get_int("amount"))
			m:set_int("price",pressed.price or m:get_int("price"))
			places.rentpanel.counts(pos)
			places.rentpanel.panel(pos, sender)
		end
	end
	places.rentpanel.on_timer = function(pos, elapsed)
		local m = minetest.get_meta(pos)
		local date = m:get_int("date")
		local l = m:get_int("list")
		local t = {"s","m","h","d"}
		local time = default.date(t[l],date)
		local a = m:get_int("amount")
		local renter = m:get_string("renter")
		local owner = m:get_string("owner")
		if time >= a and renter ~= "" then
			if m:get_int("cancel") == 1 then
				places.rentpanel.on_receive_fields(pos, "", {cancel=true})
				return
			end

			local cost = math.floor(time/a)*m:get_int("price")
			local c = Getcoin(renter)
			if c <= cost then
				Coin(renter,-c)
				Coin(owner,c)
				minetest.chat_send_player(renter,c.." coin(s) has just been taken from you due your rent ("..minetest.colorize("#FFFF00",Getcoin(renter)).." left)")
				places.rentpanel.on_receive_fields(pos, "", {cancel=true})
				return
			else
				Coin(renter,-cost)
				Coin(owner,cost)
				minetest.chat_send_player(renter,cost.." coin(s) has just been taken from you due your rent ("..minetest.colorize("#FFFF00",Getcoin(renter)).." left)")
				if c-cost <= cost then
					places.rentpanel.on_receive_fields(pos, "", {cancel=true})
					return
				end
			end
			m:set_int("date",default.date("get"))
		end
		return true
	end


minetest.register_node("places:rental", {
	description = "Rental panel",
	tiles={
		"places_wood.png",
		"places_wood.png",
		"places_wood.png",
		"places_wood.png",
		"places_wood.png",
		"places_rentalpanel.png",
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,store=200,on_load=1},
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4, -0.4, 0.5, 0.4, 0.4, 0.45},
		}
	},
	on_load = places.rentpanel.on_load,
	panel = places.rentpanel.panel,
	counts = places.rentpanel.counts,
	after_place_node = places.rentpanel.after_place_node,
	on_construct = places.rentpanel.on_construct,
	on_rightclick = places.rentpanel.on_rightclick,
	on_receive_fields = places.rentpanel.on_receive_fields,
	on_timer = places.rentpanel.on_timer,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_string("renter") == ""
	end
})

minetest.register_node("places:rental_free", {
	description = "Rental panel (free)",
	tiles={
		"places_wood.png",
		"places_wood.png",
		"places_wood.png",
		"places_wood.png",
		"places_wood.png",
		"places_rentalpanel.png^[colorize:#0F05",
	},
	drop="places:rental",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,store=200,on_load=1,not_in_creative_inventory=1},
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4, -0.4, 0.5, 0.4, 0.4, 0.45},
		}
	},
	on_load = places.rentpanel.on_load,
	panel = places.rentpanel.panel,
	counts = places.rentpanel.counts,
	after_place_node = places.rentpanel.after_place_node,
	on_construct = places.rentpanel.on_construct,
	on_rightclick = places.rentpanel.on_rightclick,
	on_receive_fields = places.rentpanel.on_receive_fields,
	on_timer = places.rentpanel.on_timer,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_string("renter") == ""
	end
})

minetest.register_node("places:selling", {
	description = "Selling panel",
	tiles={
		"places_wood.png",
		"places_wood.png",
		"places_wood.png",
		"places_wood.png",
		"places_wood.png",
		"places_rentalpanel.png^[invert:rgb",
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,store=100},
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4, -0.4, 0.5, 0.4, 0.4, 0.45},
		}
	},
	after_place_node=function(pos, placer, itemstack, pointed_thing)
		minetest.get_meta(pos):set_string("owner",placer:get_player_name())
	end,
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("price",1000)
		m:set_int("removearea",-1)
	end,
	panel=function(pos,user,preview,confirm)
		local m = minetest.get_meta(pos)
		local a = m:get_string("pos1") ~= ""
		local p1 = a and vector.add(pos,minetest.string_to_pos(m:get_string("pos1"))) or ""
		local p2 = a and vector.add(pos,minetest.string_to_pos(m:get_string("pos2"))) or ""
		local name = user and user:is_player() and user:get_player_name() or ""
		local form = "size[3,3.6]listcolors[#77777777;#777777aa;#000000ff]"
		if confirm then
			form = form
			.."label[0,-0.3;Buy this area?\n\nPrice: "..m:get_int("price").."]"
			.."button[-0.2,3;3.5,1;confirm;Confirm]"
		elseif not preview and (name ~= "" and m:get_string("owner") == name) then
			form = form
			.."label[0,-0.3;"..(a and "Area is setup" or "No area is setup").."]"
			.. "button[0,0;2.2,1;setup;Setup area]"
			.."field[0,1;1.5,1;price;;"..m:get_int("price").."]tooltip[price;Price]"
			.."field[1.5,1;1,1;removearea;;"..(m:get_int("removearea") ~= -1 and m:get_int("removearea") or "").."]tooltip[removearea;Remove area (ID) during purchase]"
			.."button[2,0.7;1,1;set;Set]"
			.."button[-0.2,3.4;3.5,0.6;cp;Customer Preview]"
			..(a and "label[0,2;Size: "..((p2.x-p1.x)+1).."x"..((p2.y-p1.y)+1).."x"..((p2.z-p1.z)+1).."]button_exit[0,2.5;3,0.6;pa;Preview area]" or "")
		else
			local renter = m:get_string("renter")
			if m:get_string("pos1") == "" then
				form = form .."label[0,-0.3;The panel is not setup]"
			else
				form = form
				.. (m:get_string("owner") ~= "" and "label[0,0.5;By: "..m:get_string("owner").."]" or "")
				..(user and "label[0,0;"..minetest.colorize("#FFFF00",Getcoin(user)).."]" or "")
				.."button[0.5,3;2.2,1;buy;Buy]"
				.."label[0,1.25;Price: "..m:get_int("price").."]"
				..(a and "label[0,2;Size: "..((p2.x-p1.x)+1).."x"..((p2.y-p1.y)+1).."x"..((p2.z-p1.z)+1).."]button_exit[0,2.5;3,0.6;pa;Preview area]" or "")
			end
		end
		m:set_string("formspec",form)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.registered_nodes["places:selling"].panel(pos, player)
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		local m = minetest.get_meta(pos)
		local name = sender and sender:get_player_name()
		if pressed.buy then
			minetest.registered_nodes["places:selling"].panel(pos, sender,true,true)
		elseif pressed.confirm then
			local c = Getcoin(sender)
			local p = m:get_int("price")
			if c < p then
				minetest.chat_send_player(name,"You can't afford "..p.." (cons: ".. c ..")")
				minetest.registered_nodes["places:selling"].panel(pos, sender)
				return
			end
			local p1 = vector.add(pos,minetest.string_to_pos(m:get_string("pos1")))
			local p2 = vector.add(pos,minetest.string_to_pos(m:get_string("pos2")))
			local id = protect.add_game_rule_area(p1,p2,"City",name,false)
			Coin(sender,-p)
			Coin(m:get_string("owner"),p+minetest.get_item_group("places:selling","store"))
			local id = m:get_int("removearea")
			if id ~= -1 then
				protect.remove_game_rule_area(id)
			end
			minetest.remove_node(pos)
		elseif pressed.cp then
			minetest.registered_nodes["places:selling"].panel(pos, sender,true)
		elseif pressed.pa then
			local p = protect.user[name]
			p.user = name
			p.markid = math.random(0,9999)
			p.pos1 = vector.add(pos,minetest.string_to_pos(m:get_string("pos1")))
			p.pos2 = vector.add(pos,minetest.string_to_pos(m:get_string("pos2")))
			local self = minetest.add_entity(pos, "protect:mark"):get_luaentity()
			self.user = name
			self.markid = p.markid
			local markid = self.markid
			minetest.after(10,function(name,markid)
				local p = protect.user[name]
				if p.markid == markid then
					protect.clear(name)
				end
			end,name,markid)
		elseif pressed.set then
			local n = tonumber(pressed.removearea)
			if pressed.removearea ~= "" and n ~= -1 then
				local f = true
				local pb = minetest.get_player_privs(name).protection_bypass == true
				for i,v in pairs(protect.areas) do
					if v.id == n then
						if v.game_rule then
							minetest.chat_send_player(name,"You can't remove a game rule area")
							f = false
						elseif v.owner == name or pb then
							m:set_int("removearea",pressed.removearea)
							minetest.chat_send_player(name,"Area set")
							f = false
						else
							minetest.chat_send_player(name,"That area doesn't belongs to you")
							f = false
						end
						break
					end
				end
				if f then
					minetest.chat_send_player(name,"Area do not exist")
				end
			else
				m:set_int("removearea",-1)
			end
			m:set_int("price",pressed.price or m:get_int("price"))
			minetest.registered_nodes["places:selling"].panel(pos, sender)
		elseif pressed.setup then
			local p = protect.user[name]
			if not (p and p.pos1 and p.pos2) then
				minetest.chat_send_player(name,'Mark with "/protect 1 /protect 2" to select the area to sell\nYou do not need to protect, just mark it\nThen Press the setup button again')
			else
				local pr,o = protect.test(p.pos1,p.pos2,name)
				if pr == false then
					minetest.chat_send_player(name,"The area is protected by "..o)
				else
					m:set_string("pos1",minetest.pos_to_string(vector.subtract(p.pos1,pos)))
					m:set_string("pos2",minetest.pos_to_string(vector.subtract(p.pos2,pos)))
					protect.clear(name)
					minetest.chat_send_player(name,"The area is confirmed")
					minetest.registered_nodes["places:selling"].on_receive_fields(pos, formname, {cancel=true}, sender)
					minetest.registered_nodes["places:selling"].panel(pos, sender)
				end
			end
		end
	end,
})

minetest.register_tool("places:rentpanel_copycard", {
	description = "Copy and past settings to renting panels",
	inventory_image = "rentpanel_copycard.png",
	groups = {flammable = 2},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if pointed_thing.type == "node" then
			local pos = pointed_thing.under
			local n = minetest.get_node(pos).name == "places:rental"
			local im = itemstack:get_meta()
			local m = minetest.get_meta(pos)
			if n and im:get_string("pos1") == "" then
				if m:get_string("pos1") == "" then
					minetest.chat_send_player(name,"No area is setup, canceled")
					return
				end
				im:set_int("list",m:get_int("list"))
				im:set_int("amount",m:get_int("amount"))
				im:set_int("price",m:get_int("price"))
				im:set_string("pos1",m:get_string("pos1"))
				im:set_string("pos2",m:get_string("pos2"))
				im:set_string("description","Settings set "..minetest.pos_to_string(pos))
				minetest.chat_send_player(name,"Panel settings is copied")
				return itemstack
			elseif n and (m:get_string("owner") == name or m:get_string("owner") == "") then
				m:set_int("list",im:get_int("list"))
				m:set_int("amount",im:get_int("amount"))
				m:set_int("price",im:get_int("price"))
				m:set_string("pos1",im:get_string("pos1"))
				m:set_string("pos2",im:get_string("pos2"))
				minetest.chat_send_player(name,"Panel settings is set")
				places.rentpanel.panel(pos, user)
				return itemstack
			end
		else
			local im = itemstack:get_meta()
			im:set_string("pos1","")
			im:set_string("description","Empty card")
			minetest.chat_send_player(name,"The card is cleared and can copy panel settings again")
			return itemstack
		end
	end,
})

player_style.register_button({
	name="Rental",
	image="places_rentalpanel.png",
	type="image",
	info="Go to rental",
	action=function(player)
		local meta = player:get_meta()
		local name = player:get_player_name()
		if meta:get_int("respawn_disallowed") == 1 then
			minetest.chat_send_player(name,"This function is disallowed in this case")
		else
			local pos = minetest.string_to_pos(meta:get_string("places_rentpanel_pos"))
			local pos2 = player:get_pos()
			local node_name = meta:get_string("places_rentpanel_node")
			if pos then
				player:set_pos(pos)
				minetest.after(2,function()
					local n = minetest.get_node(pos).name
					if n ~= node_name and n ~= "ignore" then
						meta:set_string("places_rentpanel_pos","")
						meta:set_string("places_rentpanel_node","")
						minetest.chat_send_player(name,"Looks like you as renter is terminated")
						places.rentpanel.update_waypoint(player)
						player:set_pos(pos2)
					end
				end)
			else
				minetest.chat_send_player(name,"You have to rent something first")
			end
		end
	end
})