Coin=function(player,count)
	local m = player:get_meta()
	m:set_int("coins",m:get_int("coins")+count)
end

minetest.register_on_newplayer(function(player)
	player:get_inventory():add_item("main","default:craftguide")
	player:get_meta():set_string("spawn_position",minetest.pos_to_string(player:get_pos()))
end)

apos=function(pos,x,y,z)
	return {x=pos.x+(x or 0),y=pos.y+(y or 0),z=pos.z+(z or 0)}
end

memory_mb=function()
	return string.format("%.03f",collectgarbage("count")/1000)
end

minetest.register_on_dieplayer(function(player)
	local name = player:get_player_name()
	if default.on_player_death[name] then
		for i,v in pairs(default.on_player_death[name]) do
			if type(v) == "function" then
				v(player)
			end
		end
	end
	default.on_player_death[name] = nil
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if default.on_player_death[name] then
		if type(default.on_player_death[name]) == "function" then
			default.on_player_death[name]()
		end
		default.on_player_death[name] = nil
	end
end)

minetest.register_on_respawnplayer(function(player)
	minetest.after(0, function(player)
		player:get_meta():set_string("spawn_position",minetest.pos_to_string(player:get_pos()))
	end,player)
end)

default.respawn_player=function(player,drop_bones)
	if drop_bones then
		bones.corpses[player:get_player_name()] = nil
		bones.drop(player)
	end
	player:set_hp(20)
	player:set_breath(11)
	player_style.respawn(player)
	local p = player:get_pos()
	beds.respawn(player)
	if vector.distance(p,player:get_pos()) < 0.1 then
		local ssp = minetest.settings:get("static_spawnpoint")
		if ssp then
			player:set_pos(minetest.string_to_pos(ssp))
			return
		else
			local sp = player:get_meta():get_string("spawn_position")
			if sp ~= "" then
				player:set_pos(minetest.string_to_pos(sp))
			else
				player:set_hp(0)
			end
		end
	end
end

if default.creative then
	local ohnd = minetest.handle_node_drops
	minetest.handle_node_drops=function(pos,drops,digger)
		if not (digger and digger:is_player()) then
			return ohnd(pos,drops,digger)
		end
		local inv = digger:get_inventory()
		for i,v in pairs(drops) do
			if not inv:contains_item("main",v) then
				inv:add_item("main",v)
			end
		end
	end
end

minetest.register_on_placenode(function(pos,node,placer,pointed_thing)
	return default.creative
end)

default.get_on_player_death=function(name,event)
	local a = default.on_player_death[name] or {}
	return a[event]
end

default.set_on_player_death=function(name,event,value)
	default.on_player_death[name] = default.on_player_death[name] or {}
	default.on_player_death[name][event]=value
end


--||||||||||||||||
-- ======================= Sounds
--||||||||||||||||

default.node_sound_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "", gain = 1}
	a.dig =		a.dig or {name = "", gain = 1}
	a.dug =		a.dig or {name = "", gain = 1}
	a.place =		a.place or {name = "default_place", gain = 1}
	return a
end

default.node_sound_stone_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_stone_step", gain = 1}
	a.dig =		a.dig or {name = "default_stone_dig", gain = 1}
	a.dug =		a.dug or {name = "default_stone_dug", gain = 1}
	a.place =		a.place or {name = "default_place_hard", gain = 1}
	return a
end

default.node_sound_wood_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_wood_step", gain = 1}
	a.dig =		a.dig or {name = "default_wood_dig", gain = 1}
	a.dug =		a.dug or {name = "default_wood_dug", gain = 1}
	a.place =		a.place or {name = "default_place_hard", gain = 1}
	return a
end

default.node_sound_water_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_water_step", gain = 1}
	return a
end

