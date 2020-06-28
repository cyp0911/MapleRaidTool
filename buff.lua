tankgroup = {}
warlockSpell = {"元素诅咒", "鲁莽诅咒", "暗影诅咒", "虚弱诅咒"}
rogueTask = {"人群【后】方最近柱子", "人群【前】最近柱子","人群【前】方第二根柱子","老3-BOSS专开人群柱子", "老1-替补控龙（防止T失手）","老1-替补控龙（防止T失手）"}
shamanTask = {"小红龙刷主T，打死不换目标，过量刷", "主刷T，适当近战链子"}
shadowPriest = {"岼凣"}
aoeMage = "从前的猫"
currentNumOfParties = 0
mapleName = "枫叶牛"
greenTankAssigned = 1


function clearGroup(table)
	local currentMembers = GetNumGroupMembers()
	print("现在的人员" .. currentMembers)
	if currentMembers then
		for k in pairs (table) do
			people_buff [k] = nil
		end
		print("数据清理完毕")
		SendChatMessage("Buff记录清空" , "SAY")
	end
end

function getBuffName(buffs,currentBuff)
	if buffs~= "" then
		buffs = buffs .. ", " .. currentBuff
	else
		buffs = currentBuff
	end
	return buffs
end

function yellToPublic(content)
	local myFaction, myFactionCN = UnitFactionGroup("player")
	if myFactionCN ~= "联盟" then
		SendChatMessage(content,"channel",nil,1);
		SendChatMessage(content,"yell");
	else
		print("LM号，注意不要暴露目标！")
	end
end

function notifyRaid()
	local myName = UnitName("player")
	local currentMembers = GetNumGroupMembers()
	print("当前团队成员：" .. currentMembers)

	if UnitInRaid("player") then
		for units = 1, currentMembers do
			local name,rank,subgroup,level,class = GetRaidRosterInfo(units)
			if people_buff[name] and people_buff[name]["buff数量"]>0 then		
				SendChatMessage("你有: " .. people_buff[name]["buff数量"] .. "个世界BUFF", "WHISPER", "Common", name)
				SendChatMessage("你的世界buff为: " .. people_buff[name]["所加buff"], "WHISPER", "Common", name)
				SendChatMessage("应加分值: " .. people_buff[name]["buff加分"], "WHISPER", "Common", name)
			else
				SendChatMessage("您当前身上没有世界BUFF,不加分", "WHISPER", "Common", name)
			end
		end
	elseif UnitInParty("player") then
		print("您在队伍内！")
	else
		print("您不在团队内，所以无法通知BUFF")
	end
end

function loadRaidGroup()
	local myName = UnitName("player")
	local currentMembers = GetNumGroupMembers()
	currentNumOfParties = math.ceil(currentMembers / 5)
	print("当前团队成员：" .. currentMembers)
	print("请注意：1队不要放奶德和KBZ，ZST和熊T在一队自动识别！")
	--clearGroup(class_group);
	initial_class_table()
	if UnitInRaid("player") then
		for units = 1, currentMembers do
			local name,rank,subgroup,level,class = GetRaidRosterInfo(units)
			group_buff[name] = {["ID"] = name; ["职业"] = class}
			group_buff[name]["小队"] = subgroup
			class_group[class][name] = units
			remove_useless_element(class)
			setTankGroup(name, subgroup, class)
			if contains(tankgroup, name) == false then
				num_class[class] = num_class[class] + 1
			else
				print("in tank" .. name)
			end
		end		
		reArrageTank(tankgroup)
		cal_slice()
	elseif UnitInParty("player") then
		print("您在队伍内！")
	else
		print("您不在团队内，所以读取BUFF")
	end
end

function contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function assignBuff(class, slice, last)
	local index = 1
	for name, value in pairs(class_group[class]) do
		if value ~= "" then
			index = load_class_info(name, class, num_class[class], slice, index)
		end
	end		
	debuffToggle = 1
end


