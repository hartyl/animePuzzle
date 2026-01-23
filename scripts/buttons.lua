local lg = love.graphics local g3d = require 'g3d'

local selected = {0,0,0}
local delay = 0

local bSize = math.max(Winh/8,math.min(Winh/4, 96))

-- eee
local buttons = {
	{0				,0				,bSize,bSize,		"reset"				,"always"	},
	{bSize			,0				,bSize,bSize,		"shuffle"			,"play"		},
	{Winw-bSize		,0				,bSize,bSize,		"dev"				,"always"	},
	{Winw-bSize		,bSize*2		,bSize,bSize,		"canP"				,"options"	},
	{Winw-bSize		,bSize*3		,bSize,bSize,		"canN"				,"options"	},
	{bSize*2		,Winh-bSize*2	,bSize,bSize,		"TileSpin"			,"options"	},
	{bSize*2		,Winh-bSize		,bSize,bSize,		"Floor"				,"options"	},
	{bSize*3		,Winh-bSize		,bSize,bSize,		"Houses"			,"options"	},
	{Winw-bSize*3	,Winh-bSize		,bSize,bSize,		"Width -"			,"options"	},
	{Winw-bSize*2	,Winh-bSize		,bSize,bSize,		"Width +"			,"options"	},
	{Winw-bSize*3	,Winh-bSize*2	,bSize,bSize,		"Height -"			,"options"	},
	{Winw-bSize*2	,Winh-bSize*2	,bSize,bSize,		"Height +"			,"options"	},
	{Winw-bSize		,Winh-bSize*2	,bSize,bSize,		"Speed -"			,"options"	},
	{Winw-bSize		,Winh-bSize		,bSize,bSize,		"Speed +"			,"options"	},
	{bSize*3		,0				,bSize,bSize,		"Config"			,"always"	},
	{Winw/2-bSize  ,(Winh-bSize)/2	,bSize*2,bSize,		"Pick an\nImage"	,"play"		},
	{Winw-bSize*2	,Winh-bSize		,bSize*2,bSize,		"Confirm"			,"select"	, img=Accept, w=bSize/480*2, h=bSize/270},
	{Winw-bSize*3	,Winh-bSize		,bSize,bSize,		"Cancel"			,"select"	, img=require 'scripts.cross', w=bSize/96, h=bSize/96},
	{0				,Winh-bSize		,bSize,bSize,		""					,"always"	, img=Images[Viewing][1]},
	{0				,Winh-bSize*2	,bSize,bSize,		"Zoom -"			,"img"		},
	{0				,Winh-bSize*3	,bSize,bSize,		"Zoom +"			,"img"		},
	{Winw-bSize*3	,Winh-bSize*2	,bSize*3,bSize*2,	"Open in Explorer"	,"img"		},
}

local bcon = {}
for i,v in pairs(buttons) do
	bcon[v[6]] = not bcon[v[6]] and {} or bcon[v[6]]
	v.id = i
end
bcon["always"] = nil
bcon[""] = {}

local contexts = {}
for i in pairs(bcon) do
	table.insert(contexts, i)
end

for _,button in pairs(buttons) do
	buttons[button[5]] = button

	local s = button[6]
	local t = (s == "always" and contexts or type(s) == "table" and s or {s})
	for _,v in pairs(t) do
		bcon[v][button.id] = button
	end
end

bcon["options"][buttons[""].id]=nil
bcon["img"][buttons.dev.id]=nil

local devMode = true
local function devChange ()
	devMode = not devMode
end

function GlobalReset()
	--g3d.camera.position = {0,0,1}
	selected[3] = 0
	Tile:reset()
	Tile:swipe(1,1,-1,0)
end

Imx=0
Imy=0
Imz = 0

local function imgUpdate()
	local im = Images[Viewing]
	local preview = im[1]
	local w,h = preview:getDimensions()
	local m = math.min(w,h)
	local M = math.min(Winw,Winh) * 1.1^Imz
	local b = buttons[""]
	if Context=="img" then
		local hei = bSize
		b[2] = Winh-hei
		b[3] = hei
		b[4] = hei
		b[5] = ""
		b.img = require 'scripts.cross'
		b.w = bSize/96
		b.h = bSize/96
		lg.draw(preview, Winw/2+Imx,Winh/2+Imy,0,M/m,M/m, w/2,h/2)
	else
		local hei = h/m*128
		b[2] = Winh-hei
		b[3] = w/m*128
		b[4] = hei
		b.w = 128/m
		b.h = 128/m
		b[5] = im[4] .. "    " .. im[2] .. "x" .. im[3]
		b.img = preview

	end
end
imgUpdate()

local selectCanvasResolution = 16
local selectCan
local function seCanReset()
	selectCan = lg.newCanvas(math.ceil(Winw/selectCanvasResolution), math.ceil(Winh/selectCanvasResolution), {msaa=0})
end
seCanReset()

Tile.spinned = false
local function confShow ()
	Context = Context ~= "options" and "options" or ConPre
end

