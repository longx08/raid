
modifier_tp_recovery = class({})


function modifier_tp_recovery:IsPurgable( )
	return true
	-- body
end

function modifier_tp_recovery:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
	-- body
end

function modifier_tp_recovery:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_inner_vitality.vpcf"
	-- body
end

function modifier_tp_recovery:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
	-- body
end

function modifier_tp_recovery:OnCreated(kv)
	if IsServer() then
		self.amount = kv.amount 
		self:StartIntervalThink(1.0)
	end
	-- body
end


function modifier_tp_recovery:OnIntervalThink()
	if IsServer() then
		DoHeal(self:GetCaster(),self:GetParent(),self.amount)
	end
	-- body
end