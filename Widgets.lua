local tankgroup = {"枫叶牛", "杀戮天琪", "开心的土豆"}
local warlockSpell = {"元素诅咒", "鲁莽诅咒", "暗影诅咒", "虚弱诅咒"}
local signGroup = {"{rt8}", "{rt1}", "{rt2}", "{rt3}"}
local rogueTask = {"人群【后】方最近柱子", "人群【前】最近柱子","人群【前】方第二根柱子","老3-BOSS专开人群柱子"}
local shadowPriest = {"岼凣"}
local aoeMage = "从前的猫"
local currentNumOfParties = 0


function clearGroup(table)
	local currentMembers = GetNumGroupMembers()
	print("现在的人员" .. currentMembers)
	if currentMembers then
		for k in pairs (table) do
			people_buff [k] = nil
		end
		print("数据清理完毕")
		--SendChatMessage("Buff记录清空" , "SAY")
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
	local myRace = UnitRace("player")
	if myRace ~= "矮人" then
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
	group_buff = {}
	class_group = {}
	num_class = {}
	--clearGroup(class_group);
	initial_class_table()
	if UnitInRaid("player") then
		for units = 1, currentMembers do
			local name,rank,subgroup,level,class = GetRaidRosterInfo(units)
			group_buff[name] = {["ID"] = name; ["职业"] = class}
			group_buff[name]["小队"] = subgroup
			class_group[class][name] = units
			num_class[class] = num_class[class] + 1
			remove_useless_element(class)
		end
	
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
	if class == "德鲁伊" or  class == "牧师" or  class == "法师" or class == "术士" or class == "猎人" or class == "潜行者" then
		local index = 1
		for name, value in pairs(class_group[class]) do
			if value ~= "" and index <=currentNumOfParties then
				if true then
					index = load_class_info(name, class, num_class[class], slice, index)
				end
			end
		end		
	end
end


function initial_class_table()
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

end



function remove_useless_element(class)
	if class_group[class]["name"] ~= nil then
		class_group[class]["name"]=nil
	end
end

function cal_slice()
	slice_class = {}
	class_last = {}
	for key, value in pairs(num_class) do
		print(key .. value)
		local reduant = 0
		local slice = 0
		if value ~=0 then
			reduant = currentNumOfParties % value
			slice = currentNumOfParties / value
			slice = math.ceil(slice)	
		else
			reduant = 0
			slice = currentNumOfParties
			--class_last[key] = table.insert(0)
		end
		print("分为几组：" .. value .."每个人负责几个队伍：" .. slice .. " ,最后一组：" .. reduant)
		assignBuff(key, slice, reduant)
	end

end

function load_class_info(name, class, groups, slice, index)
	if class == "德鲁伊" or class == "牧师" or class == "法师" then
		local spell = spellname (class)
		local includegroup = includeGroup(index, slice)
		
		if not contains(tankgroup, name) and not contains(shadowPriest, name) and includegroup ~= "" then
			SendChatMessage("枫叶专属插件提醒：[" .. name .. "],你负责第" .. includegroup .. "队的" .. spell .. "BUFF！", "WHISPER", "Common", "枫叶牛")
		end
		
		if class == "牧师" and index <= #tankgroup and (not contains(shadowPriest, name)) and includegroup ~= "" then 
			SendChatMessage("枫叶专属插件提醒：[" .. name .. "],你全程负责[".. tankgroup[index] .. "] 的真言术盾，同时刷死他！", "WHISPER", "Common", "枫叶牛")
		end
		return index + 1
	elseif class == "术士" then
		--SendChatMessage("枫叶专属插件提醒：[" .. name .. "],你负责全程上<<".. warlockSpell[(index - 1) % 4 + 1] .. ">>", "SAY", "Common", name)	
		--SendChatMessage("枫叶专属插件提醒：[" .. name .. "],你负责拉【".. includeGroup(index, slice) .. "】队的队友", "SAY", "Common", name)
		return index + 1
	elseif class == "猎人" then
		--SendChatMessage("枫叶专属插件提醒：[" .. name .. "],你全程负责第[".. (index - 1) % 3 + 1 .. "] 次宁神，同时负责拉<" .. signGroup[(index - 1)%4 +1] .. ">", "WHISPER", "Common", name)
		return index + 1
	elseif class == "战士" and contains(tankgroup, name) then
		--SendChatMessage("枫叶专属插件提醒：[" .. name .. "],你全程负责拉<" .. signGroup[(index - 1) % 4 + 1] .. ">", "WHISPER", "Common", name)
		return index + 1
	elseif class == "潜行者" then
		--SendChatMessage("枫叶专属插件提醒：[" .. name .. "],本次副本陷阱任务：<" .. rogueTask[(index - 1) % 4 + 1] .. ">", "SAY", "Common", name)
		return index + 1
	end
end


function spellname(class)
	if class == "德鲁伊" then
		return " <<野性赐福>>爪子"
	elseif class == "牧师" then
		return "<<耐力，精神，暗抗>>"
	elseif class == "法师" then
		return "<<智力,抑制>>"
	end
end

function includeGroup(index, slice)
	local includegroup = ""	
	for i=(index - 1)  * slice + 1, index * slice do
			if i < 9 then
				includegroup = includegroup .. "[".. i .."] "
			end
		end
	return includegroup
end
