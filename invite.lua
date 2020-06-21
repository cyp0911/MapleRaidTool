welcomeWords = "《归来》公会插件提醒："

local inviteGuildFrame = CreateFrame("Frame")
inviteGuildFrame:RegisterEvent("CHAT_MSG_GUILD")


inviteGuildFrame:SetScript("OnEvent", function(self, event, message, sender, ...)

	inviteSender(sender, message, event)
	
end)

local inviteWhisperFrame = CreateFrame("Frame")
inviteWhisperFrame:RegisterEvent("CHAT_MSG_WHISPER")

inviteWhisperFrame:SetScript("OnEvent", function(self, event, message, sender, ...)

	inviteSender(sender, message, event)
	
end)


function inviteSender(sender, message, event)
	--print("senders" .. sender .. message .. event)
	if configs["inviteToggle"] >= 1 then
		if message == configs["inviteCode"] then
			if guildRosterDB[sender] == nil then
				rankIndex, rank = getGuildRank(sender)
			else
				rankIndex = guildRosterDB[sender]["rankIndex"]
				rank = guildRosterDB[sender]["rank"]
			end
			--print("rankIndex" .. rankIndex)
			if (rankIndex <= 8 and configs["inviteToggle"] ==1) or (rankIndex <10 and configs["inviteToggle"] == 2) or (configs["inviteToggle"] == 3) then
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
			if checkZone() ~= "city" and (checkZone() == "green" or checkZone() == "blue" or checkZone() == "kzk") then
				notifyLocation(GetZoneText())
			end
		end
	end
end

function notifyLocation(place)
	--SendChatMessage(welcomeWords .. "速度上YY91162686，不跑的都是老板，不分G，当前集合位置：" .. place, "RAID_WARNING", "Common", sender)
end

function getGuildRank(nameIn)
	numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers();
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

