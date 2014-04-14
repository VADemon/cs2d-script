local debugluaState = tonumber(game("debuglua"))
if worldedit.config.silentLoading and debugluaState == 1 then parse("debuglua 0") end
-- ===

addhook("say", "worldedit.chat.processor")
addhook("join", "worldedit.data.join")
addhook("leave", "worldedit.data.leave")
--addhook("second", "worldedit.image.test")

-- ===
parse("debuglua " .. debugluaState) -- restore debuglua value