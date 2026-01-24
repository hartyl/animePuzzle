-- written by groverbuger for g3d
-- MIT license

Shaders = {}
local lg = love.graphics
local g3d = require "g3d"
local camera = g3d.camera
Winw, Winh = lg.getDimensions()

local min_dt = 1/60
local next_time = love.timer.getTime()

--require 'music'

local cloud = require 'scripts.cloud'
Background = lg.newImage("assets/animestyled_hdr.png")
Accept = lg.newImage("assets/accept.png")
Images = {
	{Background, 4,3, "Clouds", "https://www.youtube.com/watch?v=xvFZjo5PgG0"},
	{Accept, 2,2, "Acceptance", "https://www.youtube.com/watch?v=xvFZjo5PgG0"},
}
for y = 2, 10 do
for x=2, 10 do
	table.insert(Images,{require 'scripts.circle', x,y, "Test" .. #Images, "https://www.youtube.com/watch?v=xvFZjo5PgG0"})
end
end
table.insert(Images,{require 'scripts.circle', 127,127, "Dont touch this one", "https://www.youtube.com/watch?v=xvFZjo5PgG0"})
table.insert(Images,{Background, 8,6, "Clouds Hard", "https://www.youtube.com/watch?v=xvFZjo5PgG0"})
table.insert(Images,{Accept, 4,2, "Inacceptable", "https://www.youtube.com/watch?v=xvFZjo5PgG0"})
local background = g3d.newModel("assets/sphere.obj", Background, nil, nil, nil, "noMap")
local timer = 0

local newTile = require 'scripts.game'
Viewing = 1

camera.top = 300

Context = "play"

local options = {}
Options = options
for i in next, Images do
	local tile = newTile(unpack(Images[i]))
	table.insert(options,tile)
end

Tile = newTile(unpack(Images[Viewing]))
Tile.Viewing = Viewing
camera.lookAt(0,0,1,unpack(Tile.translation))

SelOpt = 10
local plane
function PlaneSet()
	plane = not plane and require 'scripts.world' or nil
end
local house
function HouseSet()
	house = not house and require 'scripts.house'() or nil
end
ConPre = Context
function CheckImage()
	Context = Context~="img" and "img" or ConPre
	Imx = 0
	Imy = 0
end
local buttons = require 'scripts.buttons'
GlobalReset()

cloud.shader:send('size', 1)
local cloudSize = 0
LevelSelect = false

local canvas
local function updateProjectionMatrix()
	camera.aspectRatio = Winw/Winh
	camera.fov = math.pi/2/camera.aspectRatio^.5
	camera.updateProjectionMatrix()
	canvas = lg.newCanvas(math.ceil(Winw/3),Winh,{msaa=2})
	for _,shader in next, Shaders do
		shader:send("projectionMatrix", g3d.camera.projectionMatrix)
	end
	SeCanReset()
	buttons.updateButtons(math.min(Winh/6, math.max(Winh/8,96)))
end

function love.update(dt)
	local ww,wh = lg.getDimensions()
	if ww~=Winw or wh ~= Winh then
		Winw, Winh = ww,wh
		updateProjectionMatrix()
	end
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

updateProjectionMatrix()

function love.draw()
if Context~="img" then
	g3d.shaderPrepare(g3d.shader)
	g3d.shaderPrepare(Tile.shader1)
	g3d.shaderPrepare(Tile.shader2)
	g3d.shaderPrepare(cloud.shader)
	--	ready
	lg.setCanvas(canvas)
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
		for i = math.max(1,math.floor(SelOpt)-14),math.min(#options, SelOpt+28) do
			local tile = options[i]
			local i = i-1
			local a = 2-math.abs(tile.translation[3]-camera.position[3])*.5
			lg.setColor(1,1,1,a)
			local i6 = math.floor(i/6)
			local angle = -(i+i6*.5)*math.pi/3+timer/20*((i6%2)*2-1)
			tile.translation = {-math.sin(angle)*2, math.cos(angle)*2, camera.top-.2+(math.floor(i/6)-SelOpt/6)*1.2}
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
	end
	buttons.draw()

	local cur_time = love.timer.getTime()+min_dt/2
	if cur_time <= next_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

