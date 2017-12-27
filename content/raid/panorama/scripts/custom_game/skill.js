"use strict";
var m_Crystal = 0;
var Timer = 0;

//创建Panel
function Init () {
	var player = Players.GetLocalPlayer();
	var hero = Players.GetPlayerHeroEntityIndex(player);
	if (hero == -1) {return};
	var Info = CustomNetTables.GetTableValue("Skill", "skill_"+hero.toString());
	if (!Info) {return};
	// 主动技能
	if (Info["active"]) {
		var row = $.CreatePanel("Panel",$("#ActivePanel"),"" );
		row.AddClass("right");
		var count = 0;
		for (var i in Info["active"]) {				
			var newPanel = $.CreatePanel("Panel",row,"active_"+i );	
			newPanel.BLoadLayoutSnippet("ability");
			newPanel.m_Index = i;
			newPanel.m_Name = Info["active"][i]["name"];
			newPanel.m_Active = true;
			newPanel.FindChildTraverse("ability_img").abilityname = Info["active"][i]["name"];
			newPanel.FindChildTraverse("level_up").text ="+" ;
			RegisterPanelEvent(newPanel);
			if (++count >= 4) {
				count = 0;
				row = $.CreatePanel("Panel",$("#ActivePanel"),"");
				row.AddClass("right");
			};
		};
	};
	// 被动技能
	if (Info["passive"]) {
		var row = $.CreatePanel("Panel",$("#PassivePanel"),"" );
		row.AddClass("right");
		var count = 0;
		for (var i in Info["passive"]) {				
			var newPanel = $.CreatePanel("Panel",row,"passive_"+i );	
			newPanel.BLoadLayoutSnippet("ability");
			newPanel.m_Index = i;
			newPanel.m_Name = Info["passive"][i]["name"];
			newPanel.m_Active = false;
			newPanel.FindChildTraverse("ability_img").abilityname = Info["active"][i]["name"];
			newPanel.FindChildTraverse("level_up").text ="+" ;
			RegisterPanelEvent(newPanel);
			if (++count >= 4) {
				count = 0;
				row = $.CreatePanel("Panel",$("#PassivePanel"),"");
				row.AddClass("right");
			};
		};
	};
	Update();
	// body...
}

// 更新
function Update () {
	//$.Msg("update skill");
	var player = Players.GetLocalPlayer();
	var hero = Players.GetPlayerHeroEntityIndex(player);
	if (hero == -1) {return};
	// 水晶数量
	var crystal_info = CustomNetTables.GetTableValue("Skill", "crystal_"+hero.toString());
	if (crystal_info) {
		m_Crystal = crystal_info["crystal"];
	};
	$("#SkillTitle").text = $.Localize(Entities.GetUnitName(hero)) + " " + $.Localize("skill_crystal")+ ": " + m_Crystal;

	var Info = CustomNetTables.GetTableValue("Skill", "skill_"+hero.toString());
	if (!Info) {return};
	// 主动技能
	if (Info["active"]) {
		for (var i in Info["active"]){
			var name = Info["active"][i]["name"];
			var current = Info["active"][i]["current"];
			var level = Info["active"][i]["level"];
			var cost = Info["active"][i]["cost"];
			var panel = $("#active_"+i);
			if (panel) {
				panel.m_Current = current;				
				panel.m_Level = level;
				panel.m_Cost = cost[level];
				panel.FindChildTraverse("name").text = "Lv " +level + "  " + $.Localize("skill_cost") + ": " +panel.m_Cost;				
				if (current == 1) {
					panel.SetHasClass("current", true);
				}
				else
				{
					panel.SetHasClass("current", false);
				}
				if (level == 0) {
					panel.FindChildTraverse("ability_img").SetHasClass("not_learned", true);
				}
				else
				{
					panel.FindChildTraverse("ability_img").SetHasClass("not_learned", false);
				}
				if (cost[level] != -1 && m_Crystal >= cost[level]) {
					panel.FindChildTraverse("level_up").SetHasClass("can_level_up", true);
				}
				else
				{
					panel.FindChildTraverse("level_up").SetHasClass("can_level_up", false);
				}
			};
		}
	};
	if (Info["passive"]) {
		for (var i in Info["passive"]){
			var name = Info["passive"][i]["name"];
			var level = Info["passive"][i]["level"];
			var cost = Info["passive"][i]["cost"];
			var panel = $("#passive_"+i);
			if (panel) {				
				panel.m_Level = level;
				panel.m_Cost = cost[level];
				panel.FindChildTraverse("name").text = "Lv " +level + "  " + $.Localize("skill_cost") + ": " +panel.m_Cost;				
				if (level == 0) {
					panel.FindChildTraverse("ability_img").SetHasClass("not_learned", true);
				}
				else
				{
					panel.FindChildTraverse("ability_img").SetHasClass("not_learned", false);
				}
				if (cost[level] != -1 && m_Crystal >= cost[level]) {
					panel.FindChildTraverse("level_up").SetHasClass("can_level_up", true);
				}
				else
				{
					panel.FindChildTraverse("level_up").SetHasClass("can_level_up", false);
				}
			};
		}
	};
	// body...
}

