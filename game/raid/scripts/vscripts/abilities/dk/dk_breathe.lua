
dk_breathe = class({})

function dk_breathe:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function dk_breathe:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil or caster == target then
		return
	end
	local multiple = self:GetSpecialValueFor("multiple")
	DoDamage(caster,target,Equip:GetAttackPower(caster)*multiple,DAMAGE_TYPE_PHYSICAL,0,self)
	-- body
end