local QueueReset = false

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
		Tile = require 'scripts.game'(Tile.texture, math.max(Tile.width-1,2),Tile.height)
		Tile:swipe(1,1,-1,0)
	end,
	function ()
		Tile = require 'scripts.game'(Tile.texture, math.min(Tile.width+1,255),Tile.height)
		Tile:swipe(1,1,-1,0)
	end,
	function ()
		Tile = require 'scripts.game'(Tile.texture, Tile.width, math.max(Tile.height-1,2))
		Tile:swipe(1,1,-1,0)
	end,
	function ()
		Tile = require 'scripts.game'(Tile.texture, Tile.width, math.min(Tile.height+1,255))
		Tile:swipe(1,1,-1,0)
	end,
	function ()
		SPD = math.max(1,SPD-1)
	end,
	function ()
		SPD = math.min(30,SPD+1)
	end,
	confShow,
	function ()
		LevelSelect = true
		CloudMove = 1
		Context = ""
	end,
	function ()
		LevelSelect = false
		Tile = require'scripts.game'(unpack(Images[Viewing]))
		QueueReset = true
		CloudMove = 1
		Context = ""
	end,
	function ()
		LevelSelect = false
		Viewing = Tile.Viewing
		CloudMove = 1
		Context = ""
	end,
	CheckImage,
	function ()
		Imz = Imz - 1
	end,
	function ()
		Imz = Imz + 1
	end,
	function ()
		love.system.openURL(Images[Viewing][5])
	end
	--	new button action
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
	lg.setMeshCullMode("none")
	lg.setDepthMode("always", false)
	--- TODO
	if Context~="img" then
		if LevelSelect then
			g3d.shaderPrepare(Tile.shader3)
			for i = math.max(1,math.floor(SelOpt)-14),math.min(#Options, SelOpt+28) do
				local tile = Options[i]
				lg.setColor(((i)/127)%1,math.floor((i)/127)/127,0,1)
				tile:drawInstanced(Tile.shader3)
			end
		else
			Tile:drawInstanced(Tile.shader2)
		end
	end
	-- UI
	lg.push()
	lg.translate(0,Winh/selectCanvasResolution)
	lg.scale(1/selectCanvasResolution,1/selectCanvasResolution)
	lg.setShader()
	for _, b in pairs(bcon[Context]) do
		lg.setColor(0,0,(b.id)/127,1)
		b[2] = -b[2] - b[4]
		lg.rectangle("fill", unpack(b,1,4))
		b[2] = -b[2] - b[4]
	end
	lg.pop()

	lg.setColor(1,1,1,1)

	lg.setCanvas()
	local p = selectCan:newImageData()
	local r,g,b = p:getPixel(x/selectCanvasResolution*2,(Winh-y)/selectCanvasResolution*2)
	if LevelSelect then
	selected = {math.ceil(r*127),math.ceil(g*127),math.ceil(b*127)}
	else
	selected = {math.ceil(r*Tile.width),math.ceil(g*Tile.height), math.ceil(b*127)}
	end
end

local moved = false
function love.mousereleased()
	if LevelSelect then
		if not moved then
			if selected[1]>0 or selected[2]>0 then
				Viewing = selected[1]+selected[2]*255
			end
		end
		moved = false
	end
	selected = {0,0,0}
	delay = math.huge
end

function love.mousemoved(_,_, dx,dy)
	if delay > 0 or Context=="options" then return end
	if love.mouse.isDown(1) then
		if Context=="img" then
			Imx = Imx + dx
			Imy = Imy + dy
			return
		end
		if not LevelSelect and selected[1] > 0 or selected[2]>0 then
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
			if Context == "select" then
				SelOpt = math.max(-2*7, math.min(#Options+2*7, SelOpt + dy/10))
				dy = 0
				moved=true
			end
			g3d.camera.firstPersonLook(-dx,-dy)
		end
	end
end

return {
	update = function (dt)
		if selected[3] ~= 0 then
			local act = actions[selected[3]]
			assert(act, "action #" .. selected[3] .. " doesn't exists")
			act()
			selected[3] = 0
		end
		delay = delay - dt
		local b = buttons["Pick an\nImage"]
		b[1] = math.abs(b[1])*((Tile.done and not LevelSelect and not QueueReset) and 1 or -1)
		if not LevelSelect and QueueReset and g3d.camera.position[3] <= 1+2^-10  then
			GlobalReset()
			QueueReset = false
		end
	end,
	draw = function()
		buttons.reset[5] = table.concat({love.mouse.getPosition()}, "\n") .. "\n\n" ..
		table.concat(selected,"\n")
		imgUpdate()

		if Context == 'options' then
			lg.setColor(0,0,0,.3)
			lg.rectangle("fill",0,0,Winw,Winh)
			lg.setColor(1,1,1,1)
		end
		local i = 0
		for _, b in pairs(bcon[Context]) do
			if b.img then
				lg.setColor(1,1,1,1)
				lg.draw(b.img,b[1],b[2],0,b.w,b.h)
			end
			lg.setColor(1,1,.4,1)
			lg.print(b[5],b[1]+4,b[2]+4)
			lg.rectangle("line", unpack(b,1,4))
			i=i+1
		end
		lg.setColor(1,1,1,1)
		if Tile.done and Context == "play" then
			lg.print("Well done!", Winw/2)
		end
	end,
	devDraw = function ()
		if devMode then
			lg.draw(selectCan,0,Winh,0,selectCanvasResolution,-selectCanvasResolution)
		end
	end
}
