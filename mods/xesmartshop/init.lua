xesmartshop={user={},tmp={},add_storage={},max_wifi_distance=30,
dir={{x=0,y=0,z=-1},{x=-1,y=0,z=0},{x=0,y=0,z=1},{x=1,y=0,z=0}},
dpos={
{{x=0.2,y=0.2,z=0},{x=-0.2,y=0.2,z=0},{x=0.2,y=-0.2,z=0},{x=-0.2,y=-0.2,z=0}},
{{x=0,y=0.2,z=0.2},{x=0,y=0.2,z=-0.2},{x=0,y=-0.2,z=0.2},{x=0,y=-0.2,z=-0.2}},
{{x=-0.2,y=0.2,z=0},{x=0.2,y=0.2,z=0},{x=-0.2,y=-0.2,z=0},{x=0.2,y=-0.2,z=0}},
{{x=0,y=0.2,z=-0.2},{x=0,y=0.2,z=0.2},{x=0,y=-0.2,z=-0.2},{x=0,y=-0.2,z=0.2}}}
}

minetest.register_craft({
	output = "xesmartshop:shop",
	recipe = {
		{"materials:gear_metal", "default:locked_chest", "materials:diode"},
		{"default:sign", "exatec:pcb", "default:sign"},
		{"default:sign", "default:lamp", "default:sign"},
	}
})

xesmartshop.strpos=function(str,spl)
	if str==nil then return "" end
	if spl then
		local c=","
		if string.find(str," ") then c=" " end
		local s=str.split(str,c)
			if s[3]==nil then
				return nil
			else
				local p={x=tonumber(s[1]),y=tonumber(s[2]),z=tonumber(s[3])}
				if not (p and p.x and p.y and p.z) then return nil end
				return p
			end
	else	if str and str.x and str.y and str.z then
			return str.x .."," .. str.y .."," .. str.z
		else
			return nil
		end
	end
end

xesmartshop.use_offer=function(pos,player,n)
	local pressed={}
	pressed["buy" .. n]=true
	xesmartshop.user[player:get_player_name()]=pos
	xesmartshop.receive_fields(player,pressed)
	xesmartshop.user[player:get_player_name()]=nil
	xesmartshop.update(pos)
end

xesmartshop.get_offer=function(pos)
	if not pos or not minetest.get_node(pos) then return end
	if minetest.get_node(pos).name~="xesmartshop:shop" then return end
	local meta=minetest.get_meta(pos)
	local inv=meta:get_inventory()
	local offer={}
	for i=1,4,1 do
		offer[i]={
		give=inv:get_stack("give" .. i,1):get_name(),
		give_count=inv:get_stack("give" .. i,1):get_count(),
		pay=inv:get_stack("pay" .. i,1):get_name(),
		pay_count=inv:get_stack("pay" .. i,1):get_count(),
		}
	end
	return offer
end

xesmartshop.receive_fields=function(player,pressed)
		local pname=player:get_player_name()
		local pos=xesmartshop.user[pname]
		if not pos then
			return
		elseif pressed.customer then
			return xesmartshop.showform(pos,player,true)
		elseif pressed.togglelime then
			local meta=minetest.get_meta(pos)
			local pname=player:get_player_name()
			if meta:get_int("type") == 0 then
				meta:set_int("type",1)
				minetest.chat_send_player(pname, "Your stock is limited")
			else
				meta:set_int("type",0)
				minetest.chat_send_player(pname, "Your stock is unlimited")
			end
			xesmartshop.showform(pos,player)
			return
		elseif pressed.del then
			local meta=minetest.get_meta(pos)
			meta:set_int("del",meta:get_int("del") == 0 and 1 or 0)
			xesmartshop.showform(pos,player)
			return
		elseif pressed.save then
			local meta=minetest.get_meta(pos)
			for i=1,4 do
				meta:set_string("pay"..i,pressed["pay"..i])
			end
		elseif not pressed.quit then
			local n=1
			for i=1,4,1 do
				n=i
				if pressed["buy" .. i] then break end
			end
			local meta=minetest.get_meta(pos)
			local type=meta:get_int("type")
			local inv=meta:get_inventory()
			local pinv=player:get_inventory()
			local pname=player:get_player_name()
			local check_storage
			if pressed["buy" .. n] then
				local name=inv:get_stack("give" .. n,1):get_name()
				local stack=name .." ".. inv:get_stack("give" .. n,1):get_count()
				local pay = tonumber(meta:get_string("pay"..n)) or 0
				local c = Getcoin(player)

				if name~="" then
