
dk_strike = class({})

function dk_strike:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function dk_strike:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil or caster == target then
		return
	end
	local multiple = self:GetSpecialValueFor("multiple")
	local damage = Equip:GetAttackPower(caster)*multiple
	if target:HasModifier("modifier_dk_breathe") then
		damage = damage * 1.5
	end
	caster:EmitSound("Hero_DragonKnight.DragonTail.Target")
	DoDamage(caster,target,damage,DAMAGE_TYPE_PHYSICAL,0,self)
	-- body
end