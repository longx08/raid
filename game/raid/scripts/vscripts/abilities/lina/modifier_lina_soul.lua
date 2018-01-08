
modifier_lina_soul = class({})



function modifier_lina_soul:IsHidden()
	return (self:GetStackCount() == 0)
	-- body
end

function modifier_lina_soul:DestroyOnExpire()
	return false
	-- body
end


function modifier_lina_soul:OnCreated(kv)
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.max = self:GetAbility():GetSpecialValueFor("max")
	self.speed = self:GetAbility():GetSpecialValueFor("speed")
	self.sp = self:GetAbility():GetSpecialValueFor("sp")
	if IsServer() then
		self.nFXIndex =  ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self:GetStackCount(), 0, 0 ) )
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
	end
	-- body
end

function modifier_lina_soul:OnRefresh(kv)
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.max = self:GetAbility():GetSpecialValueFor("max")
	self.speed = self:GetAbility():GetSpecialValueFor("speed")
	self.sp = self:GetAbility():GetSpecialValueFor("sp")
	if IsServer() then
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self:GetStackCount(), 0, 0 ) )
	end
	-- body
end

function modifier_lina_soul:DeclareFunctions(  )
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return funcs
	-- body
end


function modifier_lina_soul:OnIntervalThink()
	if IsServer() then		
		self:StartIntervalThink(-1)
		self:SetStackCount(0)
	end
	-- body
end

function modifier_lina_soul:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetStackCount() * self.speed
	-- body
end

function modifier_lina_soul:GetModifierSpellPowerBonus_Percentage(  )
	return self:GetStackCount() * self.sp
	-- body
end

function modifier_lina_soul:OnAbilityExecuted( params )
	if IsServer() then
		if params.unit == self:GetParent() then
			local hAbility = params.ability
			if hAbility ~= nil and hAbility ~= self and (not hAbility:IsItem()) and (not hAbility:IsToggle()) then
				if self:GetStackCount() < self.max then
					self:IncrementStackCount()
				else
					self:SetStackCount(self:GetStackCount())
					self:ForceRefresh()
				end
				self:SetDuration(self.duration, true)
				self:StartIntervalThink(self.duration)
			end
		end
	end
	return 0
	-- body
end