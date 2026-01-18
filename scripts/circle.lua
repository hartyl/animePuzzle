local lg = love.graphics
local cos, pi = math.cos, math.pi
local rad = 4
local circleCan = lg.newCanvas(rad*2,rad*2,{format="r8"})
lg.setCanvas(circleCan)
local start = -rad+.5--1.5
local e = rad*2
for x=start,e do
	for y=start,e do
		-- lg.setColor(1,1,1,)
		local dist = (x*x+y*y)^.5/(rad)
		lg.setColor(cos(dist*pi/2),1,1,1)
		lg.rectangle("fill",x+rad,y+rad,1,1)
	end
end
lg.setColor(0,1,1,1)
-- lg.rectangle("line",-1,-1,rad+1,rad+1)
lg.setCanvas()
local circle = lg.newImage(circleCan:newImageData())
circle:setWrap("clampzero","clampzero")
return circle
