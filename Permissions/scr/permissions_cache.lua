if perm.config.silent_loading then parse("debuglua 0") end
addhook("join","permissions.func.cache.addentries")
addhook("leave","permissions.func.cache.clearcache")
if perm.config.silent_loading then parse("debuglua 1") end

function permissions.func.cache.addentries(id)
	if perm.config.debug then print("[Permissions] ("..id..") "..player(id,"name").." joined, adding entries - caching!") end
	local usgnid=player(id,"usgn")
	
	perm.cache.perm_nodes[id] = {}
	perm.cache.user_groups[id] = perm.func.internal.getgroupstocheck(id)
	
	perm.cache.rank[id] = perm.func.getRank(id)
	perm.cache.prefix[id] = perm.func.getPrefix(id)
	perm.cache.suffix[id] = perm.func.getSuffix(id)
	
	for i=1,#permissions.cache.user_groups[id] do

		-- GROUP+INHERITANCES PERMISSIONS --
		for k,v in pairs(perm.func.internal.getGroupPermissions(perm.cache.user_groups[id][i])) do
			if permissions.cache.perm_nodes[id][k]~=true then --"true" has a higher priority
				permissions.cache.perm_nodes[id][k] = v
			end
		end
		
		-- MAP PERMISSIONS --
		if permissions.func.internal.checkMapNodes(permissions.cache.user_groups[id][i]) then
			for k,v in pairs(permissions.groups[permissions.cache.user_groups[id][i]].map[map("name")].permissions) do
				if permissions.cache.perm_nodes[id][k]~=true then --"true" has a higher priority
					permissions.cache.perm_nodes[id][k] = v
				end
			end
		end
	end
	
	-- USER PERMISSIONS --
	for k,v in pairs(permissions.func.internal.getUserPermissions(id)) do
		permissions.cache.perm_nodes[id][k] = v --highest priority
	end
	
	for k,v in pairs(permissions.cache.perm_nodes[id]) do
		print(k)
	end
	for k,v in pairs(perm.cache.user_groups[id]) do
		print(v)
	end
	
end

function permissions.func.cache.clearcache(id)
	permissions.cache.perm_nodes[id] = {}
	permissions.cache.user_groups[id] = {}
	permissions.cache.rank[id] = 0
	permissions.cache.prefix[id] = ""
	permissions.cache.suffix[id] = ""
end
