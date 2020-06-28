signGroup = {"{rt8}", "{rt1}", "{rt2}", "{rt3}"}

function sendMessageBuff(name, includegroup, class)
	local spell = spellname(class)
	SendChatMessage(welcomeWords .." [" .. name .. "],你负责第" .. includegroup .. "队的" .. spell .. "BUFF！", readChannel, "Common", name)
end


function sendMessageHeal(name, class, index)
	if class == "德鲁伊" then
		if checkZone() == "raid" then
			SendChatMessage(welcomeWords .. "[" .. name .. "],你全程看住[".. healTarget(1) .. "] 或者BOSS目标T！捏好迅捷", readChannel, "Common", name)
			addDataToTable(buff_order,"奶T", healTarget(1), name)
			if checkZone() == "bwl" then
				SendChatMessage(welcomeWords .. "[" .. name .. "], 红龙后面小怪，注意睡小红帽", readChannel, "Common", name)
				addDataToTable(buff_order,"睡龙", "睡小红帽", name)
			end
		elseif checkZone() == "green" then
			if greenTankAssigned < 7 then
				SendChatMessage(welcomeWords .. "[" .. name .. "],绿龙刷T任务分配：全力负责坦克：<" .. tankgroup[(greenTankAssigned-1)%3 + 1] .. ">", readChannel, "Common", name)
				addDataToTable(buff_order,"绿龙刷T",name, tankgroup[(greenTankAssigned-1)%3 + 1])
				--print("greenIndex" .. greenTankAssigned)
			end
			greenTankAssigned = greenTankAssigned + 1
		end
	elseif class == "牧师" then
		if checkZone() == "raid" then
			SendChatMessage(welcomeWords .. "[" .. name .. "],你全程负责[".. healTarget(index) .. "] 的真言术盾，同时刷死他！", readChannel, "Common", name)
			addDataToTable(buff_order,"牧师上盾",name, healTarget(index))
		elseif checkZone() == "green" then
			SendChatMessage(welcomeWords .. "[" .. name .. "],治疗祷言刷好第[".. group_buff[name]["小队"] .. "] 队！提前上盾，不要被晕！", readChannel, "Common", name)
			addDataToTable(buff_order,"牧师祷言刷",name, tostring(group_buff[name]["小队"]))
		end
	elseif class == "萨满祭司" then
		if checkZone() == "green" then
			if greenTankAssigned < 7 then
				SendChatMessage(welcomeWords .. "[" .. name .. "],绿龙刷T任务分配：全力负责坦克：<" .. tankgroup[(greenTankAssigned-1)%3 + 1] .. ">", readChannel, "Common", name)
				addDataToTable(buff_order,"绿龙刷T",name, tankgroup[(greenTankAssigned-1)%3 + 1])
				--print("greenIndex" .. greenTankAssigned)
			end
			greenTankAssigned = greenTankAssigned + 1
		elseif checkZone() == "green" then
			if index <= 4 then
				SendChatMessage(welcomeWords .. "[" .. name .. "],本次副本任务：<" .. shamanTask[1] .. ">", readChannel, "Common", name)
				addDataToTable(buff_order,"萨满副本任务",shamanTask[1] , name)
			else
				SendChatMessage(welcomeWords .. "[" .. name .. "],本次副本任务：<" .. shamanTask[2] .. ">", readChannel, "Common", name)
				addDataToTable(buff_order,"萨满副本任务",shamanTask[2] , name)
			end
		end
	end
	
end
function sendMessageTank(name, class)
	if class == "德鲁伊" then
		warLockTask["task"]["精灵之火（野性）】"] = name
		SendChatMessage(welcomeWords .. "[" .. name .. "],你注意上【精灵之火（野性）】 ！", readChannel, "Common", name)
		SendChatMessage(welcomeWords .. "[" .. name .. "],你全程负责拉<" .. signGroup[checkIndex(tankgroup,name)] .. ">", readChannel, "Common", name)
	elseif class == "战士" then
		SendChatMessage(welcomeWords .. "[" .. name .. "],你全程负责拉<" .. signGroup[checkIndex(tankgroup,name)] .. ">", readChannel, "Common", name)
		--print("tank2" .. tankgroup[2])
		if name == tankgroup[2] then
			SendChatMessage(welcomeWords .. "[" .. name .. "],你注意上【破甲】，【挫志怒吼】和带上【夜幕】", readChannel, "Common", name)
			warLockTask["task"]["破甲攻击"] = name
			warLockTask["task"]["挫志怒吼"] = name
			warLockTask["task"]["夜幕"] = name
		end
	end
end

function checkIndex(group, element)
	for i=1, #group do
		if group[i] == element then
			return i
		end
	end
	return 0
end

function healTarget(index)
	if index <= #tankgroup then
		return tankgroup[index]
	elseif index == (#tankgroup + 1) then
		return aoeMage
	end
	return ""
end
