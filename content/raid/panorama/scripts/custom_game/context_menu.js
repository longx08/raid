function GetContentPanel(){
	return $("#ContentPanel");
}

function SetMenu(menu){
	if(typeof(menu) != "object")return;
	$("#ContentPanel").RemoveAndDeleteChildren();
	for(var i in menu)
	{
		var p = $.CreatePanel("Panel",$("#ContentPanel"),"");
		p.AddClass("ItemMenuButton");
		p.SetPanelEvent("onactivate", menu[i]);

		var label = $.CreatePanel("Label",p,"");
		label.html = true;
		label.text = $.Localize(i);
	}
}

GameUI.CustomUIConfig().ShowCustomContextMenu = function(panel,menu){
	if(panel== undefined || panel == null)return;
	$.GetContextPanel().visible = true;
	var num = 0;
	for(var i in menu){
		num++;
	};
	var pos = GameUI.GetCursorPosition();
	pos[0] = pos[0] + 20;
	pos[1] = pos[1] - 30 * num;

	var x = pos[0];
	var y = pos[1];

	var content = $("#ContentPanel");
	content.style.x = pos[0].toString() + "px";
	content.style.y = pos[1].toString() + "px";

	while( content.actualxoffset >= pos[0] )
	{
		content.style.x = (--x).toString() + "px";
		if( x < -3000 )break;
	}

	while( content.actualxoffset <= pos[0] )
	{
		content.style.x = (++x).toString() + "px";
		if( x > 3000 )break;
	}

	while( content.actualyoffset >= pos[1] )
	{
		content.style.y = (--y).toString() + "px";
		if( y < -3000 )break;
	}

	while( content.actualyoffset <= pos[1] )
	{
		content.style.y = (++y).toString() + "px";
		if( y > 3000 )break;
	}

	SetMenu(menu);
};

GameUI.CustomUIConfig().HideCustomContextMenu = function(){
	$.GetContextPanel().visible = false;
};

(function(){
	$.GetContextPanel().GetContentPanel = GetContentPanel;
	$.GetContextPanel().visible = false;
})();