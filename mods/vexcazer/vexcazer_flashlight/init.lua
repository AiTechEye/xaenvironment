vexcazer_flashlight={users={},timer=0}

minetest.register_on_leaveplayer(function(player)
	local name=player:get_player_name()
	if vexcazer_flashlight.users[name]~=nil then vexcazer_flashlight.users[name]=nil end
end)

vexcazer.registry_mode({
	name="Flashlight",
	info="USE = on\nPLACE = off\nIt works in water and turns off in light",
	wear_on_use=3,
	on_use=function(itemstack, user, pointed_thing,input)
		vexcazer_flashlight.users[input.user_name]={player=user,slot=input.index,inside=0,item=user:get_inventory():get_stack("main", input.index):get_name()}
	end,
	on_place=function(itemstack, user, pointed_thing,input)
		vexcazer_flashlight.users[input.user_name]=nil
	end,
})

minetest.register_node("vexcazer_flashlight:flht", {
	description = "Flashlight source",
	light_source = 12,
	paramtype = "light",
	walkable=false,
	drawtype = "airlike",
	pointable=false,
	buildable_to=true,
	sunlight_propagates = true,
	groups = {not_in_creative_inventory=1},
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(1.5)
	end,
	on_timer = function (pos, elapsed)
		minetest.set_node(pos, {name="air"})
	end,
})


minetest.register_node("vexcazer_flashlight:flhtw", {
	description = "Water light",
	drawtype = "liquid",
	tiles = {"vexcazer_background.png^[colorize:#2a80e7aa"},
	alpha = 160,
	light_source = 12,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	drop = "",
	liquid_viscosity = 1,
	liquidtype = "source",
	liquid_alternative_flowing="vexcazer_flashlight:flhtw",
	liquid_alternative_source="vexcazer_flashlight:flhtw",
	liquid_renewable = false,
	liquid_range = 0,
	drowning = 1,
	sunlight_propagates = true,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, puts_out_fire = 1,not_in_creative_inventory=1},
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(1.5)
	end,
	on_timer = function (pos, elapsed)
		minetest.set_node(pos, {name="air"})
	end,
})

minetest.register_globalstep(function(dtime)
	vexcazer_flashlight.timer=vexcazer_flashlight.timer+dtime
	if vexcazer_flashlight.timer>1 then
		vexcazer_flashlight.timer=0
		for i,ob in pairs(vexcazer_flashlight.users) do
			local name=ob.player:get_inventory():get_stack("main", ob.slot):get_name()
			local pos=ob.player:get_pos()
			pos.y=pos.y+1.5
			local n=minetest.get_node(pos).name
			local light=minetest.get_node_light(pos)
			if light==nil then
				vexcazer_flashlight.users[i]=nil
				return false
			end
			if ob.inside>10 or name==nil or name~=ob.item or minetest.get_node_light(pos)>12 then
				vexcazer_flashlight.users[i]=nil
			elseif n=="air" or n=="vexcazer_flashlight:flht" then
				minetest.set_node(pos, {name="vexcazer_flashlight:flht"})
			elseif minetest.get_node_group(n, "water")>0 then
				minetest.set_node(pos, {name="vexcazer_flashlight:flhtw"})
			else
				ob.inside=ob.inside+1
			end
		end
	end
end)
