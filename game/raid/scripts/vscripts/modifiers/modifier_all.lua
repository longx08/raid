modifier_all = class({})

function modifier_all:IsHidden()
	return false
	-- body
end

function modifier_all:IsPurgable(  )
	return false
	-- body
end

function modifier_all:IsPermanent()
	return true
	-- body
end

function modifier_all:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
	return funcs
	-- body
end

function modifier_all:GetModifierExtraHealthPercentage()
	return 0.5
	-- body
end

function modifier_all:GetModifierPhysicalArmorBonus()
	return 15
	-- body
end

function modifier_all:GetModifierEvasion_Constant()
	return 20
	-- body
end

function modifier_all:GetModifierHealthRegenPercentage()
	return 10
	-- body
end


