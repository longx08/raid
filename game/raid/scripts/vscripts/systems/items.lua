--物品系统
--item.property_table 记录了该物品的属性表
--item.score 记录了该物品的评分
--nettable Items 记录了所有物品的信息

if Items == nil then
	Items = class({})
end




--[[
根据装等创建装备，随机属性
@param string name
@param int level
return handle item
]]
function Items:CreateItemByLevel( name,level )
	local property_table = {}
	local TotalScore = 0
	local count = 2
	if RandomInt(0, 100) < (level+5)*100/(level+10) then
		count = count + 1
		if RandomInt(0, 100) < (level+5)*100/(level+25) then
			count = count + 1
		end
	end
	for i=1,count do
		local property = PickRandomData(Property_Random_Table[i])
		local value,score = self:RandomPropertyValue(name,property,level)
		TotalScore = TotalScore + score
		property_table[i] = {}
		property_table[i]["property"] = property
		property_table[i]["value"] = value
	end
	local item = CreateItem(name, nil,nil)
	if item then
		item.property_table = property_table
		--DeepPrintTable(property_table)
		CustomNetTables:SetTableValue("Items", "item_property_"..item:GetEntityIndex(), property_table)
		item.score = TotalScore
		CustomNetTables:SetTableValue("Items", "item_score_"..item:GetEntityIndex(), {total = TotalScore})
	end
	return item
	-- body
end

--[[
根据属性表创建装备
@param string name
@param table property_table
return handle item
]]
function Items:CreateItemByTable( name,property_table )
	local item = CreateItem(name, nil,nil)
	if item then
		item.property_table = property_table
		CustomNetTables:SetTableValue("Items", "item_property_"..item:GetEntityIndex(), property_table)
	end
	return item
	-- body
end

Property_Random_Table = {
	{"str","agi","int","ap","sp"},
	{"health","mana"},
	{"attack","mren","cdamage","block","move"},
	{"aspeed","crit","cdamage","armor","resis"}
}

--[[
随机各属性的值
@param string name
@param string property
@param int level
return int value,float level
]]
function Items:RandomPropertyValue( name,property,level )
	local slot = Equip:GetSlotNumber( name )
	local value = 0
	local dif = RandomFloat(0-level^0.85/4 ,level^0.85/4 ) 
	level = level + dif
	if property == "str" or property =="agi" or property =="int" or property =="attack" then
		value = level 
	elseif property == "ap" or property =="sp" then
		value = level * 3
	elseif property == "health" or property == "mana" then
		value = level * 10
	elseif property == "mren" or property == "resis"then --取值为10倍整数
		value = level
	elseif property == "aspeed" or property == "cdamage" then
		value = level * 0.5
	elseif property == "armor" then
		value = level * 0.1
	elseif property == "crit"then --取值为10倍整数
		value = level * 2
	elseif property == "block" then
		value = (level+10)^1.4/5
	elseif property == "move" then
		if slot == 8 then  --鞋子的移速为5倍
			level = level * 5
		end
		value = (level +5)^0.8
	end
	return math.floor(value + 0.5),level
	-- body
end

--[[
打开宝箱，获得装备或水晶
@param handle hero
@param handle item
@param int bagSlot
]]
function Items:OpenChest( hero,item,bagSlot )
	if hero == nil or item == nil then
		return
	end
	local itemName = item:GetAbilityName()
	if string.sub(itemName, 6, 10) ~= "chest" then
		return
	end
	--箱子数量降低
	local charges = item:GetCurrentCharges()
	charges = charges - 1
	if charges <= 0 then
		Bag:ChangeItemBySlot( hero,bagSlot,-1 )
		item:RemoveSelf()
	else
		item:SetCurrentCharges(charges)
		Bag:ChangeItemBySlot( hero,bagSlot,item:GetEntityIndex() )
	end
	--宝箱等级
	local level = tonumber(string.sub(itemName, 12, -1)) 
	if RandomInt(1, 100) < 20 then   					 --20%几率宝箱等级+1
		level = level + 1
	end
	if RandomInt(1, 100) < 50 then                        --获得装备
		local name = self:GetRandomItemName(level)
		local equipment = self:CreateItemByLevel(name,level*5)
		if equipment then
			ShowTips(hero:GetPlayerOwner(),"#chest_get_equipment","#DOTA_Tooltip_ability_"..name,nil)
			Bag:AddItem( hero,equipment )
		end
	else
		local crystal = math.floor((level*5+ RandomFloat(-1, 1) )^1.1+0.5)
		ShowTips(hero:GetPlayerOwner(),"#chest_get_crystal","+"..tostring(crystal),nil)
		Skill:ChangeCrystal( hero,crystal )          --获得水晶
	end
	-- body
end

--[[
随机物品名称
@param int level
return string name
]]
function Items:GetRandomItemName( level )
	local name = ""
	local slot = RandomInt(1, 10)
	if slot == 10 then
		name = "item_ran_10_01"
	else
		name = "item_ran_0"..slot.."_01"
	end
	return name
	-- body
end

--[[
删除物品在nettable中的数据
@param int itemIndex
]]
function Items:DeleteItemFromNetTable( itemIndex )
	print("delete item:"..itemIndex)
	CustomNetTables:SetTableValue("Items", "item_property_"..itemIndex, nil)
	CustomNetTables:SetTableValue("Items", "item_owner_"..itemIndex, nil)
	CustomNetTables:SetTableValue("Items", "item_score_"..itemIndex, nil)
	-- body
end

