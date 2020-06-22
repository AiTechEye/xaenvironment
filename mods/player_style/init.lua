player_style={
	players={},
	buttons={text="",num=0,action={}},
	registered_profiles={},
	player_attached={},
	player_dive = {},
	player_running = {},
	player_tired = {},
	creative = minetest.settings:get_bool("creative_mode") == true,
	damage = minetest.settings:get_bool("enable_damage") == true,
	survive_thirst = minetest.settings:get_bool("xaenvironment_thirst") ~= false,
	survive_hunger = minetest.settings:get_bool("xaenvironment_hunger") ~= false,
	survive_fall_damage = minetest.settings:get_bool("xaenvironment_quadruplet_fall_damage") ~= false,
	survive_black_death = minetest.settings:get_bool("xaenvironment_black_death") ~= false,
}

if player_style.damage == false then
	player_style.survive_thirst = false
	player_style.survive_hunger = false
end

dofile(minetest.get_modpath("player_style") .. "/inv.lua")
dofile(minetest.get_modpath("player_style") .. "/stuff.lua")

player_style.drinkable=function(pos,player)
	return minetest.get_item_group(minetest.get_node(pos).name,"drinkable") > 0 and not minetest.is_protected(pos,player and player:get_player_name() or "") 
end

minetest.register_on_craft(function(itemstack,player,old_craft_grid,craft_inv)
	player_style.thirst(player,-0.05)
	player_style.hunger(player,-0.05)
end)

minetest.register_on_punchnode(function(pos,node,puncher,pointed_thing)
	if player_style.survive_thirst and (player_style.drinkable(pointed_thing.above,puncher) or player_style.drinkable(pointed_thing.under,puncher)) then
		player_style.thirst(puncher,1)
	else
		player_style.hunger(puncher,-0.01)
	end
end)

minetest.register_on_item_eat(function(hp_change,replace_with_item,itemstack,user,pointed_thing)
	player_style.hunger(user,hp_change)
	local wet = minetest.get_item_group(itemstack:get_name(),"wet") - minetest.get_item_group(itemstack:get_name(),"dry")
	if wet ~= 0 then
		 player_style.thirst(user,wet)
	end
end)

minetest.register_on_player_hpchange(function(player,hp_change,modifer)
	if player and modifer.type == "fall" and player_style.survive_fall_damage == true then
		hp_change = hp_change*4
		if hp_change < 0 then
			player_style.hunger(player,-1)
		end
	end
	if player and hp_change < 0 then
			minetest.sound_play("default_hurt", {to_player=player:get_player_name(), gain = 2})
	end
	return hp_change
end,true)

minetest.register_on_dieplayer(function(player)
	local p = player_style.players[player:get_player_name()]
	if player_style.survive_black_death and not p.black_death_id then
		p.black_death_id = player:hud_add({
			hud_elem_type="image",
			scale = {x=-100, y=-100},
			name="black_death",
			position={x=0,y=0},
			text="player_style_black.png",
			alignment = {x=1, y=1},
		})
	end
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	player_style.player_attached[name] = nil
	player_style.set_animation(name,"stand")
	player_style.hunger(player,0,true)
	player_style.thirst(player,0,true)
	if player_style.players[name].black_death_id then
		player:hud_remove(player_style.players[name].black_death_id)
		player_style.players[name].black_death_id = nil
	end
end)

minetest.register_on_newplayer(function(player)
	minetest.after(0,function(player)
		if player and player:get_pos() then
			player_style.thirst(player,0,true)
			player_style.hunger(player,0,true)
		end
	end,player)
end)

minetest.register_on_leaveplayer(function(player)
	local name=player:get_player_name()
	player_style.player_attached[name] = nil
	minetest.after(0, function(name)
			player_style.players[name] = nil
			player_style.player_dive[name] = nil
	end, name)
end)

