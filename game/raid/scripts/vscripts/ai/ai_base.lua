-- 单位出生时调用此函数，出生的单位为thisEntity
function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end
	if thisEntity == nil then
		return
	end
	lagunaAbility = thisEntity:FindAbilityByName("lina_laguna_blade")

	thisEntity:SetContextThink("BaseThink", BaseThink, 1)
	-- body
end

function BaseThink(  )
	if not IsServer() then
		return
	end
	if GameRules:IsGamePaused() == true then
		return 1
	end
	local target = thisEntity:GetAggroTarget()
	--当前目标为空
	if target == nil or target:IsNull() then
		return 1
	end
	if thisEntity.aggro_table then
		local index,max = TableMaxValue( thisEntity.aggro_table )
		if index and max then
			local unit = EntIndexToHScript(index)
			-- 如果最大仇恨目标不是当前目标
			if unit and (not unit:IsNull()) and unit ~= target and unit:IsAlive() then
				local aggro = thisEntity.aggro_table[target:GetEntityIndex()] or 0
				--当前目标死亡或者仇恨不够，则转移攻击对象
				if (not target:IsAlive()) or max >= aggro * 1.2 then
					thisEntity:SetAggroTarget(unit)
					return AttackTarget(unit)
				end 
			end
		end
	end
	if lagunaAbility ~= nil and lagunaAbility:IsFullyCastable() and target ~= nil then
		return LaunchLaguna(target)
	end
	return 1
	-- body
end

function AttackTarget( enemy )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = enemy:entindex(),
		Queue = false,
	})
	return 1
	-- body
end

function LaunchLaguna( enemy )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = enemy:entindex(),
		AbilityIndex = lagunaAbility:entindex(),
		Queue = false,
	})
	return 1
	-- body
end