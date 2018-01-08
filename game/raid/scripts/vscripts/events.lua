
LinkLuaModifier("modifier_tank", "modifiers/modifier_tank.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_all", "modifiers/modifier_all.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_respawn", "modifiers/modifier_respawn.lua",LUA_MODIFIER_MOTION_NONE)

--游戏状态改变
function GameMode:OnGameRulesStateChange( keys )
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then --选英雄时间
	elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then --策略时间
		self:InitListener(  ) --初始化监听器		
	elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then --游戏准备
						
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then --游戏开始
		GameRules.HERO_TABLE = HeroList:GetAllHeroes()
		self:SpawnCreeps()
		Dungeon:Init(  )
	end
	-- body
end

--刷新小怪
function GameMode:SpawnCreeps( )
	GameMode.camp_num = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("spawn_creeps"), function (  )
		if GameMode.camp_num < #GameRules.HERO_TABLE then
			local creep = CreateUnitByName("npc_dota_creature_gnoll_assassin", Vector(2000,0,128)+RandomVector(RandomInt(20, 300)), true, nil, nil, DOTA_TEAM_NEUTRALS)
			if creep then
				GameMode.camp_num = GameMode.camp_num + 1
				local total = 0
				for _,v in pairs(GameRules.HERO_TABLE) do
					total = total + v.average_score or 0
				end
				local new_health = creep:GetMaxHealth()*(1+total/100)
				creep:SetBaseMaxHealth(new_health)
				creep:SetMaxHealth(new_health)
				creep:SetHealth(new_health)
			end
		end
		if GameMode.camp_num < #GameRules.HERO_TABLE then
			return 3
		end
		return 10
		-- body
	end, 1)
	-- body
end

--玩家选择英雄
function GameMode:OnPlayerPickHero( keys )
	local hero = EntIndexToHScript(keys.heroindex)
	-- body
end

--单位出生
function GameMode:OnNPCSpawned( keys )
	local unit = EntIndexToHScript(keys.entindex)
	if unit:IsRealHero() then --英雄
		unit:AddNewModifier(unit, nil, "modifier_respawn", {duration = 3})
		unit:SetAbilityPoints(0)
		if unit.bFirstSpawned == nil then --第一次出生
			unit.bFirstSpawned = true
			--添加坦克buff
			if unit:GetUnitName() == "npc_dota_hero_dragon_knight" then  
				unit:AddNewModifier(unit, nil, "modifier_tank", {})
			end
			--初始化英雄的各系统：背包，装备，技能，战斗
			Bag:InitBag(unit)
			Equip:InitEquip( unit )
			Skill:InitSkill(unit)
			--召唤物
			unit.summon_unit = {}
		else
			Dungeon:Teleport(unit)
		end	
	end
	-- body
end

--单位死亡
function GameMode:OnEntityKilled( keys )
	local unit = EntIndexToHScript( keys.entindex_killed )
	local killer = nil
	if keys.entindex_attacker ~= nil then
    	killer = EntIndexToHScript( keys.entindex_attacker )
  	end
  	local ability = nil
  	if keys.entindex_inflictor ~= nil then
    	ability = EntIndexToHScript( keys.entindex_inflictor )
  	end
  	
  	--杀死所有召唤物
	if unit.summon_unit then
		for _,v in pairs(unit.summon_unit) do
			if v and (not v:IsNull()) and v:IsAlive() then
				v:ForceKill(false)
			end
		end
		unit.summon_unit = {}
	end
	--清除玩家的单位在仇恨表中的信息
  	if unit:GetTeam() == DOTA_TEAM_GOODGUYS then
  		Combat:DeleteFromAggroTable(unit:GetEntityIndex())
  	end
	--死亡的英雄等待战斗结束后复活
  	if unit:IsRealHero() then 
  		unit:SetContextThink(DoUniqueString("waiting_for_respawn"), function (  )
  			if unit:IsAlive() then --已经复活（比如被战复），则结束think
  				return nil
  			end
  			if GameRules.bINCOMBAT == false then
  				unit:RespawnHero(false, false)
				local hPlayer = unit:GetPlayerOwner()
				if hPlayer then
					hPlayer:SetMusicStatus(0, 1.0)
				end
				return nil
			end
			return 1
  			-- body
  		end, 2)		
  	end
  	--死亡的是怪物
  	if unit:IsCreature() then
  		local label = unit:GetUnitLabel()
  		if label == "boss" or label == "creep" or label == "add" then --副本中的怪物
  			Dungeon:OnCreatureDead(unit)
  		elseif label == "camp" then --营地里的怪
  			GameMode.camp_num = GameMode.camp_num - 1
	  		if RandomInt(0, 100) < 30 + #GameRules.HERO_TABLE*5 then
				local item = CreateItem("item_chest_01", nil,nil)
				if item then
					local position = unit:GetAbsOrigin()+RandomVector(RandomInt(1, 200))
					CreateItemOnPositionSync(position, item)
					item:LaunchLoot(false, 150, 0.75, position)
				end
			end
		elseif label == "summon" then -- 玩家召唤物
		end
  	end		
	-- body
