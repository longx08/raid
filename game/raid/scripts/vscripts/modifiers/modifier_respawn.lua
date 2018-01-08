modifier_respawn = class({})

function modifier_respawn:IsHidden()
	return false
	-- body
end

function modifier_respawn:IsPurgable(  )
	return false
	-- body
end

function modifier_respawn:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
	-- body
end

function modifier_respawn:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
	-- body
end

function modifier_respawn:CheckState(  )
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true
	}
	return state
	-- body
end
