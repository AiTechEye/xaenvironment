synth={playing={}}

synth.resettime=function(pos)
	local meta = minetest.get_meta(pos)
	local mark1 = meta:get_int("mark1")
	minetest.get_node_timer(pos):stop()
	meta:set_int("play",0)
	meta:set_int("timeline",mark1>0 and mark1-1 or 0)
	meta:set_int("scroll",math.floor(mark1*0.3))
	synth.playing[minetest.pos_to_string(pos)] = nil
	synth.form(pos)
end

synth.form=function(pos)
	local meta = minetest.get_meta(pos)
	local locked = meta:get_int("locked")
	if meta:get_int("updating") == 0 or (locked == 1 and meta:get_string("user") ~= meta:get_string("owner")) then
		return
	end

	local notes = meta:get_string("notes")
	local size = meta:get_int("size")
	local bsize = size*0.3
	local s = meta:get_int("scroll")
	local b = ""
	local idx = 0
	local idy = 1
	local note = ""
	local toggle = 0
	local play = meta:get_int("play")
	local mark1 = meta:get_int("mark1")
	local mark2 = meta:get_int("mark2")

	for x=-0.3,size/3,0.3 do
		if mark2 ~= 0 and idx == mark1 then
			note = "synth_timeline.png^synth_play.png"
			toggle = 1
		else
			if mark2 ~= 0 and idx == mark2 then
				toggle = 0
				note = "synth_timeline.png"
			elseif toggle == 1 then
				note = "synth_timeline.png"
			else
				note = "default_air.png"
			end
		end

		b=b .. "image_button[" .. (x-s) .."," .. 0.6 .. ";0.5,0.5;" .. note .. ";mark:".. idx ..";]"
		idx=idx+1
	end

	idx=0

	for y=0.9,4.6,0.3 do
	for x=-0.3,size/3,0.3 do
		if string.find(notes,"," .. idx .."x" .. idy .."!") then
			note = "synth_b1.png"
			toggle = 1
		else
			note = "synth_b0.png"
			toggle = 0
		end
		b=b .. "image_button[" .. (x-s) .."," .. y .. ";0.5,0.5;" .. note .. ";note:" .. toggle ..":" ..idx ..":" .. idy ..";]"
		idx = idx + 1
	end
		idx = 0
		idy = idy + 1
	end

	meta:set_string("formspec",
		"size[16,5]"
		.."scrollbar[-0.3,4.9;16.4,0.5;horizontal;scroll;" .. s .."]"
		.. (play == 0 and "image_button[-0.3,-0.3;1,1;synth_play.png;play;]" or "image_button[-0.3,-0.3;1,1;synth_pause.png;pause;]image["..(-0.3)..",1;0.5,4.6;synth_timeline.png]")
		 ..b

		.. (meta:get_int("repeat") == 0 and "image_button[1.3,-0.3;1,1;synth_none.png;repeat_off;]" or "image_button[1.3,-0.3;1,1;synth_repeat.png;repeat_on;]")
		.."image_button[0.5,-0.3;1,1;synth_stop.png;stop;]"
		.."image_button[2.1,-0.3;1,1;synth_clearnspc.png;clearnspc;]"

		.. (mark2 ~=0 and "image_button[2.9,-0.3;1,1;synth_delete.png;delete;]image_button[3.7,-0.3;1,1;synth_copy.png;copy;]image_button[4.4,-0.3;1,1;synth_paste.png;paste;]" or "")

		.. (locked == 1 and "image_button[5.2,-0.3;1,1;synth_lock.png;lock_on;]" or "image_button[5.2,-0.3;1,1;synth_nolock.png;lock_off;]")

		.."tooltip[play;Play]tooltip[pause;Pause]tooltip[stop;stop]tooltip[repeat_on;Repeat]tooltip[repeat_off;Repeat disabled]tooltip[clearnspc;Clear note space]tooltip[copy;Copy marked notes]tooltip[paste;Paste copied notes]tooltip[delete;Delete marked notes]tooltip[lock_on;Setable by everyone]tooltip[lock_off;Setable only by you]"
	)
end

