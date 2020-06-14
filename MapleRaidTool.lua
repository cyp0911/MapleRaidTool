SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
SlashCmdList.FRAMESTK = function()
		LoadAddOn("Blizzard_DebugTools");
		FrameStackTooltip_Toggle();
end

SLASH_RELOAD1 = "/rl"; -- new slash command for showing framestack tool
SlashCmdList.RELOAD = function()
		ReloadUI();
end

SLASH_CHECKBUFF1 = "/cb"; -- new slash command for showing framestack tool
SlashCmdList.CHECKBUFF = function()
		checkDebuffFromList(debuffCheckList);
end

SLASH_MPTool1 = "/mp"; -- new slash command for showing framestack tool



local frame = CreateFrame("Frame")
local content ="归来公会一团，每周50分钟通BWL，活动时间每周日晚上8点，DKP，新人补分机制，组织世界BUFF，会内气氛和谐，活动很多，世界BOSS，马拉松等~有兴趣联系我~"
local me = UnitName("player")
local meTarget = GetUnitName("target")

people_buff = {}
MapleRaidTool = {}

aBuff = {"屠龙者的咆哮", "风歌夜曲", "摩尔达的勇气", "赞达拉之魂", "酋长的祝福"} 
bBuff = {"抵抗火焰"}
cBuff = {"泰坦合剂", "萃取智慧", "至高能量"}


--frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("MINIMAP_PING")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")



--local mebuff = UnitBuff(meTarget,1)

frame:SetScript("OnEvent", function(self, event, ...)
	yellToPublic(content)
end)

function checkBuffs()

	yellToPublic(content)

	if (me) then
		local currentMembers = GetNumGroupMembers()
		for units = 1, currentMembers do
			local buffCount = 0
			local bBuffCount = 0
			local cBuffCount = 0
			local finalPoints = 0
			local buffs = ""
			local wholeBuffNum = 0

			
			local currentMembers = GetNumGroupMembers()

			local name,rank,subgroup,level,class = GetRaidRosterInfo(units)
		
		
			for i = 1, 32 do
				local mybuff = UnitBuff(name, i)

				if contains(aBuff, mybuff) then
					buffCount = buffCount + 1
					buffs = getBuffName(buffs, mybuff)
					wholeBuffNum = wholeBuffNum + 1
				end
				
				if contains(bBuff, mybuff) then
					buffs = getBuffName(buffs, mybuff)
					bBuffCount = bBuffCount + 1
					wholeBuffNum = wholeBuffNum + 1
				end
				
				if contains(cBuff, mybuff) then
					buffs = getBuffName(buffs, mybuff)
					cBuffCount = cBuffCount + 1
					wholeBuffNum = wholeBuffNum + 1
				end
			end
			
			if buffCount <=4 then
				finalPoints = buffCount * 3 + bBuffCount * 10 + cBuffCount * 3
				--SendChatMessage("index: " .. units .. "points " .. finalPoints, "WHISPER", "Common", "枫叶牛")

			else
				finalPoints = buffCount * 3 + bBuffCount * 10
			end
			
			--SendChatMessage("index: " .. units .. "points " .. finalPoints, "WHISPER", "Common", "枫叶牛")

			people_buff[name] = {["buff加分"] = finalPoints; ["职业"] = class}
			people_buff[name]["编号"] = units
			people_buff[name]["等级"] = level
			people_buff[name]["时间"] = date("%m/%d/%y %H:%M:%S")
			people_buff[name]["所加buff"] = buffs
			people_buff[name]["buff数量"] = wholeBuffNum
			
			table.sort(people_buff,function(a,b) return a[name]["编号"]<b[name]["编号"] end )
			
			--SendChatMessage("index: " .. units, "WHISPER", "Common", "枫叶牛")
			
		end
	end
end


----------------------------------------------------------
local backLayerFrame = CreateFrame("Frame", "buffBackFrame", UIParent, "BasicFrameTemplateWithInset");
backLayerFrame:SetSize(400,360);
backLayerFrame:SetPoint("Bottom", UIParent, "CENTER");
backLayerFrame.title = backLayerFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal');
backLayerFrame.title:SetPoint('CENTER', backLayerFrame.TitleBg, "CENTER", 0, 0);
backLayerFrame.title:SetText('枫叶团队插件');
backLayerFrame:SetMovable(true)
backLayerFrame:EnableMouse(true)
backLayerFrame:RegisterForDrag("LeftButton")
backLayerFrame:SetScript("OnDragStart", frame.StartMoving)
backLayerFrame:SetScript("OnDragStop", frame.StopMovingOrSizing)

