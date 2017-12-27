modifier_tank = class({})

function modifier_tank:IsHidden()
	return false
	-- body
end

function modifier_tank:IsPurgable(  )
	return false
	-- body
end

function modifier_tank:IsPermanent()
	return true
	-- body
end

function modifier_tank:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
	-- body
end

function modifier_tank:GetModifierExtraHealthPercentage()
	return 0.3
	-- body
end

function modifier_tank:GetModifierPhysicalArmorBonus()
	return 10
	-- body
end

function modifier_tank:GetModifierEvasion_Constant()
	return 20
	-- body
end

function modifier_tank:GetModifierTotalDamageOutgoing_Percentage()
	return -50
	-- body
end

function modifier_tank:GetModifierBlockBonus_Percentage()
	return 50
	-- body
end

