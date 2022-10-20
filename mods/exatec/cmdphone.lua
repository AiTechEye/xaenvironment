exatec.cmdphone={
	user={},
}

ob_id=function(ob)
	local en = ob and ob:get_luaentity() or nil
	return en and en.examob or ob and ob:get_player_name() or nil
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "cmdphone" then
		local item = player:get_wielded_item()
		local m = item:get_meta()
		local pass
		if m:get_int("visualcode") == 1 then
			if pressed["vc-cancel"] then
				pass = true
				m:set_int("visualcode-move",0)
				player:set_wielded_item(item)
			elseif pressed.addfor or pressed.indent then
				pass = true
			else
				for i,v in pairs(pressed) do
					if i:sub(0,8) == "vc-move-" then
						pass = true
						m:set_int("visualcode-move",tonumber(i:sub(9,-1)))
					elseif i:sub(0,10) == "vc-moveto-" then
						pass = true
						m:set_int("visualcode-moveto",tonumber(i:sub(11,-1)))
					elseif i:sub(0,7) == "vc-del-" then
						pass = true
						m:set_int("visualcode-del",tonumber(i:sub(8,-1)))
					elseif i:sub(0,7) == "vc-add-" then
						pass = true
						m:set_int("visualcode-add",tonumber(i:sub(8,-1)))
					elseif pass then
						player:set_wielded_item(item)
						break
					end
				end
			end
		end

		if pass or pressed.save or pressed.list or pressed.interval or pressed.setmob or pressed.visualcode then
			exatec.show_cmdphone(player, pressed)
		end
	end
end)

exatec.show_cmdphone=function(player,pressed)
	pressed = pressed or {}

	local name = player:get_player_name()
	local u = exatec.cmdphone.user[name]
	local self = u.ob and u.ob:get_luaentity()

	if pressed.setmob then
		local id = tonumber(pressed.mobs:sub(1,pressed.mobs:find(" ")))
		local m = u.obs[id]
		if m and m:get_luaentity() then
			u.ob = m
		elseif id then
			u.obs[id] = nil
			return
		end
	elseif not u.ob then
		for i,v in pairs(u.obs) do
			u.ob = v
			break
		end
	end

	local limit = self and self.exatec_limit
	local err = ""
	local item = player:get_wielded_item()
	local m = item:get_meta()
	local description = m:get_string("description")
	local text = pressed.text or minetest.deserialize(m:get_string("text")) or ""
	local oldtext = text
	local mlist = ""
	local c = ""

	if pressed.description and description ~= pressed.description then
		m:set_string("description",pressed.description)
		description = pressed.description
	end

	if self then
		if pressed.save or pressed.interval and not self.storage.code_execute_interval then
			self.storage.code_execute_interval = text
			self.storage.code_execute_interval_user = name
		elseif pressed.interval and self.storage.code_execute_interval then
			self.storage.code_execute_interval = nil
			self.storage.code_execute_interval_user = nil
			self.cmdphone_error = nil
		end
	end

	if self and self.cmdphone_error then
		err = self.cmdphone_error
	end

	if pressed.visualcode then
		m:set_int("visualcode",m:get_int("visualcode") == 0 and 1 or 0)
	end

	local list = ""
	local listn = 0
	local listin = pressed.posinput or ""
	local listin2 = pressed.nodeinput or ""
	local func_name
	local func_info
	local func_return
	local func_if
	local func_params
	local preslist = pressed.list and tonumber(pressed.list:sub(5,-1)) or -1
	local visualcode_enabled = m:get_int("visualcode") == 1
	--text = minetest.formspec_escape(text)

	if self and pressed.save then
		self.cmdphone_error = nil
	end

	for i,ob in pairs(u.obs) do
		local en = ob:get_luaentity()
		if en and en.examob then
			mlist = mlist ..en.examob ..(en.storage.code_execute_interval and " on" or " off") .. ","
		else
			u.obs[i] = nil
		end
	end
	mlist = mlist:sub(1,-2)

	local funcs = exatec.create_env(nil,nil,self or {})

	for i,v in pairs(funcs) do
		if type(v) == "table" then
			for i2,v2 in pairs(v) do
				if type(v2) == "function" then
					local c = funcs[i][i2.."_color"] or funcs[i.."_color"] or ""


					list = list..c..i.."."..i2..","
					listn = listn + 1
					if listn == preslist then
						func_name = i2
						func_info = funcs[i][i2.."_text"]
						func_return = funcs[i][i2.."_return"]
						func_if = funcs[i][i2.."_if"] == true
						func_params = funcs[i][i2.."_params"]
						listin = i.."."..i2.."()"
					end
				end
			end
		elseif type(v) == "function" then
			list = list..(funcs[i.."_color"] or "")..i..","
			listn = listn + 1
			if listn == preslist then
				func_name = i
				func_info = funcs[i.."_text"]
				func_return = funcs[i.."_return"]
				func_if = funcs[i.."_if"] == true
				func_params = funcs[i.."_params"]
				listin = i.."()"
			end
		end
	end
	list = list:sub(1,-2)

