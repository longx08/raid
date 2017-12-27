-- Generated from template

if GameMode == nil then
	_G.GameMode = class({})
end


require("events") --事件
require("util") --通用函数
require("debug") --debug函数


require("systems/bag")  --背包系统
require("systems/equip")  --装备系统
require("systems/skill")  --技能系统
require("systems/items")  --物品系统
require("systems/combat")  --战斗系统
require("systems/damage_heal")  --伤害治疗系统

-- 时间库，允许延迟动作
require('libraries/timers')
-- 物理库，单位的物理、动作、碰撞.  更多信息在PhysicsReadme.txt
--require('libraries/physics')
-- 投射物库，先进的3D投射物系统
--require('libraries/projectiles')
-- 通知库，在玩家、队伍、所有人界面上显示信息
require('libraries/notifications')
-- 动作库，让单位做特定动作
--require('libraries/animations')
-- 附着库，单位的附着物？
--require('libraries/attachments')
-- 玩家表，在服务器和特定玩家间的nettable
--require('libraries/playertables')
-- 容器库，用于创建物品栏或者商店等
--require('libraries/containers')
-- 制作者工具，用于搜索lua API，控制台指令"modmaker_api"
--require('libraries/modmaker')
-- 路径库，自动创建path_corner 实体
--require('libraries/pathgraph')
-- 选择库，检查并管理玩家的选择目标
--require('libraries/selection')
-- 伤害等数字显示
require("libraries/popups")

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheResource( "soundfile", "game_sounds_ui.vsndevts", context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonRaid = GameMode()
	GameRules.AddonRaid:InitGameMode()
end

function GameMode:InitGameMode()
	print( "Raid addon is loaded." )

	-- 全局变量
	GameRules.bINCOMBAT = false -- 战斗状态
	GameRules.HERO_TABLE = {} -- 英雄列表

	-- 全局设置
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 10)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetHideKillMessageHeaders( true )
	GameRules:SetFirstBloodActive(false)
	GameRules:SetPreGameTime(10)

	-- 监听
	ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, 'OnEntityKilled'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(GameMode, 'OnPlayerPickHero'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(GameMode, 'OnPlayerLevelUp'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(GameMode, 'OnItemPickedUp'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(GameMode, 'OnPlayerChat'), self)

	-- 随机种子
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  	math.randomseed(tonumber(timeTxt))

  	-- filter
  	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode,"DamageFilter"), self)
  	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode,"OrderFilter"), self)

  	-- 平衡性常数
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_DAMAGE,0)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP,5)
  	--GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN_PERCENT,5)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_STATUS_RESISTANCE_PERCENT,0.0005)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_DAMAGE,0)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR,0)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED,0.5)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT,0.0005)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE,0)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA,5)
  	--GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN_PERCENT,5)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_SPELL_AMP_PERCENT,0)
  	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESISTANCE_PERCENT,0.0005)

  	-- 其他设置
  	GameRules:GetGameModeEntity():SetBuybackEnabled(false)
  	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(13)
  	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
  	GameRules:GetGameModeEntity():SetStashPurchasingDisabled(true)
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )

	if IsInToolsMode() then
		Convars:RegisterCommand("create_random_item", function (  )
			for i=1,10 do
				local name = "item_chest_0"..RandomInt(1, 4)
				local item = CreateItem(name, nil,nil)
				if item then
					CreateItemOnPositionSync(Vector(0,0,128)+RandomVector(RandomInt(1, 200)), item)
				end
			end
			local hero = PlayerResource:GetSelectedHeroEntity(0)
			if hero then
			end
			-- body
		end, "create a random property item", FCVAR_CHEAT)
	end
end

-- Evaluate the state of the game
function GameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end