end



-- 英雄升级
function GameMode:OnPlayerLevelUp( keys )
	local player = EntIndexToHScript(keys.player)
	local hero = PlayerResource:GetSelectedHeroEntity(player:GetPlayerID())
	hero:SetAbilityPoints(0)
	-- body
end

--拾取物品
function GameMode:OnItemPickedUp( keys )
	local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
    local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    local itemname = keys.itemname
    --print("pick up item")

    if heroEntity and itemEntity then
    	if Bag:IsFull( heroEntity ) then
    		heroEntity:DropItemAtPositionImmediate(itemEntity, heroEntity:GetAbsOrigin()+RandomVector(100))
    	else  
    		heroEntity:TakeItem(itemEntity)  		
	    	Bag:AddItem(heroEntity,itemEntity)	    	
	    end
    end
	-- body
end

--玩家对话
function GameMode:OnPlayerChat( keys )
	--keys.teamonly
    --keys.userid
    --keys.text
    --keys.playerid
    if keys.text == "-tank" then
    	local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
    	if hero and hero:GetUnitName() == "npc_dota_hero_dragon_knight" then
    		if hero:HasModifier("modifier_tank") then
    			hero:RemoveModifierByName("modifier_tank")
    		else
    			hero:AddNewModifier(hero, nil, "modifier_tank", {})
    		end
    	end
    elseif keys.text == "-aggro" then
    	Combat:ShowAggro()
    elseif keys.text == "-test" then
    	local hero = PlayerResource:GetSelectedHeroEntity(keys.playerid)
    	if hero and IsInToolsMode() then
    		if hero:HasModifier("modifier_all") then
    			hero:RemoveModifierByName("modifier_all")
    		else
    			hero:AddNewModifier(hero, nil, "modifier_all", {})
    		end
    	end
    end
	-- body
end

--伤害过滤
function GameMode:DamageFilter( keys )
	--keys.entindex_inflictor_const 伤害技能
	--keys.entindex_victim_const 受害者
	--keys.entindex_attacker_const 攻击者
	--keys.damage  伤害值
	local victim = keys.entindex_victim_const
	if victim ~= nil then
		victim = EntIndexToHScript(victim)
	end
	local attacker = keys.entindex_attacker_const
	if attacker ~= nil then
		attacker = EntIndexToHScript(attacker)
	end
	if keys.entindex_inflictor_const == nil then
		local block = Equip:GetBlock( victim )
		keys.damage = keys.damage - block
	end
	-- 死亡或者刚出生不造成伤害
	if (not attacker:IsAlive()) or attacker:HasModifier("modifier_respawn") then
		print("already dead")
		return false
	end
	Combat:DealDamage(attacker,victim,keys.damage)
	return true
	-- body
end

