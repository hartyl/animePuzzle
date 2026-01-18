local g3d = require 'g3d'

local height = require 'scripts.height'

local scale = g3d.camera.farClip/10
local mesh = {}
local mmap = {}
for x=-10,10 do
	for y=-10,10 do
		local dist = (x^2+y^2)/100
		if dist <= 1 then
			local X,Y = x*dist*.5,y*dist*.5
			local z = height(X*scale,Y*scale)
			local i = #mesh+1
			mesh[i] = {X*scale,Y*scale,z,[9]=0,[10]=(z/125+.5) * (1-dist) + dist * 1,[11]=(z/128+.2) * (1-dist) + dist}
			mmap[x+y*1000] = i
		end
	end
end
local map = {}

local function f(x,y)
	if (x+.5)*(y+.5)>0 then
		if (x)^2+(y)^2<100 and (x+1)^2+(y)^2<100 and (x)^2+(y+1)^2<100 then
			map[#map+1] = mmap[x+y*1000]
			map[#map+1] = mmap[x+1+y*1000]
			map[#map+1] = mmap[x+(y+1)*1000]
		end
		if (x+1)^2+(y+1)^2<100 and (x+1)^2+(y)^2<100 and (x)^2+(y+1)^2<100 then
			map[#map+1] = mmap[x+1+y*1000]
			map[#map+1] = mmap[x+1+(y+1)*1000]
			map[#map+1] = mmap[x+(y+1)*1000]
		end
	else
		if (x+1)^2+(y+1)^2<100 and (x+1)^2+(y)^2<100 and (x)^2+(y)^2<100 then
			map[#map+1] = mmap[x+y*1000]
			map[#map+1] = mmap[x+1+y*1000]
			map[#map+1] = mmap[x+1+(y+1)*1000]
		end
		if (x+1)^2+(y+1)^2<100 and (x)^2+(y)^2<100 and (x)^2+(y+1)^2<100 then
			map[#map+1] = mmap[x+(y+1)*1000]
			map[#map+1] = mmap[x+y*1000]
			map[#map+1] = mmap[x+1+(y+1)*1000]
		end
	end
end

for y=-10,-1 do for x=-10,-1 do f(x,y) end end
for y=10,0,-1 do for x=10,0,-1 do f(x,y) end end
for y=10,0,-1 do for x=-10,-1 do f(x,y) end end
for y=-10,-1 do for x=10,0,-1 do f(x,y) end end

local world = g3d.newModel(mesh) --, "assets/earth.png")--, nil, nil, g3d.camera.farClip)
world.mesh:setVertexMap(map)

return world