default.node_sound_metal_defaults=function(a)
	a = a or {}
	a.dig =		a.dig or {name = "default_metal_dig", gain = 1}
	a.dug =		a.dug or {name = "default_metal_dug", gain = 1}
	a.place =		a.place or {name = "default_metal_place", gain = 1}
	return default.node_sound_stone_defaults(a)
end

default.node_sound_dirt_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_leaves_step", gain = 1}
	a.dig =	a.footstep or {name = "default_leaves_step", gain = 1}
	a.dug =		a.dug or {name = "default_leaves_dug", gain = 1}
	a.place =		a.place or {name = "default_place", gain = 1}
	return a
end


default.node_sound_leaves_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_leaves_step", gain = 1}
	a.dig =		a.footstep or {name = "default_leaves_step", gain = 1}
	a.dug =		a.dug or {name = "default_leaves_dug", gain = 1}
	a.place =		a.place or {name = "default_place", gain = 1}
	return a
end

default.node_sound_gravel_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_gravel_step", gain = 1}
	a.dig =		a.dig or {name = "default_gravel_step", gain = 1}
	a.dug =		a.dug or {name = "default_gravel_place", gain = 1}
	a.place =		a.place or {name = "default_gravel_place", gain = 1}
	return a
end

default.node_sound_glass_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_stone_step", gain = 1}
	a.dig =		a.dig or {name = "default_glass_dig", gain = 1}
	a.dug =		a.dug or {name = "default_break_glass", gain = 1}
	a.place =		a.place or {name = "default_place_hard", gain = 1}
	return a
end

default.node_sound_clay_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_clay_step", gain = 1}
	a.dig =		a.dig or {name = "default_clay_step", gain = 1}
	a.dug =		a.dug or {name = "default_clay_step", gain = 1}
	a.place =		a.place or {name = "default_place", gain = 1}
	return a
end

default.node_sound_snow_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_snow_step", gain = 1}
	a.dig =		a.dig or {name = "default_snow_step", gain = 1}
	a.dug =		a.dug or {name = "default_snow_step", gain = 1}
	a.place =		a.place or {name = "default_place", gain = 1}
	return a
end

default.node_sound_sand_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_sand_step", gain = 1}
	a.dig =		a.dig or {name = "default_sand_dig", gain = 1}
	a.dug =		a.dug or {name = "default_sand_dig", gain = 1}
	a.place =		a.place or {name = "default_place", gain = 1}
	return a
end

default.tool_breaks_defaults=function(a)
	a = a or {}
	a.breaks =	"default_tool_breaks"
	return a
end

default.date=function(a,c)
	if a=="get" then
		return os.time()
	else
		if a=="s" then
			return os.difftime(os.time(), c)
		elseif a=="m" then
			return os.difftime(os.time(), c) / 60
		elseif a=="h" then
			return os.difftime(os.time(), c) / (60 * 60)
		elseif a=="d" then
			return os.difftime(os.time(), c) / (24 * 60 * 60)
		end
	end
end

default.defpos=function(pos,n)
	local no = minetest.registered_nodes[minetest.get_node(pos).name]
	return no and no[n] or nil
end

default.def=function(name)
	return minetest.registered_items[name] or {}
end

default.defname=function(name,n)
	local no = minetest.registered_items[name]
	return no and no[n] or nil
end

