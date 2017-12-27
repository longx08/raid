-- 战斗系统
-- unit.aggro_table 记录了该单位的仇恨表
LinkLuaModifier("modifier_in_combat", "modifiers/modifier_in_combat.lua",LUA_MODIFIER_MOTION_NONE)

if Combat == nil then
	Combat = class({})
	Combat.ENEMIES_TABLE = {}  --战斗中的敌人
	Combat.DPS_TABLE = {}  --玩家的dps信息
	Combat.HPS_TABLE = {}  --玩家的hps信息
end

--[[
初始化，为该单位添加modifier
]]
function Combat:InitCombat( hero )
	hero:AddNewModifier(unit, nil, "modifier_in_combat", {})
	-- body
end

--[[
造成伤害
@param handle attacker 攻击者
@param handle unit 被攻击者
@param int damage 伤害值
@param boolean isOffensive 是否玩家攻击敌人
]]
function Combat:DealDamage( attacker,unit,damage,isOffensive )
	if GameRules.bINCOMBAT== false then
		self:CombatThink()
	end
	if isOffensive then --攻击敌人
		if TableFindKey(Combat.ENEMIES_TABLE,unit) == nil then
			table.insert(Combat.ENEMIES_TABLE, unit)
		end
		local playerID = attacker:GetPlayerOwnerID()
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
	else  --被攻击
		if TableFindKey(Combat.ENEMIES_TABLE,attacker) == nil then
			table.insert(Combat.ENEMIES_TABLE, attacker)
		end
	end
	-- body
end

--[[
造成治疗
@param int playerID 治疗玩家ID
@param int gain 治疗量
]]
function Combat:DealHeal(playerID,gain)
	Combat.HPS_TABLE[playerID] = (Combat.HPS_TABLE[playerID] or 0) + gain
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
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("combat_think"), function (  )		
		if Combat:IsCombatFinished() then			
			GameRules.bINCOMBAT= false			
		end
		if GameRules.bINCOMBAT== false then
			print("combat finish")
			CustomNetTables:SetTableValue("Dps", "combat", {combat = 0})
			return nil
		end
		local duration = GameRules:GetGameTime() - Combat.startTime
		local Total = {}
		for i=0,9 do
			if Combat.DPS_TABLE[i] or Combat.HPS_TABLE[i] then
				table.insert(Total, {id=i,dps=math.floor((Combat.DPS_TABLE[i] or 0)/duration),hps=math.floor((Combat.HPS_TABLE[i] or 0)/duration)})
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
	end, 1)
	-- body
end

--[[
检查怪物表，看看战斗是否结束
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