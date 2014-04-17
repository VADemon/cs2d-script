local debugluaState = tonumber(game("debuglua"))
if worldedit.config.silentLoading and debugluaState == 1 then parse("debuglua 0") end
-- ===

addhook("say", "worldedit.chat.processor")
addhook("join", "worldedit.data.join")
addhook("leave", "worldedit.data.leave")


-- ===
parse("debuglua " .. debugluaState) -- restore debuglua value