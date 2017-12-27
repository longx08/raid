modifier_equip_stat = class({})

function modifier_equip_stat:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_PERMANENT
	-- body
end

function modifier_equip_stat:IsHidden()
	return true
	-- body
end

function modifier_equip_stat:IsPurgable( )
	return false
	-- body
end

function modifier_equip_stat:RemoveOnDeath( )
	return false
	-- body
end

function modifier_equip_stat:OnCreated( kv )
	local hero = self:GetParent()
	if hero == nil then
		return
	end
	if IsServer() then		
		self.equip_stat = hero.equip_stat or {}
	else
		self.equip_stat = CustomNetTables:GetTableValue("Equip", "equip_stat_"..hero:GetEntityIndex())
	end
	-- body
end

function modifier_equip_stat:OnRefresh( kv )
	local hero = self:GetParent()
	if hero == nil then
		return
	end
	if IsServer() then		
		self.equip_stat = hero.equip_stat or {}
	else
		self.equip_stat = CustomNetTables:GetTableValue("Equip", "equip_stat_"..hero:GetEntityIndex())
	end
	-- body
end


function modifier_equip_stat:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
	return funcs
	-- body
end

function modifier_equip_stat:GetModifierBonusStats_Strength()
	if self.equip_stat then
		return self.equip_stat["str"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierBonusStats_Agility()
	if self.equip_stat then
		return self.equip_stat["agi"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierBonusStats_Intellect()
	if self.equip_stat then
		return self.equip_stat["int"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierHealthBonus()
	if self.equip_stat then
		return self.equip_stat["health"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierManaBonus()
	if self.equip_stat then
		return self.equip_stat["mana"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierConstantManaRegen()
	if self.equip_stat then
		return (self.equip_stat["mren"] or 0)/10
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierPreAttack_BonusDamage()
	if self.equip_stat then
		return self.equip_stat["attack"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierAttackSpeedBonus_Constant()
	if self.equip_stat then
		return self.equip_stat["aspeed"] or 0
	else
		return 0
	end
	-- body
end


function modifier_equip_stat:GetModifierPhysicalArmorBonus()
	if self.equip_stat then
		return self.equip_stat["armor"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierMagicalResistanceBonus()
	if self.equip_stat then
		return (self.equip_stat["resis"] or 0)/10
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierEvasion_Constant()
	if self.equip_stat then
		return (self.equip_stat["evade"] or 0)/10
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierMoveSpeedBonus_Constant()
	if self.equip_stat then
		return self.equip_stat["move"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierPercentageManacostStacking()
	if self.equip_stat then
		return 0 - (self.equip_stat["cost"] or 0)
	else
		return 0
	end
	-- body
end
----------------------------------------------------------------
-- 自定义属性
----------------------------------------------------------------

function modifier_equip_stat:GetModifierAttackPowerBonus(  )
	if self.equip_stat then
		return self.equip_stat["ap"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierSpellPowerBonus(  )
	if self.equip_stat then
		return self.equip_stat["sp"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierSpellCritBonus(  )
	if self.equip_stat then
		return (self.equip_stat["crit"] or 0)/10
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierSpellCritDamageBonus(  )
	if self.equip_stat then
		return self.equip_stat["cdamage"] or 0
	else
		return 0
	end
	-- body
end

function modifier_equip_stat:GetModifierBlockBonus(  )
	if self.equip_stat then
		return self.equip_stat["block"] or 0
	else
		return 0
	end
	-- body
end