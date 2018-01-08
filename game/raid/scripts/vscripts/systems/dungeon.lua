-- 副本系统
--Dungeon.kv   地图上所有副本信息  table
--Dungeon.info   某一个副本的信息  table
--Dungeon.bosses  储存各个副本中已刷新的boss实体  table

--Dungeon.CurrentName  当前副本名  string
--Dungeon.CurrentDifficulty  当前副本难度  int
--Dungeon.TotalPoint  当前副本已获得的点数  int
--Dungeon.RespawnPosition  副本复活位置  Vector
--Dungeon.AttackMultiple  攻击力随难度的加成系数 float
--Dungeon.HealthMultiple  血量随难度的加成系数 float
--Dungeon.HealthMultipleByPlayers  血量随人数增加的系数 float

--Dungeon.bVoting  是否在投票状态 boolean

if Dungeon == nil then
	Dungeon = class({})
end

--[[
初始化，获取该地图的所有副本信息
]]
function Dungeon:Init(  )
	--print("init dungeon")
	local dungeons = LoadKeyValues("scripts/npc/dungeons.txt")
	--该地图的所有副本信息
	Dungeon.kv = dungeons[GetMapName()]
	--所有副本名字
	local AllName = {}
	for k,_ in pairs(Dungeon.kv) do
		table.insert(AllName, k)
	end
	CustomGameEventManager:Send_ServerToAllClients("set_dungeon_names",AllName)
	--初始化记录boss实体的表
	Dungeon.bosses = {}
	--根据人数调整血量的加成值
	Dungeon.HealthMultipleByPlayers = 0
	for i=1,#GameRules.HERO_TABLE do
		if i <= 2 then
			Dungeon.HealthMultipleByPlayers = Dungeon.HealthMultipleByPlayers + 0.5
		else
			Dungeon.HealthMultipleByPlayers = Dungeon.HealthMultipleByPlayers + 1
		end
	end
	-- body
end

--[[
开启投票
@param int playerID
@param string name
@param int difficulty
]]
function Dungeon:StartVoting( playerID,name,difficulty )
	if GameRules.bINCOMBAT == true then
		ShowError(playerID,"#can_not_do_this_in_combat")
		return
	end
	if Dungeon.bVoting == true then
		ShowError(playerID,"#dungeon_already_voting")
		return
	end
	if Dungeon.kv==nil or Dungeon.kv[name] == nil or difficulty == -1 then
		ShowError(playerID,"#dungeon_not_valid")
		return
	end
	Dungeon.bVoting = true
	CustomGameEventManager:Send_ServerToAllClients("start_voting", {duration = 15,name=name,difficulty=difficulty})
	for _,v in pairs(GameRules.HERO_TABLE) do
		v.bVoteYes = false
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("vote"), function (  )
		Dungeon.bVoting = false
		local count = 0
		for _,v in pairs(GameRules.HERO_TABLE) do
			if v.bVoteYes == true then
				count = count + 1
			end
		end
		if count/(#GameRules.HERO_TABLE) >= 0.5 then
			Dungeon:ChangeCurrentDungeon(name,difficulty)
		end
		return nil
		-- body
	end, 15)
	-- body
end

--[[
开启新副本
@param string name
@param int difficulty
]]
function Dungeon:ChangeCurrentDungeon( name,difficulty )
	--print("change current dungeon")
	if GameRules.bINCOMBAT == true then
		ShowAll("#dungeon_can_not_start_in_combat",nil,nil)
		return
	end
	if Dungeon.kv[name] == nil or difficulty == -1 then
		--print("not valid dungeon")
		return
	end
	ShowAll("#dungeon_start",name,"dungeon_difficulty_"..difficulty)
	-- 名称 难度 积分
	Dungeon.CurrentName = name
	Dungeon.CurrentDifficulty = difficulty
	Dungeon.TotalPoint = 0
	CustomGameEventManager:Send_ServerToAllClients("current_dungeon_change", {name = name,difficulty=difficulty})
	-- 复活点
	Dungeon.info = Dungeon.kv[name]
	if Dungeon.info["respawn"] then
		Dungeon.RespawnPosition = Vector(Dungeon.info["respawn"]["x"],Dungeon.info["respawn"]["y"],Dungeon.info["respawn"]["z"])
		for _,v in pairs(GameRules.HERO_TABLE) do
			FindClearSpaceForUnit(v, Dungeon.RespawnPosition, true)
		end
	end
	-- 攻击力和血量随难度加成系数
	if Dungeon.info["attack"] then
		Dungeon.AttackMultiple = Dungeon.info["attack"][difficulty]
	else
		Dungeon.AttackMultiple = difficulty*0.8 + 0.2
	end
	if Dungeon.info["health"] then
		Dungeon.HealthMultiple = Dungeon.info["health"][difficulty]
	else
		Dungeon.HealthMultiple = difficulty
	end
	-- 删除以前的boss实体
	if Dungeon.bosses[name] then
		for _,v in pairs(Dungeon.bosses[name]) do
			if v and (not v:IsNull()) then
				v:RemoveSelf()
			end
		end
	end
	Dungeon.bosses[name] = {}
	--开始刷第一个怪
	self:SpawnBoss()
	-- body
