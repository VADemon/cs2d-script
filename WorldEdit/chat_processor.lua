if not worldedit.chat then worldedit.chat = {} end
worldedit.chat.commandList = {}

worldedit.chat.commandName = "!worldedit" -- temporarily
worldedit.chat.commandName2 = "!we"


function worldedit.chat.processor(id, txt)
	if txt:sub(1, 1) ~= "!" then
		return false
	end
	-- === --
	
	local firstSpace = string.find(txt, " ") - 1

	-- WE Commands?
	if txt:sub(1, firstSpace) == worldedit.chat.commandName or txt:sub(1, firstSpace) == worldedit.chat.commandName2 then
		
		local delimeter = "%S+"
		local argList = worldedit.chat.tokenize(txt, delimeter)
		
		if worldedit.chat.commandList[ argList[2] ] then -- command exists
		
			worldedit.chat.commandList[ argList[2] ]( id, argList ) -- execute command
			return 1 -- command exists thus true
		else
			worldedit.errorMsg2(id, "Command '" .. argList[2] .. "' doesn't exist!")
			return 0
		end
	else
		
		return 0-- return nothing, not a WE command
	end
end

function worldedit.chat.addCommand(command, alias, func)
	worldedit.chat.commandList[ command ] = func
	if alias ~= "" then
		worldedit.chat.commandList[ alias ] = worldedit.chat.commandList[ command ]
	end
end


function worldedit.chat.tokenize(str, delimeter)
	local wordList = {}
	local tempStr = ""
	local concatenateThis = false
	
	for word in str:gmatch(delimeter) do
		local char = word:sub(1,1)
		if char == "'" or char == '"' then
			concatenateSuccessor = true
			tempStr = word
		else
			if concatenateSuccessor then
				tempStr = tempStr .. " " .. word
				local char = word:sub(-1,-1)
				if char == "'" or char == '"' then
					wordList[ #wordList + 1 ] = tempStr
					tempStr = ""
					concatenateSuccessor = false
				end
			else
				wordList[ #wordList + 1 ] = word
			end
		end
		--print(word)
	end
	
	return wordList
end