minetest.register_node("synth:synth", {
	description = "Synthesizer",
	groups = {oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
	tiles = {
		"synth_synth.png",
		"synth_synthsides.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1875, 0.5, -0.25, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.3125, -0.1875},
		}
	},
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
--playing
		if meta:get_int("play") == 1 then
			local timeline = meta:get_int("timeline") 
			local mark1 = meta:get_int("mark1")
			local mark2 = meta:get_int("mark2")

			meta:set_int("timeline",timeline+ 1)

			meta:set_int("scroll",math.floor(meta:get_int("timeline")*0.3))
			local notes = synth.playing[minetest.pos_to_string(pos)]

			if not notes then 
				synth.resettime(pos)
				return false
			end

			local t = notes.notes[timeline ..""]

			if t then
				minetest.sound_play("synth_sp" .. t.y, {pos=pos, gain = 1})
			end

			if (mark2 ~= 0 and timeline >= mark2) or timeline >= meta:get_int("size") then
				if meta:get_int("repeat") == 1 then
					meta:set_int("timeline",mark1)
				else
					synth.resettime(pos)
					synth.form(pos)
					return false
				end
			end
			synth.form(pos)
			return true

--scrollbar timer
		elseif meta:get_int("scrolltimer") == 1 then
			meta:set_int("scrolltimer",0)
			synth.form(pos)
			return false
		end
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		local meta = minetest.get_meta(pos)
		if pressed.quit then
			meta:set_int("updating",0)
		elseif pressed.repeat_on then
			meta:set_int("repeat",0)
			synth.form(pos)
			return
		elseif pressed.repeat_off then
			meta:set_int("repeat",1)
			synth.form(pos)
			return
		elseif pressed.play then
			meta:set_int("play",1)
			local mark1 = meta:get_int("mark1")
			meta:set_int("timeline",mark1 ~=0 and mark1 or meta:get_int("timeline"))
			minetest.get_node_timer(pos):start(0.1)
			synth.playing[minetest.pos_to_string(pos)] = {notes={}}
			local d = synth.playing[minetest.pos_to_string(pos)]
			for i,v in pairs(string.split(string.gsub(meta:get_string("notes"),"!",""),",")) do
				local s = string.split(v,"x")
				d.notes[s[1]] = {x=s[1],y=s[2]}
			end
			synth.form(pos)
			return
		elseif pressed.pause then
			minetest.get_node_timer(pos):stop()
			meta:set_int("play",0)
			synth.playing[minetest.pos_to_string(pos)] = nil
			synth.form(pos)
			return
		elseif pressed.stop then
			synth.resettime(pos)
			return
		elseif pressed.clearnspc then
			local xmax = 0
			for i,v in pairs(string.split(string.gsub(meta:get_string("notes"),"!",""),",")) do
				local s = string.split(v,"x")
				local x = tonumber(s[1])
				if x > xmax then
					xmax = x
				end
			end
			meta:set_int("size",xmax+40)
			meta:set_int("mark1",0)
			meta:set_int("mark2",0)
			synth.form(pos)
			return
		elseif pressed.delete then
			local mark1 = meta:get_int("mark1")
			local mark2 = meta:get_int("mark2")

			if mark1+mark2 ~= 0 then
				local notes = ""
				for i,v in pairs(string.split(string.gsub(meta:get_string("notes"),"!",""),",")) do
					local s = string.split(v,"x")
					local x = tonumber(s[1])
					if not (x > mark1-1 and x < mark2+1) then
						notes = notes .. "," .. x .."x" .. s[2] .."!"
					end
				end
				meta:set_string("notes",notes)
				synth.form(pos)
			end
			return

		elseif pressed.copy then
			local mark1 = meta:get_int("mark1")
			local mark2 = meta:get_int("mark2")
			if mark2 > 0 then
				local copy = ""
				local copytmp = {}
				for i,v in pairs(string.split(string.gsub(meta:get_string("notes"),"!",""),",")) do
					local s = string.split(v,"x")
					local sx = tonumber(s[1])
					copytmp[sx] = copytmp[sx] or {}

					table.insert(copytmp[sx],s[2])
				end
				local nempty
				local text = ""
				local x = 0
				for i=mark1,mark2 do
					for ii,y in pairs(copytmp[i] or {}) do
						nempty = true
						text = text .. y .. ","
					end
					if not nempty then
						text = text .. "."
					end
					text = text .. ";"
					if nempty then
						copy = copy .. text
						text = ""
					end
					nempty = nil
				end
				meta:set_string("copy",copy)
			end
			return
		elseif pressed.paste then
			local mark1 = meta:get_int("mark1") - 1
			local mark2 = meta:get_int("mark2")
			if mark2 > 0 then
				local copy = meta:get_string("copy")
				local data = ""
				for i,v in pairs(string.split(copy,";")) do
					for ii,y in pairs(string.split(v,",")) do

						if y ~= "." then
							data = data .. "," .. (mark1+i) .. "x" .. y .."!"
						end

					end
				end
				meta:set_string("notes",meta:get_string("notes") .. data)
				synth.form(pos)
			end
			return
		elseif pressed.lock_off then
			meta:set_int("locked",1)
			synth.form(pos)
			return
		elseif pressed.lock_on then
			meta:set_int("locked",0)
			synth.form(pos)
			return
		end
--note/button pressed
		for i,n in pairs(pressed) do
--note
			if string.sub(i,1,5) == "note:" then
				local b = string.split(i,":")
				if b[2] == "1" then -- on
					local notes = string.gsub(meta:get_string("notes"),"," .. b[3] .. "x" .. b[4].."!","")
					meta:set_string("notes", notes)
				else
					meta:set_string("notes",meta:get_string("notes") .."," .. b[3] .. "x" .. b[4] .."!")
					local size = meta:get_int("size")
					local b3 = tonumber(b[3])
					if b3 >= size-20 then
						meta:set_int("size",size+20-(size-b3))
					end
					if b3 > meta:get_int("xmax") then
						meta:get_int("xmax",b3)
					end
					minetest.sound_play("synth_sp" .. b[4], {pos=pos, gain = 1})
				end
				synth.form(pos)
				return
--mark
			elseif string.sub(i,1,5) == "mark:" then
				local n = tonumber(string.sub(i,6,-1))

				local mark1 = meta:get_int("mark1")
				local mark2 = meta:get_int("mark2")

				if mark1 + mark2 == 0 then			-- first click / create mark
					meta:set_int("mark2",n+1)
					meta:set_int("mark1",n)
				elseif n == mark1 then			-- n clear mark
					meta:set_int("mark2",0)
					meta:set_int("mark1",0)
				elseif n > mark1+(mark2-mark1)/2 then	--n > mark1 +50%
					meta:set_int("mark2",n)
				else					-- n < mark1 +50%
					meta:set_int("mark1",n)

				end
				synth.form(pos)
				return
			end
		end
		if pressed.scroll then
			local scroll = string.sub(pressed.scroll,5,-1)
			if tonumber(scroll) ~= meta:get_int("scroll",scroll) then
				meta:set_int("scrolltimer",1)
				minetest.get_node_timer(pos):stop()
				minetest.get_node_timer(pos):start(0.3)
				meta:set_int("scroll",scroll)
				return
			end
		end
	end,
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		meta:set_int("size",40)
		meta:set_int("updating",1)
		meta:set_int("locked",1)
		meta:set_string("owner",placer:get_player_name())
		synth.form(pos)
	end,
	on_destruct=function(pos)
		synth.playing[minetest.pos_to_string(pos)]=nil
	end,
	on_rightclick = function(pos,node,player,itemstack,pointed_thing)
		local meta = minetest.get_meta(pos)
		meta:set_int("updating",1)
		meta:set_string("user",player:get_player_name())
		synth.form(pos)
	end
})

minetest.register_craft({
	output="synth:synth",
	recipe={
		{"default:tin_ingot","default:copper_ingot","default:steel_ingot"},
		{"default:electric_lump","default:electric_lump","default:electric_lump"},
		{"materials:plant_extracts","group:wood","materials:plant_extracts"},
	},
})