--fast checks
					if not pinv:room_for_item("main", stack) then
						minetest.chat_send_player(pname, "Error: Your inventory is full")
						return
					elseif meta:get_int("type") == 1 and not inv:contains_item("main", stack) then
						minetest.chat_send_player(pname, "Error: The item is out of stock")
						if meta:get_int("del") == 1 then
							inv:set_stack("give" .. n,1,nil)
							xesmartshop.showform(pos,player,true)
						else
							exatec.send(pos)
						end
					elseif c < pay then
						minetest.chat_send_player(pname, "Error: You can't afford this")
						return
					else
						pinv:add_item("main",stack)
						Coin(meta:get_string("owner"),pay)
						Coin(player,-pay)
						minetest.sound_play("default_lose_coins", {to_player=pname, gain = 2})
						if meta:get_int("type") == 1 then
							inv:remove_item("main", stack)
							if meta:get_int("del") == 1 and not inv:contains_item("main", stack) then
								inv:set_stack("give" .. n,1,nil)
							else
								exatec.send(pos)
							end
						end
						xesmartshop.showform(pos,player,true)
					end
				end
			end
		else
			xesmartshop.update_info(pos)
			xesmartshop.update(pos,"update")
			xesmartshop.user[player:get_player_name()]=nil
		end
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="xesmartshop.showform" then
		xesmartshop.receive_fields(player,pressed)
	end
end)

xesmartshop.update_info=function(pos)
	local meta=minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local owner=meta:get_string("owner")
	if meta:get_int("type")==0 then
		meta:set_string("infotext","(Smartshop by " .. owner ..") Stock is unlimited")
		return false
	end
	local name=""
	local count=0
	local stuff={}
	for i=1,4,1 do
		stuff["count" ..i]=inv:get_stack("give" .. i,1):get_count()
		stuff["name" ..i]=inv:get_stack("give" .. i,1):get_name()
		stuff["stock" ..i]=stuff["count" ..i]
		stuff["buy" ..i]=0
		for ii=1,32,1 do
			name=inv:get_stack("main",ii):get_name()
			count=inv:get_stack("main",ii):get_count()
			if name==stuff["name" ..i] then
				stuff["stock" ..i]=stuff["stock" ..i]+count
			end
		end
		local nstr=(stuff["stock" ..i]/stuff["count" ..i]) ..""
		nstr=nstr.split(nstr, ".")
		stuff["buy" ..i]=tonumber(nstr[1]) - 1

		if stuff["name" ..i]=="" or stuff["buy" ..i]==0 then
			stuff["buy" ..i]=""
			stuff["name" ..i]=""
		else
			local def = default.def(stuff["name" ..i]) or {}
			local des = def.description or stuff["name" ..i]
			stuff["buy" ..i] = "(" ..stuff["buy" ..i] ..") "
			stuff["name" ..i] = des .."\n"
		end
	end
		meta:set_string("infotext",
		"(Smartshop by " .. owner ..") Purchases left:\n"
		.. stuff.buy1 ..  stuff.name1
		.. stuff.buy2 ..  stuff.name2
		.. stuff.buy3 ..  stuff.name3
		.. stuff.buy4 ..  stuff.name4
		)
end

xesmartshop.update=function(pos,stat)
--clear
	local spos=minetest.pos_to_string(pos)
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
		if ob and ob:get_luaentity() and ob:get_luaentity().xesmartshop and ob:get_luaentity().pos==spos then
			ob:remove()	
		end
	end
	if stat=="clear" then return end
--update
	local meta=minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local node=minetest.get_node(pos)
	local dp = xesmartshop.dir[node.param2+1]
	if not dp then return end
	pos.x = pos.x + dp.x*0.01
	pos.y = pos.y + dp.y*6.5/16
	pos.z = pos.z + dp.z*0.01
	for i=1,4,1 do
		local item=inv:get_stack("give" .. i,1):get_name()
		local pos2=xesmartshop.dpos[node.param2+1][i]
		if item~="" then
			xesmartshop.tmp.item=item
			xesmartshop.tmp.pos=spos
			local e = minetest.add_entity({x=pos.x+pos2.x,y=pos.y+pos2.y,z=pos.z+pos2.z},"xesmartshop:item")
			e:set_yaw(math.pi*2 - node.param2 * math.pi/2)
		end
	end
end


minetest.register_entity("xesmartshop:item",{
	hp_max = 1,
	visual="wielditem",
	visual_size={x=.20,y=.20},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	xesmartshop=true,
	type="",
	on_activate = function(self, staticdata)
		if xesmartshop.tmp.item ~= nil then
			self.item=xesmartshop.tmp.item
			self.pos=xesmartshop.tmp.pos
			xesmartshop.tmp={}
		else
			if staticdata ~= nil and staticdata ~= "" then
				local data = staticdata:split(';')
				if data and data[1] and data[2] then
					self.item = data[1]
					self.pos = data[2]
				end
			end
		end
		if self.item ~= nil then
			self.object:set_properties({textures={self.item}})
		else
			self.object:remove()
		end
	end,
	get_staticdata = function(self)
		if self.item ~= nil and self.pos ~= nil then
			return self.item .. ';' ..  self.pos
		end
		return ""
	end,
})

