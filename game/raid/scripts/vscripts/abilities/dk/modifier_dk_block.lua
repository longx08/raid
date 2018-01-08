
modifier_dk_block = class({})


function modifier_dk_block:IsPurgable( )
	return false
	-- body
end

function modifier_dk_block:OnCreated(kv)
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	self.block = kv.block 
	-- body
end


function modifier_dk_block:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
	-- body
end

function modifier_dk_block:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
	-- body
end

function modifier_dk_block:GetModifierBlockBonus( )
	return self.block
	-- body
end

function modifier_dk_block:CheckState( )
	local state = {
		[MODIFIER_STATE_DISARMED] =true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_FROZEN] = true
	}
	return state
	-- body
end