--visualcode

	local textx = 0
	local visualcode = ""

	if visualcode_enabled then

		if pressed.addfor then
			listin = 'for i,v in pairs() do\nend'
		end

		local move = m:get_int("visualcode-move")
		local addhere = m:get_int("visualcode-add")
		local color = {IF="ff0f",pos="0f0f",count="3a3f",id="ffff"}
		local vtext = text:split("\n")
		local x = -0.2
		local y = -0.2

		if func_params then
			listin = listin:gsub("%(%)","%("..func_params.."%)")
		end

		if pressed.posinput then
			listin = "local pos = "..listin
		elseif func_return == "table" then
			listin = "for i,v in ipairs("..listin..") do\nend"
		elseif func_if then
			listin = "if ".. listin .." then\nend"
		elseif func_return and func_return ~= "" then
			listin = "local "..func_return .." = "..listin
		end

		if m:get_int("visualcode-del") > 0 then
			local del = m:get_int("visualcode-del")
			local t = ""
			local lines = 0
			for i,v in ipairs(vtext) do
				if del ~= i then
					t = t .. v .. "\n"
					lines = i
				end
			end
			text = t
			m:set_string("text",t)
			m:set_int("visualcode-del",0)
			if addhere > lines then
				addhere = lines
				m:set_int("visualcode-add",lines)
			end
		elseif listin ~= "" then
			local lines = #vtext
			local t = ""

			if addhere > lines then
				addhere = lines
				m:set_int("visualcode-add",lines)
				t = text.. "\n" .. listin
			elseif text == "" then
				t = listin
			elseif addhere == 0 then
				t = text .. "\n" ..listin
			else
				for i,v in ipairs(vtext) do
					t = t .. v .. "\n" .. (i == addhere and listin.."\n"  or "")
				end
			end
			text = t
		elseif m:get_int("visualcode-moveto") > 0 then
			local moveto = m:get_int("visualcode-moveto")
			local t = ""
			local line = ""
			if moveto > move then
				moveto = moveto -1
			end
			for i,v in ipairs(vtext) do
				if move == i then
					line = v
				else
					t = t .. v .. "\n"
				end
			end
			vtext = t:split("\n")
			t = ""
			for i,v in ipairs(vtext) do
				t = t .. v .. "\n" .. (moveto == i and line.."\n" or "")
			end
			move = 0
			text = t
			m:set_string("text",t)
			m:set_int("visualcode-move",0)
			m:set_int("visualcode-moveto",0)
		end
		
--remove spaces


		local labeltext = ""
		for i,v in ipairs(text:split("\n")) do
			for c=1,v:len() do
				if v:sub(c,c) ~= " " then
					labeltext = labeltext .. v:sub(c,-1) .."\n"
					break
				end
			end
		end
		if pressed.indent then
			text = labeltext
		end

		for i,v in ipairs(labeltext:split("\n")) do

