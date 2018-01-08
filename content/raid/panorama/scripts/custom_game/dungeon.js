"use strict";
var radios = [];
var SelectedName = "";
var Timer = -1;

// 所有副本名字
function SetAllNames(data) {
	//$.Msg("set all names");
	var dropdown = $("#NewNameList");
	if (data) {
		for(var i in data){
			var label = $.CreatePanel("Label",dropdown,"Name"+i);
			label.text= data[i];
			dropdown.AddOption(label);
		}
	}
	// body...
}

// 改变当前副本
function CurrentDungeonChange(data) {
	$("#CurrentNameText").text = $.Localize(data.name);
	$("#CurrentDifficultyText").text = $.Localize("dungeon_difficulty_"+data.difficulty);
	// body...
}

// 传送至当前副本
function Teleport() {
	//$.Msg("teleport");
	GameEvents.SendCustomGameEventToServer("dungeon_teleport", {});
	// body...
}

// 下拉菜单选择新副本
function OnDropDownChanged() {
	SelectedName = $("#NewNameList").GetSelected().text;
	
	// body...
}

// 获取当前radio选择的难度
function GetSelectedDifficulty() {
	var difficulty = -1;
	radios.forEach(function (radio,i) {
		if (radio.IsSelected()) {
			difficulty = radio.value;
		}
		// body...
	})
	//$.Msg(difficulty);
	return difficulty
	// body...
}

// 开启投票
function StartVoting() {
	//$.Msg("start voting");
	var dif = GetSelectedDifficulty();
	GameEvents.SendCustomGameEventToServer("dungeon_start_voting", {name:SelectedName,difficulty:dif});
	// body...
}

// 投票同意
function Confirm() {
	//$.Msg("confirm");
	GameEvents.SendCustomGameEventToServer("dungeon_vote_yes", {});
	$("#Confirm").SetHasClass("hidden", true);
	$("#Cancel").SetHasClass("hidden", true);
	$("#DungeonPanel").SetHasClass("hidden", true);
	// body...
}

// 投票拒绝
function Cancel() {
	//$.Msg("cancel");
	GameEvents.SendCustomGameEventToServer("dungeon_vote_no", {});
	$("#Confirm").SetHasClass("hidden", true);
	$("#Cancel").SetHasClass("hidden", true);
	$("#DungeonPanel").SetHasClass("hidden", true);
	// body...
}

function StartTimer(data) {
	Timer = data.duration;
	$("#Vote").SetHasClass("hidden", false);
	$("#VotingDungeon").text = $.Localize(data.name);
	$("#VotingDifficulty").text = $.Localize("dungeon_difficulty_"+data.difficulty);
	$("#Timer").text = Timer;
	$("#Confirm").SetHasClass("hidden", false);
	$("#Cancel").SetHasClass("hidden", false);
	$("#DungeonPanel").SetHasClass("hidden", false);
	CountTimer();
	// body...
}

function CountTimer() {
	Timer = Timer - 1;
	if (Timer > 0) {
		$("#Timer").text = Timer;
		$.Schedule(1,CountTimer);
	}
	else
	{
		$("#Vote").SetHasClass("hidden", true);
	}
	// body...
}

function OpenDungeon(argument) {
	if ($("#DungeonPanel").BHasClass("hidden")) {
		$("#DungeonPanel").SetHasClass("hidden", false);
		Game.EmitSound("ui.click_alt");
	}
	else
	{
		$("#DungeonPanel").SetHasClass("hidden", true);
		Game.EmitSound("ui.click_back");
	}
	// body...
}

(function(){
	radios.push($("#Difficulty_1"));
	radios.push($("#Difficulty_2"));
	radios.push($("#Difficulty_3"));
	$("#Difficulty_1").value = 1;
	$("#Difficulty_2").value = 2;
	$("#Difficulty_3").value = 3;
	GameEvents.Subscribe("set_dungeon_names", SetAllNames);
	GameEvents.Subscribe("current_dungeon_change", CurrentDungeonChange);
	GameEvents.Subscribe("start_voting", StartTimer);
	GameUI.CustomUIConfig().KoimOpenDungeon = OpenDungeon;
	Game.AddCommand("OpenDungeon", OpenDungeon, "", 0);
})()