end

--[[
刷boss
]]
function Dungeon:SpawnBoss(  )
	if Dungeon.info == nil then
		return
	end
	for k,v in pairs(Dungeon.info) do
		if k~="respawn" and k~="attack" and k~="health" and v["min"] <= Dungeon.TotalPoint and v["max"] >= Dungeon.TotalPoint then
			local position = Vector(v["position"]["x"],v["position"]["y"],v["position"]["z"]) 
			local unit = CreateUnitByName(k, position, true, nil, nil, DOTA_TEAM_NEUTRALS)
			if unit then
				unit.point = v["point"] --击杀单位获得的积分
				unit.drop = v["drop"]  --击杀单位后掉落的宝箱等级
				table.insert(Dungeon.bosses[Dungeon.CurrentName], unit)
				--根据难度及人数调整血量、攻击、技能等级、经验
				local new_health = unit:GetMaxHealth()*Dungeon.HealthMultiple*Dungeon.HealthMultipleByPlayers
				unit:SetBaseMaxHealth(new_health)
				unit:SetMaxHealth(new_health)
				unit:SetHealth(new_health)
				unit:SetBaseDamageMin(unit:GetBaseDamageMin()*Dungeon.AttackMultiple)
				unit:SetBaseDamageMax(unit:GetBaseDamageMax()*Dungeon.AttackMultiple)
				for i=0,15 do
					local abi = unit:GetAbilityByIndex(i)
					if abi then
						abi:SetLevel(Dungeon.CurrentDifficulty)
					end
				end
				unit.exp = v["exp"]*Dungeon.CurrentDifficulty
			end
		end
	end
	-- body
end

--[[
传送
@param handle hero
]]
function Dungeon:Teleport(hero)
	if GameRules.bINCOMBAT == true then
		ShowError(hero:GetPlayerOwnerID(),"#can_not_do_this_in_combat")
		return
	end
	if Dungeon.RespawnPosition then
		FindClearSpaceForUnit(hero, Dungeon.RespawnPosition, true)
	end
	-- body
end


--[[
怪物死亡
@param handle unit
]]
function Dungeon:OnCreatureDead(unit)
	if unit == nil then
		return
	end
	if Dungeon.info and Dungeon.info[unit:GetUnitName()] then
		Dungeon.TotalPoint = Dungeon.TotalPoint + (unit.point or 0)
		if unit.drop then
			local name = ""
			if unit.drop < 10 then
				name = "item_chest_0"..(unit.drop + 2 *(Dungeon.CurrentDifficulty-1))
			else
				name = "item_chest_"..(unit.drop + 2 *(Dungeon.CurrentDifficulty-1))
			end
			for _,v in pairs(GameRules.HERO_TABLE) do
				local item = CreateItem(name, nil,nil)
				if item then
					Bag:AddItem(v,item)
				end
			end
		end
		if unit.exp then
			for _,v in pairs(GameRules.HERO_TABLE) do
				v:AddExperience(unit.exp*Dungeon.CurrentDifficulty, 0, false, false)
			end
		end
		self:SpawnBoss()
	end
	-- body
end

--[[
团灭后重新刷怪
]]
function Dungeon:RefreshBoss()
	--先删除所有boss
	if Dungeon.bosses[Dungeon.CurrentName] then
		for _,v in pairs(Dungeon.bosses[Dungeon.CurrentName]) do
			if v and (not v:IsNull()) then
				v:RemoveSelf()
			end
		end
	end
	Dungeon.bosses[Dungeon.CurrentName] = {}
	--5秒后刷怪
	Timers:CreateTimer(5,function (  )
		self:SpawnBoss()
		-- body
	end,context)	
	-- body
end
