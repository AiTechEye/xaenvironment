local count = 40

for i = 1,count do
minetest.register_node("paintnings:paintning"..i, {
	description = "Paintning "..i,
	wield_image="paintnings_"..i..".png",
	inventory_image="paintnings_"..i..".png",
	tiles = {"paintnings_"..i..".png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2,flammable=3,not_in_creative_inventory=1},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.45, 0.5, 0.5, 0.5},
		}
	}
})
end

minetest.register_node("paintnings:frame", {
	description = "Paintning frame",
	wield_image="default_frame.png",
	inventory_image="paintnings_4.png",
	tiles = {"default_frame.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2,flammable=3},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.45, 0.5, 0.5, 0.5},
		}
	},
	on_receive_fields=function(pos, formname, pressed, sender)
		for i,v in pairs(pressed) do
			if tonumber(i) then
				local p = minetest.get_node(pos).param2
				minetest.set_node(pos,{name="paintnings:paintning"..i,param2=p})
			end
		end
	end,
	on_construct=function(pos)
		local b = ""
		local x = 0
		local y = 0
		for i=1,count do
			b = b .. "image_button["..x..","..y..";1,1;paintnings_"..i..".png;"..i..";]"
			x = x + 1
			if x >= 8 then
				x = 0
				y = y + 1
			end
		end
		minetest.get_meta(pos):set_string("formspec",
			"size[8,5]"
			.."listcolors[#77777777;#777777aa;#000000ff]"
			..b
		)
	end
})

minetest.register_craft({
	output="paintnings:frame",
	recipe={
		{"default:dye","default:stick","default:dye"},
		{"default:stick","materials:piece_of_cloth","default:stick"},
		{"default:dye","default:stick","default:dye"},
	},
})

minetest.register_craft({
	output="paintnings:tv_off",
	recipe={
		{"default:dye","materials:iron_chest","default:lamp"},
		{"materials:plastic_sheet","materials:diode","materials:plastic_sheet"},
		{"materials:plastic_sheet","default:glass_tabletop","materials:plastic_sheet"},
	},
})
minetest.register_node("paintnings:tv_off", {
	description = "TV (off)",
	tiles={"default_ironblock.png^[colorize:#000b","default_ironblock.png^[colorize:#000b","default_ironblock.png^[colorize:#000b","default_ironblock.png^[colorize:#000b","default_ironblock.png^[colorize:#000b","default_stone.png^[colorize:#000f"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2,flammable=3},
	paramtype2 = "facedir",
	on_punch=function(pos, node, player, pointed_thing)
		minetest.set_node(pos,{name="paintnings:tv_1",param2=node.param2})
	end,
	on_construct=function(pos)
		minetest.get_meta(pos):set_string("infotext","Punch toggle on/off\nClick change channel")
	end
})

for i,v in pairs({
	{t="paintnings_tv_space",w=124,h=107,sound="plasma_core_loaded",loop=1.98},
	{t="paintnings_tv_news",w=80,h=72,sound="examobs_titan_growl",loop=10,s=2},
	{t="paintnings_tv_dig",w=72,h=72,sound="default_stone_dig",loop=0.26},
	{t="paintnings_tv_icecreammonster",w=94,h=84,sound="examobs_heavy_step",loop=0.32},
	{t="paintnings_tv_ocean",w=124,h=112,sound="default_underwater",loop=5.8},
	{t="paintnings_tv_vexcazer",w=124,h=112,s=2,sound="vexcazer_lazer",loop=5},
	{t="paintnings_tv_rain",w=124,h=112,s=2,sound="weather_rain",loop=5},
}) do
minetest.register_node("paintnings:tv_"..i, {
	description = "TV",
	drop="paintnings:tv_off",
	groups = {choppy = 2, oddly_breakable_by_hand = 2,flammable=3,not_in_creative_inventory=1},
	paramtype2 = "facedir",
	light_source = 13,
	tiles={"default_ironblock.png^[colorize:#000b","default_ironblock.png^[colorize:#000b","default_ironblock.png^[colorize:#000b","default_ironblock.png^[colorize:#000b","default_ironblock.png^[colorize:#000b",
		{
			name = v.t..".png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = v.w,
				aspect_h = v.h,
				length = v.s or 1,
			}
		}
	},
	on_punch=function(pos, node, player, pointed_thing)
		minetest.set_node(pos,{name="paintnings:tv_off",param2=node.param2})
	end,
	on_rightclick=function(pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos,{name="paintnings:tv_"..(i < 7 and i+1 or 1),param2=node.param2})
	end,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(v.loop)
	end,
	on_timer = function(pos, elapsed)
		minetest.sound_play(v.sound, {pos = pos,gain = 5,max_hear_distance = 10})
		return true
	end
})
end