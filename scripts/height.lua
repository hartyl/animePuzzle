local cos = math.sin
return function (x,y)
	return cos(x/200)*30+cos(y/500)*20-(x*x+y*y)*0.00005
end
