debuffToggle = 0


debuffCheckList = {
	["破甲攻击"] = 5,
	["挫志怒吼"] = 1,
	["精灵之火(野性)"] = 1,
	["元素诅咒"] = 1,
	["鲁莽诅咒"] = 1,
	["暗影诅咒"] = 1,
	["虚弱诅咒"] = 1,
	["夜幕"] = 1,
}


personBuffCheckList = {"泰坦合剂", "猫鼬药剂", "巨人药剂", "冬泉火酒", "战斗怒吼"}



function checkDebuff(debuffs, layers)		
	for i=1,16 do
		local deBuffName, icon, number= UnitDebuff("target",i); 
		if deBuffName then 
			if deBuffName == debuffs then
				--print(i.."="..deBuffName.."nubmer: "..number .. "datatype" .. type(number)) 
				--print(i.."="..debuffs.."layers: "..layers .. "datatype" .. type(layers)) 
				if number > 0 then
					return number
				else
					return 1
				end
			end
		end
	end
	return 0
end


function checkDebuffFromList(debuffCheckList)
	if debuffToggle == 0 then
		message("请先分配团队BUFF和任务,然后选中目标后，点击本按钮！")
	elseif UnitName("target") == nil then
		message("请选中目标检查Debuff")
	end
	
	for debuff, count in pairs(debuffCheckList) do
		--print("检查".. debuff .. "层数" .. count)
		local currentLayer = checkDebuff(debuff, count)
		--print("当前".. currentLayer .. "需要" .. count)
		local requireLayer = count - currentLayer
		--print("require" .. requireLayer)
		if requireLayer > 0 and warLockTask["task"][debuff] ~= nil then
			if debuff ~= "夜幕" then
				SendChatMessage(welcomeWords .. "[" .. warLockTask["task"][debuff] .. "],速度上[" .. debuff .. "]!还差<".. requireLayer ..">层", "WHISPER", "Common", warLockTask["task"][debuff])
			elseif debuff == "夜幕" and warLockTask["task"][debuff] == "杀戮天琪" then
				SendChatMessage(welcomeWords .. "[" .. warLockTask["task"][debuff] .. "],速度上[" .. debuff .. "]!还差<".. requireLayer ..">层", "WHISPER", "Common", warLockTask["task"][debuff])
			end
		end
	end
end

function checkPersonalBuff(personBuffCheckList)
	currentBuffList = {}
	local myName = UnitName("player")
	for i = 1, 32 do
		local mybuff = UnitBuff(myName, i)
		table.insert(currentBuffList, mybuff)
	end
				
	for i = 1, #personBuffCheckList do
		if not contains(currentBuffList, personBuffCheckList[i]) then
			SendChatMessage(welcomeWords .. "自身BUFF还差：" .. personBuffCheckList[i], "WHISPER", "Common", myName)
		end
	end
	
	local fireTotem = "火焰抗性"
	local naturalTotem = "自然抗性"
	
	if not contains(currentBuffList, fireTotem) and checkZone() == "raid" then
		SendChatMessage(welcomeWords .. "插" .. fireTotem .. "!", "WHISPER", "Common", myName)
	elseif not contains(currentBuffList, naturalTotem) and checkZone() == "green" then
		SendChatMessage(welcomeWords .. "插" .. naturalTotem .. "!", "WHISPER", "Common", myName)
	end
end

function raidBuffAnounce()
	print("antest")
	for i = 1, 8 do
		print("antest2" .. i)
		local partyText = "【" .. tostring(i) .. "】队Buff："
		for spell, name in pairs(buff_order[tostring(i)]) do
			partyText = partyText .. spell .. "-(" .. name .. "), " 
		end
		SendChatMessage(partyText, "RAID", "Common", name)
	end
end