minetest.register_on_joinplayer(function(player)
	local profile=player_style.registered_profiles["default"]
	local name=player:get_player_name()

	player_style.players[name] = {}
	player_style.players[name].profile = "default"
	player_style.players[name].player = player
	player_style.inventory(player)

	player:set_properties({
		textures =	profile.texture,
		visual =		profile.visual,
		visual_size =	profile.visual_size,
		collisionbox =	profile.collisionbox,
		mesh =		profile.mesh,
		eye_height =	profile.eye_height,
		stepheight =	profile.stepheight
	})

	player_style.set_animation(name,"stand")

	player:hud_set_hotbar_image(profile.hotbar)
	player:hud_set_hotbar_selected_image(profile.hotbar_selected)

	if player_style.survive_hunger == true then
		player_style.players[name].hunger={
			level = player:get_meta():get_int("hunger"),
			step = 0,
			num = 0,
			back=player:hud_add({
				hud_elem_type="statbar",
				position={x=0.5,y=1},
				text="player_style_hunger_bar_back.png",
				number=20,
				direction = 0,
				size={x=24,y=24},
				direction=0,
				offset={x=25,y=-120},
			}),
			bar=player:hud_add({
				hud_elem_type="statbar",
				position={x=0.5,y=1},
				text="player_style_hunger_bar.png",
				number=player:get_meta():get_int("hunger"),
				direction = 0,
				size={x=24,y=24},
				direction=0,
				offset={x=25,y=-120},
			})
		}
	end

	if player_style.survive_thirst == true then
		player_style.players[name].thirst = {
			level = player:get_meta():get_int("thirst"),
			step = 0,
			num = 0,
			back=player:hud_add({
				hud_elem_type="statbar",
				position={x=0.5,y=1},
				text="player_style_thirst_bar_back.png",
				number=20,
				size={x=24,y=24},
				direction=0,
				offset={x=25,y=-150},
			}),
			bar=player:hud_add({
				hud_elem_type="statbar",
				position={x=0.5,y=1},
				text="player_style_thirst_bar.png",
				number=player:get_meta():get_int("thirst"),
				direction = 0,
				size={x=24,y=24},
				offset={x=25,y=-150},
			})
		}
	end
end)

player_style.hunger=function(player,add,reset)

	if player_style.survive_hunger == false then
		return
	end

	local name = player:get_player_name()
	local p = player_style.players[name]

	if reset then
		player:get_meta():set_int("hunger",20)
		if p and p.hunger then
			p.hunger.level = 20
		end
	end

	if not (p and p.hunger) then
		return
	elseif p.hunger.num == math.ceil(p.hunger.level+add) then
		p.hunger.level = p.hunger.level + add
		if p.hunger.level <= 5  then
			local step = math.floor(p.hunger.level*100)/100
			if p.hunger.step ~= step then
				p.hunger.step = step
				player:set_hp(player:get_hp()-1)
			end
		end
		return
	end

	local a = p.hunger.level+add
	if a < 0 then
		a = 0
		player:set_hp(0)
	elseif a > 20 then
		a = 20
	end

	p.hunger.num = math.ceil(a)
	p.hunger.level = a

	player:get_meta():set_int("hunger",p.hunger.num)
	player:hud_change(p.hunger.bar, "number", p.hunger.num)
end

player_style.thirst=function(player,add,reset)

	if player_style.survive_thirst == false then
		return
	end

	local name = player:get_player_name()
	local p = player_style.players[name]

	if not (p and p.thirst) then
		return
	elseif reset then
		player:get_meta():set_int("thirst",20)
		p.thirst.level = 20
	elseif p.thirst.num == math.ceil(p.thirst.level+add) then
		p.thirst.level = p.thirst.level + add
		return
	end

	local a = p.thirst.level+add

	if a <= 0 then
		a = 0
		minetest.after(0,function(player)
			player:set_hp(0)
		end,player)
	elseif a > 20 then
		a = 20
	elseif a <= 5 and add <= 0 then
		minetest.after(0,function(player)
			player:set_hp(player:get_hp()-1)
		end,player)
	end

	p.thirst.num = math.ceil(a)
	p.thirst.level = a

	player:get_meta():set_int("thirst",p.thirst.num)
	player:hud_change(p.thirst.bar, "number", p.thirst.num)

	if p.thirst.num <= 4 and not p.thirst.to_death then
		p.thirst.to_death = true
		player_style.thirst_to_death(player)
	end
