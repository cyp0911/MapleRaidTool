signGroup = {"{rt8}", "{rt1}", "{rt2}", "{rt3}"}

function sendMessageBuff(name, includegroup, class)
	print("debug333")
	local spell = spellname(class)
	print("spell" .. spell)
	SendChatMessage(welcomeWords .." [" .. name .. "],你负责第" .. includegroup .. "队的" .. spell .. "BUFF！", readChannel, "Common", name)
end


function sendMessageHeal(name, class, index)
	if class == "德鲁伊" then
		if checkZone == "raid" then
			SendChatMessage(welcomeWords .. "[" .. name .. "],你全程看住[".. healTarget(1) .. "] 或者BOSS目标T！捏好迅捷", readChannel, "Common", name)
		elseif checkZone == "green" then
			SendChatMessage(welcomeWords .. "[" .. name .. "],绿龙刷T任务分配：全力负责坦克：<" .. tankgroup[(greenTankAssigned-1)%3 + 1] .. ">", readChannel, "Common", name)
			print("greenIndex" .. greenTankAssigned)
			greenTankAssigned = greenTankAssigned + 1
		end
	elseif class == "牧师" then
		if checkZone == "raid" then
			SendChatMessage(welcomeWords .. "[" .. name .. "],你全程负责[".. healTarget(index) .. "] 的真言术盾，同时刷死他！", readChannel, "Common", name)
		elseif checkZone == "green" then
			SendChatMessage(welcomeWords .. "[" .. name .. "],刷好第[".. group_buff[name]["小队"] .. "] 队！提前上盾，不要被晕！", readChannel, "Common", name)
		end
	end
	
end
function sendMessageTank(name)
	warLockTask["task"]["精灵之火（野性）】"] = name
	SendChatMessage(welcomeWords .. "[" .. name .. "],你注意上【精灵之火（野性）】 ！", readChannel, "Common", name)
	SendChatMessage(welcomeWords .. "[" .. name .. "],你全程负责拉<" .. signGroup[checkIndex(tankgroup,name)] .. ">", readChannel, "Common", name)
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
