local lg = love.graphics
local g3d = require 'g3d'
local camera = g3d.camera
local cloud = g3d.newModel("assets/circle.obj", require 'scripts.circle', {0,0,0}, nil, 0.5)
cloud.shader = lg.newShader('scripts/depthboard.glsl')
table.insert(Shaders,cloud.shader)
local i = table.insert
local p = {}
local r = math.random
local scale = 8
for x=-100,100,scale do
	local s = (1-(x>0 and x or -x)/100)^.5*100
	for y=-s,s,scale do
		for z=-50,50,5 do
			i(p, {x+(r()-.5)*scale,y+(r()-.5)*scale,z+(r()-.5)*scale,r()*scale/2})
		end
	end
end
cloud:instanciate(p)

local t = cloud.translation
t[3] = 100
cloud:setTranslation(unpack(t))
local changing = 1
local camSpeed = 0
local cloudSize = 0
CloudMove = 1
function cloud.update(dt)
	if LevelSelect == true then
		changing = 1
		camSpeed = math.min(camSpeed + dt, (camera.top-camera.position[3])/8)
	else
		camSpeed = math.max(camSpeed - dt*5, (1-camera.position[3])/8)
		if camera.position[3] < 50 then
			changing = -1
		end
	end
	if math.abs(camera.position[3]-(LevelSelect and camera.top or 1)) <= 0.001 and CloudMove>0 then
		CloudMove = 0
		ConPre = camera.position[3]<50 and "play" or "select"
		if Context ~= "img" and Context ~= "options" then
			Context = ConPre
		end
	end

	camera.position[3] = camera.position[3] + camSpeed * CloudMove

	cloudSize = math.min(1,math.max(0,cloudSize + changing * dt))
	cloud.shader:send('size', cloudSize)
	return cloudSize
end
return cloud