default.register_eatable=function(kind,name,hp,gaps,def)
	def.groups = def.groups or {}
	def.groups.eatable=hp
	def.groups.gaps=gaps
	def.groups.wet=def.wet or -0.1
	local on_eat = def.on_eat or function() end
	if gaps > 1 then
		def.on_use=function(itemstack, user, pointed_thing)
			local eat = 65536/gaps
			minetest.sound_play("default_eat", {to_player=user:get_player_name(), gain = 1})
			if not minetest.registered_tools[itemstack:get_name()] then
				local item = ItemStack(itemstack:get_name() .."_eaten")
				local c = itemstack:get_count()
				item = item:to_table()
				item.metadata = minetest.serialize({eat = eat})
				item.wear = eat
				minetest.do_item_eat(hp,nil,itemstack,user,pointed_thing)
				if c > 1 then
					user:get_inventory():add_item("main",item)
				else
					itemstack:replace(item)
				end
				on_eat(itemstack, user, pointed_thing)
				return itemstack
			else
				local item = itemstack:to_table()
				local meta = minetest.deserialize(item.metadata)
				if not meta then
					meta = {eat = eat}
					item.metadata = minetest.serialize({eat = eat})
					itemstack:replace(item)
				end
				minetest.do_item_eat(hp,nil,ItemStack(itemstack:get_name()),user,pointed_thing)
				itemstack:add_wear(meta.eat)
				on_eat(itemstack, user, pointed_thing)
				return itemstack
			end
		end

	else
		def.on_use=function(itemstack, user, pointed_thing)
			minetest.sound_play("default_eat", {to_player=user:get_player_name(), gain = 1})
			on_eat(itemstack, user, pointed_thing)
			itemstack:take_item()
			return itemstack
		end
	end

	if kind == "node" then
		def.groups.dig_immediate=3
	end

	minetest["register_" .. kind](name, def)

if gaps > 1 then
	if kind ~= "tool" then
		local groups = table.copy(def.groups)
		groups.not_in_creative_inventory = 1
		minetest.register_tool(def.name .. "_eaten", {
			description = def.description,
			inventory_image = def.inventory_image or def.tiles[1],
			groups = groups,
			on_use = def.on_use
		})	
	end
end
end

default.registry_mineral=function(def)
	local uname = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local mod = minetest.get_current_modname() ..":"
	if not def.not_lump then
		def.lump = def.lump or {}
		def.drop = mod .. def.name .. "_lump"
		def.lump.description = def.lump.description or 		uname .." lump"
		def.lump.inventory_image = def.lump.inventory_image or def.texture .. "^default_alpha_lump.png^[makealpha:0,255,0"
		minetest.register_craftitem(mod .. def.name .. "_lump", def.lump)
	elseif def.drop then
		if def.drop.name then
			def.drop.name = mod .. def.drop.name
		else
			def.drop.name =  mod .. def.name
		end
		if not def.drop.inventory_image:find(".png") then
			def.drop.inventory_image = def.texture .. "^default_alpha_gem_" .. def.drop.inventory_image ..".png^[makealpha:0,255,0"
		end
		def.dropingot = def.drop.name
		def.drop.description = def.drop.description or 		uname
		minetest.register_craftitem(def.drop.name, def.drop)
		def.drop = def.drop.name
	end
--ingot
	if not def.not_ingot then
		def.ingot = def.ingot or {}
		def.dropingot = mod .. def.name .. "_ingot"
		def.ingot.description = def.ingot.description or 		uname .." ingot"
		def.ingot.inventory_image = def.texture .. "^default_alpha_ingot.png^[makealpha:0,255,0"
		minetest.register_craftitem(mod .. def.name .. "_ingot", def.ingot)
		if not def.not_ingot_craft and def.lump then
			minetest.register_craft({
				type = "cooking",
				output = mod .. def.name .. "_ingot",
				recipe = mod .. def.name .. "_lump",
				cooktime = 10,
			})
		end
	end

	if def.craftitem then
		def.dropingot = def.craftitem
	end

--block
	if not def.not_block then
		def.block = def.block or {}
		def.block.tiles =	def.block.tiles or	{def.texture}
		def.block.description =	def.block.description or	uname .. "block"
		def.block.sounds =	def.block.sounds or	default.node_sound_metal_defaults()
		def.block.groups =	def.block.groups or	{cracky=2}
		minetest.register_node(mod .. def.name .."block", def.block)
		if not def.not_block_craft and def.dropingot then
			minetest.register_craft({
				output=mod .. def.name .."block",
				recipe={
					{def.dropingot,def.dropingot,def.dropingot},
					{def.dropingot,def.dropingot,def.dropingot},
					{def.dropingot,def.dropingot,def.dropingot},
				},
			})
			minetest.register_craft({
				output=def.dropingot .. " 9",
				recipe={{mod .. def.name .."block"},},
			})
		end
	end
