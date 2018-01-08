--装备系统
-- hero.equip_stat 记录英雄的装备属性
-- hero.average_score 记录英雄的装备平均评分
-- item.raid_owner 记录装备的拥有者

LinkLuaModifier("modifier_equip_stat", "modifiers/modifier_equip_stat.lua",LUA_MODIFIER_MOTION_NONE)

if Equip == nil then
	Equip = class({})
	Equip.PlayerInfo = {}
end

--[[
初始化某玩家装备
@param handle hero
]]
function Equip:InitEquip( hero )
	if hero == nil or hero:IsNull() then
		return
	end
	local equipList = {}
	for i=1,10 do
		equipList[i] = -1
	end
	self:Update(hero,equipList)
	hero:SetContextThink("stat_update", function (  )
		Equip:UpdateStat(hero)
		return 1
		-- body
	end, 1)
	-- body
end

--[[
更新某玩家装备
@param handle hero
@param table equipList
]]
function Equip:Update( hero,equipList )
	Equip.PlayerInfo[hero:GetEntityIndex()] = equipList
	CustomNetTables:SetTableValue("Equip", "equip_"..hero:GetEntityIndex(),equipList )
	local Total_Stat,Average_Score = Equip:CalculateEquip(hero,equipList)
	--记录装备属性，用于modifier_equip_stat
	CustomNetTables:SetTableValue("Equip", "equip_stat_"..hero:GetEntityIndex(), Total_Stat)
	hero.equip_stat = Total_Stat or {}
	hero.average_score = Average_Score
	hero:AddNewModifier(hero, nil, "modifier_equip_stat", {})
	hero:CalculateStatBonus()
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(),"update_equip", {})	
	self:UpdateStat(hero)
	-- body
end

--[[
计算某玩家装备总属性和平均评分
@param handle hero
@param table equipList
return table Total_Stat
]]
function Equip:CalculateEquip( hero,equipList )
	local Total_Stat = {}
	local Total_Score = 0
	for slot,itemIndex in pairs(equipList) do --各部位装备
		if itemIndex > 0 then
			local item = EntIndexToHScript(itemIndex)
			if item and item.property_table and item.score then
				for _,info in pairs(item.property_table) do --每件装备各条属性
					Total_Stat[info["property"]] = (Total_Stat[info["property"]] or 0) + info["value"]
				end
				Total_Score = Total_Score + item.score
			end
		end
	end	
	return Total_Stat,math.floor(Total_Score/10+0.5)
	-- body
end


--[[
获取某玩家装备
@param handle hero
return table
]]
function Equip:GetInfo( hero )
	if hero == nil then
		return nil
	end
	local equipList = Equip.PlayerInfo[hero:GetEntityIndex()]
	return equipList
	-- body
end

--[[
获取某部位的装备
@param handle hero
@param int slot
return int itemIndex
]]
function Equip:GetItemBySlot( hero,slot )
	if slot <= 0 or slot > 10 then
		return -1
	end
	local equipList = self:GetInfo(hero)
	if equipList then
		return equipList[slot] or -1
	else
		return -1
	end
	-- body
end

--[[
获取某装备的所属部位 1饰品2武器3头4颈部5胸部6腰部7腿部8脚部9肩部10戒指
@param handle hero
@param int itemIndex
return int slot
]]
function Equip:GetSlotNumber( itemName )
	if itemName == nil or string.sub(itemName, 6, 8) ~= "ran" then
		return -1
	end
	return tonumber(string.sub(itemName, 10, 11)) or -1
	-- body
end

--[[
改变某部位的装备
@param handle hero
@param int itemIndex
return boolean
]]
function Equip:ChangeItemBySlot(hero,slot,itemIndex)
	local playerID = hero:GetPlayerID()
	--战斗中不能更换装备
	if GameRules.bINCOMBAT == true then
		ShowError(playerID,"#equip_can_not_change_in_combat")
		return false
	end
	--是否绑定
	if itemIndex ~= -1 then
		local item = EntIndexToHScript(itemIndex)
		if item == nil then
			return false
		end
		if item.raid_owner then
			if item.raid_owner ~= playerID then  --拥有者不是自己
				ShowError(playerID,"#equip_not_your_item")
				return false
			end
		else
			item.raid_owner = playerID  --绑定
			CustomNetTables:SetTableValue("Items", "item_owner_"..itemIndex, {owner = playerID})
		end
	end
	--改变该部位的装备
	local equipList = self:GetInfo(hero)
	if equipList then
		equipList[slot] = itemIndex
		self:Update(hero,equipList)
		return true
	end
	return false
	-- body
