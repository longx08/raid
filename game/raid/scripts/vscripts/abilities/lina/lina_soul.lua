LinkLuaModifier("modifier_lina_soul", "abilities/lina/modifier_lina_soul.lua", LUA_MODIFIER_MOTION_NONE)

lina_soul = class({})

function lina_soul:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function lina_soul:GetIntrinsicModifierName()
	return "modifier_lina_soul"
	-- body
end


function lina_soul:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil then
		return
	end
	local mod = caster:FindModifierByName("modifier_lina_soul")
	if mod then
		local count = mod:GetStackCount()
		if count > 0 then
			local damage = count * count * self:GetSpecialValueFor("multiple") * Equip:GetSpellPower(caster)
			DoDamage(caster,target,damage,DAMAGE_TYPE_MAGICAL,0,self)
			mod:SetStackCount(0)

			EmitSoundOn( "Ability.LagunaBladeImpact", target )
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, nil );
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin() + Vector( 0, 0, 96 ), true );
			ParticleManager:SetParticleControlEnt( nFXIndex, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true );
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
	-- body
end