end

player_style.thirst_to_death=function(player)
	local name = player:get_player_name()
	local p = player_style.players[name]

	if player:get_pos() and p and p.thirst then
		if p.thirst.num <= 9 then
			player_style.thirst(player,-1)
			minetest.after(10,function(player)
				player_style.thirst_to_death(player)
			end,player)
		elseif p.thirst.to_death then
			p.thirst.to_death = nil
		end
	end
end

player_style.register_profile=function(def)
	def=def or {}
	player_style.registered_profiles[def.name or "default"]={
		texture =		def.texture or {"character.png"},
		visual =		def.visual or "mesh",
		visual_size =	def.visual_size or {x=1,y=1},
		collisionbox =	def.collisionbox or {-0.35,0,-0.35,0.35,1.8,0.35},
		mesh =		def.mesh or "character.b3d",
		diving =		def.dive or true,
		flying =		def.flying or true,
		animation = 	def.animation or {
					stand={x=1,y=39,speed=30},
					walk={x=41,y=61,speed=30},
					run={x=41,y=61,speed=60},
					sneak={x=41,y=61,speed=15},
					mine={x=65,y=75,speed=30},
					hugwalk={x=80,y=99,speed=30},
					lay={x=113,y=123,speed=0},
					sit={x=101,y=111,speed=0},
					fly={x=125,y=135,speed=0},
					dive={x=136,y=156,speed=30},
				},
		eye_height =	def.eye_height or 1.6,
		stepheight =	def.stepheight or 0.7,
		hotbar =		def.hotbar or "player_api_hotbar.png",
		hotbar_selected =	def.hotbar_selected or "player_api_hotbar_selected.png",
	}
end

player_style.register_profile()

player_style.set_animation=function(name,typ,n)
	local user=player_style.players[name]

	if not user and type(name) =="userdata" then
		name = name:get_player_name()
		user=player_style.players[name]
	end

	if user and user.current ~= typ and player_style.registered_profiles[user.profile].visual=="mesh" then
		user.current = typ
		local a=player_style.registered_profiles[user.profile].animation[typ]
		user.player:set_animation({x=a.x,y=a.y},n or a.speed,0)
	end
end

player_style.get_airlike=function(pos)
	local d  = default.def(minetest.get_node(pos).name)
	return d.name == "air" or d.name == "default:vacuum" or d.name == "default:gas" or d.buildable_to and d.liquid_renewable and d.drawtype == "airlike"
end

