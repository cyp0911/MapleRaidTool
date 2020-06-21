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

inviteAnnouce = "GUILD"
inviteHeader = "世界BOSS"

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
	adjustInviteToggle(-1)
	setCheckedBox()
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
backLayerFrame:SetSize(400,450);
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
backLayerFrame.clBtn:SetText('分配团队任务');
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
			
--检查Buff			
backLayerFrame.coBtn = CreateFrame("Button", nil, backLayerFrame, "GameMenuButtonTemplate");
backLayerFrame.coBtn:SetPoint("CENTER", backLayerFrame, "TOP",100, -230);
backLayerFrame.coBtn:SetSize(140,40);
backLayerFrame.coBtn:SetText('检查自身Buff');
backLayerFrame.coBtn:SetNormalFontObject("GameFontNormalLarge");
backLayerFrame.coBtn:SetHighlightFontObject("GameFontHighLightLarge");
backLayerFrame.coBtn:SetScript("OnClick", function()
				checkPersonalBuff(personBuffCheckList)
            end)
			
			
--世界BOSS组队
myCheckButton = CreateFrame("CheckButton", "myCheckButton_GlobalName", backLayerFrame, "UICheckButtonTemplate");
myCheckButton:SetPoint("CENTER", backLayerFrame, "TOP",-150, -310);
myCheckButton:SetSize(40,40);
myCheckButton_GlobalNameText:SetText("开启有团成员组队");
myCheckButton.tooltip = "只组有团会员";
myCheckButton:SetScript("OnClick", function(self,event,arg1)
		if self:GetChecked() then
			SendChatMessage(welcomeWords .. inviteHeader .. "开组，请M我或者公会频道打：“".. configs["inviteCode"] .."”，进组，当前组团最低会阶为积极分子" , inviteAnnouce, "Common", sender)
			adjustInviteToggle(1)
		else
			SendChatMessage(welcomeWords .. inviteHeader .. "组团暂停，请等候进一步通知" , inviteAnnouce, "Common", sender)
			adjustInviteToggle(0)
			bossCheckButton:SetChecked(false)
			outsideButton:SetChecked(false)
		end
  end)
  

--世界BOSS组队
bossCheckButton = CreateFrame("CheckButton", "bossCheckButton_GlobalName", backLayerFrame, "UICheckButtonTemplate");
bossCheckButton:SetPoint("CENTER", backLayerFrame, "TOP",-150, -350);
bossCheckButton:SetSize(40,40);
bossCheckButton_GlobalNameText:SetText("接纳全体会员");
bossCheckButton.tooltip = "全体会员";
bossCheckButton: SetScript("OnClick", function(self,event,arg1)
		if self:GetChecked() then
			SendChatMessage(welcomeWords .. inviteHeader .. "开组，请M我或者公会频道打：“".. configs["inviteCode"] .."”，进组，当前组团接受全体会员" , inviteAnnouce, "Common", sender)

			adjustInviteToggle(2)
			myCheckButton:SetChecked(true)
		else
			SendChatMessage(welcomeWords .. inviteHeader .. "目前组团只组有团成员和积极分子" , inviteAnnouce, "Common", sender)
			adjustInviteToggle(1)
			outsideButton:SetChecked(false)
		end
  end)

--接受公会外成员
outsideButton = CreateFrame("CheckButton", "outsideButton_GlobalName", backLayerFrame, "UICheckButtonTemplate");
outsideButton:SetPoint("CENTER", backLayerFrame, "TOP",-150, -390);
outsideButton:SetSize(40,40);
outsideButton_GlobalNameText:SetText("接纳全服部落");
outsideButton.tooltip = "接纳会外成员";
outsideButton: SetScript("OnClick", function(self,event,arg1)
		if self:GetChecked() then
			SendChatMessage(welcomeWords .. inviteHeader .. "开组，请M我或者公会频道打：“".. configs["inviteCode"] .."”，进组，当前组团接受全体部落" , inviteAnnouce, "Common", sender)
			adjustInviteToggle(3)
			myCheckButton:SetChecked(true)
			bossCheckButton:SetChecked(true)
		else
			SendChatMessage(welcomeWords .. "停止接受会外成员" , inviteAnnouce, "Common", sender)
			adjustInviteToggle(2)
		end
  end)
  

-- 密语
myEditBox = CreateFrame("EditBox", "WPDemoBox", backLayerFrame, "InputBoxTemplate");
myEditBox:SetPoint("CENTER", backLayerFrame, "TOP",100, -310);
myEditBox:SetSize(150, 40)
myEditBox:SetAutoFocus(false)
myEditBox:SetText("组队密码");
myEditBox:SetCursorPosition(0)
myEditBox:SetMaxLetters(3)
myEditBox:SetNumeric()
myEditBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		configs["inviteCode"] = myEditBox:GetText()
		
		print("组团密语设置为: " .. configs["inviteCode"])
  end)
myEditBox:SetScript("OnEscapePressed", myEditBox.ClearFocus)

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

function adjustInviteToggle(toggle)
	if configs == nil and toggle == -1 then
		configs = {}
		configs["inviteToggle"] = 0
	elseif toggle == 0 then
		configs["inviteToggle"] = 0
	elseif toggle == 1 then
		configs["inviteToggle"] = 1
	elseif toggle == 2 then
		configs["inviteToggle"] = 2
	elseif toggle == 3 then
		configs["inviteToggle"] = 3
	end
	
	if configs["inviteCode"] == nil then
		configs = {}
		configs["inviteCode"] = "233"
		myEditBox:SetText("组队密码");
	else
		myEditBox:SetText(configs["inviteCode"]);
	end
end

function setCheckedBox()
	if configs["inviteToggle"] == 0 then
		--print("0")
	elseif configs["inviteToggle"] == 1 then
		myCheckButton:SetChecked(true)
	elseif configs["inviteToggle"] == 2 then
		myCheckButton:SetChecked(true)
		bossCheckButton:SetChecked(true)
	elseif configs["inviteToggle"] == 3 then
		myCheckButton:SetChecked(true)
		bossCheckButton:SetChecked(true)
		outsideButton:SetChecked(true)
	end
end


