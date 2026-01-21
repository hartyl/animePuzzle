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
Background = lg.newImage("assets/animestyled_hdr.png")
Images = {
	{Background, 4,3, "Clouds", credits},
	{Background, 8,6, "Clouds Hard"},
}
for y = 2, 10 do
for x=2, 10 do
	table.insert(Images,{require 'scripts.circle', x,y, "Test" .. #Images})
end
end
table.insert(Images,{require 'scripts.circle', 255,255, "Dont touch this one"})
--	im:setWrap("clampzero","clampzero")
local background = g3d.newModel("assets/sphere.obj", Background, nil, nil, nil, "noMap")
local timer = 0

local newTile = require 'scripts.game'
Viewing = 1

camera.top = 300

local options = {}
Options = options
for i in next, Images do
	local tile = newTile(unpack(Images[i]))
	table.insert(options,tile)
end

Tile = newTile(unpack(Images[Viewing]))
Tile.Viewing = Viewing
camera.lookAt(0,0,1,unpack(Tile.translation))

SelOpt = 1
local plane
function PlaneSet()
	plane = not plane and require 'scripts.world' or nil
end
local house
function HouseSet()
	house = not house and require 'scripts.house'() or nil
end
local buttons = require 'scripts.buttons'
GlobalReset()

cloud.shader:send('size', 1)
local cloudSize = 0
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


	lg.setColor(1,1,1,1)

	if cloudSize>0 then
		cloud:drawBillboardInstanced()
	end

	if camera.position[3]<50 then
		Tile:drawInstanced(Tile.shader1)
	else
		for i = math.max(1,math.floor(SelOpt)-14),math.min(#options, SelOpt+14) do
			local tile = options[i]
			local a = 2-math.abs(tile.translation[3]-camera.position[3])*.5
			lg.setColor(1,1,1,a)
			local i7 = math.floor(i/7)
			local angle = -(i+i7*.5)*math.pi/3+timer/20*((i7%2)*2-1)
			tile.translation = {-math.sin(angle)*2, math.cos(angle)*2, camera.top-.2+(math.floor(i/7)-SelOpt/7)*1.2}
			if a > 0 then
				tile:setRotation(-math.pi/2-(camera.position[3]-tile.translation[3])*.1,0,angle,0)
				tile:drawInstanced()
			end
		end
	end


	lg.setShader()
	buttons.devDraw()

	lg.setMeshCullMode("back")
	lg.setColor(.75,.75,.5,1)
	--	lg.print("FPS: "..love.timer.getFPS())
	--	lg.print(table.concat(selected, ";"))

	lg.setColor(1,1,1,1)
	local cur_time = love.timer.getTime()+min_dt/2
	if cur_time <= next_time then
		next_time = cur_time
		return
	end
	local preview = Images[Viewing][1]
	local w,h = preview:getDimensions()
	local m = math.min(w,h)
	lg.draw(preview, 0,Winh,0,128/m,128/m, 0,h)
	lg.print(Images[Viewing][4] .. "    " .. Images[Viewing][2] .. "x" .. Images[Viewing][3],0,Winh-32)
	buttons.draw()
	love.timer.sleep(next_time - cur_time)
end

