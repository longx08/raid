
modifier_lina_light_thinker = class({})



function modifier_lina_light_thinker:IsHidden()
	return true
	-- body
end


function modifier_lina_light_thinker:OnCreated(kv)
	self.delay = self:GetAbility():GetSpecialValueFor("delay")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.multiple = self:GetAbility():GetSpecialValueFor("multiple")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.sp = kv.sp
	if IsServer() then
		self:StartIntervalThink(self.delay)
		EmitSoundOnLocationForAllies(self:GetParent():GetOrigin(), "Ability.PreLightStrikeArray", self:GetCaster())
		local nFXIndex = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, 1 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
	-- body
end


function modifier_lina_light_thinker:OnIntervalThink()
	if IsServer() then
		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					DoDamage(self:GetCaster(),enemy,self.sp*self.multiple,DAMAGE_TYPE_MAGICAL,0,self:GetAbility())
					local mod = enemy:FindModifierByNameAndCaster("modifier_lina_light", self:GetCaster())
					if mod then
						mod:SetDuration(self.duration)
						mod.sp = self.sp
					else
						enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_lina_light", { duration = self.duration,sp=self.sp } )
					end
				end
			end
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, 1, 1 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Ability.LightStrikeArray", self:GetCaster() )

		UTIL_Remove( self:GetParent() )

	end
	-- body
end