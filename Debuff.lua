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
	for debuff, count in pairs(debuffCheckList) do
		--print("检查".. debuff .. "层数" .. count)
		local currentLayer = checkDebuff(debuff, count)
		--print("当前".. currentLayer .. "需要" .. count)
		local requireLayer = count - currentLayer
		--print("require" .. requireLayer)
		if requireLayer > 0 and warLockTask["task"][debuff] ~= nil then
			SendChatMessage("《归来》团队插件提醒：[" .. warLockTask["task"][debuff] .. "],速度上[" .. debuff .. "]!还差<".. requireLayer ..">层", "WHISPER", "Common", warLockTask["task"][debuff])
		end
	end
end
