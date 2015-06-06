--Licensed under WTFPLv2; script made by VADemon
if not LUA_PRINT then LUA_PRINT = print end --prevents from crashes when reloading
function print(...)
local s = ""
local t = {...}
if type(t[1])=="string" then s = string.gsub(t[1], "\t", "    ") else s = tostring(t[1]) end --handles the first value
	if #t==1 then LUA_PRINT(s); return nil end --very small improvement
	for i=2, #t do
		if type(t[i])=="string" then
			s = s.. "    ".. string.gsub(t[i], "\t", "    ")
		else
			s = s.. "    "..(tostring(t[i]))
		end
	end
	
	LUA_PRINT(s)
end
--[[
function foo()
local x = 1
print(x)
coroutine.yield()
print(2*x)
end

--lua print("That=string",5,true,false,perm,player,file,x)
--lua file=io.open("test","r")
--lua x=coroutine.create(foo)


function test()
local runs = 100000
local time_start=os.clock()

--
	for z=1,runs do
		print("That=string",5,true,false,perm,player,file,x)
		--print("That=string")
	end
--

local time_end=os.clock()
LUA_PRINT("Runs: "..runs.." | Started: "..time_start..", ended: "..time_end..", diff: "..time_end-time_start)
end
]]