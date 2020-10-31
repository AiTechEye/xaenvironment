exatec.cmdphone={
	user={},
}

ob_id=function(ob)
	local en = ob and ob:get_luaentity() or nil
	return en and en.examob or ob and ob:get_player_name() or nil
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "cmdphone" and (pressed.save or pressed.run or pressed.list or pressed.interval or pressed.setmob) then
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

	local memory = 0
	
	local err = ""
	local limit = 0
	local item = player:get_wielded_item()
	local m = item:get_meta()
	local text = pressed.text or minetest.deserialize(m:get_string("text")) or ""
	local mlist = ""
	local c = ""

	if self and not pressed.run then
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

	if pressed.run and self then
		local mb = memory_mb()
		err,limit = exatec.run_code(text,{type={run=true},user=name,mob=true,self=self,pos=self and self.object and vector.round(self.object:get_pos())})
		memory = math.floor((memory_mb()-mb)*1000)/1000
		if self then
			self.cmdphone_error = nil
		end
	end
	local list = "textlist[10,-0.3;2.1,11.5;list;"
	local c = ""
	local listn = 0
	local listin = pressed.posinput or ""
	local func_info
	local preslist = pressed.list and tonumber(pressed.list:sub(5,-1)) or -1

	text = minetest.formspec_escape(text)

	if self and (pressed.run or pressed.save) then
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

	minetest.after(0.2, function(name,err,list,listin,memory,limit)
		minetest.show_formspec(name,"cmdphone","size[12,11]"
			.."button[-0.2,-0.2;1,1;save;Save]"
			.."button[0.7,-0.2;1,1;run;Run]"

			..(self and "label[3.7,0;"..minetest.colorize("#00FF00",self.examob.." is connected").."]" or "label[3.7,0;"..minetest.colorize("#FFFF00","No mob connected").."]")
			.."button[2.5,-0.2;1,1;setmob;Set]tooltip[setmob;Select mob from the list]"
			.."button[1.6,-0.2;1,1;interval;"..(self and self.storage.code_execute_interval and minetest.colorize("#00FF00","on") or minetest.colorize("#FF0000","off")).."]tooltip[interval;Code execute interval]"
			.."dropdown[1.6,0.5;2;mobs;" ..mlist..";"..(self and self.examob or "").."]"

			.."textarea[0,1;10.5,12;text;;"..text.."]"
			..list.."]"
			.."field[4,1;3,0.1;listin;;"..listin.."]"
			.."label[0,11;"..err.."]"
			.."tooltip[channel;Channel]"
			.."label[4.5,-0.3;"..memory.."MB]"
			.."label[6.5,-0.2;"..(limit or 0).."/10000 Events]"
			.."label[6.5,0.2;Incoming variable: event]"
			.."label[6.5,0.6;storage variable: storage]"

			.."image_button[-0.2,0.5;0.7,0.7;default_unknown.png"..(func_info and "^[invert:r" or "")..";info;]"
			.."tooltip[info;" .. (func_info or "event: incoming variable\nevent.storage: storage\nevent.pos: incoming position\n\nrun mob.collect_objects_inside_radius_text()\nto add objects the a list of ID's and make the mob able to interact with other objects")
		.."]")
	end,name,err,list,listin,memory,limit)
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