function initial_class_table()
	group_buff = {}
	class_group = {}
	num_class = {}
	warLockTask = {}
	tankgroup = {}
	buffTaskSaveGroup = {}
	personal_buff = {}
	buff_order = {}


	class_group["潜行者"] = {["name"] = ""}
	class_group["萨满祭司"] = {["name"] = ""}
	class_group["猎人"] = {["name"] = ""}
	class_group["战士"] = {["name"] = ""}
	class_group["牧师"] = {["name"] = ""}
	class_group["法师"] = {["name"] = ""}
	class_group["术士"] = {["name"] = ""}
	class_group["德鲁伊"] = {["name"] = ""}
	
	num_class["潜行者"] = 0
	num_class["萨满祭司"] = 0
	num_class["猎人"] = 0
	num_class["战士"] = 0
	num_class["牧师"] = 0
	num_class["法师"] = 0
	num_class["德鲁伊"] = 0
	num_class["术士"] = 0
	
	warLockTask["task"] = {["spell"] = "name"}
	buffTaskSaveGroup["技能"] = {["ID"] = "队伍"}
	greenTankAssigned = 1
end



function remove_useless_element(class)
	if class_group[class]["name"] ~= nil then
		class_group[class]["name"]=nil
	end
end

function cal_slice()
	slice_class = {}
	class_last = {}
	for class, numberClass in pairs(num_class) do
		--print(key .. value)
		local reduant = 0
		local slice = 0
		if numberClass ~=0 then
			reduant = currentNumOfParties % numberClass
			slice = currentNumOfParties / numberClass
			slice = math.ceil(slice)	
		else
			reduant = 0
			slice = currentNumOfParties
			--class_last[key] = table.insert(0)
		end
		print("分为几组：" .. numberClass .."每个人负责几个队伍：" .. slice .. " ,最后一组：" .. reduant)
		assignBuff(class, slice, reduant)
	end
end

function load_class_info(name, class, groups, slice, index)
	print("debug" .. name .. class)
	if class == "德鲁伊" then	
		if contains(tankgroup, name) then
			sendMessageTank(name)
			return index
		else
			local includegroup = includeGroup(index, slice, name, class)		
			sendMessageBuff(name, includegroup, class)
			sendMessageHeal(name, class, index)
			return index + 1
		end
	elseif class == "牧师" then
		if contains(shadowPriest, name) == false then
			local includegroup = includeGroup(index, slice, name, class)
			sendMessageBuff(name, includegroup, class)
			sendMessageHeal(name, class, index)
			return index + 1
		else
			return index
		end
	elseif class == "法师" then
		local includegroup = includeGroup(index, slice, name, class)
		sendMessageBuff(name, includegroup, class)
	elseif class == "术士" then
		SendChatMessage(welcomeWords .. "[" .. name .. "],你负责全程上<<".. warlockSpell[(index - 1) % 4 + 1] .. ">>", readChannel, "Common", name)
		warLockTask["task"][warlockSpell[(index - 1) % 4 + 1]] = name
		SendChatMessage(welcomeWords .. "[" .. name .. "],你负责拉【".. includeGroup(index, slice, name, class) .. "】队的队友", readChannel, "Common", name)
	elseif class == "猎人" then
		if checkZone() == "raid" then 
			SendChatMessage(welcomeWords .. "[" .. name .. "],你全程负责第[".. index .. "] 次宁神", readChannel, "Common", name)
		end
		SendChatMessage(welcomeWords .. "[" .. name .. "],你全程负责卡<" .. signGroup[(index - 1)%4 +1] .. ">的视野和仇恨", readChannel, "Common", name)
		if index == 1 then
			SendChatMessage(welcomeWords .. "[" .. name .. "],你全程负责卡<" .. signGroup[(index - 1)%4 +1] .. ">的视野和仇恨", readChannel, "Common", name)
		end
	elseif class == "战士" and contains(tankgroup, name) then
		sendMessageTank(name)
	elseif class == "潜行者" and checkZone() == "bwl" then
		SendChatMessage(welcomeWords .. "[" .. name .. "],本次副本陷阱任务：<" .. rogueTask[(index - 1) % 4 + 1] .. ">", readChannel, "Common", name)
	elseif class == "萨满祭司" then
		sendMessageHeal(name, class, index)
	end
	return index + 1
