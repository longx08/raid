"use strict";

function SortNumber (a,b) {
	return b.dps-a.dps;
	// body...
}

function Update (){
	var Combat = CustomNetTables.GetTableValue("Dps", "combat");
	var Duration = CustomNetTables.GetTableValue("Dps", "duration");
	if (!Combat) {return};
	var tt = $.Localize("combat_" + Combat.combat);
	if (Duration) {
		tt = tt + " " + Duration.minute_10 +Duration.minute_01 + ":" +Duration.second_10 +Duration.second_01 ;
	};
	$("#Time").text = tt;

	var Info = CustomNetTables.GetTableValue("Dps", "all_info");
	if (!Info) {return};		
	$("#DpsPanel").RemoveAndDeleteChildren();
	for (var i in Info)
	{
		var panel = $.CreatePanel("Panel",$("#DpsPanel"),"");
		panel.BLoadLayoutSnippet("row");
		panel.FindChildTraverse("ranking").text = i;
		panel.FindChildTraverse("player").text = Players.GetPlayerName(Info[i]["id"]);
		panel.FindChildTraverse("dps").text = Info[i]["dps"];
		panel.FindChildTraverse("hps").text = Info[i]["hps"];
	}
	// body...
}



(function(){
	$("#TitlePanel").BLoadLayoutSnippet("row");
	$("#TitlePanel").FindChildTraverse("ranking").text = $.Localize("dps_ranking");
	$("#TitlePanel").FindChildTraverse("player").text = $.Localize("dps_player");
	$("#TitlePanel").FindChildTraverse("dps").text = $.Localize("dps_dps");
	$("#TitlePanel").FindChildTraverse("hps").text = $.Localize("dps_hps");
	CustomNetTables.SubscribeNetTableListener("Dps",Update);
})()
