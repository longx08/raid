-- 技能库系统
-- hero.crystal 记录玩家的水晶数量

if Skill == nil then
	Skill = class({})
	Skill.PlayerInfo = {}
	Skill.kv = LoadKeyValues("scripts/npc/skill_info.txt")
end

Skill.MaxNumber = 6  --最大技能数量

--[[
初始化某玩家技能库、水晶
@param handle hero
]]
function Skill:InitSkill( hero )
	if hero == nil or hero:IsNull() then
		return
	end
	hero.crystal = 0
	CustomNetTables:SetTableValue("Skill", "crystal_"..hero:GetEntityIndex(), {crystal = 0})

	local skillList = Skill.kv[hero:GetUnitName()] 
	if skillList then
		Skill.PlayerInfo[hero:GetEntityIndex()] = skillList
		CustomNetTables:SetTableValue("Skill", "skill_"..hero:GetEntityIndex(),skillList )
		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "init_skill", {})
		--给英雄添加技能或buff
		self:Apply(hero)
	end
	-- body
end

--[[
更新某玩家技能库
@param handle hero
@param table skillList
]]
function Skill:Update( hero,skillList )
	Skill.PlayerInfo[hero:GetEntityIndex()] = skillList
	CustomNetTables:SetTableValue("Skill", "skill_"..hero:GetEntityIndex(),skillList )
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "update_skill", {})
	-- body
end

--[[
获取某玩家技能库
@param handle hero
return table
]]
function Skill:GetInfo( hero )
	if hero == nil then
		return nil
	end
	local skillList = Skill.PlayerInfo[hero:GetEntityIndex()]
	return skillList
	-- body
end

--[[
获取主动技能信息
@param handle hero
@param string name
return table info
]]
function Skill:GetActiveSkillInfo( hero,name )
	local skillList = Skill:GetInfo(hero)
	if skillList and skillList["active"] then
		for _,v in pairs(skillList["active"]) do
			if v["name"] == name then
				return v
			end
		end
	end
	return nil
	-- body
end

--[[
获取当前技能数量
@param handle hero
return int num
]]
function Skill:GetCurrentNumber( hero )
	local skillList = Skill:GetInfo(hero)
	local num = 0
	if skillList and skillList["active"] then
		for _,v in pairs(skillList["active"]) do
			if v["current"] == "1" then
				num = num + 1
			end
		end
	end
	return num
	-- body
end

--[[
改变技能为（非）当前技能
@param handle hero
@param int index
@param int num
]]
function Skill:ChangeCurrent( hero,index,num )
	local skillList = Skill:GetInfo(hero)
	if skillList and skillList["active"] then
		local info = skillList["active"][index]
		if info == nil then
			print('nothing')
			return
		end
		if num == 1 and Skill:GetCurrentNumber( hero ) >= Skill.MaxNumber then
			ShowError(hero:GetPlayerOwnerID(),"skill_max_number")
			return
		end
		info["current"] = num
		skillList["active"][index] = info
		self:Update(hero,skillList)
	end
	-- body
end

--[[
升级技能
@param handle hero
@param string kind
@param int index
@param int cost
]]
function Skill:LevelUp( hero,kind,index,cost )
	local skillList = Skill:GetInfo(hero)
	if skillList and skillList[kind] then
		local info = skillList[kind][index]
		if info == nil then
			print("find nothing")
			return
		end
		if cost > (hero.crystal or 0) or cost == -1 then
			ShowError(hero:GetPlayerOwnerID(),"skill_not_enough_crystal")
			return
		end
		info["level"] = info["level"] + 1
		skillList[kind][index] = info
		self:Update(hero,skillList)
		Skill:ChangeCrystal(hero,0-cost)
	end
	-- body
end

--[[
应用技能库，实际给英雄技能和buff
@param handle hero
]]
function Skill:Apply( hero )
	--print("apply")
	local playerID = hero:GetPlayerID()
	if bINCOMBAT == true then
		ShowError(playerID,"skill_can_not_change_in_combat")
		return
	end
	local skillList = self:GetInfo(hero)
	if skillList then
		if skillList["active"] then
			--删除技能
			for i=0,15 do
				local abi = hero:GetAbilityByIndex(i)
				if abi then
					hero:RemoveAbility(abi:GetAbilityName())
				end
			end
			-- 添加技能
			for _,v in pairs(skillList["active"]) do
				if v["current"] == 1 then
					local new_abi = hero:AddAbility(v["name"])
					if new_abi then
						new_abi:SetLevel(v["level"])
					end
				end
			end
		end
		if skillList["passive"] then
			for _,v in pairs(skillList["passive"]) do				
				local mod = hero:FindModifierByName("modifier_"..v["name"])
				if mod then
					mod.level = v["level"]
				else
					local new_mod = hero:AddNewModifier(hero, nil, "modifier_"..v["name"], {})
					new_mod.level = level
				end
			end
		end
	end
	-- body
end

--[[
改变某玩家水晶
@param handle hero
@param int num
]]
function Skill:ChangeCrystal( hero,num )
	local crystal = hero.crystal or 0
	crystal = crystal + num
	if crystal < 0 then
		crystal = 0
	end
	hero.crystal = crystal
	CustomNetTables:SetTableValue("Skill", "crystal_"..hero:GetEntityIndex(), {crystal = crystal})
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "update_skill", {})
	-- body
end