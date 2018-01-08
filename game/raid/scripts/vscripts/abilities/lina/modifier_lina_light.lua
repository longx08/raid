
modifier_lina_light = class({})



function modifier_lina_light:IsDebuff()
	return true
	-- body
end

function modifier_lina_light:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
	-- body
end

function modifier_lina_light:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
	-- body
end

function modifier_lina_light:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
	-- body
end

function modifier_lina_light:OnCreated(kv)
	self.dot = self:GetAbility():GetSpecialValueFor("dot")
	self.sp = kv.sp
	if IsServer() then
		self:StartIntervalThink(1)
	end
	-- body
end


function modifier_lina_light:OnIntervalThink()
	if IsServer() then		
		DoDamage(self:GetCaster(),self:GetParent(),self.sp*self.dot,DAMAGE_TYPE_MAGICAL,0,self:GetAbility())
	end
	-- body
end