-- written by groverbuger for g3d
-- MIT license

local lg = love.graphics
local floor, _, abs, random, cos,sin,pi, min,max =
math.floor,math.ceil,math.abs,math.random,math.cos,math.sin,math.pi,math.min,math.max
Winw, Winh = lg.getDimensions()

local min_dt = 1/60
local next_time = love.timer.getTime()

--require 'music'

local circle = require 'scripts.circle'

local g3d = require "g3d"
local moon = g3d.newModel("assets/circle.obj", circle, {0,10,0}, nil, 0.5)
local background = g3d.newModel("assets/sphere.obj", "assets/animestyled_hdr.png", nil, nil, g3d.camera.farClip, "noMap")
local plane = require 'scripts.world'
local timer = 0
local bill = lg.newShader("g3d/billboard.vert", 'scripts/cloud.frag')--"g3d/cut.frag")
bill:send("projectionMatrix", g3d.camera.projectionMatrix)
-- moon.shader = lg.newShader("g3d/depthboard.glsl",[[
local cloudShader = lg.newShader('scripts/cloud.vert' ,'scripts/cloud.frag')
cloudShader:send("projectionMatrix", g3d.camera.projectionMatrix)
moon.shader = cloudShader
-- house.shader = bill
g3d.shader:send("projectionMatrix", g3d.camera.projectionMatrix)

--	local floatEncode, floatDecode = unpack(require 'scripts.floatPack')

local house = require 'scripts.house'
local game = require 'scripts.game'

local lol = 0
g3d.camera.position = {0,0,1}
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
	if love.keyboard.isDown "r" then
		g3d.camera.position = {0,0,0}
	end
	--plane:setTranslation(0,0,math.sin(timer/20)-2)
end

local canvas = lg.newCanvas(Winw/3+1,Winh,{msaa=2})
function love.draw()
	lg.setCanvas(canvas)
	g3d.shaderPrepare(bill)
	g3d.shaderPrepare(g3d.shader)
	g3d.shaderPrepare(moon.shader)
	--g3d.shaderDepthBillPrepare(moon.shader)
	--	ready
	lg.setMeshCullMode("none")
	background:setTranslation(unpack(g3d.camera.position))
	background:draw()
	lg.setMeshCullMode("front")
	plane:draw()
	lg.setCanvas()
	lg.setMeshCullMode("back")
	lg.setShader()
	lg.setDepthMode("always", false)
	lg.draw(canvas,0.5,Winh,0,3,-1)
	lg.setDepthMode("lequal", true)
	house:drawInstanced(nil,house.instances)
	--moon:drawInstanced(nil, house.instances)
	game:drawInstanced()
	lg.setShader()
	lg.setColor(.75,.75,.5,1)
	--	local out = ""
	--	for y=0, size do
	--		for x=0, size do
	--			-- local c = floor(density[y][x]+.5)
	--			-- local c = (density[y][x])
	--			local c = floor(density[y][x]+.5)
	--			out = out .. (c == 0 and "  " or c < 0 and c or c > 0 and (" " .. c))  .. " "
	--		end
	--		out = out .. "\n"
	--	end
	lg.print(love.timer.getFPS())
	--	lg.print(tostring(lol))
	lg.push()
	lg.scale(.1)
	lg.translate(lg.getDimensions())
	lg.translate(lg.getDimensions())
	lg.pop()
	lg.setColor(1,1,1,1)
	local cur_time = love.timer.getTime()
	if cur_time <= next_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

function love.mousemoved(_,_, dx,dy)
	g3d.camera.firstPersonLook(dx,dy)
end
