local g3d = require 'g3d'

local insert = table.insert

local scale = .1
local mesh = {}
for x=0,1 do
	for y=0,1 do
		mesh[#mesh+1] = {x*scale,y*scale,0,x,y}
	end
end
local map = {1, 3, 2, 2, 3, 4}

local tile = g3d.newModel(mesh) --, "assets/earth.png")--, nil, nil, g3d.camera.farClip)
tile.mesh:setVertexMap(map)
tile.positions = {}
local offx, offy = 0,0
for y=1,10 do
	for x=1,10 do
		insert(tile.positions, {x*.1+offx,y*.1+offy,0})
	end
end
tile:instanciate(tile.positions)

return tile