--ore
	if not def.not_ore then
		def.ore = def.ore or {}
		def.ore.drop = def.ore.drop or def.drop
		def.ore.tiles =	def.ore.tiles or			{def.texture .. "^default_alpha_ore.png"}
		def.ore.description =	def.ore.description or	uname .. " ore"
		def.ore.sounds =	def.ore.sounds or	default.node_sound_stone_defaults()
		def.ore.groups =	def.ore.groups or	{cracky=2}

		minetest.register_node(mod .. def.name .. "_ore", def.ore)
	end
--ore settings
	if not def.not_ore or (def.ore_settings and def.ore_settings.ore) then
		def.ore_settings = def.ore_settings or {}
		minetest.register_ore({
			ore_type		=	"scatter",
			ore		=	def.ore_settings.ore or		mod .. def.name .. "_ore",
			wherein		=	def.ore_settings.wherein or		"default:stone",
			clust_scarcity	=	def.ore_settings.clust_scarcity or	8 * 8 * 8,
			clust_num_ores	=	def.ore_settings.clust_num_ores or	5,
			clust_size		=	def.ore_settings.clust_size	or	5,
			y_min		=	def.ore_settings.y_min	or	-31000,
			y_max		=	def.ore_settings.y_max	or	-50,
		})
	end


--pick
	if not def.not_pick then
		def.pick = def.pick or {}
		def.pick.groups = def.pick.groups or {not_regular_craft=1}
		def.pick.sound = default.tool_breaks_defaults()
		def.pick.description = def.pick.description or 		 uname .." pickaxe"
		def.pick.inventory_image = def.pick.inventory_image or	def.texture .. "^default_alpha_pick.png^[makealpha:0,255,0"
		def.pick.tool_capabilities = def.pick.tool_capabilities or		{
			full_punch_interval = 1,
			max_drop_level = 0,
			groupcaps = {
				cracky={times={[3]=1.5},uses=20,maxlevel=1}
			},
			damage_groups={fleshy=2}
		}
		minetest.register_tool(mod .. def.name .. "_pick", def.pick)
		minetest.register_craft({
			output=mod .. def.name .. "_pick",
			recipe={
				{def.dropingot,def.dropingot,def.dropingot},
				{"","group:stick",""},
				{"","group:stick",""},
			},
		})
	end
--shovel
	if not def.not_shovel then
		def.shovel = def.shovel or {}
		def.shovel.groups = def.shovel.groups or {not_regular_craft=1}
		def.shovel.description = def.shovel.description or 			uname .." shovel"
		def.shovel.inventory_image = def.shovel.inventory_image or	def.texture .. "^default_alpha_shovel.png^[makealpha:0,255,0"
		def.shovel.sound = default.tool_breaks_defaults()
		def.shovel.tool_capabilities = def.shovel.tool_capabilities or		{
			full_punch_interval = 1.1,
			max_drop_level = 0,
			groupcaps = {
				crumbly={times={[1]=1.9,[2]=1.4,[3]=0.6},uses=20,maxlevel=1},
			},
			damage_groups={fleshy=1},
		}
		minetest.register_tool(mod .. def.name .. "_shovel", def.shovel)
		minetest.register_craft({
			output=mod .. def.name .. "_shovel",
			recipe={
				{"",def.dropingot,""},
				{"","group:stick",""},
				{"","group:stick",""},
			},
		})
	end
