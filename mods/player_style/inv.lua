player_style.register_button=function(def)
	local b = (def.type and (def.type .. "_button") or "button")
	.. (def.exit and "_exit" or "")
	.. "["..player_style.buttons.num..",0;1,1;" -- ",7.2;1,1;"
	.. (((def.type == "image" or def.type == "item_image") and def.image and (def.image .. ";")) or "")
	.. def.name ..";"
	.. (def.label or "") .."]"
	..(def.info and ("tooltip["..def.name..";"..def.info.."]") or "")
	player_style.buttons.text = player_style.buttons.text .. b
	player_style.buttons.num = player_style.buttons.num + 0.8
	player_style.buttons.num_of_buttons = player_style.buttons.num_of_buttons + 1
	player_style.buttons.action[def.name]=def.action
end

player_style.register_manual_page=function(def)
	if type(def.name) ~= "string" then
		error("name (string) required!")
	elseif type(def.text) ~= "string" and type(def.action) ~= "function" then
		error("text (string) or action (function) required!")
	end
	local t
	if def.itemstyle then
		t = "label[0,0;"..def.name.."]item_image[0,0.5;1,1;"..def.itemstyle.."]textarea[0,1.5;8.5,8.0;;;"..(def.text or "").."]"
	else
		t = def.text:find("%[") and def.text or "label[0,"..(def.label and 1 or 0)..";"..def.text.."]"
		t = t .. (def.label and "label[0,0;"..def.label.."]" or "")
	end
	table.insert(player_style.manual_pages,{name=def.name,text=t,tags=def.tags,action=def.action})
end

minetest.register_privilege("creative", {
	description = "Creative",
	give_to_singleplayer= false,
	on_grant=function(name)
		minetest.after(0,function(name)
			player_style.inventory(minetest.get_player_by_name(name))
		end,name)
	end,
	on_revoke=function(name)
		minetest.after(0,function(name)
			player_style.inventory(minetest.get_player_by_name(name))
		end,name)
	end
})

player_style.register_button({
	name="Manual",
	image="default_unknown.png",
	type="image",
	info="User manual",
	action=function(player)
		player_style.manual(player)
	end
})

player_style.inventory=function(player)
	local name = player:get_player_name()
	player_style.players[name].inv = player_style.players[name].inv or {}
	local invp = player_style.players[name].inv

--detached inventory (backpack)

	if not invp.backpack then
		
