"use strict";
var m_EquipSlotList = [];
var m_Slot = -1;
var m_Item = -1;
var player = -1;
var hero = -1;
var localHero = -1;

function Update () {
	//$.Msg("update");
	player = Players.GetLocalPlayer();
	hero = Players.GetLocalPlayerPortraitUnit();
	localHero = Players.GetPlayerHeroEntityIndex(player);
	if (Entities.IsRealHero(hero) == false ) {
		hero = localHero;
	};

	var equipInfo = CustomNetTables.GetTableValue("Equip", "equip_"+hero.toString());
	if (!equipInfo) {return};
	m_EquipSlotList.forEach(function (slot,i) {
		var itemIndex = equipInfo[i+1];
		if (!itemIndex) {return};
		slot.m_ItemIndex = itemIndex;
		slot.FindChild("item_img").itemname = Abilities.GetAbilityName(itemIndex);
		// body...
	})
	// body...
}

function RegisterSlotEvent (slot) {
	slot.SetDraggable(true);
	$.RegisterEventHandler( 'DragEnter', slot, OnDragEnter );
	$.RegisterEventHandler( 'DragDrop', slot, OnDragDrop );
	$.RegisterEventHandler( 'DragLeave', slot, OnDragLeave );
	$.RegisterEventHandler( 'DragStart', slot, OnDragStart );
	$.RegisterEventHandler( 'DragEnd', slot, OnDragEnd );
	slot.SetPanelEvent('oncontextmenu',function() {
		OnContextMenu(slot);
	});
	slot.SetPanelEvent('onmouseover',function() {
		OnMouseOver(slot);
	});
	slot.SetPanelEvent('onmouseout',function() {
		OnMouseOut(slot);
	});
	slot.SetPanelEvent('ondblclick',function() {
		OnDoubleClick(slot);
	});
	slot.SetPanelEvent('onactivate',function() {
		OnActivate(slot);
	});
	// body...
}

function OnDragStart (panelId,dragCallbacks) {
	var slot = $('#'+panelId);
	if (slot.m_ItemIndex == -1) {return;};
	if (hero != localHero) {return};

	OnMouseOut(slot);

	slot.SetHasClass("dragging_from", true);
	var displayPanel = $.CreatePanel("DOTAItemImage",$.GetContextPanel(),"dragImage");
	displayPanel.m_Source = "equip";
	displayPanel.m_EquipSlot = slot.m_EquipSlot;
	displayPanel.m_ItemIndex = slot.m_ItemIndex;
	displayPanel.itemname = Abilities.GetAbilityName(slot.m_ItemIndex);
	displayPanel.m_Completed = false;


	dragCallbacks.displayPanel = displayPanel;
	dragCallbacks.offsetX = 0;
	dragCallbacks.offsetY = 0;
	// body...
}

function OnDragEnter (panelId,draggedPanel) {
	var panel = $('#'+panelId);
	
	panel.SetHasClass("potential_drop_target", true);
	// body...
}

function OnDragLeave (panelId,draggedPanel) {
	var panel = $('#'+panelId);
	panel.SetHasClass("potential_drop_target", false);
	// body...
}

function OnDragDrop (panelId,draggedPanel) {

	var slot = $('#'+panelId);
	//$.Msg("dragging from:"+draggedPanel.m_Source);
	//$.Msg("drop:"+panelId);
	draggedPanel.m_Completed = true;
	if (hero != localHero) {return};
	
	if (draggedPanel.m_Source === "bag") {
		GameEvents.SendCustomGameEventToServer("equip_swap_with_bag", {bagSlot:draggedPanel.m_BagSlot,equipSlot:slot.m_EquipSlot});
		Game.EmitSound("CustomGameUI.ItemDropToPublicStash");
	};
	// body...
}

function OnDragEnd (panelId,draggedPanel) {
	if (draggedPanel.m_Completed == false) {
		GameEvents.SendCustomGameEventToServer("equip_drop_item", {slot:draggedPanel.m_EquipSlot,itemIndex:draggedPanel.m_ItemIndex});
	};
	draggedPanel.DeleteAsync(0);
	var slot = $('#'+panelId);
	slot.SetHasClass("dragging_from",false);

	// body...
}

function OnMouseOver (slot) {
	if (slot.m_ItemIndex > 0) {
		ShowItemTooltip(hero,"equip",slot);
	};
	// body...
}

function OnMouseOut (slot) {
	HideItemTooltip();
	// body...
}

