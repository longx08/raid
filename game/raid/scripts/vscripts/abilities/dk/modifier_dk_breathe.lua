
modifier_dk_breathe = class({})


function modifier_dk_breathe:IsDebuff()
	return true
	-- body
end

function modifier_dk_breathe:IsPurgable( )
	return true
	-- body
end

function modifier_dk_breathe:OnCreated(kv)
	self.decrease = self:GetAbility():GetSpecialValueFor("decrease")
	-- body
end


function modifier_dk_breathe:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
	-- body
end

function modifier_dk_breathe:GetModifierDamageOutgoing_Percentage(  )
	return self.decrease
	-- body
end