--axe
	if not def.not_axe then
		def.axe = def.axe or {}
		def.axe.groups = def.axe.groups or {not_regular_craft=1}
		def.axe.sound = default.tool_breaks_defaults()
		def.axe.description = def.axe.description or 			uname .." axe"
		def.axe.inventory_image = def.axe.inventory_image or	def.texture .. "^default_alpha_axe.png^[makealpha:0,255,0"
		def.axe.tool_capabilities = def.axe.tool_capabilities or		{
			full_punch_interval = 1,
			max_drop_level = 0,
			groupcaps = {
				choppy={times={[1]=2,[2]=1.9,[3]=1.2},uses=20,maxlevel=1},
			},
			damage_groups={fleshy=2},
		}
		minetest.register_tool(mod .. def.name .. "_axe", def.axe)
		minetest.register_craft({
			output=mod .. def.name .. "_axe",
			recipe={
				{def.dropingot,def.dropingot,""},
				{def.dropingot,"group:stick",""},
				{"","group:stick",""},
			},
		})
	end
--vineyardknife
	if not def.not_vineyardknife then
		def.vineyardknife = def.vineyardknife or {}
		def.vineyardknife.groups = def.vineyardknife.groups or {not_regular_craft=1}
		def.vineyardknife.sound = default.tool_breaks_defaults()
		def.vineyardknife.description = def.vineyardknife.description or 		uname .." vineyardknife"
		def.vineyardknife.inventory_image = def.vineyardknife.inventory_image or	def.texture .. "^default_alpha_vineyardknife.png^[makealpha:0,255,0"
		def.vineyardknife.tool_capabilities = def.vineyardknife.tool_capabilities or		{
			full_punch_interval = 0.5,
			max_drop_level = 0,
			groupcaps = {
				snappy={times={[1]=1.5,[2]=1,[3]=0.5},uses=20,maxlevel=1},
			},
			damage_groups={fleshy=2},
		}
		minetest.register_tool(mod .. def.name .. "_vineyardknife", def.vineyardknife)
		minetest.register_craft({
			output=mod .. def.name .. "_vineyardknife",
			recipe={
				{"",def.dropingot,def.dropingot},
				{"","",def.dropingot},
				{"","group:stick",""},
			},
		} )
	end
--hoe
	if not def.not_hoe then
		def.hoe = def.hoe or {}
		def.hoe.groups = def.hoe.groups or {not_regular_craft=1}
		def.hoe.sound = default.tool_breaks_defaults()
		def.hoe.description = def.hoe.description or 		uname .." hoe"
		def.hoe.inventory_image = def.hoe.inventory_image or	def.texture .. "^default_alpha_hoe.png^[makealpha:0,255,0"
		def.hoe.tool_capabilities = def.tool_capabilities or		{
			full_punch_interval = 2,
			damage_groups={fleshy=5},
		}
		local uses = (def.hoe.uses or 5) - 1
		def.hoe.on_place=function(itemstack, user, pointed_thing)
			local pos = pointed_thing.under
			if pos
			and not minetest.is_protected(pos,user:get_player_name())
			and minetest.get_item_group(minetest.get_node(pos).name,"soil") > 0
			and minetest.find_node_near(pos,7,{"group:water"}) then
				minetest.set_node(pos,{name="default:wet_soil"})
				local pos2 = {x=pos.x,y=pos.y+1,z=pos.z}
				local n2 = minetest.get_node(pos2).name
				if minetest.get_item_group(n2,"plant") > 0 and not minetest.is_protected(pos2,user:get_player_name()) then
					minetest.add_item(pos2,n2)
					minetest.remove_node(pos2)
				end
				itemstack:add_wear(math.floor(65535/uses))
				return itemstack
			end
		end

		minetest.register_tool(mod .. def.name .. "_hoe", def.hoe)
		minetest.register_craft({
			output=mod .. def.name .. "_hoe",
			recipe={
				{def.dropingot,def.dropingot,""},
				{"","group:stick",""},
				{"","group:stick",""},
			},
		})
	end
