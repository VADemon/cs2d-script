vlogging = {
	-- fileHandle	-- log file handle
	flushTimer = 3,	-- in seconds, how often to save logs to disk
	-- flushCounter	-- used by the hook
}
vlogging.folder = "sys/logs/"

function vlogging.init()
	vlogging.fileHandle = vlogging.makeLogFile()
	
	
	----
	
	if vlogging.__ORIGINAL_ADDHOOK then
		addhook = vlogging.__ORIGINAL_ADDHOOK
		vlogging.__ORIGINAL_ADDHOOK = nil
	end
	
	vlogging.__ORIGINAL_ADDHOOK = addhook

	function addhook(hook, func, priority)
		vlogging.log("[ADDHOOK] ".. hook ..", ".. func ..", ".. tostring(priority))
		
		vlogging.__ORIGINAL_ADDHOOK(hook, func, priority or 0)
	end
	
	print("©175025255VLOGGING Script was loaded!")
end

function vlogging.getPlayerInfo(id)
	return ("ID: ".. id .."\tIP: ".. player(id, "ip").. "\t".. player(id, "name") .. "\t#".. player(id, "usgn").. "\t\t")
end

addhook("say", "vlogging.say", -985000)
addhook("sayteam", "vlogging.say", -985000)
function vlogging.say(id, txt)
	
	if rp_vip or rp_Adminlevel then
		local viplevel = rp_vip and rp_vip[id] or "nothing"
		local adminlevel = rp_Adminlevel and rp_Adminlevel[id] or "nothing"
		
		vlogging.log( vlogging.getPlayerInfo(id) .. "said: ".. txt .."\t|\tRP Level: VIP(".. viplevel ..") ADMIN(".. adminlevel ..")")
	else
		vlogging.log( vlogging.getPlayerInfo(id) .. "said: ".. txt)
	end
end

addhook("join", "vlogging.join")
function vlogging.join(id)
	vlogging.log( vlogging.getPlayerInfo(id) .. "joined! Port: ".. player(id, "port"))
	
	timer(15000, "vlogging.join_delayed", tostring(id))
end

-- some information like spraycolor is not available instantly, player has to load the map first
function vlogging.join_delayed(id)
	id = tonumber(id)
	
	vlogging.log( vlogging.getPlayerInfo(id) .. " join info: Sprayname: ".. player(id, "sprayname") .." Spraycolor: ".. player(id, "spraycolor"))
end

addhook("leave", "vlogging.leave")
function vlogging.leave(id, reason)
	vlogging.log( vlogging.getPlayerInfo(id) .. "left the game. Reason: " .. reason)
end

addhook("vote", "vlogging.vote")
function vlogging.vote(id, mode, target)
	if mode == 1 then
		vlogging.log( vlogging.getPlayerInfo(id) .. "voted to kick: ".. tostring(target) .." Info:\n\t\t" .. vlogging.getPlayerInfo(target))
	elseif mode == 2 then
		vlogging.log( vlogging.getPlayerInfo(id) .. "voted for map: ".. tostring(target) )
	end
end

addhook("name", "vlogging.name")
function vlogging.name(id, oldName, newName, forced)
	vlogging.log( vlogging.getPlayerInfo(id) .. "name changed to: ".. newName .. " By Servercmd? ".. (forced==1 and "yes" or "no"))
end


function vlogging.log(txt)
	vlogging.fileHandle:write("[".. os.date("%H:%M:%S") .."] " .. txt .. "\n")
end

function vlogging.makeLogFile()
	local filename = "vlog_" .. os.date("%Y.%m.%d-%H.%M.%S"):gsub("[^A-z0-9%s%.]", "-"):gsub("%s", "_") .. ".log"
	print("[VLOGGING] New log file name: ".. vlogging.folder .. filename)
	
	local fileHandle = io.open(vlogging.folder .. filename, "a")
	
	return fileHandle
end

addhook("second", "vlogging.flushLog")	-- saves logs to disk
function vlogging.flushLog()
	if not vlogging.flushCounter then
		vlogging.flushCounter = vlogging.flushTimer
	end
	
	vlogging.flushCounter = vlogging.flushCounter - 1
	
	if vlogging.flushCounter == 0 then
		vlogging.flushCounter = vlogging.flushTimer
		
		if vlogging.fileHandle then
			vlogging.fileHandle:flush()
			
		end
	end
end


vlogging.init()