-- label
			local addx = 0
			local labelcolor = "dddf"
			local label_info = ""
			local find = v:find("%(")
			local label = v:sub(0,find and find-1 or -1)

			if v:gsub(" ",""):find('="') then
				label = v
			end

			if label:sub(0,6) == "local " then		--local var = 
				local find2 = label:find("=")
				labelcolor = find2 and color[label:sub(7,find2-1):gsub(" ","")] or labelcolor
				if find2 and label:sub(find2+1,find2+1) == " " then
					label = label:sub(find2+2,-1)
				elseif find2 then
					label = label:sub(find2+1,-1)
				end
			end
			if v:sub(0,4) == "for " and find then
				label = "for "..v:sub(find+1,v:find("%)")-1)
				addx = 0.2
				labelcolor = color["IF"]
			end
			if find and label:find("%.") then			--mob.func
				label = (v:sub(0,3) == "if " and "if " or "") .. label:sub(label:find("%.")+1,-1)
			end

			if v:sub(0,3) == "if "  then
				labelcolor = color["IF"]
				addx = 0.2
			elseif v:sub(0,4) == "else" or v:sub(0,6) == "elseif " then
				addx = 0.2
				x = x -0.2
				labelcolor = color["IF"]
			elseif v == "end" then
				labelcolor = color["IF"]
				if x > -0.2 then
					x = x - 0.2
				end
			end
			label_info = v
			label = label:sub(0,10)
-- label

			visualcode = visualcode
			.."box["..x..","..y..";2,0.5;#"..labelcolor.."]"
			.."tooltip["..x..","..y..";2,0.5;"..label_info.."]"
			.."label["..x..","..y..";"..minetest.colorize("#000",label).."]"

			..(move == 0 and "button["..(x+2)..","..y..";1,0.5;vc-move-"..i..";M]tooltip[vc-move-"..i..";Move]" or (move == i and "button["..(x+2)..","..y..";2,0.5;vc-cancel;Cancel]" or "button["..(x+2)..","..y..";1,0.5;vc-moveto-"..i..";To]tooltip[vc-moveto-"..i..";Put under]"))
			..(move == 0 and "button["..(x+2.8)..","..y..";1,0.5;vc-del-"..i..";-]tooltip[vc-del-"..i..";Remove]" or "")
			..(move == 0 and addhere ~= i and "button["..(x+3.6)..","..y..";1,0.5;vc-add-"..i..";+]tooltip[vc-add-"..i..";Add here]" or "")

			y = y + 0.5
			x = x + addx
			textx = textx < x and x or textx
		end

-- add spaces

		if pressed.indent then
			local ltext = ""
			local ix = ""
			local ix2 = ""
			for i,v in ipairs(text:split("\n")) do
				if v:sub(1,3) == "if " or v:find(" do\n") then
					ix2 = "  "
				elseif v:sub(1,7) == "elseif " or v == "else" then
					ix = ix:sub(1,-3)
					ix2 = "  "
				elseif v == "end" then
					ix = ix:sub(1,-3)
				end
				ltext = ltext .. ix ..v .."\n"
				ix = ix .. ix2
				ix2 = ""
			end

			text = ltext
		end

		textx = textx +4.5

		y = #text:split("\n")
 		local scroll = minetest.explode_scrollbar_event(pressed.scrollbar).value or 0
		local h = 20
		local my = 5+((y-h)*0.06)
		local sy = (y-h) >= 0 and math.ceil((y-h)*my) or 0
		visualcode ="scrollbaroptions[max="..(sy).."]"
		.."scrollbar["..textx..",1.2;0.5,10.2;vertical;scrollbar;"..(scroll or 0).."]"
		.."scroll_container[0,1.8;"..(textx+1.5)..",12.3;scrollbar;vertical]"
		..visualcode
		.."scroll_container_end[scrollbar]"
	end


--save
	if oldtext ~= text or pressed.text then
		m:set_string("text",minetest.serialize(text))
	end
	player:set_wielded_item(item)


