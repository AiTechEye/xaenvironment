bones={
	enabled=minetest.settings:get_bool("xaenvironment_itemlosing") ==  true
}


minetest.register_node("bones:boneblock", {
	description = "Bone block",
	tiles={"bones_bone1.png","bones_bone3.png","bones_bone3.png","bones_bone3.png","bones_bone2.png","bones_bone3.png"},
	groups = {dig_immediate = 3,flammable=3},
	paramtype2="facedir",
})


minetest.register_craftitem("bones:bone", {
	description = "Bone",
	inventory_image = "bones_bone.png",
	wield_scale={x=2,y=2,z=2},
})



