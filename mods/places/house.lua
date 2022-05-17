minetest.register_craft({
	output="places:rental",
	recipe={
		{"default:locked_chest","materials:plastic_sheet","materials:gear_metal"},
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
	groups = {choppy=3,oddly_breakable_by_hand=3,store=200},
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
		m:set_int("amount",1)
		m:set_int("price",1)
		m:set_int("list",3)
	end,
	panel=function(pos,user,preview)
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
				form = form .."label[0,-0.3;Occupied by "..renter.."]"
			else
				form = form
				.. (m:get_string("owner") ~= "" and "label[0.5,0;Owner: "..m:get_string("owner").."]" or "")
				..(user and "label[2,0;"..minetest.colorize("#FFFF00",Getcoin(user)).."]" or "")
				.."button[0.5,1;2.2,1;"..(renter == name and "cancel;Cancel" or "rent;Rent").."]"
				.."label[-0.2,2;Price: "..m:get_int("price").."\n"..m:get_int("amount").."'th "..tt[t].."]"
			end

		end
		m:set_string("formspec",form)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.registered_nodes["places:rental"].panel(pos, player)
	end,
	counts = function(pos)
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
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		local m = minetest.get_meta(pos)
		local name = sender and sender:get_player_name() or m:get_string("renter")

		if pressed.rent then
			local c = Getcoin(sender)
			local p = m:get_int("price")
			if c < p then
				minetest.chat_send_player(name,"You can't afford "..p.." (cons: ".. c ..")")
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
			minetest.registered_nodes["places:rental"].panel(pos, sender)
		elseif pressed.cancelrenting then
			m:set_int("cancel",1)
			minetest.chat_send_player(m:get_string("owner"),"The renting is canceling")
			minetest.chat_send_player(m:get_string("renter"),"The renting is canceling")
			minetest.registered_nodes["places:rental"].panel(pos, sender)
		elseif pressed.cancel then
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
		elseif pressed.cp then
			minetest.registered_nodes["places:rental"].panel(pos, sender,true)
		elseif pressed.set then
			m:set_int("amount",pressed.amount or m:get_int("amount"))
			m:set_int("price",pressed.price or m:get_int("price"))
			minetest.registered_nodes["places:rental"].counts(pos)
			minetest.registered_nodes["places:rental"].panel(pos, sender)
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
					minetest.registered_nodes["places:rental"].on_receive_fields(pos, formname, {cancel=true}, sender)
					minetest.registered_nodes["places:rental"].panel(pos, sender)
				end
			end
		elseif pressed.list then
			m:set_int("list",minetest.explode_textlist_event(pressed.list).index)
			m:set_int("amount",pressed.amount or m:get_int("amount"))
			m:set_int("price",pressed.price or m:get_int("price"))
			minetest.registered_nodes["places:rental"].counts(pos)
			minetest.registered_nodes["places:rental"].panel(pos, sender)
		end
	end,
	on_timer = function (pos, elapsed)
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
				minetest.registered_nodes["places:rental"].on_receive_fields(pos, "", {cancel=true})
				return
			end

			local cost = math.floor(time/a)*m:get_int("price")
			local c = Getcoin(renter)
			if c <= cost then
				Coin(renter,-c)
				Coin(owner,c)
				minetest.chat_send_player(renter,c.." coin(s) has just been taken from you due your rent ("..minetest.colorize("#FFFF00",Getcoin(renter)).." left)")
				minetest.registered_nodes["places:rental"].on_receive_fields(pos, "", {cancel=true})
				return
			else
				Coin(renter,-cost)
				Coin(owner,cost)
				minetest.chat_send_player(renter,cost.." coin(s) has just been taken from you due your rent ("..minetest.colorize("#FFFF00",Getcoin(renter)).." left)")
				if c-cost <= cost then
					minetest.registered_nodes["places:rental"].on_receive_fields(pos, "", {cancel=true})
					return
				end
			end
			m:set_int("date",default.date("get"))
		end
		return true
	end,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_string("renter") == ""
	end
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
				minetest.registered_nodes["places:rental"].panel(pos, user)
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