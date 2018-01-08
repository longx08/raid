
modifier_lina_ghost = class({})



function modifier_lina_ghost:OnCreated(kv)
	self.incoming = self:GetAbility():GetSpecialValueFor("incoming")
	-- body
end

function modifier_lina_ghost:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
	-- body
end

function modifier_lina_ghost:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
	-- body
end


function modifier_lina_ghost:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
	-- body
end

function modifier_lina_ghost:GetModifierIncomingDamage_Percentage()
	return self.incoming
	-- body
end

function modifier_lina_ghost:CheckState(  )
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true
	}
	return state
	-- body
end