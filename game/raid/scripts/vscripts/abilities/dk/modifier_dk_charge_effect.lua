
modifier_dk_charge_effect = class({})

function modifier_dk_charge_effect:IsHidden()
	return false
	-- body
end

function modifier_dk_charge_effect:IsStunDebuff()
	return true
	-- body
end

function modifier_dk_charge_effect:IsPurgable( )
	return true
	-- body
end

function modifier_dk_charge_effect:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_dk_charge_effect:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_dk_charge_effect:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
	-- body
end