--bow
	if not def.not_bow then
		def.bow = def.bow or {}

		local item = def.dropingot or (not def.not_ingot and mod .. def.name .. "_ingot") or (not def.not_lump and mod .. def.name .. "_lump") or (not def.not_block and mod .. def.name .."block")

		bows.register_bow(def.bow.name or def.name,{
			description=def.bow.description or def.name.upper(def.name:sub(1,1)) .. def.name:sub(2,-1) .." bow",
			texture=def.texture,
			groups = def.bow.groups or {not_regular_craft=1},
			uses=def.bow.uses or 50,
			level=def.bow.level or 1,
			shots=def.bow.shots or 1,
			craft = def.bow.craft or {{"",item,"materials:string"},{item,"","materials:string"},{"",item,"materials:string"}},
		})
	end
--arrow
	if not def.not_arrow then
		def.arrow = def.arrow or {}
		bows.register_arrow(def.arrow.name or def.name,{
			description=def.arrow.description or def.name.upper(def.name:sub(1,1)) .. def.name:sub(2,-1) .." arrow",
			texture=def.texture,
			damage=def.arrow.damage or 1,
			craft_count=def.arrow.craft_count or 8,
			groups = def.arrow.groups,
			on_hit_node=def.arrow.on_hit_node,
			on_hit_object=def.arrow.on_hit_object,
			craft=def.arrow.craft or {{"group:arrow", def.dropingot or (not def.not_ingot and mod .. def.name .. "_ingot") or (not def.not_lump and mod .. def.name .. "_lump") or (not def.not_block and mod .. def.name .."block")}}
		})
	end

	if def.additional_craft then
		for _,c in pairs(def.additional_craft) do
			minetest.register_craft(c)
		end
	end
end

default.registry_bucket=function(node_name)
	local mod = minetest.get_current_modname() ..":"
	local def = minetest.registered_nodes[node_name]
	if not def then
		error("bucket: " .. node_name .." is not a valid node")
		return
	end
	local tan = mod .. "tankstorage_with_" .. string.sub(node_name,string.find(node_name,":")+1,-1)
	local buk = mod .. "bucket_with_" .. string.sub(node_name,string.find(node_name,":")+1,-1)
	local tex = (def.inventory_image ~="" and def.inventory_image) or (type(def.tiles[1]) == "string" and def.tiles[1]) or (type(def.tiles[1])=="table" and def.tiles[1].name) or "default_grass.png"

	minetest.register_tool(buk, {
		description = "Bucket of " .. def.description,
		inventory_image = tex .. "^default_alpha_bucket.png^[makealpha:0,255,0",
		groups = {bucket=1,bucket_water=minetest.get_item_group(node_name,"water") > 0 and 1 or nil},
		liquids_pointable = true,
		on_place = function(itemstack, user, pointed_thing)
			local p = pointed_thing
			local n = user:get_player_name()
			if p.type == "node" then
				local no = minetest.get_node(p.under)
				if default.defpos(p.under,"buildable_to") and not minetest.is_protected(n,p.under) then
					minetest.set_node(p.under,{name=node_name})
				elseif (no.name == "default:tankstorage" or no.name == tan) and no.param2 < 56 then
					minetest.set_node(p.under,{name=tan,param2=no.param2+7})
					minetest.get_meta(p.under):set_string("bucket",buk)
				elseif default.defpos(p.above,"buildable_to") and not minetest.is_protected(n,p.above) then
					minetest.set_node(p.above,{name=node_name})
				else
					return itemstack
				end
				itemstack:replace(ItemStack("default:bucket"))
				return itemstack
			end
		end,
	})
	default.bucket[node_name] = buk

	minetest.register_node(tan, {
		description = "Tankstorage of ".. def.description,
		drop = "default:tankstorage",
		tiles={"default_glass_with_frame.png","default_glass.png"},
		special_tiles={tex},
		groups = {glass=1,cracky=3,oddly_breakable_by_hand=3,tankstorage=2,not_in_creative_inventory=1,used_by_npc=1},
		sounds = default.node_sound_glass_defaults(),
		drawtype = "glasslike_framed",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "glasslikeliquidlevel",
		light_source = def.light_source,
		can_dig = function(pos, player)
			return minetest.get_node(pos).param2 == 0
		end
	})

