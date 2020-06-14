local inviteFrame = CreateFrame("Frame")
inviteFrame:RegisterEvent("CHAT_MSG_GUILD")

--[[
message("lol")

inviteFrame:SetScript("OnEvent", function(self, event, message, sender, ...)
	if message == "枫叶牛" then
		--SendChatMessage("【归来】公会插件自动回复：帅！", "Guild")
	end
	
	if message == "233" then
		
	end
end)

--]]