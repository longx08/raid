
modifier_dk_taunt = class({})

function modifier_dk_taunt:IsPassive()
	return true
	-- body
end

function modifier_dk_taunt:IsHidden()
	return true
	-- body
end

function modifier_dk_taunt:IsPurgable( )
	return false
	-- body
end

function modifier_dk_taunt:OnCreated(kv)
	self.armor = self:GetAbility():GetSpecialValueFor("armor")
	-- body
end


function modifier_dk_taunt:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
	-- body
end

function modifier_dk_taunt:GetModifierPhysicalArmorBonus()
	return self.armor
	-- body
end
