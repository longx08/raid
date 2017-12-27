if modifier_dk_charge_effect == nil then
	modifier_dk_charge_effect = class({})
end

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


function modifier_dk_charge_effect:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
	-- body
end
