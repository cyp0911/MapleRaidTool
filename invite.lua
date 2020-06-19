welcomeWords = "《归来》公会插件提醒："

local inviteGuildFrame = CreateFrame("Frame")
inviteGuildFrame:RegisterEvent("CHAT_MSG_GUILD")


inviteGuildFrame:SetScript("OnEvent", function(self, event, message, sender, ...)

	inviteSender(sender, message)
	
end)

local inviteWhisperFrame = CreateFrame("Frame")
inviteWhisperFrame:RegisterEvent("CHAT_MSG_WHISPER")

inviteWhisperFrame:SetScript("OnEvent", function(self, event, message, sender, ...)

	inviteSender(sender, message)
	
end)


function inviteSender(sender, message)
	--print("senders" .. sender .. message)
	if inviteToggle >= 1 then
		if message == inviteCode then
			local rankIndex, rank = getGuildRank(sender)
			--print("rankIndex" .. rankIndex)
			if (rankIndex <= 8 and inviteToggle ==1) or (rankIndex <10 and inviteToggle == 2) or (inviteToggle == 3) then
				InviteUnit(sender)
				checkIfConvert()
				if rank == "out" then
					SendChatMessage(welcomeWords .. "【会外友人】你好，请速度上YY91162686，进不了频道请在团队吼，有专人拉，打工必须听指挥", "WHISPER", "Common", sender)
				else
					SendChatMessage(welcomeWords .. "【".. rank .."】会员你好，请速度上YY91162686，没有马甲请联系团长发放（遵照公会统一格式）", "WHISPER", "Common", sender)
				end
			elseif rankIndex > 8 and rankIndex <10 then
				SendChatMessage(welcomeWords .. "【".. rank .."】会员你好，您的会阶低于当前组团最低会阶，请稍后片刻，等待有团成员先入团，可提前进入YY91162686待命！", "WHISPER", "Common", sender)
			else 
				SendChatMessage(welcomeWords .. "会外朋友您好，打工请输入微信群密语，消费请报上消费部件，谢谢。如果进组请提前进入YY91162686待命！世界BOSS微信群请加yinpeng911入群", "WHISPER", "Common", sender)
			end
		end
	end
end

function getGuildRank(nameIn)

	numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers();
	--print("numofonline" .. numOnlineMembers)
	--SetGuildRosterShowOffline(true);
	SetGuildRosterShowOffline(true);
	GuildRoster();
	SortGuildRoster( "online" );
	for i=1, numTotalMembers do
		name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		if nameIn == name then
			--print("goster" .. name .. rankIndex .. zone .. status)
			return rankIndex, rank
		end
	end
	return 20, "out"
end

function checkIfConvert(sender)
	local currentMembers = GetNumGroupMembers()
	local myName = UnitName("player")
	if currentMembers >=2 then
		ConvertToRaid()
		if lootmethod ~= "master" then
			setLootMethods(myName)
		end
	end
	
		

end