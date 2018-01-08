--LinkLuaModifier("modifier_tp_treatment", "abilities/dk/modifier_tp_treatment.lua", LUA_MODIFIER_MOTION_NONE)

tp_treatment = class({})

function tp_treatment:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function tp_treatment:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil or bInterrupted == true then
		return
	end

	local amount = self:GetSpecialValueFor("multiple")*Equip:GetSpellPower( caster )
	caster:EmitSound("Hero_Medusa.ManaShield.On")
	if target:GetTeam() == caster:GetTeam() then
		DoHeal(caster,target,amount)
	else
		DoDamage(caster,target,amount,DAMAGE_TYPE_MAGICAL,0,self)
	end
	-- body
end