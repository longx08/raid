LinkLuaModifier("modifier_lina_steal", "abilities/lina/modifier_lina_steal.lua", LUA_MODIFIER_MOTION_NONE)

lina_steal = class({})

function lina_steal:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function lina_steal:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil then
		return
	end
	caster:EmitSound("Hero_BountyHunter.Target")
	self.duration = self:GetSpecialValueFor("duration")
	self.mana = self:GetSpecialValueFor("multiple") * Equip:GetSpellPower(caster)
	target:AddNewModifier(caster, self, "modifier_lina_steal", {duration = self.duration,mana = self.mana})
	-- body
end