local attached_players = player_style.player_attached

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name=player:get_player_name()
		if not attached_players[name] then
			local key=player:get_player_control()
			local a="stand"
			local hunger = -0.0001
			if key.up or key.down or key.left or key.right then
				hunger = -0.0002
				a="walk"
				local p = player:get_pos()
				local pr = player_style.player_dive[name]
				local v = player:get_player_velocity()

				if pr and pr.kong then
					if default.defpos({x=p.x,y=p.y-0.1,z=p.z},"walkable") then
						pr.kong = nil
						player_style.player_diveing(name,player)
					else
						a="dive"
					end
				elseif key.sneak or minetest.get_item_group(minetest.get_node(p).name,"liquid") > 0 then
					hunger = -0.0005
					a="dive"
					player_style.player_diveing(name,player,true,minetest.get_item_group(minetest.get_node(p).name,"liquid"))
				elseif key.aux1 then
					a="run"
					player_style.player_run(name,player,true)
					local run = player_style.player_running[name]
					if run then
						hunger = -0.0005
					end
					if run and run.wallrun then
						local d = player:get_look_dir()
						local walkable = default.defpos({x=p.x+(d.x*2),y=p.y,z=p.z+(d.z*2)},"walkable")
						local v = player:get_player_velocity()
						hunger = -0.002
						if key.jump then
							run.wallrun = nil
							player:set_physics_override({jump=1.25})
							hunger = -0.05
						elseif run.wallrun == 1 and walkable and v.y == 0 and math.abs(v.x+v.z) > 1.5 then
							player:set_physics_override({jump=1.8})
							run.wallrun = 2
							hunger = -0.05
						elseif run.wallrun == 2 and not walkable then
							player:set_physics_override({jump=1.25})
							run.wallrun = 1
							hunger = -0.05
						elseif key.up and not (key.down or key.left or key.right)
						and default.defpos({x=p.x,y=p.y-1,z=p.z},"walkable") 
						and default.defpos({x=p.x+(d.x*2),y=p.y,z=p.z+(d.z*2)},"walkable")
						and not default.defpos({x=p.x+(d.x*2),y=p.y+1,z=p.z+(d.z*2)},"walkable") then
							player:set_pos(apos(p,0,1,0))
							a="dive"
							player_style.player_diveing(name,player,true,nil,{x=p.x+(d.x*2),y=p.y,z=p.z+(d.z*2)})
							player:add_player_velocity({x=d.x*20,y=5,z=d.z*20})
						end
					end
				end
				if v.y < 0 and not default.defpos(apos(p,0,-1),"walkable") then
					local d = player:get_look_dir()
					local w = vector.add(apos(p,0),{x=d.x,y=0,z=d.z})
					if default.defpos(apos(w,0,1),"walkable") and not default.defpos(apos(w,0,2),"walkable") then
						if player_style.get_airlike(p) and player_style.get_airlike(apos(p,0,1)) then
							if default.defpos(apos(p,0,1),"drowning") == 1 then
								minetest.set_node(p,{name="player_style:edgehook2"})
								minetest.set_node(apos(p,0,1),{name="player_style:edgehook2"})
							else
								minetest.set_node(p,{name="player_style:edgehook"})
								minetest.set_node(apos(p,0,1),{name="player_style:edgehook"})
							end

							--local vy = math.abs(v.y)*1.5
							--vy = vy < 3 and vy or 3
							--player:add_player_velocity({x=0,y=vy,z=0})
						end
					elseif default.defpos(apos(w,0,0),"walkable") and not default.defpos(apos(w,0,1),"walkable") then
						if player_style.get_airlike(p) then

							if default.defpos(p,"drowning") == 1 then
								minetest.set_node(p,{name="player_style:edgehook2"})
							else
								minetest.set_node(p,{name="player_style:edgehook"})
							end
							--local vy = math.abs(v.y)*1.5
							--vy = vy <= 3 and vy or 3
							--local ps = player_style.players[name]
							--if not ps.climbedge then
							--	ps.climbedge = p
							--	player:add_player_velocity({x=0,y=vy,z=0})
							--else
							--	if key.jump then
							--		player:add_player_velocity({x=0,y=vy,z=0})
							--	else
							--		player:add_player_velocity({x=0,y=(p.y-ps.climbedge.y)*10,z=0})
							--		player:set_pos(ps.climbedge)
							--	end
							--end
						end
					end
				--elseif player_style.players[name].climbedge then
					--player_style.players[name].climbedge = nil
				elseif key.aux1 and key.jump and vector.distance(vector.new(),v) < 9 then--and  not (key.left or key.right) then

					local ly = player:get_look_yaw()
					local x1 =math.sin(ly) * -1
					local z1 =math.cos(ly)
					local x2 =math.sin(ly)
					local z2 =math.cos(ly) * -1
					local l = default.defpos({x=p.x+x1,y=p.y,z=p.z+z1},"walkable")
					local r = default.defpos({x=p.x+x2,y=p.y,z=p.z+z2},"walkable")

					if l then
						local d = player:get_look_dir()
						player:add_player_velocity({x=d.x+(x2*4),y=1,z=d.z+(z2*4)})
					elseif r then
						local d = player:get_look_dir()
						player:add_player_velocity({x=d.x+(x1*4),y=1,z=d.z+(z1*4)})
					end
				end


			elseif key.sneak or minetest.get_item_group(minetest.get_node(player:get_pos()).name,"liquid") > 0 then
				a = "fly"
				player_style.player_diveing(name,player,true)
			elseif key.LMB or key.RMB then
				a="mine"
			elseif player:get_hp()<=0 then
				a="lay"
			end

			if player_style.player_dive[name] and not (a == "fly" or a == "dive") then
				local p = player:get_pos()
				 if default.defpos({x=p.x,y=p.y+1.5,z=p.z},"walkable") then
					if key.up or key.down or key.left or key.right then
						a="dive"
					else
						a = "fly"
					end
					if not player_style.player_dive[name].blocking then
						player_style.player_dive[name].blocking = true
						player:set_physics_override({speed=0.5})
					end
				else
					player_style.player_diveing(name,player)
				end

			elseif player_style.player_running[name] and not key.aux1 then
				player_style.player_run(name,player)

			end
			player_style.set_animation(name,a)
			player_style.hunger(player,hunger)
			player_style.thirst(player,hunger*2)
			player_style.tired(name,player)

		end
	end
