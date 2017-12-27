"use strict";
var m_BagSlotList = []; // 所有的背包格子
var m_Slot = -1; // 当前格子index
var m_Item = -1; // 当前物品index
var player = Players.GetLocalPlayer(); // 当前玩家
var hero = Players.GetPlayerHeroEntityIndex(player); // 当前玩家英雄

// 更新背包
function Update () {

	hero = Players.GetPlayerHeroEntityIndex(player);
	// 从nettable获取到背包的信息
	var bagInfo = CustomNetTables.GetTableValue("Bag", "bag_"+hero.toString());
	if (!bagInfo) {return};
	// 更新每一个格子的信息
	m_BagSlotList.forEach(function(slot,i){
		var itemIndex = bagInfo[i+1];
		if(!itemIndex)return;
		// 物品index
		slot.m_ItemIndex = itemIndex;
		// 物品图标
		slot.FindChild("item_img").itemname = Abilities.GetAbilityName(itemIndex);
		// 物品堆叠层数
		if (Items.ShouldDisplayCharges(itemIndex)) {
			slot.FindChild("item_charges").text = Items.GetCurrentCharges(itemIndex);
		}
		else
		{
			slot.FindChild("item_charges").text = "";
		}
	})
	// body...
}

// 注册格子的事件
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

// 开始拖动
function OnDragStart (panelId,dragCallbacks) {
	var slot = $('#'+panelId);
	if (slot.m_ItemIndex == -1) {return;};

	OnMouseOut(slot);

	slot.SetHasClass("dragging_from", true);
	var displayPanel = $.CreatePanel("DOTAItemImage",$.GetContextPanel(),"dragImage");
	displayPanel.m_Source = "bag";
	displayPanel.m_BagSlot = slot.m_BagSlot;
	displayPanel.m_ItemIndex = slot.m_ItemIndex;
	displayPanel.itemname = Abilities.GetAbilityName(slot.m_ItemIndex);
	displayPanel.m_Completed = false;


	dragCallbacks.displayPanel = displayPanel;
	dragCallbacks.offsetX = 0;
	dragCallbacks.offsetY = 0;
	// body...
}

// 拖动进入
function OnDragEnter (panelId,draggedPanel) {
	var panel = $('#'+panelId);
	
	panel.SetHasClass("potential_drop_target", true);
	// body...
}

// 拖动离开
function OnDragLeave (panelId,draggedPanel) {
	var panel = $('#'+panelId);
	panel.SetHasClass("potential_drop_target", false);
	// body...
}

// 拖动掉入
function OnDragDrop (panelId,draggedPanel) {

	var slot = $('#'+panelId);
	draggedPanel.m_Completed = true;
		
	if (draggedPanel.m_Source === "bag") {
		if (draggedPanel.m_BagSlot === slot.m_BagSlot) {return};
		GameEvents.SendCustomGameEventToServer("bag_swap_item", {from:draggedPanel.m_BagSlot,to:slot.m_BagSlot});
		Game.EmitSound("CustomGameUI.ItemDropToPublicStash");
	};
	if (draggedPanel.m_Source === "equip") {
		GameEvents.SendCustomGameEventToServer("equip_swap_with_bag", {equipSlot:draggedPanel.m_EquipSlot,bagSlot:slot.m_BagSlot});
	};
	// body...
}

// 拖动结束
function OnDragEnd (panelId,draggedPanel) {
	if (draggedPanel.m_Completed == false) {
		GameEvents.SendCustomGameEventToServer("bag_drop_item", {slot:draggedPanel.m_BagSlot,itemIndex:draggedPanel.m_ItemIndex});
	};
	draggedPanel.DeleteAsync(0);
	var slot = $('#'+panelId);
	slot.SetHasClass("dragging_from",false);

	// body...
}

function OnMouseOver (slot) {
	if (slot.m_ItemIndex > 0) {
		ShowItemTooltip(hero,"bag",slot);
	};
	// body...
}

function OnMouseOut (slot) {
	HideItemTooltip();
	// body...
}

// 单击
function OnActivate (slot) {
	// body...
}

// 双击
function OnDoubleClick (slot) {
	if (slot.m_ItemIndex == -1) {return};
	HideItemTooltip();
	GameEvents.SendCustomGameEventToServer("bag_equip_item", {slot:slot.m_BagSlot,itemIndex:slot.m_ItemIndex});
	// body...
}

// 右键
function OnContextMenu (slot) {
	if (slot.m_ItemIndex == -1) {return};
	HideItemTooltip();
	m_Slot = slot.m_BagSlot;
	m_Item = slot.m_ItemIndex;
	var menu = {};
	menu["bag_equip_item"] = OnEquipItem;
	menu["bag_drop_item"] = OnDropItem;
	if (Items.IsSellable(slot.m_ItemIndex)) {
		menu["bag_sell_item"] = OnSellItem;
	}
	GameUI.CustomUIConfig().ShowCustomContextMenu($.GetContextPanel(),menu);	
	// body...
}

// 装备物品
function OnEquipItem() {
	HideItemTooltip();
	if (m_Item == -1) {return};
	GameEvents.SendCustomGameEventToServer("bag_equip_item", {slot:m_Slot,itemIndex:m_Item});
	GameUI.CustomUIConfig().HideCustomContextMenu();
	// body...
}

// 丢弃物品
function OnDropItem() {
	HideItemTooltip();
	if (m_Item == -1) {return};
	GameEvents.SendCustomGameEventToServer("bag_drop_item", {slot:m_Slot,itemIndex:m_Item});
	GameUI.CustomUIConfig().HideCustomContextMenu();
	// body...
}

// 出售物品
function OnSellItem() {
	HideItemTooltip();
	if (m_Item == -1) {return};
	GameEvents.SendCustomGameEventToServer("bag_sell_item", {slot:m_Slot,itemIndex:m_Item});
	GameUI.CustomUIConfig().HideCustomContextMenu();
	// body...
}

// 打开背包
function OpenBag () {
	if ($("#BagPanel").BHasClass("hidden")) {
		Update();
		$("#BagPanel").SetHasClass("hidden", false);
		Game.EmitSound("ui.click_alt");
	}
	else
	{
		$("#BagPanel").SetHasClass("hidden", true);
		Game.EmitSound("ui.click_back");
	}
	// body...
}

(function(){
	// 创建背包
	var col = 0;
	var row = $.CreatePanel("Panel",$("#ContentPanel"),"");
	row.AddClass("right");
	for(var i = 1; i<=18;i++){
		var slot = $.CreatePanel("Panel",row,"BagSlot"+i);
		slot.BLoadLayoutSnippet("slot");
		slot.m_BagSlot = i;
		slot.m_ItemIndex = -1;
		m_BagSlotList.push(slot);
		RegisterSlotEvent(slot);
		if (++col >= 6) {
			col = 0;
			row = $.CreatePanel("Panel",$("#ContentPanel"),"");
			row.AddClass("right");
		};
	}
	// 更新一次
	Update();
	// 监听背包更新事件
	GameEvents.Subscribe("update_bag", Update);
	// 打开背包按钮
	GameUI.CustomUIConfig().KoimOpenBag = OpenBag;
	Game.AddCommand("OpenBag", OpenBag, "", 0);
})();
