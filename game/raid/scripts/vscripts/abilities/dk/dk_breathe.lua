LinkLuaModifier("modifier_dk_breathe", "abilities/dk/modifier_dk_breathe", LUA_MODIFIER_MOTION_NONE)
dk_breathe = class({})

function dk_breathe:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function dk_breathe:OnSpellStart()
	self.caster = self:GetCaster()
	self.point = self:GetCursorPosition()
	if self.caster == nil then
		return
	end
	self.duration = self:GetSpecialValueFor("duration")
	self.multiple = self:GetSpecialValueFor("multiple")
	self.ap = Equip:GetAttackPower(self.caster)

	local direction = self.point - self.caster:GetAbsOrigin()
	direction.z = 0.0
	direction = direction:Normalized()
	local info = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
		vSpawnOrigin = self.caster:GetAbsOrigin(),
		fDistance = 600,
		fStartRadius = 200,
		fEndRadius = 500,
		Source = self.caster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit = false,
		vVelocity = direction*1000,
		bProvidesVision = true,
		iVisionRadius = 300
	}
	ProjectileManager:CreateLinearProjectile(info)
	self.caster:EmitSound("Hero_DragonKnight.BreathFire")
	-- body
end

function dk_breathe:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		hTarget:AddNewModifier(self.caster, self, "modifier_dk_breathe", {duration=self.duration})
		DoDamage(self.caster,hTarget,self.ap*self.multiple,DAMAGE_TYPE_MAGICAL,0,self)
	end	
	return false
	-- body
end