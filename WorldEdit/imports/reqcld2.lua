reqcld2_data = {}
reqcld2_data.requests = {}
-- VADemon > Updated 14.04.2014 to support reqcld optional parameters
function reqcld2(id, mode, parameter, func, custom_parameter) -- custom_parameters is optional
	if not (type(func) == "function") then
		msg("©255000000error in reqcld2: MISSING ARGUMENT: callback function (reqcld2(id, mode, parameter,func[,custom parameter]))")
		return 1
	end
	local temp = {}
	temp.id = id
	temp.mode = mode
	temp.func = func
	temp.parameter = parameter
	temp.custom_parameter = custom_parameter
	reqcld2_data.requests[#reqcld2_data.requests+1] = temp
	reqcld(id,mode)
end

addhook("clientdata","reqcld2_data.clientdata")
function reqcld2_data.clientdata(id,mode,x,y)
	i = 0
	while (i < #reqcld2_data.requests) do
		i = i + 1
		if (id == reqcld2_data.requests[i].id) and (mode == reqcld2_data.requests[i].mode) then
			reqcld2_data.requests[i].func(id,x,y,reqcld2_data.requests[i].custom_parameter)
			reqcld2_data.requests[i] = reqcld2_data.requests[#reqcld2_data.requests]
			reqcld2_data.requests[#reqcld2_data.requests] = nil
			break
		end
	end
end