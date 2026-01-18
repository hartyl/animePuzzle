local g3d = require 'g3d'
local floor = math.floor
local random = math.random
local height = require 'scripts.height'
local insert = table.insert
local house = g3d.newModel("assets/house.obj")
house.positions = {}
local offx, offy = -400, -30
for y=-10,150 do
	for x=-10,150 do
		if math.random(0,60) == 0 then
			local y = y -x*.5
			local _x,_y = x*2 + floor((x+1)/2) + random(-1,1) + offx,y*2 + floor(y/3) + random(-1,1) + offy
			insert(house.positions, {_x,_y,height(_x,_y),1})
		end
	end
end

house:instanciate(house.positions)
house:setRotation(0,0,-1)
return house
