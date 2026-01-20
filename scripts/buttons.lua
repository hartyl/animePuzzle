local lg = love.graphics
local g3d = require 'g3d'

local selected = {0,0,0}
local delay = 0

local bSize = math.max(Winh/8,math.min(Winh/4, 96))

-- eee
local buttons = {
	{0				,0				,bSize,bSize, "reset"},
	{bSize			,0				,bSize,bSize, "shuffle"},
	{Winw-bSize		,0				,bSize,bSize, "dev"},
	{Winw-bSize		,bSize*2		,bSize,bSize, "canP"},
	{Winw-bSize		,bSize*3		,bSize,bSize, "canN"},
	{0				,Winh-bSize		,bSize,bSize, "TileSpin"},
	{bSize*2		,Winh-bSize		,bSize,bSize, "Floor"},
	{bSize*3		,Winh-bSize		,bSize,bSize, "Houses"},
	{Winw-bSize*3	,Winh-bSize		,bSize,bSize, "Width -"},
	{Winw-bSize*2	,Winh-bSize		,bSize,bSize, "Width +"},
	{Winw-bSize*3	,Winh-bSize*2	,bSize,bSize, "Height -"},
	{Winw-bSize*2	,Winh-bSize*2	,bSize,bSize, "Height +"},
	{Winw-bSize		,Winh-bSize*2	,bSize,bSize, "Speed -"},
	{Winw-bSize		,Winh-bSize		,bSize,bSize, "Speed +"},
	{bSize*3		,0				,bSize,bSize, "Config"},
	{(Winw-bSize)/2	,(Winh-bSize)/2	,bSize,bSize, "Change\nImage"},
}

local config = true

for _,v in pairs(buttons) do buttons[v[5]] = v end

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
	Tile:reset()
end

local selectCanvasResolution = 16
local selectCan
local function seCanReset()
	selectCan = lg.newCanvas(math.ceil(Winw/selectCanvasResolution), math.ceil(Winh/selectCanvasResolution), {msaa=0})
end
seCanReset()

Tile.spinned = false
local function confShow ()
	config = not config
	local k = config and 1 or -1
	for _,v in pairs({
		"Width -",
		"Width +",
		"Height -",
		"Height +",
		"Speed -",
		"Speed +",
	}) do
		buttons[v][1] = k* math.abs(buttons[v][1])
	end
end
confShow()

-- ccc
local actions = {
	GlobalReset,
	function ()
		Tile:shuffle()
	end,
	devChange,
	function ()
		selectCanvasResolution=math.min(selectCanvasResolution+1,18)
		seCanReset()
	end,
	function ()
		selectCanvasResolution=math.max(selectCanvasResolution-1,2)
		seCanReset()
	end,
	function ()
		if Tile.spinned then
			Tile:setRotation(math.pi+1,0,0)
		else
			Tile:setRotation(math.pi+1 +math.random()-.5,0,math.random()-.5)
		end
		Tile.spinned = not Tile.spinned
	end,
	PlaneSet,
	HouseSet,
	function ()
		Tile = require 'scripts.game'(im, math.max(Tile.width-1,2),Tile.height)
	end,
	function ()
		Tile = require 'scripts.game'(im, math.min(Tile.width+1,255),Tile.height)
	end,
	function ()
		Tile = require 'scripts.game'(im, Tile.width, math.max(Tile.height-1,2))
	end,
	function ()
		Tile = require 'scripts.game'(im, Tile.width, math.min(Tile.height+1,255))
	end,
	function ()
		SPD = math.max(1,SPD-1)
	end,
	function ()
		SPD = math.min(30,SPD+1)
	end,
	confShow,
	function ()
		LevelSelect = not LevelSelect
	end,
}

function love.keypressed(k)
	if Tile.anim < 1 then return end
	if k == 'left' then
		Tile:swipeAny(-1,0)
	end
	if k == 'right' then
		Tile:swipeAny(1,0)
	end
	if k == 'up' then
		Tile:swipeAny(0,-1)
	end
	if k == 'down' then
		Tile:swipeAny(0,1)
	end
	if k=='r' then
		GlobalReset()
	end
end

function love.mousepressed(x,y)
	delay = .025
	selected[1] = math.huge
	lg.setCanvas(selectCan)
	lg.clear()
	lg.setMeshCullMode("back")
		lg.setDepthMode("always", false)
	Tile.shader = Tile.shader2
	Tile.instanceMesh:setVertex(1, {Tile.emptySpot[1],Tile.emptySpot[2]})
	Tile:drawInstanced()
	Tile.instanceMesh:setVertex(1, {math.huge,math.huge})

	-- reset
	lg.push()
	lg.translate(0,Winh/selectCanvasResolution)
	lg.scale(1/selectCanvasResolution,1/selectCanvasResolution)
	for i, v in ipairs(buttons) do
		lg.setColor(0,0,i/255,1)
		v[2] = -v[2] - v[4]
		lg.rectangle("fill", unpack(v,1,4))
		v[2] = -v[2] - v[4]
	end
	lg.pop()
	-- shuffle

	lg.setColor(1,1,1,1)

	lg.setCanvas()
	local p = selectCan:newImageData()
	selected = {p:getPixel(x/selectCanvasResolution,(Winh-y)/selectCanvasResolution)}
	selected = {math.ceil(selected[2]*Tile.width),math.ceil(selected[1]*Tile.height), selected[3]*255}
end

function love.mousereleased()
	selected = {0,0,0}
	delay = math.huge
end

function love.mousemoved(_,_, dx,dy)
	if delay > 0 or config then return end
	if love.mouse.isDown(1) then
		if selected[1] > 0 then
			local x,y
			if math.abs(dx) > math.abs(dy) then
				y=0
				x=dx<0 and -1 or 1
			else
				x=0
				y=dy<0 and -1 or 1
			end
			if Tile.anim >= 1 then
				Tile:swipe(selected[1], selected[2], x,y)
			end
		elseif selected[3] == 0 then
			g3d.camera.firstPersonLook(-dx,-dy)
		end
	end
end

return {
	update = function (dt)
		if selected[3] ~= 0 then
			actions[selected[3]]()
			selected[3] = 0
		end
		delay = delay - dt
	end,
	draw = function()
		for _, v in ipairs(buttons) do
			lg.print(v[5],v[1]+4,v[2]+4)
			lg.rectangle("line", unpack(v,1,4))
		end
		if Tile.solved then
			lg.print("Well done!", Winw/2)
		end
	end,
	devDraw = function ()
		if devMode then
			lg.draw(selectCan,0,Winh,0,selectCanvasResolution,-selectCanvasResolution)
		end
	end
}
