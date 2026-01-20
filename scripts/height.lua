local Far = require 'g3d'.camera.farClip
local FAR = Far^-3*1000
local far = Far * .8
return function (x,y)
	return (
	-(x+x-far)*x*(x+x+far))
	*FAR
end
