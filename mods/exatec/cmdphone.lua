exatec.cmdphone={
	user={},
}

ob_id=function(ob)
	local en = ob and ob:get_luaentity() or nil
	return en and en.examob or ob and ob:get_player_name() or nil
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "cmdphone" and (pressed.save or pressed.list or pressed.interval or pressed.setmob) then
		exatec.show_cmdphone(player, pressed)
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

	m:set_string("text",minetest.serialize(text))
	player:set_wielded_item(item)

	local list = "textlist[10,-0.3;4.1,11.5;list;"
	local c = ""
	local listn = 0
	local listin = pressed.posinput or ""
	local func_info
	local preslist = pressed.list and tonumber(pressed.list:sub(5,-1)) or -1

	text = minetest.formspec_escape(text)

	if self and pressed.save then
		self.cmdphone_error = nil
	end

	for i,ob in pairs(u.obs) do
		local en = ob:get_luaentity()
		if en and en.examob then
			mlist = mlist .. c..en.examob ..(en.storage.code_execute_interval and " on" or " off")
			c = ","
		else
			u.obs[i] = nil
		end
	end
	c = ""
	local funcs = exatec.create_env(nil,nil,self or {})
	for i,v in pairs(funcs) do
		if type(v) == "table" then
			for i2,v2 in pairs(v) do
				if type(v2) == "function" then
					list = list..c..i.."."..i2
					c=","
					listn = listn + 1
					if listn == preslist then
						func_info = funcs[i][i2.."_text"]
						listin = i.."."..i2.."()"
					end
				end
			end
		elseif type(v) == "function" then
			list = list..c..i
			c=","
			listn = listn + 1
			if listn == preslist then
				func_info = funcs[i.."_text"]
				listin = i.."()"
			end
		end
	end

	local showfosp = "size[14,11]"
	.."button[-0.2,-0.2;1,1;save;Save]"
	.."label[3.7,-0.2;"..(self and minetest.colorize("#00FF00",self.examob.." is connected") or minetest.colorize("#FFFF00","No mob connected")).."]"
	.."button[2.5,-0.2;1,1;setmob;Set]tooltip[setmob;Select mob from the list]"
	.."button[1.6,-0.2;1,1;interval;"..(self and self.storage.code_execute_interval and minetest.colorize("#00FF00","on") or minetest.colorize("#FF0000","off")).."]tooltip[interval;Code execute interval]"
	.."dropdown[1.6,0.5;2;mobs;" ..mlist..";"..(self and self.examob or "").."]"

	.."textarea[0,1;10.5,12;text;;"..text.."]"
	..list.."]"
	.."field[7,1;3,0.1;listin;;"..listin.."]"
	.."field[3.7,1;3,0.1;description;;"..description.."]tooltip[description;Item description]"
	.."label[0,11;"..err.."]"
	.."tooltip[channel;Channel]"
	.."label[6.8,-0.2;"..(limit or 0).."/10000 Events]"

	.."image_button[-0.2,0.5;0.7,0.7;default_unknown.png"..(func_info and "^[invert:r" or "")..";info;]"
	.."tooltip[info;" .. (func_info or "event: incoming variable\nevent.storage: storage\nevent.pos: incoming position\n\nrun mob.collect_objects_inside_radius_text()\nto add objects the a list of ID's and make the mob able to interact with other objects").."]"

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
			pressed={posinput="{x="..p.x..",y="..p.y..",z="..p.z.."}"}
		end
		exatec.show_cmdphone(user,pressed)
	end,
	on_place=function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local pressed
		exatec.cmdphone.user[name] = exatec.cmdphone.user[name] or {obs={}}
		if pointed_thing.type == "node" then
			local p = vector.round(pointed_thing.under)
			pressed={posinput="{x="..p.x..",y="..p.y..",z="..p.z.."}"}
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