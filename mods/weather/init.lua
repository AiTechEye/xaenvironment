apos=function(pos,x,y,z)
	return {x=pos.x+(x or 0),y=pos.y+(y or 0),z=pos.z+(z or 0)}
end

weather={
	mintimeout=200,
	maxtimeout=1000,
	players={},
	timecheck=0,
	time2=0,
	time=0,
	chance=100,
	size=500,
	strength=100,
	currweather={},
	perlin={
		offset=50,
		scale=50,
		spread={x=1000,y=1000,z=1000},
		seed=5349,
		octaves=3,
		persist=0.5,
		lacunarity=2,
		flags="default"
	},
}


minetest.register_chatcommand("weather", {
	params = "",
	description = "weather settings: <set 20-400> or <stop>",
	privs = {settime=true},
	func = function(name, param)
		local a
		if string.find(param,"set ")~=nil then
			local s=param.split(param," ")
			if not s then return end
			for _,n in pairs(s) do
				local num=tonumber(n)
				if num then
					a=num
					break
				end
			end
			if not a then
				minetest.chat_send_player(name, "<weather> /weather set <20-" .. weather.strength ..">")
				return
			end
			a = a <= weather.strength and a or weather.strength
		elseif string.find(param,"stop")~=nil then
			a=0
		else
			minetest.chat_send_player(name, "<weather> /weather set <20-" .. weather.strength ..">")
			minetest.chat_send_player(name, "<weather> /weather stop")
			return
		end

		local user=minetest.get_player_by_name(name)
		if not user then return end
		local pos=user:get_pos()
		for i, w in pairs(weather.currweather) do
			if vector.distance(w.pos,pos)<w.size and pos.y>-20 and pos.y<120 then
				if a==0 then
					weather.currweather[i]=nil
					return
				else
					weather.currweather[i].strength=a
					weather.currweather[i].change_strength=1
					return
				end
			end
		end
		if a~=0 then
			weather.add({pos=pos,strength=a})
		end	
		return
	end
})

minetest.register_globalstep(function(dtime)
	weather.time=weather.time+dtime
	weather.time2=weather.time2+dtime
	if weather.time > 0.1 then
		weather.time=0
		weather.ac()
		weather.add()
	end

	if weather.time2 > 10 then
		weather.time2=0
		for _,w in pairs(weather.players) do
			local ins
			local s
			local pos=w.player:get_pos()
			for i, w in pairs(weather.currweather) do
				if vector.distance(w.pos,pos)<w.size and pos.y>-20 and pos.y<120 then
					ins=1
					if w.sound then
						s=1
					end
				end
			end
			if not s and weather.players[w.player:get_player_name()].sound then
				minetest.sound_stop(weather.players[w.player:get_player_name()].sound)
			end
			if not ins then
				w.player:set_clouds({density=0.4,speed={y=-2,x=0},color={r=240,g=240,b=255,a=229}})
				w.player:set_sky({},"regular",{})
				weather.players[w.player:get_player_name()]=nil
			end
		end
	end
end)


minetest.register_on_leaveplayer(function(player)
	local name=player:get_player_name()
	if weather.players[name] and weather.players[name].sound then
		minetest.sound_stop(weather.players[name].sound)
		weather.players[name]=nil
	end
end)

weather.get_temp=function(pos)
	if pos.y<-50 then return 0 end
	local p={x=math.floor(pos.x),y=0,z=math.floor(pos.z)}
	return minetest.get_perlin(weather.perlin):get2d({x=p.x,y=p.z}) - 40
end



weather.get_bio=function(pos)
	local green,dry,cold=0,0,0

	local tmp=weather.get_temp(pos)

	if tmp>25 then
		dry=dry+1
	elseif tmp<=0 then
		cold=cold+1
	else
		green=green+1
	end

	local m=math.max(unpack({green,dry,cold}))
	if green+dry+cold==0 then
		return 0
	elseif m==green then
		return 1
	elseif m==dry then
		return 2
	else -- cold
		return 3
	end
end

weather.ac=function()
	local t=minetest.get_timeofday()*24
	for i, w in pairs(weather.currweather) do
		for _,player in ipairs(minetest.get_connected_players()) do
			local p=player:get_pos()
			local range = player:get_player_control().aux1 == false and 1 or 2

			local d = player:get_look_dir()
			p = apos(p,d.x*5,0,d.z*5)

			if player_style.player_attached[player:get_player_name()] then
				range = 2
				local d = player:get_look_dir()
				p = apos(p,d.x*5,0,d.z*5)
			end

			if p.y>-20 and p.y<120 and vector.distance(w.pos,p)<=w.size then
				local name=player:get_player_name()
--if the player is in another bio, then limit the area to that bio
				weather.timecheck=weather.timecheck+1
				if weather.timecheck>10 then
					weather.timecheck=0
					local bio=weather.get_bio(p)
					if bio~=w.bio then
						weather.currweather[i].size=vector.distance(w.pos,p)
						w.bio=bio
					end
				end
--rnd change strength
				if math.random(1,100)==1 then
					weather.currweather[i].strength=math.random(10,weather.strength)
				end