---记录全团世界BUFF
backLayerFrame.rlBtn = CreateFrame("Button", nil, backLayerFrame, "GameMenuButtonTemplate");
backLayerFrame.rlBtn:SetPoint("CENTER", backLayerFrame, "TOP",-100, -70);
backLayerFrame.rlBtn:SetSize(140,40);
backLayerFrame.rlBtn:SetText('记录全团世界BUFF');
backLayerFrame.rlBtn:SetNormalFontObject("GameFontNormalLarge");
backLayerFrame.rlBtn:SetHighlightFontObject("GameFontHighLightLarge");
backLayerFrame.rlBtn:SetScript("OnClick", function()
                checkBuffs();
            end)
			
---清空世界BUFF纪录			
backLayerFrame.clBtn = CreateFrame("Button", nil, backLayerFrame, "GameMenuButtonTemplate");
backLayerFrame.clBtn:SetPoint("CENTER", backLayerFrame, "TOP",-100, -150);
backLayerFrame.clBtn:SetSize(140,40);
backLayerFrame.clBtn:SetText('清空世界BUFF纪录');
backLayerFrame.clBtn:SetNormalFontObject("GameFontNormalLarge");
backLayerFrame.clBtn:SetHighlightFontObject("GameFontHighLightLarge");
backLayerFrame.clBtn:SetScript("OnClick", function()
                clearGroup(people_buff);
            end)

---通知己纪录世界BUFF			
backLayerFrame.clBtn = CreateFrame("Button", nil, backLayerFrame, "GameMenuButtonTemplate");
backLayerFrame.clBtn:SetPoint("CENTER", backLayerFrame, "TOP",-100, -230);
backLayerFrame.clBtn:SetSize(140,40);
backLayerFrame.clBtn:SetText('通知纪录世界BUFF');
backLayerFrame.clBtn:SetNormalFontObject("GameFontNormalLarge");
backLayerFrame.clBtn:SetHighlightFontObject("GameFontHighLightLarge");
backLayerFrame.clBtn:SetScript("OnClick", function()
                notifyRaid();
				yellToPublic(content);
            end)	
			
---分配团队BUFF			
backLayerFrame.clBtn = CreateFrame("Button", nil, backLayerFrame, "GameMenuButtonTemplate");
backLayerFrame.clBtn:SetPoint("CENTER", backLayerFrame, "TOP",100, -70);
backLayerFrame.clBtn:SetSize(140,40);
backLayerFrame.clBtn:SetText('分配团队BUFF');
backLayerFrame.clBtn:SetNormalFontObject("GameFontNormalLarge");
backLayerFrame.clBtn:SetHighlightFontObject("GameFontHighLightLarge");
backLayerFrame.clBtn:SetScript("OnClick", function()
                loadRaidGroup();
            end)

--检查Debuff			
backLayerFrame.clBtn = CreateFrame("Button", nil, backLayerFrame, "GameMenuButtonTemplate");
backLayerFrame.clBtn:SetPoint("CENTER", backLayerFrame, "TOP",100, -150);
backLayerFrame.clBtn:SetSize(140,40);
backLayerFrame.clBtn:SetText('检查目标Debuff');
backLayerFrame.clBtn:SetNormalFontObject("GameFontNormalLarge");
backLayerFrame.clBtn:SetHighlightFontObject("GameFontHighLightLarge");
backLayerFrame.clBtn:SetScript("OnClick", function()
				checkDebuffFromList(debuffCheckList);
            end)
			
--世界BOSS组队
myCheckButton = CreateFrame("CheckButton", "myCheckButton_GlobalName", backLayerFrame, "ChatConfigCheckButtonTemplate");
myCheckButton:SetPoint("CENTER", backLayerFrame, "TOP",-150, -310);
myCheckButton:SetSize(40,40);
myCheckButton_GlobalNameText:SetText("开启组队");
myCheckButton.tooltip = "点击开启自动组队模式";
myCheckButton:SetScript("OnClick", 
  function()
		print("功能尚未完成")
  end
);

--世界BOSS组队

--myEditBox:SetPoint("CENTER", UIParent, "CENTER");
--myEditBox:SetSize(40,40);
--:SetText("开启组队");
--myEditBox.tooltip = "This is where you place MouseOver Text.";


--[[
backLayerFrame.ckBtn = CreateFrame("CheckButton", "myCheckButton_GlobalName", parentFrame, "ChatConfigCheckButtonTemplate");
backLayerFrame.ckBtn:SetPoint("CENTER", backLayerFrame, "TOP",100, -230);
--backLayerFrame.ckBtn:SetSize(140,40);
myCheckButton_GlobalName:SetText('世界BOSS组队');
backLayerFrame.ckBtn.tooltip = "This is where you place MouseOver Text.";
--backLayerFrame.ckBtn:SetNormalFontObject("GameFontNormalLarge");
--backLayerFrame.ckBtn:SetHighlightFontObject("GameFontHighLightLarge");
backLayerFrame.ckBtn:SetScript("OnClick", function()
				print("checked")
            end)
--]]		


--backLayerFrame:Hide();

SlashCmdList["MPTool"] = function()   
	if backLayerFrame:IsShown() then
		backLayerFrame:Hide();
	else
		backLayerFrame:Show();
	end
end



