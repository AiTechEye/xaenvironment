vexcazer_telepad={reg={},tmp={},tuser={}}

-- powersaving mode in 3 steps
--checks 10 times/s 5< away
--checks 1 times/s 10< away
--checks 1 time each 2'th s >10 away
--slow down if something keep same distance it in 20s

minetest.register_craft({
	output = "vexcazer_telepad:pad",
	recipe = {
	{"default:glass","",""},
	{"default:emerald","",""},
	{"default:titaniumblock","",""}
}})

vexcazer_telepad.roundpos=function(pos)
	if not pos or not pos.x then return nil end
	return {x=vexcazer.round(pos.x),y=vexcazer.round(pos.y),z=vexcazer.round(pos.z)}
end

vexcazer_telepad.avoid=function(add,check)
	if check then
		local id1=""
		local id2=" "
		local en1=check:get_luaentity()
		if en1 then
			id1=en1.vexcazer_telepad_id
		elseif check:is_player() then
			id1=check:get_player_name()
		end
		for i, o in pairs(vexcazer_telepad.tuser) do
			local en2=o.ob:get_luaentity()
			if en2 then
				id2=en2.vexcazer_telepad_id or " "
			elseif o.ob:is_player() then
				id2=o.ob:get_player_name()
			end
			if id1==id2 then
				return true
			end

		end
		return false
	end
	if add then
		local pos=add:get_pos()
		local id=""
		if add:is_player() then
			id=add:get_player_name()
		else
			id=math.random(1,1000)
			add:get_luaentity().vexcazer_telepad_id=id
		end
		table.insert(vexcazer_telepad.tuser,{id=id,ob=add,pos=vexcazer_telepad.roundpos(pos)})
	end
	local obs=0
	for i, o in pairs(vexcazer_telepad.tuser) do
		obs=obs+1
		local p=vexcazer_telepad.roundpos(o.ob:get_pos())
		if not p or p.x~=o.pos.x or p.y~=o.pos.y or p.z~=o.pos.z then
			obs=obs-1
			if o.ob:get_luaentity() then
				o.ob:get_luaentity().vexcazer_telepad_id=nil
			end
			table.remove(vexcazer_telepad.tuser,i)
		end
	end
	if obs>0 then
		minetest.after(1, function()
			vexcazer_telepad.avoid()
		end)
	end
end

vexcazer_telepad.save=function()
	for i, v in pairs(vexcazer_telepad.reg) do
		local c
		for i, v in pairs(v) do
			c=1
		end
		if not c then
			vexcazer_telepad.reg[i]=nil
		end
	end
	local w=io.open(minetest.get_worldpath() .. "/vexcazer_telepad", "w")
	w:write(minetest.serialize(vexcazer_telepad.reg))
	w:close()
end

vexcazer_telepad.load=function()
	local r=io.open(minetest.get_worldpath() .. "/vexcazer_telepad", "r")
	if not r then return end
	local d=minetest.deserialize(r:read("*a"))
	r:close()
	if not d or d=="" then return end
	vexcazer_telepad.reg=d
end

vexcazer_telepad.load()

vexcazer_telepad.form=function(pos,name)
	vexcazer_telepad.tmp[name]=pos
	local list=""
	local meta=minetest.get_meta(pos)
	local title=meta:get_string("title")
	local sel=1
	local c=0
	local co=""

	if vexcazer_telepad.reg[name] then
		for i, v in pairs(vexcazer_telepad.reg[name]) do
			if i~=title then
				c=c+1
				if c>1 then co="," end
				list=list .. co .. i
				if i==meta:get_string("sel") then sel=c end
			end
		end
	end
	local gui=""
	.."size[3,1]"
	.."dropdown[0,-0.5;3,1;sel;" .. list.. ";" .. sel .. "]"
	.."field[0,0.5;1.5,1;title;;" .. title  .."]"
	.."button_exit[1,0.25;1,1;set;Set]"
	.."tooltip[del;Disconnect selected]"
	.."button_exit[2,0.25;1,1;del;Del]"
	
	minetest.after((0.1), function(gui)
		return minetest.show_formspec(name, "vexcazer_telepad.form",gui)
	end, gui)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="vexcazer_telepad.form" then
		local name=player:get_player_name()
		local pos=vexcazer_telepad.tmp[name]
		if pressed.del then
			if vexcazer_telepad.reg[name] then
				vexcazer_telepad.reg[name][pressed.sel]=nil
			end
			vexcazer_telepad.form(vexcazer_telepad.tmp[name],name)
			return
		elseif pressed.set then
			if not vexcazer_telepad.reg[name] then
				vexcazer_telepad.reg[name]={}
			end
			local meta=minetest.get_meta(pos)
			local reg=vexcazer_telepad.reg[name]
			local title=pressed.title

			if string.find(title,",") or (reg[title] and not (reg[title].x==pos.x and reg[title].y==pos.y and reg[title].z==pos.z)) then
				vexcazer_telepad.form(pos,name)
				return
			end

			vexcazer_telepad.reg[name][meta:get_string("title")]=nil
			vexcazer_telepad.reg[name][title]=pos

			meta:set_string("title",title)
			meta:set_string("sel",pressed.sel)
		end
		if pressed.quit then
			minetest.get_node_timer(pos):start(0.1)
			vexcazer_telepad.tmp[name]=nil
			vexcazer_telepad.save()
		end
	end
end)

minetest.register_node("vexcazer_telepad:pad", {
	description = "Teleport pad",
	tiles = {"vexcazer_telepad.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	drawtype="nodebox",
	paramtype2="facedir",
	paramtype="light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
		}
	},
	can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			if vexcazer_telepad.reg[name] then
				vexcazer_telepad.reg[name][meta:get_string("title")]=nil
				vexcazer_telepad.save()
			end
			return true
		end
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name or meta:get_string("owner")=="" or minetest.check_player_privs(name, {protection_bypass=true}) then
			vexcazer_telepad.form(pos,name)
		end
	end,
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("title","title")
		meta:set_string("sel","")
	end,
	on_timer = function (pos, elapsed)
		local d=11
		local od=11
		local meta = minetest.get_meta(pos)
		local sel=meta:get_string("sel")
		local slow=meta:get_int("slow")
		local tic=meta:get_int("tic")
		local dis=meta:get_int("dis")

		local reg=vexcazer_telepad.reg[meta:get_string("owner")]


		if not (reg and reg[sel]) then
			minetest.get_node_timer(pos):stop()
			return
		end

		for _, ob in ipairs(minetest.get_objects_inside_radius(pos,20)) do
			local opos=ob:get_pos()
			local od=vector.distance(pos, opos)
			if od<1 then
				if not vexcazer_telepad.avoid(1,ob) then
					ob:set_pos(reg[sel])
					vexcazer_telepad.avoid(ob)
				end
			end

			local p=vexcazer_telepad.roundpos(ob:get_pos())

			if od<d then
				d=od
			end
		end
		d=vexcazer.round(d)

		if slow==0 and d==dis and d<10 then
			tic=tic+1
			if tic>100 then
				tic=0
				slow=1
			end
			meta:set_int("slow",slow)
			meta:set_int("tic",tic)
		elseif d~=dis then
			tic=0
			slow=0
			meta:set_int("slow",0)
			meta:set_int("tic",0)
		end
		dis=d
		meta:set_int("dis",d)
		if d<5 and slow==0 then
			minetest.get_node_timer(pos):start(0.1)
		elseif d<10 and slow==0 then
			minetest.get_node_timer(pos):start(1)
		else
			minetest.get_node_timer(pos):start(2)
		end
end})