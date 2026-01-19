-- written by groverbuger for g3d
-- MIT license

local lg = love.graphics
local g3d = require "g3d"
local pi = math.pi
Winw, Winh = lg.getDimensions()

local min_dt = 1/60
local next_time = love.timer.getTime()

--require 'music'

local circle = require 'scripts.circle'

local camera = g3d.camera
--camera.lookInDirection(0,0,1,0,0)
local moon = g3d.newModel("assets/circle.obj", circle, {0,10,0}, nil, 0.5)
im = lg.newImage("assets/animestyled_hdr.png")
--	im:setWrap("clampzero","clampzero")
local background = g3d.newModel("assets/sphere.obj", im, nil, nil, g3d.camera.farClip, "noMap")
--local plane = require 'scripts.world'
local timer = 0
-- moon.shader = lg.newShader("g3d/depthboard.glsl",[[
-- house.shader = bill
g3d.shader:send("projectionMatrix", g3d.camera.projectionMatrix)

--	local floatEncode, floatDecode = unpack(require 'scripts.floatPack')

--local house = require 'scripts.house'
local tile = require 'scripts.game'
camera.lookAt(0,0,1,unpack(tile.translation))

local lol = 0
local selected = {0,0,0}
local delay = 0

local bSize = math.max(Winh/8,math.min(Winh/4, 96))
local buttons = {
	reset = 	{0,			0,		bSize,bSize, 1},
	shuffle =	{bSize,		0,		bSize,bSize, 254/255},
	dev =		{Winw-bSize,0,		bSize,bSize, 253/255},
	canP =		{Winw-bSize,bSize*2,bSize,bSize, 252/255},
	canN =		{Winw-bSize,bSize*3,bSize,bSize, 251/255},
	tileSpin =	{0		,Winh-bSize,bSize,bSize, 250/255},

}
local devMode = true
local function devChange ()
	devMode = not devMode
	local k = devMode and 1 or -1
	buttons.canN[1] = k* math.abs(buttons.canN[1])
	buttons.canP[1] = k* math.abs(buttons.canP[1])
end
devChange()

function GlobalReset()
	g3d.camera.position = {0,0,1}
	selected[3] = 0
	tile.reset()
end
local reso = 16
local selectCan
local function seCanReset()
	selectCan = lg.newCanvas(Winw/reso, math.ceil(Winh/reso), {msaa=0})
end
seCanReset()

tile.spinned = false

local actions = {
	[buttons.reset[5]] = GlobalReset,
	[buttons.shuffle[5]] = tile.shuffle,
	[buttons.dev[5]] = devChange,
	[buttons.canP[5]] = function ()
		reso=math.min(reso+1,18)
		seCanReset()
	end,
	[buttons.canN[5]] = function ()
		reso=math.max(reso-1,2)
		seCanReset()
	end,
	[buttons.tileSpin[5]] = function ()
		if tile.spinned then
			tile:setRotation(0,-1,0)
		else
			tile:setRotation(math.random()-.5,math.random()-.5-1,0)
		end
		tile.spinned = not tile.spinned
	end,
}

function love.update(dt)
	next_time = next_time + min_dt
	lol = lol + (love.keyboard.isDown'o' and 1 or 0) + (love.keyboard.isDown'l' and -1 or 0)
	timer = timer + dt
	--moon:setTranslation(cos(timer)*5 + 4, sin(timer)*5, sin(timer*2)*5)
	moon:setRotation(0, 0, timer - pi/2)
	g3d.camera.firstPersonMovement(dt)
	if love.keyboard.isDown "escape" then
		love.event.push "quit"
	end
	if selected[3] ~= 0 then
		actions[selected[3]]()
		selected[3] = 0
	end
	--plane:setTranslation(0,0,math.sin(timer/20)-2)

	if tile.anim < 1 then
		local spd = dt * 10
		tile.anim = tile.anim + spd
		tile.anim = (tile.anim >= 1-spd and 1 or tile.anim)
		local p = tile.positions[tile.moving]
		local anim = tile.anim
		local nanim = 1-anim
		tile.instanceMesh:setVertex(tile.moving, {p[1]*anim + tile.emptySpot[1]*nanim, p[2]*anim + tile.emptySpot[2]*nanim, p[3], p[4]})
	else
		tile.anim = 1
	end
	delay = delay - dt
end
function love.keypressed(k)
	if tile.anim < 1 then return end
	if k == 'left' then
		tile.swipeAny(-1,0)
	end
	if k == 'right' then
		tile.swipeAny(1,0)
	end
	if k == 'up' then
		tile.swipeAny(0,-1)
	end
	if k == 'down' then
		tile.swipeAny(0,1)
	end
	if k=='r' then
		GlobalReset()
	end
end


local canvas = lg.newCanvas(Winw/3+1,Winh,{msaa=2})
function love.draw()
	g3d.shaderPrepare(g3d.shader)
	g3d.shaderPrepare(tile.shader1)
	g3d.shaderPrepare(tile.shader2)
	lg.setCanvas(canvas)
	--	ready
	lg.setMeshCullMode("none")
	background:setTranslation(unpack(g3d.camera.position))
	background:draw()
	--[[
		lg.setMeshCullMode("front")
		plane:draw()
		lg.setCanvas()
		lg.setMeshCullMode("back")
		lg.setShader()
		lg.setDepthMode("always", false)
		lg.draw(canvas,0.5,Winh,0,3,-1)
		lg.setDepthMode("lequal", true)
		if camera.target[1] < 0.55 then
			house:drawInstanced(nil,house.instances)
		end
	]]
		lg.setCanvas()
	lg.setMeshCullMode("front")
	lg.setShader()
		lg.setDepthMode("always", false)
		lg.draw(canvas,0.5,Winh,0,3,-1)
		lg.setDepthMode("lequal", true)
	tile.shader = tile.shader1
	tile:drawInstanced()

	lg.setShader()
	if devMode then
		lg.draw(selectCan,0,Winh,0,reso,-reso)
	end
		lg.setDepthMode("lequal", true)

	lg.setMeshCullMode("back")
	lg.setColor(.75,.75,.5,1)
	lg.print(love.timer.getFPS())
	--	lg.print(tostring(lol))
	--	lg.print(table.concat(selected, ";"))
	lg.push()
	lg.scale(.1)
	lg.translate(lg.getDimensions())
	lg.translate(lg.getDimensions())
	lg.pop()
	lg.setColor(1,1,1,1)
	local cur_time = love.timer.getTime()+min_dt/2
	if cur_time <= next_time then
		next_time = cur_time
		return
	end
	lg.push()
	for n, v in pairs(buttons) do
		lg.print(n,v[1]+4,v[2]+4)
		lg.rectangle("line", unpack(v))
	end
	lg.pop()
	love.timer.sleep(next_time - cur_time)
end

function love.mousepressed(x,y)
	delay = .025
	selected[1] = math.huge
	lg.setCanvas(selectCan)
	lg.clear()
	lg.setMeshCullMode("back")
		lg.setDepthMode("always", false)
	tile.shader = tile.shader2
	tile.instanceMesh:setVertex(1, {tile.emptySpot[1],tile.emptySpot[2]})
	tile:drawInstanced()
	tile.instanceMesh:setVertex(1, {math.huge,math.huge})

	-- reset
	lg.push()
	lg.translate(0,Winh/reso)
	lg.scale(1/reso,1/reso)
	for _, v in pairs(buttons) do
		lg.setColor(0,0,v[5],1)
		v[2] = -v[2] - v[4]
		lg.rectangle("fill", unpack(v))
		v[2] = -v[2] - v[4]
	end
	lg.pop()
	-- shuffle

	lg.setColor(1,1,1,1)

	lg.setCanvas()
	local p = selectCan:newImageData()
	selected = {p:getPixel(x/reso,(Winh-y)/reso)}
	selected = {math.ceil(selected[2]*tile.width),math.ceil(selected[1]*tile.height), selected[3]}
end
function love.mousereleased()
	selected = {0,0,0}
	delay = math.huge
end
function love.mousemoved(_,_, dx,dy)
	if delay > 0 then return end
	if love.mouse.isDown(1) then
		if selected[1] > 0 then
			local x,y
			if math.abs(dx) > math.abs(dy) then
				y=0
				x=dx<0 and 1 or -1
			else
				x=0
				y=dy<0 and 1 or -1
			end
			if tile.anim == 1 then
				tile.swipe(selected[1], selected[2], x,y)
			end
		elseif selected[3] == 0 then
			g3d.camera.firstPersonLook(-dx,-dy)
		end
	end
end