--form


	local showfosp = "size["..(visualcode_enabled and 20 or 14)..",11]"
	.."box[-0.2,1;"..(visualcode_enabled and 20 or 14)..",10.4;#ffff]"
	.."style[text;textcolor=black;noclip=true]"

	.."button[-0.2,-0.4;1,1;save;Save]"
	.."label[3.7,-0.2;"..(self and minetest.colorize("#00FF00",self.examob.." is connected") or minetest.colorize("#FFFF00","No mob connected")).."]"
	.."button[2.5,-0.4;1,1;setmob;Set]tooltip[setmob;Select mob from the list]"
	.."button[1.6,-0.4;1,1;interval;"..(self and self.storage.code_execute_interval and minetest.colorize("#00FF00","on") or minetest.colorize("#FF0000","off")).."]tooltip[interval;Code exacute interval]"
	.."dropdown[1.6,0.3;2;mobs;" ..mlist..";"..(self and self.examob or "").."]"

	.."button[0.8,-0.4;1,1;visualcode;"..(m:get_int("visualcode") == 1 and minetest.colorize("#00FF00","on") or minetest.colorize("#FF0000","off")).."]tooltip[visualcode;Visual programmingl]"

	..(visualcode_enabled == false and "textarea[0,1;10.5,12.2;text;;"..text.."]" or "textarea["..(textx+0.8)..",1;"..(15.8-textx)..",12.2;text;;"..text.."]button[7.6,0.3;1,1;addfor;for]tooltip[addfor;Add a for block]button[8.6,0.3;1,1;indent;_]tooltip[indent;Autoset indent spaces]")

	.."textlist["..(visualcode_enabled and 16 or 10)..",-0.3;4.1,11.7;list;"..list.."]"
	.."field[3.7,1;1.5,0.1;description;;"..description.."]tooltip[description;Item description]"
	.."field[5,1;1.5,0.1;listin;;"..listin.."]"
	.."field[6.3,1;1.5,0.1;listin2;;"..listin2.."]"
	.."label["..(textx+0.8)..",11;"..minetest.colorize("#000",err).."]"
	.."tooltip[channel;Channel]"
	.."label[6.8,-0.2;"..(limit or 0).."/10000 Events]"

	.."image_button[-0.2,0.5;0.7,0.7;default_unknown.png"..(func_info and "^[invert:r" or "")..";info;]"
	.."tooltip[info;" .. (func_info or "event: incoming variable\nevent.storage: storage\nevent.pos: incoming position\n\nrun mob.collect_objects_inside_radius_text()\nto add objects the a list of ID's and make the mob able to interact with other objects").."]"

	..visualcode

	minetest.after(0.2, function(name,showfosp)
		minetest.show_formspec(name,"cmdphone",showfosp)
	end,name,showfosp)
end

minetest.register_tool("exatec:cmdphone", {
	description = "CMD phone",
	inventory_image = "exatec_phone.png",
	groups = {store=500},
	on_use=function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local pressed
		exatec.cmdphone.user[name] = exatec.cmdphone.user[name] or {obs={}}
		if pointed_thing.type == "object" then
			local en = pointed_thing.ref:get_luaentity()
			if en and en.examob then
				exatec.cmdphone.user[name].obs[en.examob] = pointed_thing.ref
				return itemstack
			end
		elseif pointed_thing.type == "node" then
			local p = vector.round(pointed_thing.above)
			--pressed={posinput="{x="..p.x..",y="..p.y..",z="..p.z.."}"}
			pressed={posinput="vector.new("..p.x..","..p.y..","..p.z..")",nodeinput=minetest.get_node(p).name}

		end
		exatec.show_cmdphone(user,pressed)
	end,
	on_place=function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local pressed
		exatec.cmdphone.user[name] = exatec.cmdphone.user[name] or {obs={}}
		if pointed_thing.type == "node" then
			local p = vector.round(pointed_thing.under)
			--pressed={posinput="{x="..p.x..",y="..p.y..",z="..p.z.."}"}
			pressed={posinput="vector.new("..p.x..","..p.y..","..p.z..")",nodeinput=minetest.get_node(p).name}
		end
		exatec.show_cmdphone(user,pressed)
	end,
})

