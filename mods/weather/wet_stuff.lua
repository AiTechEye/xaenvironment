for name,def in pairs(minetest.registered_nodes) do
	if def.drop == "default:dirt" and def.groups and def.groups.dirt and def.groups.weather_wet == nil and name ~= "default:wet_soil" then
		local def2 = table.copy(def)
		local name2 = "weather".. def.name:sub(def.name:find(":"),-1) .."_wet"
		table.insert(weather.is_wet_nodes,name2)
		table.insert(weather.can_be_wet_nodes,name)
		weather.wet_nodes[name] = name2
		weather.weter_nodes[name] = name2.."er"

		def2.sounds = default.node_sound_clay_defaults()
		def2.name = nil
		def2.description = def.description.." (wet)"

		def2.groups.weather_wet = 1
		def2.groups.slippery=1
		def2.groups.not_in_creative_inventory = 1
		def2.groups.on_load = 1
		def2.groups.spreading_dirt_type = nil

		for i,v in ipairs(def.tiles) do
			def2.tiles[i] = def.tiles[i] .."^[colorize:#00000022"
		end
		def2.on_load=function(pos)
			if not weather.while_rain(pos) then
				minetest.set_node(pos,{name=name})
			else
				minetest.get_node_timer(pos):start(10)
			end
		end
		def2.on_construct=function(pos)
			minetest.get_node_timer(pos):start(10)
		end
		def2.on_timer = function (pos, elapsed)
			if math.random(1,10) == 1 and not weather.while_rain(pos) then
				minetest.set_node(pos,{name=name})
			else
				local upos = apos(pos,0,1)
				if minetest.get_node(pos).name == name2.."er" and math.random(1,100) == 1 and default.defpos(upos,"buildable_to") and not minetest.is_protected(upos,"") then
					minetest.set_node(upos,{name="default:water_flowing",param2=2})
				end
				return true
			end
		end

		minetest.register_node(name2, def2)
		local def3 = table.copy(def2)
		def3.tiles[1] = def.tiles[1] .."^[colorize:#0000aa55"		-- .."^default_water.png"
		def3.description = def.description.." (weter)"
		def3.groups.slippery=5
		minetest.register_node(name2.."er", def3)
	end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer > 1 then
		timer = 0
		for _,w in pairs(weather.players) do
			local pos=w.player:get_pos()
			local raining,strength=weather.while_rain(pos)
			strength = strength or 20
			for i2,pos2 in ipairs(minetest.find_nodes_in_area(vector.subtract(pos,30),vector.add(pos,30),weather.can_be_wet_nodes)) do
				if math.random(1,105-strength) == 1 then
					if strength > 20 and math.random(1,110-strength) == 1 then
						minetest.set_node(pos2,{name=weather.weter_nodes[minetest.get_node(pos2).name]})
					else
						minetest.set_node(pos2,{name=weather.wet_nodes[minetest.get_node(pos2).name]})
					end
				end
			end
		end
	end
end)