-- Backpack
		local m = player:get_meta()
		if player:get_meta():get_string("backpack") ~= "" then
			m:set_string("backpack1",m:get_string("backpack"))
			m:set_string("backpackslot1",m:get_string("backpackslot"))
			m:set_string("backpack","")
			m:set_string("backpackslot","")
		end

		invp.backpacki = m:get_int("backpackindex")
		invp.backcraft = m:get_int("backcraftlistring")


		for i=1,4 do
			invp["backpackslot"..i] = minetest.create_detached_inventory("backpackslot"..i, {
				allow_put = function(inv, listname, index, stack, player)
					return minetest.get_item_group(stack:get_name(),"backpack") > 0 and stack:get_count() or 0
				end,
				allow_take = function(inv, listname, index, stack, player)
					for i,v in pairs(minetest.deserialize(player:get_meta():get_string("backpack"..i) or "") or {}) do
						if ItemStack(v):get_count() > 0 then
							return 0
						end
					end
					return stack:get_count()
				end,
				on_put = function(inv, listname, index, stack, player)
					player:get_meta():set_string("backpackslot"..i,minetest.serialize(stack:to_table()))
					if not invp.backpack_object then
						invp.backpack_object = minetest.add_entity(player:get_pos(),"default:wielditem")
						invp.backpack_object:set_attach(player, "body2",{x=2, y=0, z=0}, {x=180,y=90,z=0})
						invp.backpack_object:set_properties({textures={"player_style:backpack"},visual_size = {x=0.15,y=0.15,z=0.3}})
					end

					minetest.after(0,function(player)
						player_style.inventory(player)
					end,player)
				end,
				on_take = function(inv, listname, index, stack, player)
					player:get_meta():set_string("backpackslot"..i,"")
					if invp.backpack_object then
						invp.backpack_object:remove()
						invp.backpack_object = nil
					end
					player_style.inventory(player)
				end
			})

			invp["backpackslot"..i]:set_size("main",1)
			invp["backpackslot"..i]:set_stack("main",1,ItemStack(minetest.deserialize(player:get_meta():get_string("backpackslot"..i) or "")) or {})

			if invp["backpackslot"..i]:is_empty("main") == false then
				minetest.after(0.1,function(invp,player)
					invp.backpack_object = minetest.add_entity(player:get_pos(),"default:wielditem")
					invp.backpack_object:set_attach(player, "body2",{x=2, y=0, z=0}, {x=180,y=90,z=0})
					invp.backpack_object:set_properties({textures={"player_style:backpack"},visual_size = {x=0.15,y=0.15,z=0.3}})
				end,invp,player)
			end
		end
		invp.backpack = minetest.create_detached_inventory("backpack", {
			allow_put = function(inv, listname, index, stack, player)
				local invps = player_style.players[name].inv
				if invps.backpacki == 0 or inv:is_empty("main") and minetest.get_item_group(stack:get_name(),"backpack") > 0 then
					return 0
				elseif invps["backpackslot"..invps.backpacki]:is_empty("main") then
					return 0
				end
				return stack:get_count()
			end,
			on_move = function(inv, from_list, from_index, to_list, to_index, count,player)
				local name = player:get_player_name()
				local d = {}
				for i,v in pairs(inv:get_list("main")) do
					d[i]=v:to_table()
				end
				player:get_meta():set_string("backpack"..player_style.players[name].inv.backpacki,minetest.serialize(d))
			end,
			on_put = function(inv, listname, index, stack, player)
				local name = player:get_player_name()
				local d = {}
				for i,v in pairs(inv:get_list("main")) do
					d[i]=v:to_table()
				end
				player:get_meta():set_string("backpack"..player_style.players[name].inv.backpacki,minetest.serialize(d))
			end,
			on_take = function(inv, listname, index, stack, player)
				local name = player:get_player_name()
				local d = {}
				for i,v in pairs(inv:get_list("main")) do
					d[i]=v:to_table()
				end
				player:get_meta():set_string("backpack"..player_style.players[name].inv.backpacki,minetest.serialize(d))
			end
		})
		invp.backpack:set_size("main",24)

--hat

		invp.hat = minetest.create_detached_inventory("hat", {
			allow_put = function(inv, listname, index, stack, player)
				return default.def(stack:get_name()).hat_properties and 1 or 0
			end,
			on_put = function(inv, listname, index, stack, player)
				player:get_meta():set_string("hat",minetest.serialize(stack:to_table()))
				local def = minetest.registered_items[stack:get_name()]
				if not invp.hat_object and def and def.hat_properties then
					invp.hat_object = minetest.add_entity(player:get_pos(),"default:wielditem")
					invp.hat_object:set_attach(player, "head",def.hat_properties.pos or {x=0, y=6, z=0}, def.hat_properties.rotation or {x=0,y=90,z=0})
					invp.hat_object:set_properties({textures={stack:get_name()},visual_size = def.hat_properties.size or {x=0.5,y=0.5,z=0.5}})
				end
			end,
			on_take = function(inv, listname, index, stack, player)
				if invp.hat_object then
					invp.hat_object:remove()
					invp.hat_object = nil
				end
				player:get_meta():set_string("hat","")
			end
		})
		invp.hat:set_size("main",1)
		local item = ItemStack(minetest.deserialize(player:get_meta():get_string("hat") or ""))
		invp.hat:set_stack("main",1,item or {})
		local def = minetest.registered_items[item:get_name()]

		if invp.hat:is_empty("main") == false and def and def.hat_properties then
			minetest.after(0.1,function(invp,player)
				invp.hat_object = minetest.add_entity(player:get_pos(),"default:wielditem")
				invp.hat_object:set_attach(player, "head",def.hat_properties.pos or {x=0, y=6, z=0}, def.hat_properties.rotation or {x=0,y=90,z=0})
				invp.hat_object:set_properties({textures={item:get_name()},visual_size = def.hat_properties.size or {x=0.5,y=0.5,z=0.5}})
			end,invp,player)
		end

	end