end

--[[
丢弃某部位的装备
@param handle hero
@param int itemIndex
return boolean
]]
function Equip:DropItem( hero,slot,itemIndex )
	local playerID = hero:GetPlayerID()
	--战斗中不能更换装备
	if GameRules.bINCOMBAT == true then
		ShowError(playerID,"#equip_can_not_change_in_combat")
		return false
	end
	local equipList = Equip:GetInfo(hero)
	if equipList and equipList[slot] == itemIndex then
		equipList[slot] = -1
		self:Update(hero,equipList)
		local item = EntIndexToHScript(itemIndex)
		if item then
			CreateItemOnPositionSync(hero:GetAbsOrigin()+RandomVector(100), item)
		end
		return true
	end
	return false
	-- body
end

function Equip:SellItem( hero,slot,itemIndex )
	local playerID = hero:GetPlayerID()
	--战斗中不能更换装备
	if GameRules.bINCOMBAT == true then
		ShowError(playerID,"#equip_can_not_change_in_combat")
		return false
	end
	local equipList = Equip:GetInfo(hero)
	if equipList and equipList[slot] == itemIndex then
		local item = EntIndexToHScript(itemIndex)
		if item and item:IsSellable() then
			local price = item:GetCost() or 0
			if item.score then
				price = math.floor(math.pow(item.score/5, 1.1)+0.5)
				Items:DeleteItemFromNetTable(itemIndex)
			end
			EmitSoundOnClient("General.Sell", hero:GetPlayerOwner())
			Skill:ChangeCrystal(hero,price)
			equipList[slot] = -1
			self:Update(hero,equipList)
			item:RemoveSelf()
			return true
		end
	end
	return false
	-- body
end

-------------------------------------------------------------------------------------
--玩家属性相关
-------------------------------------------------------------------------------------

--[[
更新玩家属性
@param handle hero
]]
function Equip:UpdateStat( hero )
	
	--计算总属性，用于UI界面显示
	local stat_table = {}
	stat_table["score"] = hero.average_score or 0 --平均装备评分
	stat_table["ap"] = Equip:GetAttackPower(hero) -- 攻强
	stat_table["sp"] = Equip:GetSpellPower(hero) -- 法强
	stat_table["crit"] = Equip:GetSpellCrit(hero)  -- 技能暴击几率
	stat_table["cdamage"] = Equip:GetSpellCritDamage(hero) --技能暴击伤害
	stat_table["block"] = Equip:GetBlock(hero)  -- 格挡
	CustomNetTables:SetTableValue("Equip", "stat_"..hero:GetEntityIndex(), stat_table)
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "update_stat", stat_table)
	-- body
end

--[[
获取英雄的攻强
@param handle hero
return int ap
]]
function Equip:GetAttackPower( hero )
	local ap = 100  --基础值
	local apBonus_Constant = 0  --增加值
	local apBonus_Percentage = 0  --百分比增加
	local count = hero:GetModifierCount()
	for i=0,count - 1 do
		local mn = hero:GetModifierNameByIndex(i)
		local mod = hero:FindModifierByName(mn)
		if mod then
			if mod.GetModifierAttackPowerBonus then
				apBonus_Constant = apBonus_Constant + mod:GetModifierAttackPowerBonus()
			end
			if mod.GetModifierAttackPowerBonus_Percentage then
				apBonus_Percentage = apBonus_Percentage + mod:GetModifierAttackPowerBonus_Percentage()
			end
		end
	end
	ap = (ap + apBonus_Constant)*(1+apBonus_Percentage/100)
	hero.ap = ap
	return ap
	-- body
end