-- 治疗过滤器
function GameMode:HealingFilter( keys )
	--keys.heal  治疗量
	--keys.entindex_inflictor_const 来源，可能为nil
	--keys.entindex_target_const 受到治疗的目标

	if keys.entindex_inflictor_const and GameRules.bINCOMBAT == true then
		local caster = EntIndexToHScript(keys.entindex_inflictor_const)
		if caster then
			Combat:DealHeal(caster,keys.heal)
		end
	end
	return true
	-- body
end

--行为过滤
function GameMode:OrderFilter( keys )
	return true
	-- body
end

--初始化监听器
function GameMode:InitListener(  )
	CustomGameEventManager:RegisterListener("bag_swap_item", OnBagSwapItem)
	CustomGameEventManager:RegisterListener("bag_equip_item", OnBagEquipItem)
	CustomGameEventManager:RegisterListener("bag_drop_item", OnBagDropItem)
	CustomGameEventManager:RegisterListener("bag_sell_item", OnBagSellItem)

	CustomGameEventManager:RegisterListener("equip_swap_with_bag", OnEquipSwapWithBag)	
	CustomGameEventManager:RegisterListener("equip_unequip_item", OnEquipUnequipItem)
	CustomGameEventManager:RegisterListener("equip_drop_item", OnEquipDropItem)
	CustomGameEventManager:RegisterListener("equip_sell_item", OnEquipSellItem)

	CustomGameEventManager:RegisterListener("skill_change_current", OnSkillChangeCurrent)
	CustomGameEventManager:RegisterListener("skill_level_up", OnSkillLevelUp)
	CustomGameEventManager:RegisterListener("skill_apply", OnSkillApply)

	CustomGameEventManager:RegisterListener("dungeon_start_voting", OnDungeonStartVoting)
	CustomGameEventManager:RegisterListener("dungeon_vote_yes", OnDungeonVoteYes)
	CustomGameEventManager:RegisterListener("dungeon_vote_no", OnDungeonVoteNo)
	CustomGameEventManager:RegisterListener("dungeon_teleport", OnDungeonTeleport)
	-- body
end

--[[
事件：背包物品交换位置
@param handle event
@param handle data
]]
function OnBagSwapItem( event,data )
	if type(data.from) ~= "number" or type(data.to) ~= "number" then
		return
	end
	if data.from == data.to or data.from > Bag.MaxSlot or data.to > Bag.MaxSlot or data.from < 0 or data.to <0 then
		return
	end
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	Bag:SwapItem(hero,data.from,data.to)
	-- body
end