end

function includeGroup(index, slice, name, class)
	local includegroup = ""	
	local spell = spellname(class)
	for i=(index - 1)  * slice + 1, index * slice do
			if i < 9 and i <= currentNumOfParties then
				includegroup = includegroup .. "[".. i .."]"
				addDataToTable(buff_order, i, spell, name)
			elseif i < 9 and i > currentNumOfParties then
				local backI = i - currentNumOfParties
				includegroup = includegroup .. "[".. backI .."]"
				addDataToTable(buff_order, backI, spell, name)
			else
				local doSub = i - 8
				includegroup = includegroup .. "[".. doSub .."]"
				addDataToTable(buff_order, doSub, spell, name)
			end
		end
	return includegroup
end

function spellname(class)
	if class == "德鲁伊" then
		return "<爪子>"
	elseif class == "牧师" then
		return "<耐力，精神，暗抗>"
	elseif class == "法师" then
		return "<智力,抑制>"
	elseif class == "术士" then
		return "<召唤队友>"
	end
end

function checkZone()
	local zoneName = GetZoneText();
	local greenDragonZone = {"辛特兰", "菲拉斯", "暮色森林", "灰谷"}
	local raidZone = {"黑翼之巢", "熔火之心"}
	local kzkZone = "诅咒之地"
	local blueZone = "艾萨拉"
	local city = {"奥格瑞玛", "幽暗城", "雷霆崖"}

	if contains(greenDragonZone, zoneName) then
		return "green"
	elseif contains(raidZone, zoneName) then
		return "raid"
	elseif zoneName == "黑翼之巢" then
		return "bwl"
	elseif zoneName == kzkZone then
		return "kzk"
	elseif zoneName == blueZone then
		return "blue"
	elseif contains(city, zoneName) then
		return "city"
	end
	
	return ""
end

function addDataToTable(tableTo, first, second, third)
	if tableTo[tostring(first)] == nil then
		tableTo[tostring(first)] = {[second] = third}
	else
		tableTo[tostring(first)][second] = third
	end
end

function setTankGroup(name, subgroup, class)
	if subgroup == 1 then
		if class == "战士" or class == "德鲁伊" then
			tankgroup[#tankgroup + 1] = name
			print("tank setted" .. name .. class)
		end
	end
end

function reArrageTank(tankgroup)
	local temp = ""
	for i = 1, #tankgroup do
		if tankgroup[i] == "枫叶牛" and i ~= 1 then
			temp = tankgroup[1]
			tankgroup[1] = tankgroup[i]
			tankgroup[i] = temp
		end
		

		if group_buff[tankgroup[i]]["职业"] == "德鲁伊" and #tankgroup > 2 and i ~= 3 then
			temp = tankgroup[3]
			tankgroup[3] = tankgroup[i]
			tankgroup[i] = temp
		end
	end
end

lootMasters = {"枫叶牛", "枫叶老虎", "从前的猫", "啊我太难了", "吃了一个大龙", "开心的土豆", "丶三营长", "托尼托尼", "罗罗诺亚","大门五郎","开心的萝卜", "艾泽拉夜刃", "大角顶你"}

function setLootMethods(name)
	lootmethod= GetLootMethod()
	local myName = UnitName("player")
	affectingCombat = UnitAffectingCombat("unit");
	
	if myName == "枫叶牛" and affectingCombat == false and lootmethod ~= "master" then
		SetLootMethod("master", "枫叶牛");
	elseif affectingCombat == true and lootmethod ~= "master" then
		message("退出战斗后，记得改拾取！！！")
		SendChatMessage(welcomeWords .. "记得提醒团长战斗结束后改队长分配！！！", "YELL")
	else
		SetLootMethod("master", myName);
	end
end