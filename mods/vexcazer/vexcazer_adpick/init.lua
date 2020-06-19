minetest.register_alias("vex_adpick", "vexcazer_adpick:pick")

minetest.register_craft({
	output = "vexcazer_adpick:pick",
	recipe = {{"vexcazer_adpick:pick"}}})

minetest.register_tool("vexcazer_adpick:pick", {
	description ="Vexcazer adpick",
	range = 15,
	inventory_image = "vexcazer_adpick.png",
	groups = {not_in_creative_inventory = 1},
	tool_capabilities = {
		full_punch_interval = 0.20,
		max_drop_level = 3,
		groupcaps = {
			unbreakable={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			fleshy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			choppy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			bendy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			cracky={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			crumbly={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			snappy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			dig_immediate={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
		},
		damage_groups={fleshy=9000},
	},
})


vexcazer.registry_mode({
	name="Adpick",
	info="USE to get an admin pick",
	disallow_damage_on_use=true,
	hide_mode_default=true,
	hide_mode_mod=true,
	on_button=function(user,input)
		local inv=user:get_inventory()
		for i=0,32,1 do
			if inv:get_stack("main",i):get_name()=="vexcazer_adpick:pick" then
				return
			end
		end
		inv:add_item("main", "vexcazer_adpick:pick")
	end,
})