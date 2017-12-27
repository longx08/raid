LinkLuaModifier("modifier_dk_charge", "abilities/dk/modifier_dk_charge.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_dk_charge_effect", "abilities/dk/modifier_dk_charge_effect.lua", LUA_MODIFIER_MOTION_NONE)
dk_charge = class({})

function dk_charge:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function dk_charge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil or caster == target then
		return
	end
	caster:AddNewModifier(caster, self, "modifier_dk_charge", {})
	-- body
end