end

default.wieldlight=function(name,i,item)
	local user = minetest.get_player_by_name(name)
	if user then
		local pos = user:get_pos()
		pos.y = pos.y + 0.5
		local n = minetest.get_node(pos)
		if (n.name == "air" or n.name == "default:lightsource") and user:get_wield_index() == i and user:get_wielded_item():get_name() == item and (minetest.get_node_light(pos) or 0) < 11 then
			minetest.set_node(pos,{name="default:lightsource"})
			minetest.after(0.3, function(name,i,item)
				default.wieldlight(name,i,item)
			end,name,i,item)
		end
	end
end

default.punch_pos=function(pos,damage,even_items)
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos,1)) do
		local en = ob:get_luaentity()
		if even_items or not (en and en.itemstring) then
			default.punch(ob,ob,damage)
		end
	end
end

default.punch=function(target,puncher,damage)
	if type(puncher)=="table" and puncher.object then puncher=puncher.object end
	target:punch(puncher,1,{full_punch_interval=1,damage_groups={fleshy=damage}})
end

default.take_item=function(clicker)
	local i = clicker:get_wield_index()
	local item = clicker:get_inventory():get_stack("main",i)
	item:take_item()
	clicker:get_inventory():set_stack("main",i,item)
end

default.dye_texturing=function(i,def)
	def = def or {}
	def.opacity = def.opacity or 150
	def.image_w = def.image_w or 16
	def.image_h = def.image_h or 16
	def.palette_w = def.palette_w or 7
	def.palette = def.palette or "default_palette.png"
	i = i or 1
	local x = 1
	local y = 0
	local gx = def.palette_w*-1
	for ii=0,i do
		x = x - 1
		if x == gx then
			x = 0
			y = y -1
		end
	end
	return "([combine:1x1:"..x..","..y.."="..def.palette.."^[opacity:"..def.opacity.."^[resize:"..def.image_w.."x"..def.image_h..")"
end

default.dye_coloring=function(pos, node, player, pointed_thing)
	if not minetest.is_protected(pos,player:get_player_name()) and player:get_wielded_item():get_name() == "default:dye" then
		local color = player:get_wielded_item():to_table()
		default.take_item(player)
		if not color.meta.palette_index then
			return
		end
		minetest.swap_node(pos,{name=node.name,param2=color.meta.palette_index or 1})
	end
end

default.treasure=function(def)
	local items={}
	def.node = def.node or "default:chest"
	def.level = def.level or 1

	if def.levels then
		for i,v in pairs(minetest.registered_items) do
			if v.groups and v.groups.treasure then
				for i1,v2 in pairs(def.levels) do
					if v.groups.treasure == v2 then
						table.insert(items,i)
					end
				end
			end
		end
	elseif def.level > 1 then
		for i,v in pairs(minetest.registered_items) do
			if v.groups and v.groups.treasure and v.groups.treasure == def.level then
				table.insert(items,i)
			end
		end
	elseif not def.items then
		for i,v in pairs(minetest.registered_items) do
			if v.groups and v.groups.treasure and v.groups.treasure == 1 then
				table.insert(items,i)
			end
		end
	else
		items = def.items
	end
	if type(def.node) == "table" then
		minetest.set_node(def.pos,def.node)
	else
		minetest.set_node(def.pos,{name=def.node})
	end
	local m = minetest.get_meta(def.pos):get_inventory()
	local size = m:get_size("main")
	local its = #items

	for i=1,size do
		if math.random(1,def.chance or math.floor(size/4)) == 1 then
			m:set_stack(def.list or "main",i,items[math.random(1,its)].." ".. math.random(1,10))
		end
	end
end