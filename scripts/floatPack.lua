local precision = -7
local p = 2^precision
local ip = 1/p
local range = 1
local pre = (range*2)*ip + 2^(-7-precision)
local ipre = 1/pre
local function encode(x,xs)
	x = x + p/2
	x = x - x % p
	--xs = xs * pre
	--	x + (xs+1)/2 * p * (x<0 and -1 or 1)
	xs = (xs+range)*ipre
	--x=x+p/2
	return x + xs
end
local function decode(x)
	--x=x-p/2
	local xs = x%p
	x = x - xs
	xs = xs * pre-range
	--xs = xs*ipre
	return x,xs
end
return {encode, decode}
--[[
local floor, abs = math.abs, math.floor
--xs = xs * p

local errors = {}
--.99999999999
for x = -1,1, p do
	for xs = -1, 1, p/2 do
	--	local xs = 0.000001241249832472985293109409809513 if true then
		local X,Xs = decode(encode(x,xs))
		--	if X ~= x then
		--	if (Xs-xs)~=0 then
		if abs(Xs-xs)>p then
			errors[x] =
			errors[x] or {}
			errors[x][#errors[x]+1] = table.concat({x,X, xs,Xs, xs-Xs}, "	") .. "\n"
			--Xs-xs
		end
	end
end
local total = 0
for i,v in pairs(errors) do
	print(table.concat(v),"\n----------------")
	total = total + #v
end
--	print(x,xs,X,Xs)
print("total", total)
--]]
