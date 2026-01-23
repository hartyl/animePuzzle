local lg = love.graphics
local rad = 96
local crossCan = lg.newCanvas(rad,rad,{format="r8"})
lg.setCanvas(crossCan)
local start = -0.0-- -rad+.5-
local e = rad*2
local w = 16
for x=start,e do
	for y=start,e do
		-- lg.setColor(1,1,1,)
		lg.setColor(
			(w-x+y)*-1*
			(-(-w-x+y)*1)
			* -(rad+w-x-y)*-1*
			(-(rad-w-x-y)*1) ,0,1,1)
		lg.rectangle("fill",x,y,1,1)
	end
end
lg.setColor(0,1,1,1)
-- lg.rectangle("line",-1,-1,rad+1,rad+1)
lg.setCanvas()
local cross = lg.newImage(crossCan:newImageData())
return cross
