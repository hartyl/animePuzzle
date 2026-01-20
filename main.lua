-- written by groverbuger for g3d
-- MIT license

local lg = love.graphics
local g3d = require "g3d"
local camera = g3d.camera
local pi = math.pi
Winw, Winh = lg.getDimensions()

local min_dt = 1/60
local next_time = love.timer.getTime()

--require 'music'

local cloud = require 'scripts.cloud'
im = lg.newImage("assets/animestyled_hdr.png")
--	im:setWrap("clampzero","clampzero")
local background = g3d.newModel("assets/sphere.obj", im, nil, nil, nil, "noMap")
local timer = 0

Tile = require 'scripts.game'(im,10,3)
camera.lookAt(0,0,1,unpack(Tile.translation))

local plane
function PlaneSet()
	plane = not plane and require 'scripts.world' or nil
end
local house
function HouseSet()
	house = not house and require 'scripts.house'() or nil
end
local buttons = require 'scripts.buttons'

cloud.shader:send('size', 1)
local cloudSize = 1
LevelSelect = false
function love.update(dt)
	next_time = next_time + min_dt
	timer = timer + dt
	g3d.camera.firstPersonMovement(dt)
	if love.keyboard.isDown "escape" then
		love.event.push "quit"
	end
	buttons.update(dt)
	Tile:update(dt)
	-- press a button to ascend, press another button to descend
	cloudSize = cloud.update(dt)
end

Tile2 = require'scripts.game'(im,1,1)

local canvas = lg.newCanvas(Winw/3+1,Winh,{msaa=2})
function love.draw()
	g3d.shaderPrepare(g3d.shader)
	g3d.shaderPrepare(Tile.shader1)
	g3d.shaderPrepare(Tile.shader2)
	g3d.shaderPrepare(cloud.shader)
	lg.setCanvas(canvas)
	--	ready
	lg.setMeshCullMode("none")
	background:setTranslation(unpack(g3d.camera.position))
	background:draw()
	lg.setMeshCullMode("front")
	if plane and camera.position[3] < 100 then
		plane:draw()
		if house and camera.target[1] < 0.55 then
			house:drawInstanced(nil,house.instances)
		end
	end
	lg.setCanvas()
	lg.setShader()

	lg.setDepthMode("always", false)
	lg.draw(canvas,0.5,Winh,0,3,-1)
	lg.setDepthMode("lequal", true)

	Tile.shader = Tile.shader1
	Tile:drawInstanced()

	if cloudSize>0 then
		cloud:drawBillboardInstanced()
	end

	Tile2.shader = Tile2.shader1
	g3d.shaderPrepare(Tile2.shader)
	Tile2:setTranslation(0,0,0)
	Tile2:setRotation(0,0,0)

	lg.setDepthMode("always", false)
	Tile2:draw()
	lg.setShader()
	buttons.devDraw()

	lg.setMeshCullMode("back")
	lg.setColor(.75,.75,.5,1)
	--	lg.print("FPS: "..love.timer.getFPS())
	lg.print(cloud.translation[3])

	--	lg.print(table.concat(selected, ";"))

	lg.setColor(1,1,1,1)
	local cur_time = love.timer.getTime()+min_dt/2
	if cur_time <= next_time then
		next_time = cur_time
		return
	end
	buttons.draw()
	love.timer.sleep(next_time - cur_time)
end

