
modifier_dk_taunt_debuff = class({})


function modifier_dk_taunt_debuff:IsPurgable( )
	return false
	-- body
end

function modifier_dk_taunt_debuff:IsDebuff()
	return true
	-- body
end


function modifier_dk_taunt_debuff:CheckState( )
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}
	return state
	-- body
end