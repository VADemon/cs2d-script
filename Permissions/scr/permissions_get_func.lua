
-- @Param id User's ID
-- @Param node (String) A node to check
-- @Param cstm_msg (True or Nil) Show the default message when the user don't have a permission?
-- @return (Boolean) Returns True or False after checking a node
function permissions.func.check(id,node,cstm_msg)
	local user_perm = permissions.func.internal.getUserPermissions(id)
	if user_perm[node]==false then
		if perm.config.debug then perm.func.output.found_nnode(id,node) end
		if not cstm_msg then permissions.output.denied(id) end
		return false
	end
	
	local groups_tocheck = permissions.func.internal.getgroupstocheck(id)
	for i=1,#groups_tocheck do --groups' perm nodes
		if permissions.groups[groups_tocheck[i]].permissions[node]==false then
			if perm.config.debug then perm.func.output.found_nnode(id,node) end
			if not cstm_msg then permissions.output.denied(id) end  --print default msg or not
			return false
		end
		
		if permissions.func.internal.checkMapNodes(groups_tocheck[i]) then --maps' perm nodes
			if permissions.groups[groups_tocheck[i]].map[map("name")].permissions[node]==false then
				if perm.config.debug then perm.func.output.found_nnode(id,node) end
				if not cstm_msg then permissions.output.denied(id) end
				return false
				
			elseif permissions.groups[groups_tocheck[i]].map[map("name")].permissions[node] then
				if perm.config.debug then perm.func.output.found_node(id,node) end
				return true
			end
		end
		
		if permissions.groups[groups_tocheck[i]].permissions[node] then --groups' perm nodes again
			if perm.config.debug then perm.func.output.found_node(id,node) end
			return true
		end
	end
	
	if user_perm[node] then
		if perm.config.debug then perm.func.output.found_node(id,node) end
		return true
	end
	
	print("[Permissions] User ("..id..") "..player(id,"name").." was checked for \""..node.."\", nothing found!")
	if not cstm_msg then permissions.output.denied(id) end
	return false
end

-- @return (String) Only one user's group (there could be more)
function permissions.func.getGroup(id)
	--print("Checking USGN")
	local usgnid=player(id,"usgn")
	if permissions.users[usgnid] and permissions.users[usgnid].group[1] then
		--print("Has an entry!")
		return permissions.users[usgnid].group[1]
	else
		--print("Default group!")
		return permissions.config.default_group
	end
end

-- @return (Table) User's groups (returns a table even if there's only one group)
function permissions.func.getAllGroups(id)
	local usgnid=player(id,"usgn")
	if permissions.users[usgnid] and permissions.users[usgnid].group then
		return permissions.users[usgnid].group
	end
	
	return {permissions.config.default_group}
end

-- @Param id Player's ID
-- @return (Integer) User's rank
function permissions.func.getRank(id)
	local usgnid=player(id,"usgn")
	local get_group_rank=perm.func.internal.group_option
	
	if usgnid==0 then
		return (get_group_rank(permissions.config.default_group, "rank") or 0)
	end
	
	local user_rank = permissions.func.internal.user_option(usgnid, "rank")
	if user_rank then
		return user_rank
	end
	
	local user_groups=perm.func.getAllGroups(id)
	local return_rank=get_group_rank(user_groups[1], "rank") or 0
	
	for i=2,#user_groups do
		--print(user_groups[i])
		local temp_rank=get_group_rank(user_groups[i], "rank")
		if temp_rank then
			if temp_rank>return_rank then
				return_rank=temp_rank
			end
		end
	end	
	
	--print(return_rank)
	return return_rank
end

-- @Param Player ID
-- @return Player's prefix
function permissions.func.getPrefix(id)
	local usgnid=player(id,"usgn")
	if usgnid~=0 then
		local prefix = permissions.func.internal.user_option(usgnid, "prefix")
		if prefix then
			return prefix
		end
	end
	
	local group_opt_check = permissions.func.internal.group_option
	local prefix = ""
	local groups = permissions.func.getAllGroups(id)
	
	for i=1,#groups do
		local pre = group_opt_check(groups[i], "prefix")
		--print(groups[i])
		if pre then
			prefix = prefix..pre
		end
	end
	
	return prefix
end

-- @Param Player ID
-- @return (String) Player's suffix
function permissions.func.getSuffix(id)
	local usgnid=player(id,"usgn")
	if usgnid==0 then
		return (permissions.groups[permissions.config.default_group].options.suffix or "")
	else
		if permissions.users[usgnid] and permissions.users[usgnid].options then
			return (permissions.users[usgnid].options.suffix or permissions.func.internal.getpresuf(id,"suffix"))
		end
	end
end

-- @Param id Player ID
-- @return (Table) With all player's groups and inheritances of these (Supports only single inheritance at the moment)
-- group1(inheritance: group2) and group4(inheritance: group3)
function permissions.func.getInheritance(id) -- To-Do: improve this function
	local user_groups=permissions.func.getAllGroups(id)
	local return_inheritance = {}
	local equals=true
	
	for i=1,#user_groups do
	local temp_gcheck=permissions.groups[user_groups[i]].inheritance --temp_groupcheck
		if temp_gcheck then
			for x=1,#temp_gcheck do
				for z=1,#return_inheritance do
					--print(temp_gcheck[x].."= IF ="..return_inheritance[z])
					if temp_gcheck[x]==return_inheritance[z] then
						--print(temp_gcheck[x].."=="..return_inheritance[z])
						equals=false
					end
				end
				if equals then
					--print("True, "..temp_gcheck[x])
					table.insert(return_inheritance,temp_gcheck[x])
					equals=true
				end
			end
		end
	end
	return return_inheritance
end

-- @Param id Player ID
-- @return (Table) User's exclusive permission nodes
function permissions.func.internal.getUserPermissions(id)
	local usgnid=player(id,"usgn")
	if permissions.users[usgnid] then
		if permissions.users[usgnid].permissions then
			return permissions.users[usgnid].permissions
		end
	end
	return {}
end

-- @Param group_name Group's name
-- @return (Table) Group's permissions nodes
function permissions.func.internal.getGroupPermissions(group_name)
	if perm.groups[group_name] then
		if perm.groups[group_name].permissions then
			return perm.groups[group_name].permissions
		end
	end
	return {}
end