local g3d = require 'g3d'

local insert = table.insert

local function reset(self)
	self.positions = {}
	for y=0,self.height-1 do
		for x=0,self.width-1 do
			insert(self.positions, {
				(x-.5)*self.iwidth-.5,
				(y-.5)*self.iheight-.5,
				(y-.5)*self.iheight,
				(x-.5)*self.iwidth,
			})
		end
	end
	self.emptySpot = {self.positions[1][1]-self.iwidth,self.positions[1][2]}
	self:instanciate(self.positions)
	self.anim = 1
end
local function check(self)
	local solved = true
	local i = 1
	for y=0,self.height-1 do
		for x=0,self.width-1 do
			solved = solved and
			math.abs(self.positions[i][1] - ((x-.5)*self.iwidth-.5)) < self.iwidth/2 and
			math.abs(self.positions[i][2] - ((y-.5)*self.iheight-.5)) < self.iheight/2
			i=i+1
		end
		if not solved then break end
	end
	return solved
end

local function swipeAny(self, dx,dy)
	local ex, ey = self.emptySpot[1]-dx*self.iwidth, self.emptySpot[2]-dy*self.iheight
	for i=1, #self.positions do
		local v = self.positions[i]
		if math.abs(v[2]-ey)<self.iheight/2 and math.abs(v[1]-ex)<self.iwidth/2 then
			local x,y = v[1], v[2]
			self.positions[i][1],self.positions[i][2] =
			self.positions[i][1]+dx*self.iwidth,
			self.positions[i][2]+dy*self.iheight
			self.emptySpot = {x,y}
			self.anim = 0
			self.moving = i
			return
		end
	end
end

local function shuffle(self)
	if self.width <= 2 or self.height <= 2 then
		for _=1,self.width*self.height do
			local h = math.random(0,1)
			local v = 1-h
			local d = math.random(0,1)*2-1
			self:swipeAny(h*d,v*d)
		end
	else
		for i=2,#self.positions do
			local a = self.positions[i]
			local b = self.positions[math.random(2,#self.positions)]
			local x,y = unpack(a,1,2)
			a[1], a[2] = unpack(b,1,2)
			b[1], b[2] = x,y
		end
	end
	self:instanciate(self.positions)
end

local function swipe(self, X,Y, dx,dy)
	local i = X+(Y-1)*self.width
	local ex, ey = self.emptySpot[1]-dx*self.iwidth, self.emptySpot[2]-dy*self.iheight
	local v = self.positions[i]
	if v and math.abs(v[2]-ey)<self.iheight/2 and math.abs(v[1]-ex)<self.iwidth/2 then
		local x,y = v[1], v[2]
		self.positions[i][1],self.positions[i][2] = self.positions[i][1]+dx*self.iwidth, self.positions[i][2]+dy*self.iheight
		self.emptySpot = {x,y}
		self.anim = 0
		self.moving = i
		return true
	end
end

local shader1 = love.graphics.newShader( [[
attribute vec4 InstancePosition;
uniform lowp mat4 projectionMatrix;
uniform mat3 viewMatrix;
uniform mat4 modelMatrix;

varying vec3 worldPosition;
varying vec3 viewPosition;

varying vec2 texCoord;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    worldPosition = (modelMatrix * (vec4(InstancePosition.xy,0,0) +vertexPosition)).xyz;
	texCoord = InstancePosition.wz + vertexPosition.xy;
    viewPosition = viewMatrix * worldPosition;
    return projectionMatrix * vec4(viewPosition,1);
} ]] , "g3d/cut.frag")

local shader2 = love.graphics.newShader( [[
attribute vec4 InstancePosition;
uniform lowp mat4 projectionMatrix;
uniform mat3 viewMatrix;
uniform mat4 modelMatrix;

varying vec3 worldPosition;
varying vec3 viewPosition;

varying vec2 texCoord;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    worldPosition = (modelMatrix * (vec4(InstancePosition.xy,0,0) +vertexPosition)).xyz;
	texCoord = InstancePosition.wz + vertexPosition.xy;
    viewPosition = viewMatrix * worldPosition;
	viewPosition.y=-viewPosition.y;
    return projectionMatrix * vec4(viewPosition,1);
}
]],[[
varying vec2 texCoord;
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    return vec4(texCoord,0,1);
}
]])
local shader3 = love.graphics.newShader( [[
attribute vec4 InstancePosition;
uniform lowp mat4 projectionMatrix;
uniform mat3 viewMatrix;
uniform mat4 modelMatrix;

varying vec3 worldPosition;
varying vec3 viewPosition;

vec4 position(mat4 transformProjection, vec4 vertexPosition) {
    worldPosition = (modelMatrix * (vec4(InstancePosition.xy,0,0) +vertexPosition)).xyz;
    viewPosition = viewMatrix * worldPosition;
	viewPosition.y=-viewPosition.y;
    return projectionMatrix * vec4(viewPosition,1);
}
]],[[
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    return vec4(color.rg,0,1);
}
]])

table.insert(Shaders,shader1)
table.insert(Shaders,shader2)
table.insert(Shaders,shader3)

SPD = 10
local function update(self,dt)
	if self.anim < 1 then
		local spd = dt * SPD*math.max(self.anim,.1)
		self.anim = self.anim + spd
		self.anim = (self.anim >= 1-spd and 1 or self.anim)
		local p = self.positions[self.moving]
		local anim = self.anim
		local nanim = 1-anim
		self.instanceMesh:setVertex(self.moving, {p[1]*anim + self.emptySpot[1]*nanim, p[2]*anim + self.emptySpot[2]*nanim, p[3], p[4]})
		self.done = false
	elseif self.anim == 1 then
		self.anim = 2
		self.done = self:check()
	end
end

local map = {1, 2, 3, 2, 4, 3}

return function (im, width, height)
local iwidth, iheight = 1/width, 1/height
local mesh = {}
for x=iwidth*.5,-iwidth*.5,-iwidth do
for y=-iheight*.5,iheight*.5,iheight do
		mesh[#mesh+1] = {iwidth-x,iheight-y,}
	end
end

local tile = g3d.newModel(mesh, im, {0,.5,.5}, nil, nil, nil,
	{{"VertexPosition", "float", 2}})

tile:setRotation(math.pi+1,0,0)

tile.mesh:setVertexMap(map)
tile.width = width
tile.height = height
local w,h = im:getDimensions()
local m = math.min(w,h)

tile:setScale(w/m,h/m,1)

tile.iwidth = iwidth
tile.iheight = iheight

tile.reset = reset
tile:reset()
tile.check = check
tile.done = false
tile.shuffle = shuffle


tile.swipeAny = swipeAny
tile.swipe = swipe

tile.shader1 = shader1
tile.shader2 = shader2
tile.shader3 = shader3
tile.shader = shader1

tile.update = update

return tile
end
