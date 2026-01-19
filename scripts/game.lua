local g3d = require 'g3d'

local insert = table.insert

local width, height = 10, 3
local iwidth, iheight = 1/width, 1/height
local mesh = {}
for x=-iwidth*.5,iwidth*.5,iwidth do
for y=-iheight*.5,iheight*.5,iheight do
		mesh[#mesh+1] = {iwidth-x,iheight-y,}
	end
end
local map = {1, 2, 3, 2, 4, 3}

local tile = g3d.newModel(mesh, im, {.5,0,.5}, nil, nil, nil,
	{{"VertexPosition", "float", 2}})
--, "assets/earth.png")--, nil, nil, g3d.camera.farClip)
tile.mesh:setVertexMap(map)
tile.width = width
tile.height = height

function tile.reset()
	tile.positions = {}
	local offx, offy = iwidth/2,iheight/2
	for y=0,height-1 do
		for x=0,width-1 do
			insert(tile.positions, {x*iwidth-1/2,y*iheight - 1/2,(y-1)*iheight+offy,(x-1)*iwidth+offx,})
		end
	end
	tile.emptySpot = {tile.positions[1][1],tile.positions[1][2]}
	tile.positions[1][1] = math.huge
	tile.positions[1][2] = math.huge
	tile:instanciate(tile.positions)
	tile.anim = 1
end
tile.reset()
function tile.shuffle()
	tile.positions[1][1] = tile.emptySpot[1]
	tile.positions[1][2] = tile.emptySpot[2]
	for _,a in pairs(tile.positions) do
		local b = tile.positions[math.random(#tile.positions)]
		local x,y = a[1],a[2]
		a[1],a[2]=b[1],b[2]
		b[1],b[2]=x,y
	end
	tile.emptySpot = {tile.positions[1][1],tile.positions[1][2]}
	tile.positions[1][1] = math.huge
	tile.positions[1][2] = math.huge
	tile:instanciate(tile.positions)
	tile.anim = 1
end

tile:lookAt(g3d.camera.position)

function tile.swipeAny(dx,dy)
	local dx, dy = dy, dx
	local ex, ey = tile.emptySpot[1]-dx*iwidth, tile.emptySpot[2]-dy*iheight
	for i=2, #tile.positions do
		local v = tile.positions[i]
		if math.abs(v[2]-ey)<iheight/2 then
			if math.abs(v[1]-ex)<iwidth/2 then --and v[1] == tile.emptySpot[1]+dx then
			local x,y = v[1], v[2]
			tile.positions[i][1],tile.positions[i][2] = tile.positions[i][1]+dx*iwidth, tile.positions[i][2]+dy*iheight
			tile.emptySpot = {x,y}
			tile.anim = 0
			tile.moving = i
			return
		end
		end
	end
end

function tile.swipe(X,Y, dx,dy)
	local i = X+(Y-1)*width
	local dx, dy = dy, dx
	local ex, ey = tile.emptySpot[1]-dx*iwidth, tile.emptySpot[2]-dy*iheight
	local v = tile.positions[i]
	if math.abs(v[2]-ey)<iheight/2 then
		if math.abs(v[1]-ex)<iwidth/2 then --and v[1] == tile.emptySpot[1]+dx then
			local x,y = v[1], v[2]
			tile.positions[i][1],tile.positions[i][2] = tile.positions[i][1]+dx*iwidth, tile.positions[i][2]+dy*iheight
			tile.emptySpot = {x,y}
			tile.anim = 0
			tile.moving = i
		end
	end
end


local s = [[
attribute vec4 InstancePosition;
uniform lowp mat4 projectionMatrix; // handled by the camera
uniform mat3 viewMatrix;       // handled by the camera
uniform mat4 modelMatrix;      // models send their own model matrices when drawn
uniform bool isCanvasEnabled;  // detect when this model is being rendered to a canvas

// the vertex normal attribute must be defined, as it is custom unlike the other attributes
attribute vec3 VertexNormal;
attribute vec4 groupId;

// define some varying vectors that are useful for writing custom fragment shaders
varying vec3 worldPosition;
varying vec3 viewPosition;

varying vec2 texCoord;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    // calculate the positions of the transformed coordinates on the screen
    // save each step of the process, as these are often useful when writing custom fragment shaders
    worldPosition = (modelMatrix * (vec4(InstancePosition.xy,0,0) +vertexPosition)).xyz;
	texCoord = InstancePosition.zw + vertexPosition.yx;
	texCoord.y = 1-texCoord.y;
    viewPosition = viewMatrix * worldPosition;
    return projectionMatrix * vec4(viewPosition,1);
} ]]

tile.shader1 = love.graphics.newShader( s,
[[
varying vec2 texCoord;
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 texcolor = Texel(tex, texCoord);
	texcolor.a = 1;
    return texcolor * color;
}
]]
)
tile.shader2 = love.graphics.newShader( [[
attribute vec4 InstancePosition;
uniform lowp mat4 projectionMatrix; // handled by the camera
uniform mat3 viewMatrix;       // handled by the camera
uniform mat4 modelMatrix;      // models send their own model matrices when drawn

// the vertex normal attribute must be defined, as it is custom unlike the other attributes
attribute vec3 VertexNormal;
attribute vec4 groupId;

// define some varying vectors that are useful for writing custom fragment shaders
varying vec3 worldPosition;
varying vec3 viewPosition;

varying vec2 texCoord;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    // calculate the positions of the transformed coordinates on the screen
    // save each step of the process, as these are often useful when writing custom fragment shaders
    worldPosition = (modelMatrix * (vec4(InstancePosition.xy,0,0) +vertexPosition)).xyz;
	texCoord = InstancePosition.zw + vertexPosition.yx;
	texCoord.y = 1-texCoord.y;
    viewPosition = viewMatrix * worldPosition;
    return projectionMatrix * vec4(viewPosition,1);
} ]]
,
[[
varying vec2 texCoord;
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    return vec4(texCoord.x, 1-texCoord.y,0,1);
}
]]
)

tile.shader1:send("projectionMatrix", g3d.camera.projectionMatrix)
tile.shader2:send("projectionMatrix", g3d.camera.projectionMatrix)

return tile