minetest.register_node("exatec:mindforcer", {
	description = "Mindforcer (not fully working yet)",
	tiles={"spacestuff_gen.png^[invert:rgb",
		"spacestuff_gen.png^[invert:rgb",
		"spacestuff_gen.png^[invert:rgb^exatec_wirecon.png"
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_stone_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_wire_connected=1,store=200},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 1)
		m:set_string("formspec",
			"size[8,5]" ..
			"listcolors[#77777777;#777777aa;#000000ff]"..
			"image[3.5,0;1,1;exatec_phone.png]"..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;3.5,0;1,1;]" ..
			"list[current_player;main;0,1.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return stack:get_name() == "exatec:cmdphone" and not minetest.is_protected(pos, player:get_player_name()) and stack:get_count() or 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		return not minetest.is_protected(pos, player:get_player_name()) and stack:get_count() or 0
	end,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
	exatec={
		on_wire = function(pos)
			local rad = 40
			local meta = minetest.get_meta(pos)
			if meta:get_inventory():is_empty("main") then
				return
			end
			local o = minetest.add_entity(pos,"plasma:impulse")
			local en = o:get_luaentity()
			en.end_scale = rad
			o:set_properties({textures={"default_cloud.png^[colorize:#0044cc99"}})

			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, rad/2)) do
			--	local en = ob:get_luaentity()
				if ob:is_player() and ob:get_hp() > 0 then
					local p = player_style.players[ob:get_player_name()]
					if not p.mindforcer then
						p.mindforcer = {level=0,catched=false,id=0,id2=-1}
						exatec.re_mindforcer(ob)
					elseif p.mindforcer.catched then
						return
					end

					if p.black_death_id then
						ob:hud_remove(p.black_death_id)
					end
					local l = {"11","22","33","44","55","66","77","88","99","aa","bb","cc","dd","ee","ff"}
					p.mindforcer.level = p.mindforcer.level + 1
					p.mindforcer.id = p.mindforcer.id + 1
					if p.mindforcer.level >= 15 then
						ob:set_hp(0)
						local e = minetest.add_entity(ob:get_pos(),"examobs:npc")
						local en = e:get_luaentity()
						e:set_properties({textures=ob:get_properties().textures})
						en.storage.npcname = ob:get_player_name()
						ob:set_attach(e, "",{x=0, y=0, z=0}, {x=0,y=0,z=0})
						ob:set_look_vertical(0)
						p.mindforcer.object = e
						p.mindforcer.catched=true
						return
					end

					p.black_death_id = ob:hud_add({
						hud_elem_type="image",
						scale = {x=-100, y=-100},
						name="black_death",
						position={x=0,y=0},
						text="default_gas.png^[colorize:#0044cc"..l[p.mindforcer.level],
						alignment = {x=1, y=1},
					})
				end
			end
		end
	}
})

minetest.register_on_respawnplayer(function(player)
	local p = player_style.players[player:get_player_name()]
	if p.mindforcer then
		if p.black_death_id then
			player:hud_remove(p.black_death_id)
		end
		if player:get_attach() then
			player:set_detach()
		end
		p.mindforcer = nil
	end

end)

exatec.re_mindforcer=function(player,id)
	local p = player_style.players[player:get_player_name()]
	if not (p and p.mindforcer) then
		return
	elseif p.mindforcer.catched and p.mindforcer.object and p.mindforcer.object:get_luaentity() then
		player:set_look_horizontal(p.mindforcer.object:get_rotation().y)
		minetest.after(0.5,function(player)
			exatec.re_mindforcer(player)
		end,player)
	elseif p.mindforcer.id ~= p.mindforcer.id2 then
		p.mindforcer.id2 = p.mindforcer.id
		minetest.after(1.1,function(player)
			exatec.re_mindforcer(player)
		end,player)
	else
		p.mindforcer.level = p.mindforcer.level -1
		if p.mindforcer.level <= 0 or player:get_hp() <= 0 then
			player_style.players[player:get_player_name()].mindforcer = nil
			if p.black_death_id then
				player:hud_remove(p.black_death_id)
			end
			return
		else
			local l = {"11","22","33","44","55","66","77","88","99","aa","bb","cc","dd","ee","ff"}
			if p.black_death_id then
				player:hud_remove(p.black_death_id)
			end
			p.black_death_id = player:hud_add({
				hud_elem_type="image",
				scale = {x=-100, y=-100},
				name="black_death",
				position={x=0,y=0},
				text="default_gas.png^[colorize:#0044cc"..l[p.mindforcer.level],
				alignment = {x=1, y=1},
			})
			minetest.after(0.1,function(player)
				exatec.re_mindforcer(player)
			end,player)
		end
	end
end