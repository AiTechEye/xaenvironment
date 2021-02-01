clock={}

minetest.register_craft({
	output="clock:clock1",
	recipe={
		{"group:stick","default:iron_ingot","group:stick"},
		{"group:wood","default:paper","group:wood"},
		{"group:stick","group:wood","group:stick"},
	},
})

clock.time=function(pos,s)
	local t = math.floor((minetest.get_timeofday() * 24)+0.5)
	if t > 12 then
		t = t - 12
	elseif t == 0 then
		t = 12
	end
	if t ~= s then
		local p =minetest.get_node(pos).param2
		minetest.swap_node(pos,{name="clock:clock" .. t,param2=p})
	end
end

for i=1,12 do
minetest.register_node("clock:clock" .. i, {
	description = "Clock",
	tiles={"[combine:16x16:"..((i-1)*-16)..",0=clock_anim.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png"},
	wield_image="clock.png",
	drop="clock:clock1",
	inventory_image="clock.png",
	groups = {dig_immediate=3,flammable=2,not_in_creative_inventory = i ~= 1 and 1 or nil,used_by_npc=i == 1 and 2 or nil,store= i == 1 and 170 or nil},
	sounds = default.node_sound_wood_defaults(),
	use_texture_alpha = true,
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1875, -0.4375, -0.4375, 0.1875},
			{-0.4375, -0.5, -0.3125, -0.375, -0.4375, 0.3125},
			{-0.375, -0.5, -0.375, -0.3125, -0.4375, 0.375},
			{-0.3125, -0.5, -0.4375, -0.1875, -0.4375, 0.4375},
			{-0.1875, -0.5, -0.5, 0.1875, -0.4375, 0.5},
			{0.1875, -0.5, -0.4375, 0.3125, -0.4375, 0.4375},
			{0.3125, -0.5, -0.375, 0.375, -0.4375, 0.375},
			{0.375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125},
			{0.4375, -0.5, -0.1875, 0.5, -0.4375, 0.1875},
		}
	},
	selection_box={type="fixed",fixed={-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}},
	paramtype2="wallmounted",
	paramtype = "light",
	sunlight_propagates = true,
	after_place_node = function(pos, placer, itemstack)
		minetest.rotate_node(itemstack,placer,{under=pos,above=pos})
	end,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function (pos, elapsed)
		clock.time(pos,i)
		return true
	end,
})
end