--wet/rain
				if w.bio==1 then
					if not weather.players[name] or weather.players[name].bio~=w.bio or weather.currweather[i].change_strength then
						local s=(w.strength*0.01)*1.2
						local sound
						if w.strength>30 then
							sound=minetest.sound_play("weather_rain", {to_player = name,gain = 2.0,loop=true})
						end
						if t>6 and t<19 then
							player:set_sky({r=149-(s*2),g=154-(s*3),b=209-(s*9),a=255},"plain",{})
							player:set_clouds({density=0.5+(s*0.05),color={r=240/s,g=240/s,b=255/s,a=229*s}})
						end
						if weather.players[name] and weather.players[name].sound then
							minetest.sound_stop(weather.players[name].sound)
						end
						weather.players[name]={player=player,sound=sound,bio=w.bio}
					end

					for s=1,w.strength*range,1 do
						local p={x=p.x+math.random(-7*range,7*range),y=p.y+math.random(5,10),z=p.z+math.random(-7*range,7*range)}

						if minetest.get_node_light(p,0.5)==15  then
							minetest.add_particle({
								pos=p,
								velocity={x=math.random(-0.5,0.5),y=-math.random(7,9),z=math.random(-0.5,0.5)},
								acceleration={x=0,y=-4,z=0},
								expirationtime=3,
								size=3,
								collisiondetection=true,
								collision_removal=true,
								vertical=true,
								texture="weather_drop.png",
								playername=player:get_player_name(),
							})
						end
					end
--hot/dry
				elseif w.bio==2 then
					if  not weather.players[name] or weather.players[name].bio~=w.bio then
						if t>6 and t<19 then
							player:set_sky({r=100,g=160,b=209,a=255},"plain",{})
						end
						player:set_clouds({density=0.2,color={r=240,g=240,b=255,a=229}})
						if weather.players[name] and weather.players[name].sound then
							minetest.sound_stop(weather.players[name].sound)
						end
						weather.players[name]={player=player,bio=w.bio}
					end
--cold/snowy
				elseif w.bio==3 then
					if  not weather.players[name] or weather.players[name].bio~=w.bio or weather.currweather[i].change_strength then
						local s=(w.strength*0.01)*1.2
						if t>6 and t<19 then
							player:set_sky({r=149-(s*2),g=154-(s*3),b=209-(s*9),a=255},"plain",{})
							player:set_clouds({density=0.5+(s*0.05),color={r=240/s,g=240/s,b=255/s,a=229*s}})
						end
						if weather.players[name] and weather.players[name].sound then
							minetest.sound_stop(weather.players[name].sound)
						end
						weather.players[name]={player=player,bio=w.bio}
					end
					for s=1,math.floor(w.strength/4),1 do
						local p={x=p.x+math.random(-10,10),y=p.y+math.random(5,10),z=p.z+math.random(-10,10)}

						if minetest.get_node_light(p,0.5)==15  then
							minetest.add_particle({
								pos=p,
								velocity={x=math.random(-0.5,0.5),y=-math.random(1,2),z=math.random(-0.5,0.5)},
								acceleration={x=0,y=0,z=0},
								expirationtime=6,
								size=1,
								collisiondetection=true,
								collision_removal=true,
								vertical=true,
								texture="weather_snow" .. math.random(1,4) .. ".png",
								playername=player:get_player_name(),
							})
						end
					end
				end
--neutral
			end
--weather timeout
		weather.currweather[i].timeout=weather.currweather[i].timeout-1
		if weather.currweather[i].timeout<20 then
			weather.currweather[i].timeout=0
			weather.currweather[i].strength=weather.currweather[i].strength-10
			if weather.currweather[i].strength<20 then
				weather.currweather[i]=nil
				return
			end
		end

		end

	weather.currweather[i].change_strength=nil
	end
end

weather.add=function(set)
	if set then
		if set.pos.y>-20 and set.pos.y<120 then
			local b=weather.get_bio(set.pos)
			if b==1 or b==2 or b==3 then 
				table.insert(weather.currweather,{timeout=math.random(weather.mintimeout,weather.maxtimeout),pos=set.pos,size=math.random(20,weather.size),strength=set.strength,sound=1,bio=b})
			end
		end
		return
	end

	if math.random(1,weather.chance)~=1 then return end
	local players={}
	local n=0

	for _,player in ipairs(minetest.get_connected_players()) do
		n=n+1
		players[n]=player
	end
	for o=1,n,1 do
		local p=players[math.random(1,n+20)]
		if p then
			local pos = p:get_pos()
			pos={x=math.floor(pos.x+0.5),y=math.floor(pos.y+0.5),z=math.floor(pos.z+0.5)}
			if pos.y>-20 and pos.y<120 then
				local ins
				for i, w in pairs(weather.currweather) do
					if vector.distance(w.pos,pos)<w.size then
						ins=1
					end
				end
				if not ins then
					local b=weather.get_bio(pos)
					if b==1 or b==2 or b==3 then 
						table.insert(weather.currweather,{timeout=math.random(weather.mintimeout,weather.maxtimeout),pos=pos,size=math.random(20,weather.size),strength=math.random(2,weather.strength),sound=1,bio=b})
						return
					end
				end
			end
		end
	end
end