function OnApplyButton() {
	if (Timer <= 0) {
		GameEvents.SendCustomGameEventToServer("skill_apply", {});
		Timer = 10;
		CountTimer();
	}
	// body...
}

function CountTimer() {
	if (Timer > 0) {
		$("#ApplyButton").text = $.Localize("skill_cooldown") + Timer;
		Timer = Timer - 1;
		$.Schedule(1,CountTimer);
	}	
	else
	{
		$("#ApplyButton").text = $.Localize("skill_apply") ;
	}
	// body...
}

// 注册事件
function RegisterPanelEvent (slot) {
	var img = slot.FindChildTraverse("ability_img");
	var lu = slot.FindChildTraverse("level_up");
	img.SetPanelEvent("onmouseover", function  () {
		ShowAbility(slot);
		// body...
	})
	img.SetPanelEvent("onmouseout", function  () {
		HideAbility(slot);
		// body...
	})
	if (slot.m_Active) {
		img.SetPanelEvent("onactivate", function  () {
			ChangeCurrent(slot);
			// body...
		});
	};
	
	lu.SetPanelEvent("onactivate", function  () {
		LevelUpAbility(slot);
		// body...
	})
	// body...
}

// 显示技能信息
function ShowAbility (slot) {
	$.DispatchEvent("DOTAShowAbilityTooltip",slot,slot.m_Name);
	// body...
}

// 关闭技能信息
function HideAbility (slot) {
	$.DispatchEvent("DOTAHideAbilityTooltip",slot);
	// body...
}

// 将技能变为（非）当前技能
function ChangeCurrent (slot) {	
	GameEvents.SendCustomGameEventToServer("skill_change_current", {index:slot.m_Index,current:slot.m_Current});
	
	// body...
}

function LevelUpAbility (slot) {
	GameEvents.SendCustomGameEventToServer("skill_level_up", {active:slot.m_Active,index:slot.m_Index,cost:slot.m_Cost});
	// body...
}

// 打开或关闭面板
function OpenSkill () {
	if ($("#ContentPanel").BHasClass("hidden")) {
		Update();
		$("#ContentPanel").SetHasClass("hidden", false);
		Game.EmitSound("ui.click_alt");
	}
	else
	{
		$("#ContentPanel").SetHasClass("hidden", true);
		Game.EmitSound("ui.click_back");
	}
	// body...
}

(function(){
	GameUI.CustomUIConfig().KoimOpenSkill = OpenSkill;
	Game.AddCommand("OpenSkill", OpenSkill, "", 0);
	GameEvents.Subscribe("init_skill", Init);
	GameEvents.Subscribe("update_skill", Update);
})()
