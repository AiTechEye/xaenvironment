maps = {
	user={},
	maps={
		["tutorial"]={
			file="maps_tutorial.exexn",
			pos={x=0,y=28501,z=0},
			size={y=51,x=133,z=100},
			player_spawn={
				pos={x=60,y=28531,z=42},
			},
		},
	}
}

maps.interacts=function(pos,map)
	for i,v in pairs(maps.maps) do
		local pos1,pos2 = protect.sort(pos,vector.add(pos1,v.size))
		if map ~= i
		and (pos.x >= v.pos1.x and pos.x <= v.pos2.x)
		and (pos.y >= v.pos1.y and pos.y <= v.pos2.y)
		and (pos.z >= v.pos1.z and pos.z <= v.pos2.z) then
			return true
		end
	end
	return false
end