end)

player_style.tired=function(name,player)
	local hunger = player_style.players[name].hunger
	local h = (hunger and hunger.level or 20)
	if player_style.player_dive[name] or player_style.player_running[name] then
		player_style.player_tired[name] = nil
	elseif not player_style.player_tired[name] and h <= 8 then
		player_style.player_tired[name] = true
		player:set_physics_override({
			jump=0.7,
			speed = 0.7,
		})
	elseif h > 8 and player_style.player_tired[name] then
		player_style.player_tired[name] = nil
		player:set_physics_override({
			jump=1,
			speed = 1,
		})
	end
end

player_style.player_run=function(name,player,a)
	local hunger = player_style.players[name].hunger
	local h = (hunger and hunger.level or 20)
	if player_style.player_dive[name] then
	elseif a and not player_style.player_running[name] and h > 10 then
		player_style.player_running[name] = {wallrun=1}
		player:set_physics_override({
			jump=1.25,
			speed = 2,
		})
	elseif (not a or h <= 10) and player_style.player_running[name] then
		player_style.player_running[name] = nil
		player:set_physics_override({
			jump=1,
			speed = 1,
		})
	end
end

player_style.player_diveing=function(name,player,a,water,kong)
	if a and not player_style.player_dive[name] then
		player_style.player_run(name,player)
		player_style.player_dive[name] = {kong = kong}
		player:set_properties({
			eye_height = 0.6,
			collisionbox = {-0.35,0,-0.35,0.35,0.49,0.35},
			stepheight=1.1,
		})
		player:set_physics_override({
			jump= water == 0 and 0 or 1,
		})
	else
		local pr =  player_style.player_dive[name]
		local p = player:get_pos()
		if not a and pr and (pr.kong == nil or player:get_player_velocity().y == 0) then --default.defpos({x=p.x,y=p.y-1,z=p.z},"walkable") ~= true
			local profile=player_style.registered_profiles[player_style.players[name].profile]
			player_style.player_dive[name] = nil
			player:set_properties({
				eye_height = profile.eye_height,
				collisionbox = profile.collisionbox,
				stepheight = profile.stepheight,
			})
			player:set_physics_override({
				jump=1,
				speed = 1,
			})
		end
	end
end