minetest.register_privilege("vexcazer", {
	description = "Can use moderator vexcazer",
	give_to_singleplayer= false,
})
minetest.register_privilege("vexcazer_ad", {
	description = "Can use admin vexcazer",
	give_to_singleplayer= false,
})
minetest.register_privilege("vexcazer_wo", {
	description = "Can use world vexcazer",
	give_to_singleplayer= false,
})


local colors={"FFFFFFFA","FF0000FA","ff009cFA","ff7700FA"}
local colora={{255,255,255} ,{255,0,0} ,{255,0,170},{255,119,0}}
for i=1,4,1 do
minetest.register_node("vexcazer:lazer" ..i, {
	description = "Lazer",
	drawtype="glasslike",
	alpha=50,
	tiles = {"vexcazer_background.png^[colorize:#" ..  colors[i]},
	drop="",
	light_source = 14,
	paramtype = "light",
	walkable=false,
	sunlight_propagates = true,
	liquid_viscosity = 1,
--pointable=false,
	buildable_to = true,
	groups = {not_in_creative_inventory=1,vex_lazer=1},
	post_effect_color = {a = 255, r=colora[i][1], g=colora[i][2], b=colora[i][3]},
on_punch = function(pos, node, player, pointed_thing)
	minetest.get_node_timer(pos):start(1)
end,
	on_timer=function(pos, elapsed)
		minetest.remove_node(pos)
	end,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
})
end

minetest.register_tool("vexcazer:default", {
	description = "Vexcazer",
	range = vexcazer.range.default,
	inventory_image = "vexcazer_rifle_default.png",
	on_use = function(itemstack, user, pointed_thing)
		vexcazer.use(itemstack, user, pointed_thing,{
		default=true,
		mod=false,
		admin=false,
		max_amount=vexcazer.max_amount.default,
		on_use=true,
		on_place=false,
		user=user,
		user_name=user:get_player_name(),
		index=user:get_wield_index(),
		lazer="vexcazer:lazer1"
		})
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		vexcazer.use(itemstack, user, pointed_thing,{
		default=true,
		mod=false,
		admin=false,
		max_amount=vexcazer.max_amount.default,
		on_use=false,
		on_place=true,
		user=user,
		user_name=user:get_player_name(),
		index=user:get_wield_index(),
		lazer="vexcazer:lazer1"
		})
		return itemstack
	end,
})

minetest.register_tool("vexcazer:mod", {
	description = "Vexcazer mod",
	range = vexcazer.range.mod,
	inventory_image = "vexcazer_rifle_mod.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		vexcazer.use(itemstack, user, pointed_thing,{
		default=false,
		mod=true,
		admin=false,
		max_amount=vexcazer.max_amount.mod,
		on_use=true,
		on_place=false,
		user=user,
		user_name=user:get_player_name(),
		index=user:get_wield_index(),
		lazer="vexcazer:lazer2"
		})
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		vexcazer.use(itemstack, user, pointed_thing,{
		default=false,
		mod=true,
		admin=false,
		max_amount=vexcazer.max_amount.mod,
		on_use=false,
		on_place=true,
		user=user,
		user_name=user:get_player_name(),
		index=user:get_wield_index(),
		lazer="vexcazer:lazer2"
		})
		return itemstack
	end,
})

minetest.register_tool("vexcazer:admin", {
	description = "Vexcazer admin",
	range = vexcazer.range.admin,
	inventory_image = "vexcazer_rifle_admin.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		vexcazer.use(itemstack, user, pointed_thing,{
		default=false,
		mod=false,
		admin=true,
		max_amount=vexcazer.max_amount.admin,
		on_use=true,
		on_place=false,
		user=user,
		user_name=user:get_player_name(),
		index=user:get_wield_index(),
		lazer="vexcazer:lazer3"
		})
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		vexcazer.use(itemstack, user, pointed_thing,{
		default=false,
		mod=false,
		admin=true,
		max_amount=vexcazer.max_amount.admin,
		on_use=false,
		on_place=true,
		user=user,
		user_name=user:get_player_name(),
		index=user:get_wield_index(),
		lazer="vexcazer:lazer3"
		})
		return itemstack
	end,
})

minetest.register_tool("vexcazer:world", {
	description = "Vexcazer world",
	range = vexcazer.range.admin,
	inventory_image = "vexcazer_rifle_world.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		vexcazer.use(itemstack, user, pointed_thing,{
		default=false,
		mod=false,
		admin=true,
		world=true,
		max_amount=vexcazer.max_amount.world,
		on_use=true,
		on_place=false,
		user=user,
		user_name=user:get_player_name(),
		index=user:get_wield_index(),
		lazer="vexcazer:lazer4"
		})
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		vexcazer.use(itemstack, user, pointed_thing,{
		default=false,
		mod=false,
		admin=true,
		world=true,
		max_amount=vexcazer.max_amount.world,
		on_use=false,
		on_place=true,
		user=user,
		user_name=user:get_player_name(),
		index=user:get_wield_index(),
		lazer="vexcazer:lazer4"
		})
		return itemstack
	end,
})

minetest.register_tool("vexcazer:controler", {
	description = "Vexcazer controler",
	range = 10,
	inventory_image = "vexcazer_controler.png",
	on_use = function(itemstack, user, pointed_thing)
		for i=1,8,1 do
			local stack=user:get_inventory():get_stack("main", i):get_name()
			if string.find(stack,"r:default",7) or string.find(stack,"r:mod",7) or string.find(stack,"r:admin",8) then
				vexcazer.form_update(user,i)
				return itemstack
			end
		end
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		for i=1,8,1 do
			local stack=user:get_inventory():get_stack("main", i):get_name()
			if string.find(stack,"r:default",7) or string.find(stack,"r:mod",7) or string.find(stack,"r:admin",8) then
				vexcazer.set_mode({user=user,add=1,index=i})
				return itemstack
			end
		end
		return itemstack
	end,
})