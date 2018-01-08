
modifier_tp_bless = class({})


function modifier_tp_bless:IsPurgable( )
	return false
	-- body
end

function modifier_tp_bless:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
	-- body
end

function modifier_tp_bless:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
	-- body
end

function modifier_tp_bless:OnCreated(table)
	self.resis = self:GetAbility():GetSpecialValueFor("resis")
	-- body
end

function modifier_tp_bless:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
	-- body
end

function modifier_tp_bless:GetModifierMagicalResistanceBonus()
	return self.resis
	-- body
end