--BackPacks
	local backpack = ""

	if invp.backpacki ~= 0 and minetest.get_item_group(invp["backpackslot"..invp.backpacki]:get_stack("main",1):get_name(),"backpack") > 0 then
		backpack = "list[detached:backpack;main;0,1;4,7;]listring[current_player;main]listring[detached:backpack;main]" or ""
		local list = {}
		for i,v in pairs(minetest.deserialize(player:get_meta():get_string("backpack"..invp.backpacki) or "") or {}) do
			list[i]=ItemStack(v)
		end
		invp.backpack:set_list("main", list)
	end
	for i=1,4 do
		if invp.backpacki ~= i and minetest.get_item_group(invp["backpackslot"..i]:get_stack("main",1):get_name(),"backpack") > 0 then
			backpack = backpack .. "image_button["..(i-1)..",0.6;1,0.5;default_stone.png;backpack"..i..";"..i.."]"
		end

		backpack = backpack
		.."image_button["..(i-1)..",-0.2;1,1;player_style_backpack.png;backpack"..i..";]"
		.."list[detached:backpackslot"..i..";main;"..(i-1)..",-0.2;1,1;]"
	end

--inventory

	local skin = minetest.formspec_escape(player:get_properties().textures[1] or "character.png")
	local model = "model[4,0;3,3;character_preview;character.b3d;"..skin..";0,180;false;true;1,31]"
	local buttons = "scrollbaroptions[max="..((player_style.buttons.num_of_buttons-10)*10)..";]scrollbar[0,8;12,0.5;horizontal;scrollbar;]scroll_container[0,8.2;15,1.5;scrollbar;horizontal]"
		..player_style.buttons.text
		.."scroll_container_end[scrollbar]"

	if not (player_style.creative or minetest.check_player_privs(name, {creative=true})) then
--default inventory
		player:set_inventory_formspec(
			"size[12,8]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."list[current_player;main;4,3;8,4;]"
			.."list[current_player;craft;8,0;3,3;]"
			.."list[current_player;craftpreview;11,1;1,1;]"
			.."item_image[11,0;1,1;player_style:top_hat]"
			.."list[detached:hat;main;11,0;1,1;]"
			.."listring[current_player;main]"
			.. (invp.backcraft == 0 and "listring[current_player;craft]image_button[7,2;1,1;default_craftgreed.png;backcraft;]tooltip[backcraft;Shift-move to craftgreed]" or "listring[detached:backpack;main]image_button[7,2;1,1;player_style_backpack.png;backcraft;]tooltip[backcraft;Shift-move to backpack]")
			..model
			..buttons
			..backpack
		)
	else
--creative inventory items
		if not player_style.inventory_items then
			player_style.inventory_items={}
			for i,it in pairs(minetest.registered_items) do
				if not (it.groups and it.groups.not_in_creative_inventory) then
					table.insert(player_style.inventory_items,it.name)
				end
			end
			table.sort(player_style.inventory_items)

			minetest.create_detached_inventory("deleteslot", {
				on_put = function(inv, listname, index, stack, player)
					inv:set_stack("main",1,"")
				end
			}):set_size("main", 1)
		end
