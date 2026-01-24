local lg = love.graphics local g3d = require 'g3d'

local selected = {0,0,0}
local delay = 0

local bSize
local buttons = {}
local cross = require 'scripts.cross'
local crossw, crossh = cross:getDimensions()
local function updateButtons(s)
	bSize = s
	for i,v in next, {
		{0		,0			,s,s	,"reset"			,"always"	},
		{s		,0			,s,s	,"shuffle"			,"play"		},
		{-s		,0			,s,s	,"dev"				,"always"	},
		{-s		,s*2		,s,s	,"canP"				,"options"	},
		{-s		,s*3		,s,s	,"canN"				,"options"	},
		{0		,-s*3		,s,s	,"TileSpin"			,"options"	},
		{0		,-s*2		,s,s	,"Floor"			,"options"	},
		{0		,-s			,s,s	,"Houses"			,"options"	},
		{-s*3	,-s			,s,s	,"Width -"			,"options"	},
		{-s*2	,-s			,s,s	,"Width +"			,"options"	},
		{-s*3	,-s*2		,s,s	,"Height -"			,"options"	},
		{-s*2	,-s*2		,s,s	,"Height +"			,"options"	},
		{-s		,-s*2		,s,s	,"Speed -"			,"options"	},
		{-s		,-s			,s,s	,"Speed +"			,"options"	},
		{0		,s			,s,s	,"Config"			,"always"	},
		{s*5  	,(Winh-s)/2	,s*2,s	,"Pick an\nImage"	,"play"		},
		{-s*2	,-s			,s*2,s	,"Confirm"			,"select"	, img=Accept, w=s/480*2, h=s/270},
		{-s*3	,-s			,s,s	,"Cancel"			,"select"	, img=cross, w=s/crossw, h=s/crossh},
		{0		,-s			,s,s	,""					,"always"	, img=Images[Viewing][1]},
		{0		,-s			,s,s	,"exit"				,"img"		, img=cross, w=s/crossw, h=s/crossh},
		{0		,-s*2		,s,s	,"Zoom -"			,"img"		},
		{0		,-s*3		,s,s	,"Zoom +"			,"img"		},
		{-s*3	,0			,s*3,s*2,"Open in Explorer"	,"img"		},
	} do
		for j,b in next,v do
			buttons[i] = buttons[i] or {}
			buttons[i][j] = b
		end
	end
end

updateButtons(math.max(Winh/8,math.min(Winh/6, 96)))
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
bcon["img"][buttons.reset.id]=nil
bcon["img"][buttons.Config.id]=nil
bcon["img"][buttons[""].id]=nil

local devMode = false
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
		lg.draw(preview, Winw/2+Imx,Winh/2+Imy,0,M/m,M/m, w/2,h/2)
	else
		local bs = bSize*1.5
		local hei = h/m*bs
		b[2] = Winh-hei
		b[3] = w/m*bs
		b[4] = hei
		b.w = bs/m
		b.h = bs/m
		b[5] = im[4] .. "    " .. im[2] .. "x" .. im[3]
		b.img = preview
	end
end
imgUpdate()

local selectCanvasResolution = 16
local selectCan
function SeCanReset()
	selectCan = lg.newCanvas(math.ceil(Winw/selectCanvasResolution), math.ceil(Winh/selectCanvasResolution), {msaa=0})
end
SeCanReset()

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
		SeCanReset()
	end,
	function ()
		selectCanvasResolution=math.max(selectCanvasResolution-1,2)
		SeCanReset()
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

local swipeLock = false
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
			local r = (i)%128
				lg.setColor(r/128,(i-r)/128^2,0,1)
				tile:drawInstanced(Tile.shader3)
			end
		else
			Tile:drawInstanced(Tile.shader2)
		end
	end
	-- UI
	lg.push()
	--lg.translate(0,Winh/selectCanvasResolution)
	lg.scale(1/selectCanvasResolution,1/selectCanvasResolution)
	lg.setShader()
	for _, b in pairs(bcon[Context]) do
		lg.setColor(0,0,(b.id)/128,1)
		lg.rectangle("fill", b[1]%Winw,b[2]%Winh, unpack(b,3,4))
	end
	lg.pop()

	lg.setColor(1,1,1,1)

	lg.setCanvas()
	local p = selectCan:newImageData()
	local w,h =  p:getDimensions()
	local px,py = x/Winw*w,(y)/Winh*h
	local r,g,b
	if px>0 and py>0 and px<w and py<h then
		r,g,b = p:getPixel(px,py)
	else
		r,g,b = 0,0,0
	end
	if LevelSelect then
		selected = {math.ceil(r*128)+math.ceil(g*128)*128,0,math.ceil(b*128)}
	else
		selected = {math.ceil(r*Tile.width),math.ceil(g*Tile.height), math.ceil(b*128)}
		swipeLock = false
	end
end

local moved = false
function love.mousereleased()
	if LevelSelect then
		if not moved and selected[1]>0 or selected[2]>0 then
			Viewing = selected[1]
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
		if not LevelSelect and selected[1] > 0 or selected[2]>0 and Tile.anim >= 1 then
			local x,y
			if math.abs(dx) > math.abs(dy) then
				y=0
				x=dx<0 and -1 or 1
			else
				x=0
				y=dy<0 and -1 or 1
			end
			swipeLock = swipeLock or Tile:swipe(selected[1], selected[2], x,y)
		end
		if not swipeLock and selected[3] == 0 then
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
		bcon["play"][b.id] = (Tile.done and not LevelSelect and not QueueReset) and b or nil
		if not LevelSelect and QueueReset and g3d.camera.position[3] <= 1+2^-10  then
			GlobalReset()
			QueueReset = false
		end
	end,
	draw = function()
		--buttons.reset[5] = table.concat({love.mouse.getPosition()}, "\n") .. "\n\n" ..
		--table.concat(selected,"\n")
		imgUpdate()

		if Context == 'options' then
			lg.setColor(0,0,0,.3)
			lg.rectangle("fill",0,0,Winw,Winh)
			lg.setColor(1,1,1,1)
		end
		local i = 0
		for _, b in pairs(bcon[Context]) do
			local x,y = b[1]%Winw,b[2]%Winh
			if b.img then
				lg.setColor(1,1,1,1)
				lg.draw(b.img,x,y,0,b.w,b.h)
			end
			lg.setColor(1,1,.4,1)
			lg.print(b[5],x+4,y+4)
			lg.rectangle("line",x,y, unpack(b,3,4))
			i=i+1
		end
		lg.setColor(1,1,1,1)
		if Tile.done and Context == "play" then
			lg.print("Well done!", Winw/2)
		end
	end,
	devDraw = function ()
		if devMode then
			lg.setColor(1,1,1,1)
			lg.draw(selectCan,0,0,0,selectCanvasResolution)
		end
	end,
	updateButtons = updateButtons,
}
