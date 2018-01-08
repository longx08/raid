-- 战斗系统
-- unit.aggro_table 记录了该单位的仇恨表
--LinkLuaModifier("modifier_in_combat", "modifiers/modifier_in_combat.lua",LUA_MODIFIER_MOTION_NONE)

if Combat == nil then
	Combat = class({})
	Combat.ENEMIES_TABLE = {}  --战斗中的敌人
	Combat.DPS_TABLE = {}  --玩家的dps信息
	Combat.HPS_TABLE = {}  --玩家的hps信息
end

--[[
造成伤害
@param handle attacker 攻击者
@param handle unit 被攻击者
@param int damage 伤害值
@param boolean isOffensive 是否玩家攻击敌人
]]
function Combat:DealDamage( attacker,unit,damage )
	if attacker == nil or unit == nil then
		return
	end
	if attacker:GetTeamNumber() == unit:GetTeamNumber() then
		--print("friendly")
		return
	end
	if GameRules.bINCOMBAT== false then
		self:CombatThink()
	end
	if attacker:GetTeam() == DOTA_TEAM_GOODGUYS then --攻击敌人
		if TableFindKey(Combat.ENEMIES_TABLE,unit) == nil then
			--print("add unit:"..unit:GetUnitName())
			table.insert(Combat.ENEMIES_TABLE, unit)
		end
		local playerID = attacker:GetPlayerOwnerID()
		--print(damage)
		Combat.DPS_TABLE[playerID] = (Combat.DPS_TABLE[playerID] or 0) + damage
		-- 仇恨
		if unit.aggro_table == nil then
			unit.aggro_table = {}
		end
		local aggro = damage
		if attacker:HasModifier("modifier_tank") then
			aggro = aggro * 10
		end
		unit.aggro_table[attacker:GetEntityIndex()] = (unit.aggro_table[attacker:GetEntityIndex()] or 0) + aggro
	end
	if unit:GetTeam() == DOTA_TEAM_GOODGUYS then --被攻击
		if TableFindKey(Combat.ENEMIES_TABLE,attacker) == nil then
			--print("add unit:"..attacker:GetUnitName())
			table.insert(Combat.ENEMIES_TABLE, attacker)
		end
	end
	-- body
end

--[[
造成治疗
@param handle unit 治疗来源单位
@param int gain 治疗量
]]
function Combat:DealHeal(unit,gain)
	if unit == nil or unit:GetTeam() == DOTA_TEAM_NEUTRALS then
		return
	end
	local playerID = unit:GetPlayerOwnerID()
	Combat.HPS_TABLE[playerID] = (Combat.HPS_TABLE[playerID] or 0) + gain
	if #Combat.ENEMIES_TABLE > 0 then
		for _,v in pairs(Combat.ENEMIES_TABLE) do
			if v and (not v:IsNull()) and  v:IsAlive() then
				if v.aggro_table == nil then
					v.aggro_table = {}
				end
				v.aggro_table[unit:GetEntityIndex()] = (v.aggro_table[unit:GetEntityIndex()] or 0) + gain/3
			end
		end
	end
	-- body
end

--[[
开始战斗计时
]]
function Combat:CombatThink(  )
	print("start combat think")
	--清空各个表，记录开始时间
	Combat.ENEMIES_TABLE = {}
	Combat.DPS_TABLE = {}
	Combat.HPS_TABLE = {}
	Combat.startTime = GameRules:GetGameTime()
	--更新战斗状态
	GameRules.bINCOMBAT= true
	CustomNetTables:SetTableValue("Dps", "combat", {combat = 1})
	for _,v in pairs(GameRules.HERO_TABLE) do
		if v then
			local hPlayer = v:GetPlayerOwner()
			if hPlayer then
				hPlayer:SetMusicStatus(2, 1.0)
			end
		end
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("combat_think"), function (  )
		--判断战斗是否应该结束
		if GameRules.bINCOMBAT == true then
			if Combat:IsCombatFinished() or Combat:IsTeamWipe() then			
				GameRules.bINCOMBAT = false						
			end
		end
		-- 如果战斗已经结束，则结束think
		if GameRules.bINCOMBAT == false then
			print("combat finish")
			CustomNetTables:SetTableValue("Dps", "combat", {combat = 0})
			Combat.ENEMIES_TABLE = {}		
			return nil
		end
		-- 更新时间和dps、hps
		local duration = GameRules:GetGameTime() - Combat.startTime
		local Total = {}
		for i=0,9 do
			if Combat.DPS_TABLE[i] or Combat.HPS_TABLE[i] then
				table.insert(Total, {id=i,dps=math.floor((Combat.DPS_TABLE[i] or 0)/duration+0.5),hps=math.floor((Combat.HPS_TABLE[i] or 0)/duration+0.5)})
			end
		end
		table.sort( Total, function ( a,b )
			return a.dps > b.dps
			-- body
		end )
		CustomNetTables:SetTableValue("Dps", "all_info", Total)
		local t = math.floor(duration+0.5)
		local minutes = math.floor(t / 60)
	    local seconds = t - (minutes * 60)
	    local m10 = math.floor(minutes / 10)
	    local m01 = minutes - (m10 * 10)
	    local s10 = math.floor(seconds / 10)
	    local s01 = seconds - (s10 * 10)
	    local timer = {
	    	minute_10 = m10,
	    	minute_01 = m01,
	    	second_10 = s10,
	    	second_01 = s01,
		}
		CustomNetTables:SetTableValue("Dps", "duration", timer)
		return 1
		-- body
	end, 0)
	-- body
end

--[[
检查怪物表，看看战斗是否胜利
]]
function Combat:IsCombatFinished(  )
	if #Combat.ENEMIES_TABLE > 0 then
		for _,v in pairs(Combat.ENEMIES_TABLE) do
			if v and v:IsNull()==false and v:IsAlive() then
				return false
			end
		end
	end
	return true
	-- body
end

-- 是否全部阵亡（团灭）
function Combat:IsTeamWipe( )
	--print("hero number:"..#GameRules.HERO_TABLE)
	for _,v in pairs(GameRules.HERO_TABLE) do
		if v:IsAlive() then
			return false
		end
	end
	ShowAll("#combat_team_wipe",nil,nil)
	Dungeon:RefreshBoss()
	return true
	-- body
end

-- 打印仇恨表
function Combat:ShowAggro(  )
	if #Combat.ENEMIES_TABLE > 0 then
		for _,v in pairs(Combat.ENEMIES_TABLE) do
			if v and (not v:IsNull()) and v:IsAlive() then
				if v.aggro_table then
					print(v:GetUnitName())
					for index,aggro in pairs(v.aggro_table) do
						print(index,aggro)
					end
				end
			end
		end
	end
	-- body
end

--删除已死亡单位在仇恨表中的信息
function Combat:DeleteFromAggroTable(index)
	if GameRules.bINCOMBAT == false then
		return
	end
	if #Combat.ENEMIES_TABLE > 0 then
		for _,v in pairs(Combat.ENEMIES_TABLE) do
			if v and (not v:IsNull()) and v:IsAlive() then
				if v.aggro_table then
					v.aggro_table[index] = nil
				end
			end
		end
	end
	-- body
end