--creative inventory
		invp.index = invp.index or 1
		invp.size = invp.size or 34
		invp.search = invp.search and invp.search.text ~= "" and invp.search or nil

		local itemlist = invp.search and invp.search.items or player_style.inventory_items
		local pages = math.floor(#itemlist/player_style.players[name].inv.size)
		local page = math.floor(player_style.players[name].inv.index/player_style.players[name].inv.size)
		local itembutts = ""
		local x=12
		local y=0

		for i=invp.index,invp.index+invp.size do
			local it = itemlist[i]
			if it then
				itembutts = itembutts.."item_image_button["..x..","..y..";1,1;"..it..";itembut_"..it..";]"
				x = x + 0.8
				if x >= 16 then
					y = y + 0.9
					x = 12
				end
			end
		end
		player:set_inventory_formspec(
			"size[16,8]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."list[current_player;main;4,3;8,4;]"
			.."list[current_player;craft;8,0;3,3;]"
			.."list[current_player;craftpreview;11,1;1,1;]"

			.."item_image[11,0;1,1;player_style:top_hat]"

			.."list[detached:hat;main;11,0;1,1;]"

			.."listring[current_player;main]"
			.. (invp.backcraft == 0 and "listring[current_player;craft]image_button[7,2;1,1;default_craftgreed.png;backcraft;]tooltip[backcraft;Shift-move to craftgreed]" or "listring[detached:backpack;main]image_button[7,2;1,1;player_style_backpack.png;backcraft;]tooltip[backcraft;Shift-move to backpack]")

			..buttons

			.."image_button[12,7;1,1;default_crafting_arrowleft.png;creinvleft;]"
			.."image_button[13,7;1,1;default_crafting_arrowright.png;creinvright;]"
			.."image_button[14,7;1,1;synth_repeat.png;reset;]"
			.."image_button[15,7;1,1;default_bucket.png;clean;]"
			.."tooltip[creinvleft;Back]"
			.."tooltip[creinvright;Forward]"
			.."tooltip[reset;Reset]"
			.."tooltip[clean;Clean your inventory]"
			.."image[11,2;1,1;default_bucket.png]list[detached:deleteslot;main;11,2;1,1;]"
			.."label[13.6,7.9;"..page.."/"..pages.."]"

			.."field[12.3,6.5;3,1;searchbox;;"..(invp.search and invp.search.text or "").."]"
			.."image_button[15,6.3;1,0.8;player_style_search.png;search;]"
			..model
			..backpack
			..itembutts
		)
	end
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	
	if form == "" then
		local name = player:get_player_name()
		for i,v in pairs(pressed) do
			if player_style.buttons.action[i] then
				player_style.buttons.action[i](player)
				return
			end
		end
		local invp = player_style.players[name].inv
		if invp then
			if pressed.quit then
				player_style.players[name].inv.clean = nil
				return
			elseif pressed.creinvright and invp.index+invp.size < (invp.search and #invp.search.items or #player_style.inventory_items) then
				invp.index = invp.index + invp.size+1
				player_style.inventory(player)
				return
			elseif pressed.creinvleft and invp.index > 1 then
				invp.index = invp.index - invp.size-1
				player_style.inventory(player)
				return
			elseif pressed.reset then
				invp.index = 1
				invp.search = nil
				player_style.inventory(player)
				return
			elseif pressed.clean then
				if not invp.clean then
					minetest.chat_send_player(name,"Press again to clean you inventory")
					invp.clean = true
				else
					local inv = player:get_inventory()
					for i,v in pairs(inv:get_list("main")) do
						inv:set_stack("main",i,"")
					end
					player_style.players[name].inv.clean = nil
				end
			elseif pressed.search then
				local its = {}
				local s = pressed.searchbox:lower()
				for i,it in pairs(player_style.inventory_items) do
					if it:find(s) or (minetest.registered_items[it].description or ""):lower():find(s) then
						table.insert(its,it)
					end
				end
				invp.index = 1
				invp.search={
					text = s,
					items = its
				}
				player_style.inventory(player)
				return


			elseif pressed.backcraft then
				local m = player:get_meta()
				invp.backcraft = m:get_int("backcraftlistring") == 0 and 1 or 0
				m:set_int("backcraftlistring",invp.backcraft)
				player_style.inventory(player)
			else
				for i=1,4 do
					if pressed["backpack"..i] and minetest.get_item_group(invp["backpackslot"..i]:get_stack("main",1):get_name(),"backpack") > 0 then
						player:get_meta():set_int("backpackindex",i)
						invp.backpacki = i
						player_style.inventory(player)
						return
					end
				end
			end
			for i,v in pairs(pressed) do
				if i:sub(1,8) == "itembut_" then
					local t = i:sub(9,-1)
					player:get_inventory():add_item("main",t.." "..minetest.registered_items[t].stack_max)
					break
				end
			end
		end
	elseif form == "player_style.manual" then
		if pressed.manuallist then
			local i = minetest.explode_textlist_event(pressed.manuallist).index
			player_style.manual(player,i)
		elseif pressed.close then
			player_style.manual(player)
		else
			for i,v in pairs(pressed) do
				if i:sub(1,7) == "manual_" then
					player_style.manual(player,tonumber(i:sub(8,-1)))
					break
				end
			end
		end
	end
end)

player_style.manual=function(player,page)
	local name = player:get_player_name()
	local ppr = player_style.players[name]
	ppr.manual = ppr.manual or {}
	local text = "size[8,8]listcolors[#77777777;#777777aa;#000000ff]"

	if not page then
		local dir = player:get_look_dir()
		local pos = player:get_pos()
		local p1 = {x=pos.x+dir.x,y=pos.y+1.4,z=pos.z+dir.z}
		local p2 = {x=pos.x+(dir.x*5),y=pos.y+1.4+(dir.y*5),z=pos.z+(dir.z*5)}

		local node
		local object
		local sh

		for v in minetest.raycast(p1,p2,true,true) do
			if v.type == "node" then
				node = minetest.get_node(v.under).name
			elseif v.type == "object" then
				local en = v.ref:get_luaentity()
				if en then
					object = en.name
				end
			end
			break
		end

		local item = object or node or player:get_wielded_item():get_name()
		local items = ""
		local c = ""
		for i,v in ipairs(player_style.manual_pages) do
			items = items .. c .. v.name
			c = ","
			if not sh and v.tags and item then
				local def = minetest.registered_items[item] or {}
				local groups = def.groups or {}
				for i1,v1 in ipairs(v.tags) do
					if item == v1 or groups[v1] then
						sh = true
						if def then
							text = text .. "item_image_button[7,0;1,1;"..item..";manual_"..i..";]"
						else
							text = text .. "image_button[7,0;1,1;default_unknown.png;manual_"..i..";]"
						end
						break
					end
				end
			end
		end
		text = text .. "textlist[0,0;4,8;manuallist;".. items .."]"
		return minetest.show_formspec(name, "player_style.manual",text)
	else

		local p = player_style.manual_pages[page]
		text = text .. (p.text or "")
		if p.action then
			text = text .. p.action(player) or ""
		end

		text = text .. "button[7.2,-0.3;1,1;close;X]"
		return minetest.show_formspec(name, "player_style.manual",text)
	end
end

player_style.register_manual_page({
	name = "Controls",
	text = "",
	tags = {"default:dirt","default:dirt_with_grass","snowy"},
	action=function(player)
		local y = 0
		local t = ""
		local l = {
			["Crawl"]="sneak",
			["Run"]="special/aux1",
			["Wallrun"]="run + jump into a wall (can be hard)",
			["Edge climb"]="touch an edge above the ground",
			["Kong"]="run into a block",
			["Cat leap"]="jump backwards in edge climbing",
			["Tic tac/walljump"]="run + jump side of a wall",
			["Double wall climb"]="hold left & right",
			["Backflip	"]="jump, (hold) place/RMB & press back",
			["Frontflip"]="jump, (hold) place/RMB & press forward",
			["Right sideflip"]="jump, (hold) place/RMB & press right",
			["Left sideflip"]="jump, (hold) place/RMB & press left",
			["Roll"]="sneak when falling from a height",
			["Dive roll"]="place/RMB and press up",
		}
		table.sort(l)
		for i,v in pairs(l) do
			t = t .. "label[-0.2,"..y..";"..i.."]label[2.5,"..y..";"..v.."]"
			y = y + 0.5
		end
		t = t .. "label[-0.2,"..y..";You can use all flips to reach more height and come over\nobstacles on 2 blocks while running, but sideflips wont hurt\non obstacles and there is no risk you breaks your neck.]"
		return t
	end
})