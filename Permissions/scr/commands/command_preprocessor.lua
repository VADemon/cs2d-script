addhook("say","permissions.say")


function permissions.say(id,say)
	print("command")
	local string=string
	local found=string.find(say," ")
	print(type(found))
	print("string.sub")
	if found and string.sub(say,1,found)=="!permissions " then --say:match("^!(%a+)") is slower than s.sub(say,1,s.find(say," ")) :P   PS: noob's invention is faster! /// old version: string.sub(say,1,5)=="!perm"
		local pat="%a+" --pattern
		local say=string.sub(say,found,-1) --творит чудеса!
		local arg={}
		print("words")
		for word in string.gmatch(say, pat) do 
			arg[#arg+1]=word --count own #arg? local k_arg
		end
		print("func=arg[1]")
		local func=arg[1]
		if permissions.commands[func] then
			--table.remove(arg,1) --removed the command itself, now the command is used as perm.node 28.12.12
			
			--if #arg==permissions.commands.meta.args[func] then --removed due to "hard" command syntax
			if not permissions.commands[func](id, unpack(arg)) then --the command function MUST return a positive value if all "went better than expected"
				--perm.output.error(id, "[Permissions] Wrong command syntax: "..perm.func.internal.command_help(func))
			end

			--elseif #arg>permissions.commands.meta.args[func] then--improve via local?
			--	msg2(id,"©255180180[Permissions] Too many arguments!"..perm.func.internal.command_help(func))
			--else
			--	msg2(id,"©255180180[Permissions] Not enough arguments!"..perm.func.internal.command_help(func))
			--end
		else
			perm.output.error(id, "[Permissions] Command \""..func.."\" does not exist! "..perm.func.internal.command_help(func))
		end
	end
end

function permissions.func.internal.command_help(func)
	if perm.commands.meta.help[func] then
		return perm.commands.meta.help[func]
	end
	return "(Help wasn't found for this command!)"
end

function permissions.func.internal.addCommand(name, args, help, syntax, funct)
	permissions.commands[name] = funct
	permissions.commands.meta.args[name] = args
	permissions.commands.meta.help[name] = help
	permissions.commands.meta.syntax[name] = syntax
end

-- @param target Group name or user USGN
-- @param targetType "user" or "group"
-- @param task "set" or "get"
-- @param option Which option?
-- @param value Set option to ...
-- @return success, errorMessage Requested value/true/false, if false then return errorMessage

function permissions.func.internal.commandOption(target, targetType, task, option, value)
	local success, msg
	if task=="get" then
		if targetType=="group" then
			return permissions.get.groupOption(target, option)
		else
			return permissions.get.userOption(target, option)
		end
	elseif task=="set" then
		if option=="prefix" or option=="suffix" or option=="rank" then
			if targetType=="group" then
				success, msg = permissions.set.groupOption(target, option, value)
			else
				success, msg = permissions.set.userOption(target, option, value)
			end
		end
		
	else
		perm.output.error("Unknown task, error code: 001")
	end
	
	if success then
		return true
	else
		return false, "This " ..targetType.." doesn't exist!"
	end
end