function OnActivate (slot) {
	// body...
}

function OnDoubleClick (slot) {
	OnMouseOut(slot);
	if (hero != localHero) {
		return;
	};
	if (slot.m_ItemIndex == -1) {return};
	GameEvents.SendCustomGameEventToServer("equip_unequip_item", {slot:slot.m_EquipSlot,itemIndex:slot.m_ItemIndex});
	Game.EmitSound("CustomGameUI.ItemDropToPublicStash");
	// body...
}

function OnContextMenu (slot) {
	if (slot.m_ItemIndex == -1) {return};
	HideItemTooltip();
	if (hero != localHero) {return};
	m_Slot = slot.m_EquipSlot;
	m_Item = slot.m_ItemIndex;
	var menu = {};
	menu["equip_unequip_item"] = OnUnequipItem;
	menu["equip_drop_item"] = OnDropItem;
	if (Items.IsSellable(m_Item)) {
		menu["equip_sell_item"] = OnSellItem;
	}
	GameUI.CustomUIConfig().ShowCustomContextMenu($.GetContextPanel(),menu);
	// body...
}

function OnUnequipItem() {
	HideItemTooltip();
	if (m_Item == -1) {return};
	GameEvents.SendCustomGameEventToServer("equip_unequip_item", {slot:m_Slot,itemIndex:m_Item});
	GameUI.CustomUIConfig().HideCustomContextMenu();
	// body...
}

function OnDropItem() {
	HideItemTooltip();
	if (m_Item == -1) {return};
	GameEvents.SendCustomGameEventToServer("equip_drop_item", {slot:m_Slot,itemIndex:m_Item});
	GameUI.CustomUIConfig().HideCustomContextMenu();
	// body...
}

function OnSellItem() {
	HideItemTooltip();
	if (m_Item == -1) {return};
	GameEvents.SendCustomGameEventToServer("equip_sell_item", {slot:m_Slot,itemIndex:m_Item});
	GameUI.CustomUIConfig().HideCustomContextMenu();
	// body...
}

function UpdateStat () {
	var stat = CustomNetTables.GetTableValue("Equip", "stat_"+hero.toString());
	if (!stat) {return};

	$("#HeroName").text = $.Localize(Entities.GetUnitName(hero)) + "   LV " + Entities.GetLevel(hero);
	$("#AverageScore").text = $.Localize("equip_score") + " : " + stat["score"] ;
	for(var property in stat){
		var label = $("#"+property);
		if (label == undefined) {return};
		var value = stat[property];
		if (property == "crit") {
			label.text = $.Localize("property_"+ property)  + value.toFixed(1);
		}
		else
		{
			label.text = $.Localize("property_"+ property)  + value.toFixed(0);
		}
	}
	// body...
}


function UpdateQueryUnit () {
	//$.Msg("update query unit");
	var target = Players.GetLocalPlayerPortraitUnit();
	if (Entities.IsRealHero(target)) {
		Update();
		UpdateStat();
	};
	// body...
}

function OpenEquip () {
	if ($("#EquipPanel").BHasClass("hidden")) {
		Update();
		UpdateStat();
		$("#EquipPanel").SetHasClass("hidden", false);
		Game.EmitSound("ui.click_alt");
	}
	else
	{
		$("#EquipPanel").SetHasClass("hidden", true);
		Game.EmitSound("ui.click_back");
	}
	// body...
}

(function(){
	var col = $("#col_1");
	var slot_class = "col_1";
	for (var i = 1; i <= 10; i++) {
		if (i>2) {
			col = $("#col_2");
			slot_class = "col_2";
		};
		if (i>8) {
			col = $("#col_3");
			slot_class = "col_3";
		};
		var slot = $.CreatePanel("Panel",col,"EquipSlot"+i);
		slot.BLoadLayoutSnippet("slot");
		slot.m_EquipSlot = i;
		slot.m_ItemIndex = -1;
		slot.SetHasClass(slot_class, true);
		m_EquipSlotList.push(slot);
		RegisterSlotEvent(slot);
	};
	Update();
	GameEvents.Subscribe("update_equip", Update);
	GameEvents.Subscribe("update_stat", UpdateStat);
	GameEvents.Subscribe("dota_player_update_query_unit", UpdateQueryUnit);
	GameUI.CustomUIConfig().KoimOpenEquip = OpenEquip;
	Game.AddCommand("OpenEquip", OpenEquip, "", 0);
})()
