--背包系统

if Bag == nil then
	Bag = class({})
	Bag.PlayerInfo = {}  --所有玩家的背包信息
end

Bag.MaxSlot = 18

--[[
初始化某玩家背包
@param handle hero
]]
function Bag:InitBag( hero )
	--print("init bag for hero")
	if hero == nil or hero:IsNull() then
		return nil
	end
	local itemList = {}
	for i=1,Bag.MaxSlot do
		itemList[i] = -1
	end
	self:Update(hero,itemList)
	-- body
end

--[[
更新某玩家背包
@param handle hero
@param handle itemList
]]
function Bag:Update( hero,itemList )
	Bag.PlayerInfo[hero:GetEntityIndex()] = itemList
	CustomNetTables:SetTableValue("Bag", "bag_"..hero:GetEntityIndex(),itemList )
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "update_bag", {})
	-- body
end


--[[
获取某玩家背包
@param handle hero
@return table
]]
function Bag:GetInfo( hero )
	if hero == nil or hero:IsNull() then
		return nil
	end
	local itemList = Bag.PlayerInfo[hero:GetEntityIndex()]
	return itemList
	-- body
end

--[[
按照物品名称寻找物品
@param handle hero
@param string name
return handle item
return int bagIndex
]]
function Bag:FindItemByName( hero,name )
	local itemList = self:GetInfo(hero)
	if itemList then
		for k,v in pairs(itemList) do
			if v > 0 then
				local item = EntIndexToHScript(v)
				if item and not item:IsNull() and item:GetAbilityName() == name then
					return item,k
				end
			end
		end
	end
	return nil
	-- body
end

--[[
获取一个空栏位
@param handle hero
@return int
]]
function Bag:GetUnusedIndex( hero )
	local bagIndex = -1
	local itemList = Bag:GetInfo(hero)
	if itemList then
		for k,v in pairs(itemList) do
			if v == -1 then
				bagIndex = k
				break
			end
		end
	end
	return bagIndex
	-- body
end

--[[
获取某栏位的物品
@param handle hero
@param int bagSlot
@return int itemIndex
]]
function Bag:GetItemBySlot( hero,bagSlot )
	local itemList = self:GetInfo(hero)
	if itemList then
		return itemList[bagSlot] or -1
	end
	return -1
	-- body
end

--[[
某玩家背包是否已满
@param handle hero
@return boolean
]]
function Bag:IsFull( hero )
	local itemList = Bag:GetInfo(hero)
	if itemList == nil then
		return false
	end
	for _,v in pairs(itemList) do
		if v == -1 then
			return false
		end
	end
	return true
	-- body
end

--[[
某玩家背包是否有某物品
@param handle hero
@param handle item
@return boolean
]]
function Bag:HasItem( hero,item )
	if hero == nil or item == nil then
		return false
	end
	local itemList = Bag:GetInfo(hero)
	if itemList then
		for _,v in pairs(itemList) do
			if v == item:GetEntityIndex() then
				return true
			end
		end
	end
	return false
	-- body
end



--[[
修改某栏位的物品
@param handle hero
@param int bagSlot
@param int itemIndex
]]
function Bag:ChangeItemBySlot( hero,bagSlot,itemIndex )
	local itemList = Bag:GetInfo(hero)
	if itemList then
		itemList[bagSlot] = itemIndex
		self:Update(hero,itemList)
	end
	-- body
end

--[[
交换两物品
@param handle hero
@param int bagSlot1
@param int bagSlot2
]]
function Bag:SwapItem( hero,bagSlot1,bagSlot2 )
	local itemList = Bag:GetInfo(hero)
	if itemList then
		local temp = itemList[bagSlot1]
		itemList[bagSlot1] = itemList[bagSlot2]
		itemList[bagSlot2] = temp
		Bag:Update(hero,itemList)
	end
	-- body
end

--[[
丢弃物品
@param handle hero
@param int bagSlot
@param int itemIndex
]]
function Bag:DropItem( hero,bagSlot,itemIndex )
	local itemList = Bag:GetInfo(hero)
	if itemList and itemList[bagSlot] == itemIndex then
		itemList[bagSlot] = -1
		self:Update(hero,itemList)
		local item = EntIndexToHScript(itemIndex)
		if item then
			CreateItemOnPositionSync(hero:GetAbsOrigin()+RandomVector(100), item)
			EmitSoundOnClient("Item.DropWorld", hero:GetPlayerOwner())
		end
	end
	-- body
end

--[[
出售物品
@param handle hero
@param int bagSlot
@param int itemIndex
]]
function Bag:SellItem( hero,bagSlot,itemIndex )
	local itemList = Bag:GetInfo(hero)
	if itemList and itemList[bagSlot] == itemIndex then
		local item = EntIndexToHScript(itemIndex)
		if item and item:IsSellable() then
			local price = item:GetCost() or 0
			if item.score then --装备的价格
				price = math.floor(math.pow(item.score/5, 1.1)+0.5)
				Items:DeleteItemFromNetTable(itemIndex)
			end	
			EmitSoundOnClient("General.Sell", hero:GetPlayerOwner())
			-- 增加水晶
			Skill:ChangeCrystal(hero,price)
			-- 删除物品
			itemList[bagSlot] = -1
			self:Update(hero,itemList)
			item:RemoveSelf()			
		end
	end
	-- body
end

--[[
某玩家添加物品
@param handle hero
return boolean
]]
function Bag:AddItem( hero,item )
	--print("try to add item")
	if hero == nil or item == nil then
		return false
	end
	if Bag:IsFull(hero) == true then
		print("bag is full")
		unit:DropItemAtPositionImmediate(item, hero:GetAbsOrigin())
		return false
	end
	if Bag:HasItem(hero,item) then
		print("bag has it")
		return false
	end
	ShowTips(hero:GetPlayerOwner(),"#get_item","#DOTA_Tooltip_ability_"..item:GetAbilityName(),nil)
	local itemList = Bag:GetInfo(hero)
	if item:IsStackable() then
		local sameItem,bagSlot = self:FindItemByName(hero,item:GetAbilityName())
		if sameItem and sameItem:IsStackable() then
			--print("stack item")
			sameItem:SetCurrentCharges(sameItem:GetCurrentCharges()+item:GetCurrentCharges())
			item:RemoveSelf()
			self:Update(hero,itemList)
			return true
		end
	end
	local bagIndex = Bag:GetUnusedIndex(hero)
	if bagIndex ~= -1 then
		--print("add item")		
		itemList[bagIndex] = item:GetEntityIndex()
		self:Update(hero,itemList)
		return true
	end
	return false
	-- body
end