--[[
获取英雄的法强
@param handle hero
return float ap
]]
function Equip:GetSpellPower( hero )
	local sp = 100  --基础值
	local spBonus_Constant = 0  --增加值
	local spBonus_Percentage = 0  --百分比增加
	local count = hero:GetModifierCount()
	for i=0,count - 1 do
		local mn = hero:GetModifierNameByIndex(i)
		local mod = hero:FindModifierByName(mn)
		if mod then
			if mod.GetModifierSpellPowerBonus then
				spBonus_Constant = spBonus_Constant + mod:GetModifierSpellPowerBonus()
			end
			if mod.GetModifierSpellPowerBonus_Percentage then
				spBonus_Percentage = spBonus_Percentage + mod:GetModifierSpellPowerBonus_Percentage()
			end
		end
	end
	sp = (sp + spBonus_Constant)*(1+spBonus_Percentage/100)
	hero.sp = sp
	return sp
	-- body
end

--[[
获取英雄的法术暴击
@param handle hero
return float crit
]]
function Equip:GetSpellCrit( hero )
	local crit = 5  --基础值
	local critBonus_Constant = 0  --增加值
	local critBonus_Percentage = 0  --百分比增加
	local count = hero:GetModifierCount()
	for i=0,count - 1 do
		local mn = hero:GetModifierNameByIndex(i)
		local mod = hero:FindModifierByName(mn)
		if mod then
			if mod.GetModifierSpellCritBonus then
				critBonus_Constant = critBonus_Constant + mod:GetModifierSpellCritBonus()
			end
			if mod.GetModifierSpellCritBonus_Percentage then
				critBonus_Percentage = critBonus_Percentage + mod:GetModifierSpellCritBonus_Percentage()
			end
		end
	end
	crit = (crit + critBonus_Constant)*(1+critBonus_Percentage/100)
	hero.crit = crit
	return crit
	-- body
end

--[[
获取英雄的法术暴击伤害
@param handle hero
return float cdamage
]]
function Equip:GetSpellCritDamage(hero)
	local cdamage = 150  --基础值
	local cdamageBonus_Constant = 0  --增加值
	local cdamageBonus_Percentage = 0  --百分比增加
	local count = hero:GetModifierCount()
	for i=0,count - 1 do
		local mn = hero:GetModifierNameByIndex(i)
		local mod = hero:FindModifierByName(mn)
		if mod then
			if mod.GetModifierSpellCritDamageBonus then
				cdamageBonus_Constant = cdamageBonus_Constant + mod:GetModifierSpellCritDamageBonus()
			end
			if mod.GetModifierSpellCritDamageBonus_Percentage then
				cdamageBonus_Percentage = cdamageBonus_Percentage + mod:GetModifierSpellCritDamageBonus_Percentage()
			end
		end
	end
	cdamage = (cdamage + cdamageBonus_Constant)*(1+cdamageBonus_Percentage/100)
	hero.cdamage = cdamage
	return cdamage
	-- body
end

--[[
获取英雄的闪避
@param handle hero
return float evasion
]]
function Equip:GetEvasion( hero )
	local hit = 100  --被攻击概率
	local count = hero:GetModifierCount()
	for i=0,count - 1 do
		local mn = hero:GetModifierNameByIndex(i)
		local mod = hero:FindModifierByName(mn)
		if mod then
			if mod.GetModifierEvasion_Constant then
				hit = hit * (1 - mod:GetModifierEvasion_Constant()/100)
			end
		end
	end
	return 100 - hit
	-- body
end

--[[
获取英雄的格挡
@param handle hero
return float block
]]
function Equip:GetBlock( hero )
	local block = 0  --基础值
	local blockBonus_Constant = 0  --增加值
	local blockBonus_Percentage = 0  --百分比增加
	local count = hero:GetModifierCount()
	for i=0,count - 1 do
		local mn = hero:GetModifierNameByIndex(i)
		local mod = hero:FindModifierByName(mn)
		if mod then
			if mod.GetModifierBlockBonus then
				blockBonus_Constant = blockBonus_Constant + mod:GetModifierBlockBonus()
			end
			if mod.GetModifierBlockBonus_Percentage then
				blockBonus_Percentage = blockBonus_Percentage + mod:GetModifierBlockBonus_Percentage()
			end
		end
	end
	block = (block + blockBonus_Constant)*(1+blockBonus_Percentage/100)
	hero.block = block
	return block
	-- body
end