xesmartshop.showform=function(pos,player,re)
	local meta=minetest.get_meta(pos)
	local creative=meta:get_int("creative")
	local inv = meta:get_inventory()
	local gui=""
	local spos=pos.x .. "," .. pos.y .. "," .. pos.z
	local uname=player:get_player_name()
	local owner = meta:get_string("owner") == uname or minetest.check_player_privs(uname, {protection_bypass=true})
	if re then
		owner = false
	end
	xesmartshop.user[uname]=pos
	if owner then
		if meta:get_int("type")==0 and not (minetest.check_player_privs(uname, {creative=true}) or minetest.check_player_privs(uname, {give=true})) then
			meta:set_int("creative",0)
			meta:set_int("type",1)
			creative=0
		end

		gui = "size[8,10]"

		.."button_exit[5,0;2,1;customer;Customer]"
		.."button[6.8,0;0.8,1;del;Del]tooltip[del;Delete offer on out of stock "..(meta:get_int("del") == 1 and "(on)" or "(off)").."]"
		.."label[0,0.2;Item:]"
		.."label[0,1.2;Price:]"
		.."list[nodemeta:" .. spos .. ";give1;1,0;1,1;]"
		.."list[nodemeta:" .. spos .. ";give2;2,0;1,1;]"
		.."list[nodemeta:" .. spos .. ";give3;3,0;1,1;]"
		.."list[nodemeta:" .. spos .. ";give4;4,0;1,1;]"

		if creative == 1 then
			gui=gui .."button[6,1;2,1;togglelime;Toggle]tooltip[togglelime;"..(meta:get_int("type") == 1 and "limited" or "unlimited").."]"
		end
		gui=gui
		.."list[nodemeta:" .. spos .. ";main;0,2;8,4;]"
		.."list[current_player;main;0,6.2;8,4;]"
		.."listring[nodemeta:" .. spos .. ";main]"
		.."listring[current_player;main]"
		.."button[5,1;1.3,1;save;Save]tooltip[save;Save the pay options]"
		for i=1,4 do
			local c = tonumber(meta:get_string("pay"..i)) or 0
			c = c > 0 and c or "0"
			gui = gui .. "field["..(i+0.3)..",1.2;1,1;pay".. i..";;"..c.."]"
		end
	else
		gui="size[8,6]"
		.."list[current_player;main;0,2.2;8,4;]"
		.."label[0,-0.3;"..minetest.colorize("#FFFF00",Getcoin(player)).."]"
		.."label[0,0.2;Item:]"
		.."label[0,1.2;Price:]"

		for i=1,4 do
			if not inv:is_empty("give" .. i) then
				local def = minetest.registered_items[inv:get_stack("give"..i,1):get_name()] or {}
				local c = tonumber(meta:get_string("pay"..i)) or 0
				c = c > 0 and c or "Free"
				gui = gui .. "item_image["..(i+1)..",0;1,1;".. inv:get_stack("give"..i,1):get_name() .." "..inv:get_stack("give"..i,1):get_count().."]"
				.."item_image_button["..(i+1)..",1;1,1;player_style:coin;buy"..i..";"..c.."]"
				.."tooltip["..(i+1)..",0;1,1;"..(def.description or inv:get_stack("give"..i,1):get_name()).."]"
			end
		end

	end
	minetest.after(0.1, function(gui)
		return minetest.show_formspec(player:get_player_name(), "xesmartshop.showform",gui)
	end, gui)
end

