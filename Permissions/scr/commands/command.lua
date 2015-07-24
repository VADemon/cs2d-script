local add = permissions.func.internal.addCommand

-- name , number of args , help, syntax , function
add("add", nil, "Adds a node to a group//user", "add <node> <value> user//group <usgn//name>", --[for//until time]
function (...)
local id, node, value, target, name, time_setting, time = ...

	if node then
		if target then
				if name then
					if target=="group" then
						if perm.group_exist(name) then
							permissions.group_add(name, node, perm.func.internal.toBoolean(value))
							msg2(id,"©255255255[Permissions] Node "..node.." = "..value.." was added to group \""..name.."\"!")
							return true
						else
							msg2(id,"©255180180[Permissions] Group \"".. name .."\" doesn't exist!")
						end
					elseif target=="user" then
						local name = tonumber(name)
						permissions.user_add(name, node, perm.func.internal.toBoolean(value))
						msg2(id,"©255255255[Permissions] Node "..node.." = "..value.." was added to user \'"..name.."\'!")
						return true
					else
						msg2(id,"©255180180[Permissions] There's no target "..target.."! Only \"user\" and \"group\" are applicable!")
						return false
					end
				end
			end
		end
	end

)

-- Group Commands
add("groups", nil, "Lists all registered groups", "groups",
function (id, cmd)
	if permissions.check(id, "permissions.command." .. cmd) then
		msg2(id, "Listing groups:")
		for k,_ in pairs(permissions.groups) do
			msg2(id, k)
			print(k)
		end
	end
	
	return true
end
)
--cmd: nodes player <name> | nodes group <name> [world]
add("group", nil, "Group managing commands", "group <name> <command> [option]", 
function (...)
	local id, cmd, name, command, value, arg1 = ...
	
	local commandFunc = {}
	commandFunc["setprefix"], commandFunc["getprefix"], commandFunc["setsuffix"], commandFunc["getsuffix"], commandFunc["getrank"], commandFunc["setrank"] = true,true,true,true,true,true
	
	if permissions.misc.groupExist(name) then
		--
		if commandFunc[ command ] then
			if not perm.check(id, "permissions.command.group." .. command) then return true; end
			
			local success, msg = permissions.func.internal.commandOption(name, "group", string.sub(command, 1, 3), string.sub(command, 4), value)
			if not success then
				perm.output.error("[Permissions] "..msg)
				return true
			end
			
		else
			perm.output.error(id, "[Permissions] Command \""..command.."\" doesn't exist!")
			return true
		end
		
		--
		
		if command == "create" and perm.check(id, "permissions.command.group.create") then
			local success, msg = permissions.create.group(name, {value})
			
			if value then value = " Parent group: \'" ..value.. "\'" end
			if success then
				perm.output.print(id, "[Permissions] Group \'" ..name.. "\' was sucessfully created!")
			else
				perm.output.error(id, msg)
			end
			
			return true
		end
		
		--
		
		if command=="delete" and perm.check(id, "permissions.command.group.delete") then --( perm.check(id, "permissions.command.group.delete") or perm.check(id, "permissions.command.group.delete." .. name) )
			perm.output.print("[Permissions] User " ..player(id, "name").. " (" ..id.. ", USGN: #" ..player(id, "usgn").. ") requested deleting group \'" ..name.. "\'!")
			if permissions.delete.group(name) then
				perm.output.print("[Permissions] Sucessfully deleted group \'" ..name.. "\'!")
				perm.output.print(id, "[Permissions] Sucessfully deleted group \'" ..name.. "\'!")
			else
				perm.output.print("[Permissions] Failed deleting group \'" ..name.. "\'! The chosen group doesn't exist!")
				perm.output.print(id, "[Permissions] Failed deleting group \'" ..name.. "\'! The chosen group doesn't exist!")
			end
			return true
		end
		
		--
		
		if command == "parents" then
			if value == "list" and perm.check(id, "permissions.command.group.parent.list") then
				perm.output.print(id, "[Permissions] Listing parents for group " ..name..":")
				for k,v in pairs(permissions.groups[name].inheritance) do
					perm.output.print(id, "["..k.."] " ..v)
				end
				
			elseif value == "add" and perm.check(id, "permissions.command.group.parent.add") then
				local success, msg = permissions.add.groupParent(name, arg1)
				if success then
					perm.output.print("[Permissions] Group \""..arg1.."\" was added as a parent for group \""..name.."\"!")
				else
					perm.output.error(id, msg)
				end
				
			elseif value == "remove" and perm.check(id, "permissions.command.group.parent.remove") then
				
			else
				perm.output.error(id, "[Permissions] Wrong sub-command \'"..value"\'!")
			end
		end
		
		--
	else
		perm.output.error(id, "[Permissions] You have to specify the group!")
	end
	
	return false
	
	end
)




