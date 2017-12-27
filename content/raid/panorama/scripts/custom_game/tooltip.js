"use strict";

// 显示物品的文本
function ShowItemTooltip (heroIndex,source,slot) {
	if (slot.m_ItemIndex < 0) return;
	var itemName = Abilities.GetAbilityName(slot.m_ItemIndex);
	var itemInfo = CustomNetTables.GetTableValue("Items", "item_property_"+slot.m_ItemIndex);
	if (itemInfo) {
		// 物品名称
		var title = $.Localize("#DOTA_Tooltip_ability_"+itemName) ;
		var tooltip = ""+"<br>";	
		// 物品评分
		var score = CustomNetTables.GetTableValue("Items", "item_score_"+slot.m_ItemIndex);
		if (score) {
			tooltip = tooltip + $.Localize("item_score") + " : " + score.total.toFixed(1) + "<br>" ;
		};
		// 物品拥有者
		var owner_info = CustomNetTables.GetTableValue("Items", "item_owner_"+slot.m_ItemIndex);			
		if (owner_info) {
			var playerName = Players.GetPlayerName(owner_info["owner"]);
			tooltip = tooltip + $.Localize("item_owner") + " : " + playerName + "<br>";
		}
		else
		{
			tooltip = tooltip + $.Localize("item_no_owner") + "<br>";
		}
		// 物品属性
		tooltip = tooltip + $.Localize("slot_" + itemName.substring(9,11)) + "<br>" +"<br>";
		for (var i = 1; i <= 4; i++) {
			if (itemInfo[i]) {
				var property = itemInfo[i]["property"];
				var value = itemInfo[i]["value"];	
				tooltip = tooltip  +$.Localize("property_"+property)+ "  + ";			
				if (property == "mren" || property == "resis" || property == "evade" || property == "crit" ) {
					value =value/10;
					tooltip = tooltip + value.toFixed(1);
				}
				else
				{
					tooltip = tooltip + value;
				}
				tooltip = tooltip + "<br>";
			};
		};
		// 物品价格
		tooltip = tooltip + "<br>" + $.Localize("item_price") + " : " + Math.round(Math.pow(score.total/5,1.1));
		$.DispatchEvent("DOTAShowTitleTextTooltip",slot,title,tooltip);
	}
	else{		
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex",slot,itemName,heroIndex);
	};
	
	// body...
}

function HideItemTooltip () {
	$.DispatchEvent("DOTAHideAbilityTooltip",$.GetContextPanel());
	$.DispatchEvent("DOTAHideTitleTextTooltip",$.GetContextPanel());
}