local count = 32

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
			"size[8,4]"
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