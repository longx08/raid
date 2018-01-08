LinkLuaModifier("modifier_tp_recovery", "abilities/tp/modifier_tp_recovery.lua", LUA_MODIFIER_MOTION_NONE)

tp_recovery = class({})

function tp_recovery:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function tp_recovery:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil then
		return
	end

	self.duration = self:GetSpecialValueFor("duration")
	self.amount = self:GetSpecialValueFor("multiple")*Equip:GetSpellPower( caster )
	caster:EmitSound("Hero_Huskar.Inner_Vitality")
	local old_one = target:FindModifierByNameAndCaster("modifier_tp_recovery", caster)
	if old_one then
		old_one:SetDuration(self.duration, true)
		old_one.amount = self.amount
	else
		target:AddNewModifier(caster, self, "modifier_tp_recovery", {duration=self.duration,amount=self.amount})
	end
	-- body
end