--[[
事件：背包装备物品（双击物品）
@param handle event
@param handle data
]]
function OnBagEquipItem( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	local item = EntIndexToHScript(data.itemIndex)
	if item == nil then
		return
	end
	local itemName = item:GetAbilityName()
	if string.sub(itemName, 6 ,8) == "ran" then
		local equipSlot = Equip:GetSlotNumber( itemName )  --该物品所属的部位
		if equipSlot > 0 then			
			local equipItemIndex = Equip:GetItemBySlot( hero,equipSlot ) --该部位当前装备
			if Equip:ChangeItemBySlot(hero,equipSlot,data.itemIndex) then
				Bag:ChangeItemBySlot( hero,data.slot,equipItemIndex )	
			end	
		end
	elseif string.sub(itemName, 6, 10) == "chest" then
		Items:OpenChest(hero,item,data.slot)
	end
end

--[[
事件：背包丢弃物品
@param handle event
@param handle data
]]
function OnBagDropItem( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	local item = EntIndexToHScript(data.itemIndex)
	if item == nil then
		return
	end
	Bag:DropItem(hero,data.slot,data.itemIndex)
	-- body
end

--[[
事件：背包出售物品
@param handle event
@param handle data
]]
function OnBagSellItem( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	local item = EntIndexToHScript(data.itemIndex)
	if item == nil then
		return
	end
	Bag:SellItem(hero,data.slot,data.itemIndex)
	-- body
end

--[[
事件：装备栏和背包交换物品
@param handle event
@param handle data
]]
function OnEquipSwapWithBag( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	local equipItemIndex = Equip:GetItemBySlot(hero,data.equipSlot)  --该部位当前装备
	local bagItemIndex = Bag:GetItemBySlot(hero,data.bagSlot)  --背包装备
	if bagItemIndex ~= -1 then --背包有物品
		local bagItem = EntIndexToHScript(bagItemIndex)
		local need_slot = Equip:GetSlotNumber(bagItem:GetAbilityName())
		if need_slot ~= -1 and need_slot == data.equipSlot then --正确部位
			if Equip:ChangeItemBySlot(hero,data.equipSlot,bagItemIndex) then
				Bag:ChangeItemBySlot(hero,data.bagSlot,equipItemIndex)
			end
		else
			ShowError(data.PlayerID,"#equip_not_the_right_slot")
		end
	else		
		if Equip:ChangeItemBySlot(hero,data.equipSlot,-1) then
			Bag:ChangeItemBySlot(hero,data.bagSlot,equipItemIndex)
		end
	end

	-- body
end

--[[
事件：从装备栏脱掉装备
@param handle event
@param handle data
]]
function OnEquipUnequipItem( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	local item = EntIndexToHScript(data.itemIndex)
	local bagSlot = Bag:GetUnusedIndex( hero )
	if bagSlot == -1 then
		Equip:DropItem(hero,data.slot,data.itemIndex)
	else
		if Equip:ChangeItemBySlot(hero,data.slot,-1) then
			Bag:ChangeItemBySlot(hero,bagSlot,data.itemIndex)
		end
	end
	-- body
end

--[[
事件：从装备栏丢弃物品
@param handle event
@param handle data
]]
function OnEquipDropItem( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	local item = EntIndexToHScript(data.itemIndex)
	if item == nil then
		return
	end
	Equip:DropItem(hero,data.slot,data.itemIndex)
	-- body
end

--[[
事件：装备栏出售物品
@param handle event
@param handle data
]]
function OnEquipSellItem( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	local item = EntIndexToHScript(data.itemIndex)
	if item == nil then
		return
	end
	Equip:SellItem(hero,data.slot,data.itemIndex)
	-- body
end

--[[
事件：技能变为（非）当前技能
@param handle event
@param handle data
]]
function OnSkillChangeCurrent( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	if tonumber(data.current) == 0 then		
		Skill:ChangeCurrent(hero,data.index,1)
	else
		Skill:ChangeCurrent(hero,data.index,0)
	end
	-- body
end

--[[
事件：技能升级
@param handle event
@param handle data
]]
function OnSkillLevelUp( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	if tonumber(data.active) == 1 then
		Skill:LevelUp(hero,"active",data.index,data.cost)
	else
		Skill:LevelUp(hero,"passive",data.index,data.cost)
	end
	-- body
end

--[[
事件：技能库应用
@param handle event
@param handle data
]]
function OnSkillApply( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	Skill:Apply(hero)
	-- body
end

--[[
事件：开启副本投票
@param handle event
@param handle data
]]
function OnDungeonStartVoting( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	--print("start voting")
	Dungeon:StartVoting(data.PlayerID, data.name,data.difficulty )
	-- body
end

--[[
事件：副本投票YES
@param handle event
@param handle data
]]
function OnDungeonVoteYes( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	--print("yes")
	hero.bVoteYes = true
	--CustomGameEventManager:Send_ServerToAllClients("player_vote_info", {id=data.PlayerID,yes=true})
	-- body
end

--[[
事件：副本投票NO
@param handle event
@param handle data
]]
function OnDungeonVoteNo( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	--print("no")
	hero.bVoteYes = false
	--CustomGameEventManager:Send_ServerToAllClients("player_vote_info", {id=data.PlayerID,yes=false})
	-- body
end

--[[
事件：副本传送
@param handle event
@param handle data
]]
function OnDungeonTeleport( event,data )
	local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	if hero == nil then
		return
	end
	--print("teleport")
	Dungeon:Teleport(hero)
	-- body
end