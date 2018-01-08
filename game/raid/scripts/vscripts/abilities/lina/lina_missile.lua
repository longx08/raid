--LinkLuaModifier("modifier_lina_missile", "abilities/lina/modifier_lina_missile.lua", LUA_MODIFIER_MOTION_NONE)

lina_missile = class({})

function lina_missile:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function lina_missile:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil or bInterrupted == true then
		return
	end

	local info = {
		EffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
		Ability = self,
		iMoveSpeed = self:GetSpecialValueFor("speed"),
		Source = caster,
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
	}
	ProjectileManager:CreateTrackingProjectile(info)
	caster:EmitSound("Hero_VengefulSpirit.MagicMissile")

	-- body
end

function lina_missile:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and (not hTarget:IsInvulnerable()) and (not hTarget:IsMagicImmune()) then
		hTarget:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		local multiple = self:GetSpecialValueFor("multiple")
		local damage = multiple * Equip:GetSpellPower(self:GetCaster())
		DoDamage(self:GetCaster(),hTarget,damage,DAMAGE_TYPE_MAGICAL,0,self)
	end
	return true
	-- body
end