minetest.register_node("xesmartshop:shop", {
	description = "Smartshop",
	tiles = {"default_birch_wood.png^default_glass.png^default_chest_top.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 1,on_load=1,exatec_wire=1,exatec_tube_connected=1,store=2000},
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.0,0.5,0.5,0.5}},
	paramtype2="facedir",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 10,
	after_place_node = function(pos, placer)
		local meta=minetest.get_meta(pos)
		meta:set_string("owner",placer:get_player_name())
		meta:set_string("infotext", "Smartshop by: " .. placer:get_player_name())
		meta:set_int("type",1)
		if minetest.check_player_privs(placer:get_player_name(), {creative=true}) or minetest.check_player_privs(placer:get_player_name(), {give=true}) then
			meta:set_int("creative",1)
			meta:set_int("type",0)
		end
	end,
	on_construct = function(pos)
		local meta=minetest.get_meta(pos)
		meta:set_int("state", 0)
		meta:get_inventory():set_size("main", 32)
		meta:get_inventory():set_size("give1", 1)
		meta:get_inventory():set_size("give2", 1)
		meta:get_inventory():set_size("give3", 1)
		meta:get_inventory():set_size("give4", 1)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		xesmartshop.showform(pos,player)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname:sub(1,4) == "give" then
			minetest.get_meta(pos):get_inventory():set_stack(listname,1, stack)
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname:sub(1,4) == "give" then
			minetest.get_meta(pos):get_inventory():set_stack(listname,1, nil)
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local inv = minetest.get_meta(pos):get_inventory()
		if from_list:sub(1,4) == "give" then
			inv:set_stack(from_list,1, nil)
		elseif to_list:sub(1,4) == "give" then
			local stack = inv:get_stack(from_list,from_index)
			inv:set_stack(to_list,1, stack)
		else
			return count
		end
		return 0
	end,
	exatec = {
		input_list="main",
		test_input=function(pos,stack,opos,cpos)
			local inv = minetest.get_meta(pos):get_inventory()
			return inv:room_for_item("main",stack)
		end,
	},
	on_timer = function (pos, elapsed)
		for _, player in pairs(minetest.get_connected_players()) do 
			if vector.distance(pos,player:get_pos()) <= 15 then
				xesmartshop.update(pos)
				break
			end
		end
		xesmartshop.update(pos,"clear")
		return true
	end,
	on_load=function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	can_dig = function(pos, player)
		if minetest.get_meta(pos):get_inventory():is_empty("main") then
			xesmartshop.update(pos,"clear")
			return true
		end
	end
})

minetest.register_node("xesmartshop:gamerules_shop", {
	description = "Smartshop (Not for usage)",
	drop = "xesmartshop:shop",
	tiles = {"default_birch_wood.png^default_glass.png^default_chest_top.png"},
	groups = {choppy = 2, on_load=1,not_in_creative_inventory=1},
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.0,0.5,0.5,0.5}},
	paramtype2="facedir",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 10,
	after_place_node = function(pos, placer)
		local meta=minetest.get_meta(pos)
		meta:set_string("owner","*CityTrader")
		meta:set_string("infotext", "Smartshop by: CityTrader")
		meta:set_int("type",1)
		meta:set_int("del",1)
	end,
	on_construct = function(pos)
		local meta=minetest.get_meta(pos)
		meta:set_int("state", 0)
		meta:get_inventory():set_size("main", 32)
		meta:get_inventory():set_size("give1", 1)
		meta:get_inventory():set_size("give2", 1)
		meta:get_inventory():set_size("give3", 1)
		meta:get_inventory():set_size("give4", 1)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		xesmartshop.showform(pos,player,true)
	end,
	on_timer = function (pos, elapsed)
		for _, player in pairs(minetest.get_connected_players()) do 
			if vector.distance(pos,player:get_pos()) <= 10 then
				xesmartshop.update(pos)
				break
			end
		end
		xesmartshop.update(pos,"clear")
		return true
	end,
	on_load=function(pos)
		minetest.get_node_timer(pos):start(5)
		minetest.registered_nodes["xesmartshop:gamerules_shop"].rnd_set_items(pos)
	end,
	rnd_set_items = function(pos)
		local items = {}
		local items2set = {}
		local meta = minetest.get_meta(pos)
		local group = meta:get_string("add_group_stuff")

		for i,v in pairs(minetest.registered_items) do
			local g = v.groups
			if g and g.store then
				if group == "exatec" then
					if g.exatec or g.tech_connect or g.exatec_tube or g.exatec_tube_connected or g.exatec_wire or g.exatec_wire_connected or g.exatec_data_wire or g.exatec_data_wire_connected then
						table.insert(items,{name=v.name,price=g.store})
					end
				elseif group == "eatable" then
					if g.eatable or g.drinkable then
						table.insert(items,{name=v.name,price=g.store})
					end
				elseif group == "ingot" then
					if g.ingot or g.lump then
						table.insert(items,{name=v.name,price=g.store})
					end
				elseif (group == "" or g[group]) then
					table.insert(items,{name=v.name,price=g.store})
				end
			end
		end
		for i=1,4 do
			local a = items[math.random(1,#items)]
			items2set[a.name] = math.random(math.ceil(a.price/2),a.price+math.ceil(a.price/2),#items)
		end
		minetest.registered_nodes["xesmartshop:gamerules_shop"].add_items(pos, items2set)
	end,
	add_items = function(pos, items)
		local meta=minetest.get_meta(pos)
		meta:get_inventory():set_list("main", {})
		local inv = minetest.get_meta(pos):get_inventory()
		local a=0
		for i,v in pairs(items) do	
			a = a +1
			if a <= 4 then
				inv:set_stack("give"..a,1, i)
				meta:set_string("pay"..a,v)
				inv:add_item("main",ItemStack(i.." "..math.random(1,99)))
			else
				xesmartshop.update_info(pos)
				return
			end
		end
		xesmartshop.update_info(pos)
	end,
})