player_style.skins = {
	skins={
		{name="ASDASD",skin="character.png",cost=0,info="Default character, random made npc for aliveai",origin="Aliveai"},
		{name="Dacy",skin="player_style_dacy.png",cost=0,info="Another default character, random made npc for aliveai",origin="Aliveai"},
		{name="Villager",skin="examobs_villager.png",cost=100,info="Just another fool",origin="XaEnvironment"},
		{name="Spacesuit",skin="spacestuff_spacesuit2.png",cost=200,info="Suit used to protect against non breathable areas",origin="Marssurvive"},
		{name="Underground npc",skin="examobs_underground_npc.png",cost=300,info="An underground living thing",origin="XaEnvironment"},
		{name="Tomato NPC",skin="examobs_tomato_npc.png",cost=500,info="Tomato farmer that is farming its own family",origin="XaEnvironment"},
		{name="Terminator",skin="examobs_terminator.png",cost=2000,info="Destruction machine",origin="Aliveai"},
		{name="Gassman",skin="examobs_gassman.png",cost=1500,info="High explosive machine",origin="Aliveai"},
		{name="Air monster",skin="examobs_airmonster.png",cost=2000,info="An odd phenomenon",origin="XaEnvironment"},
		{name="Mummy",skin="pyramids_mummy.png",cost=1000,info="Living in ancient pyramids civilizations",origin="Aliveai"},
	},
}

player_style.register_button({
	name="Skins",
	image="character.png",
	type="image",
	info="Change or buy skins",
	action=function(player)
		player_style.skins.store(player)
	end
})

player_style.skins.store=function(player,scroll)
	local text = ""
	local m = player:get_meta()
	local skin = m:get_string("skin")
	local own = minetest.deserialize(m:get_string("skins")) or {}
	local y = 0
	for i,v in ipairs(player_style.skins.skins) do
		text = text
		.."label[2,"..y..";"..v.name..(v.origin and (" - " ..v.origin) or "").."]"
		.."label[2,"..(y+0.5)..";"..v.info.."]"
		.."model[-0.5,"..y..";2,3;preskin;character.b3d;"..v.skin..";0,180;false;true;1,31]"
		if skin == v.skin then
		elseif own[v.name] then
			text = text .."button[1.2,"..y..";1,1;skinuse="..i..";Use]"
		else
			text = text .."image_button[1.2,"..y..";1,1;player_style_coin.png;skinbuy="..i..";"..(v.cost > 0 and v.cost or "Free").."]"
		end
		y = y +3
	end
	return minetest.show_formspec(player:get_player_name(), "player_style_skins",
		"size[8,8]" 
		.."listcolors[#77777777;#777777aa;#000000ff]"
		.."label[6,-0.35;"..minetest.colorize("#FFFF00",m:get_int("coins")).."]"
		.."scrollbaroptions[max="..((#player_style.skins.skins-3)*36)..";]"
		.."scrollbar[7.5,0;0.5,8;vertical;scrollbar;"..(scroll or 0).."]"
		.."scroll_container[0,0;9,10;scrollbar;vertical]"
		..text
		.."scroll_container_end[scrollbar]"
	)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "player_style_skins" then
		local name = player:get_player_name()
		if pressed.quit then
			return
		end
		for i,v in pairs(pressed) do
			local index = i:sub(1,8)
			if index == "skinbuy=" then
				local m = player:get_meta()
				local v = player_style.skins.skins[tonumber(i:sub(9,-1))]
				if m:get_int("coins") >= v.cost then
					local own = minetest.deserialize(m:get_string("skins")) or {}
					own[v.name] = true
					m:set_string("skins", minetest.serialize(own))
					m:set_int("coins",m:get_int("coins")-v.cost)
					index = "skinuse_after_buy"
				end
			end
			if index == "skinuse=" or index == "skinuse_after_buy" then
				local m = player:get_meta()
				local textures = player:get_properties().textures
				local skin = m:get_string("skin")
				local v = player_style.skins.skins[tonumber(i:sub(9,-1))]
				if textures[1] == skin or skin == "" then
					textures[1] = v.skin
					player:set_properties({textures=textures})
				elseif index == "skinuse_after_buy" then
					minetest.chat_send_player(player:get_player_name(),"Please take off your suit/armor/stuff that effects your skin and try again (to avoid bugs) or wait until next restart")
				end
				m:set_string("skin",v.skin)
				local scbv = minetest.explode_scrollbar_event(pressed.scrollbar).value or 0
				player_style.inventory(player)
				player_style.skins.store(player,scbv)
				break
			end
		end
	end
end)