req_lcd = {}
req_lcd.requests = {}

function reqcld2(id,mode,func,parameter) --parameters is optional
	if not (type(func) == "function") then
		msg("©255000000error in reqcld2: MISSING ARGUMENT: callback function (reqcld2(id,mode,func[,parameter]))")
		return 1
	end
	local temp = {}
	temp.id = id
	temp.mode = mode
	temp.func = func
	temp.parameter = parameter
	req_lcd.requests[#req_lcd.requests+1] = temp
	reqcld(id,mode)
end

addhook("clientdata","req_lcd.clientdata")
function req_lcd.clientdata(id,mode,x,y)
	i = 0
	while (i < #req_lcd.requests) do
		i = i + 1
		if (id == req_lcd.requests[i].id) and (mode == req_lcd.requests[i].mode) then
			req_lcd.requests[i].func(id,x,y,req_lcd.requests[i].parameter)
			req_lcd.requests[i] = req_lcd.requests[#req_lcd.requests]
			req_lcd.requests[#req_lcd.requests] = nil
			break
		end
	end
end