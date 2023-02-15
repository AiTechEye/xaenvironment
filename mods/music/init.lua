music = {
	tracks = {},
}

local time = 0
minetest.register_globalstep(function(dtime)
	time = time + dtime

	if time > 0.5 then
		time = 0
		local count = 0
		for name,p in pairs(player_style.players) do
			if p.music.timeout then
				count = count + 1

				if p.music.open and not p.music.gain_changed then
					music.show(minetest.get_player_by_name(name))
				end
				if default.date("s",p.music.timeout) >= 0 then
					if p.music.play then
						music.rnd_play(minetest.get_player_by_name(name))
					else
						p.music.timeout = nil
					end
				end
			end
		end
		if count == 0 then
			time = -60
		end
	end
end)

minetest.register_on_mods_loaded(function(player)
	for i,v in ipairs(minetest.get_dir_list(minetest.get_modpath("music").."/sounds",false)) do
		local file_name = v:sub(1,-5)
		local real_name = file_name:gsub("_"," ")
		local f = real_name:split("-")
		local author = f[2] and f[1] or ""
		local name = f[2] or real_name
		table.insert(music.tracks,{author=author,name=name,file=file_name,index=i,length=tonumber(f[3]) or 60})
	end
end)

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	local name = player:get_player_name()
	local dontplay = {}

	time = 1

	if meta:get_int("music_setup") == 0 then
		meta:set_int("music_setup",1)
		meta:set_int("music_play",0)
		meta:set_float("music_gain",0.2)
	end

	for i,v in ipairs(meta:get_string("music_dontplay"):split(",")) do
		dontplay[v] = true
	end

	player_style.players[name].music = {
		id=0,
		play = meta:get_int("music_play") == 1,
		track=math.random(1,#music.tracks),
		gain=meta:get_float("music_gain"),
		dontplay = dontplay
	}
	local m = player_style.players[name].music

	if meta:get_int("music_play") == 1 then
		music.rnd_play(player)
	end
end)

music.rnd_play=function(player)
	local name = player:get_player_name()
	local m = player_style.players[name].music
	local playlist = {}
	for i,v in pairs(music.tracks) do
		if not m.dontplay[v.file] then
			table.insert(playlist,v)
		end
	end

	minetest.sound_fade(m.id,1,0)

	local track = playlist[math.random(1,#playlist)]
	m.track = track.index
	m.id = minetest.sound_play(track.file, {to_player=name, gain=m.gain,loop=m.loop,fade=1})

	m.timeout = default.date("get") + track.length

	if m.open then
		music.show(player)
	end
end

music.show=function(player)
	local name = player:get_player_name()
	local m = player_style.players[name].music

	local list = ""
	local dontplay
	local track

	m.open = true

	for i,v in pairs(music.tracks) do
		list = list .. (m.dontplay[v.file] and "#ff0000 " or "") .. v.author.."\t\t\t\t" .. v.name ..","
		if m.track == v.index then
			dontplay = m.dontplay[v.file]  --true
			track = v
		end
	end

	local sec = m.timeout and (default.date("s",m.timeout)*-1) or 0
	local min = math.floor(sec/60)

	minetest.show_formspec(name, "music",
		"size[11.25,10.5]" 
		.."bgcolor[#1155aa55]"
		.."textlist[1,0.5;10,10;tracks;" .. list:sub(1,-2) .. ";"..m.track.."]"
		.."image_button[0,0.5;1,1;synth_play.png".. (m.play and "" or "^default_cross.png") ..";play;]tooltip[play;Playing by it self]"
		.."image_button[0,1.5;1,1;synth_stop.png;stop;]tooltip[stop;Stop]"
		.."image_button[0,2.5;1,1;synth_repeat.png".. (m.loop and "" or "^default_cross.png") ..";loop;]tooltip[loop;Repeat]"
		.."image_button[0,3.5;1,1;heart.png".. (dontplay and "^default_cross.png" or "") ..";dontplay;]tooltip[dontplay;Play / Don't play this one]"
		.. "scrollbaroptions[max=100]scrollbar[0,-0.2;11,0.5;horizontal;gain;"..(m.gain*100).."]"
		.. "label[0,10;" .. min..":"..(sec-(min*60)) .. "]"
	)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "music" then
		local name = player:get_player_name()
		local m = player_style.players[name].music
		m.open = pressed.quit == nil
		time = 1

		if pressed.quit then
			time = 1
			if m.gain_changed then
				m.gain_changed = nil
				player:get_meta():set_float("music_gain",m.gain)
			end
		elseif pressed.tracks then
			minetest.sound_fade(m.id,1,0)
			local i = minetest.explode_textlist_event(pressed.tracks).index
			m.track = i
			m.id = minetest.sound_play(music.tracks[i].file, {to_player=name, gain = m.gain,loop=m.loop})
			m.timeout = default.date("get") + music.tracks[i].length

			music.show(player)
		elseif pressed.stop then
			minetest.sound_fade(m.id,1,0)
			m.timeout = nil
			music.show(player)
		elseif pressed.play then
			if m.play then
				m.play = false
				player:get_meta():set_int("music_play",0)
			else
				m.play = true
				m.loop = nil
				player:get_meta():set_int("music_play",1)
				music.rnd_play(player)
			end
			music.show(player)
		elseif pressed.loop then
			if m.loop then
				minetest.sound_fade(m.id,1,0)
				m.id = minetest.sound_play(music.tracks[m.track].file, {to_player=name, gain=m.gain,fade=1})
				m.loop = nil
				m.timeout = default.date("get") + music.tracks[m.track].length
			else
				minetest.sound_fade(m.id,1,0)
				m.id = minetest.sound_play(music.tracks[m.track].file, {to_player=name, gain=m.gain, loop=true,fade=1})
				m.loop = true
				m.timeout = default.date("get") + music.tracks[m.track].length
				m.play = false
				player:get_meta():set_int("music_play",0)
			end
			music.show(player)
		elseif pressed.dontplay then
			local meta = player:get_meta()

			local i = music.tracks[m.track].file

			if m.dontplay[i] then
				m.dontplay[i] = nil
			else
				m.dontplay[i] = true
			end

			local list = ""
			for i,v in pairs(m.dontplay) do
				list = list .. i..","
			end

			meta:set_string("music_dontplay",list:gsub(1,-2))
			music.show(player)
		elseif pressed.gain then
			local i = minetest.explode_textlist_event(pressed.gain).index
			m.gain = i*0.01
			m.gain_changed = true
			minetest.sound_stop(m.id)
			m.id = minetest.sound_play(music.tracks[m.track].file, {to_player=name, gain = m.gain,loop=m.loop})
			m.timeout = default.date("get") + music.tracks[m.track].length
		end
	end
end)