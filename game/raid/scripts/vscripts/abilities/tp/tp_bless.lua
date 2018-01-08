LinkLuaModifier("modifier_tp_bless", "abilities/tp/modifier_tp_bless.lua", LUA_MODIFIER_MOTION_NONE)

tp_bless = class({})

function tp_bless:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function tp_bless:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil then
		return
	end

	self.duration = self:GetSpecialValueFor("duration")
	caster:EmitSound("Hero_Omniknight.Repel")
	target:Purge(false, true, false, true, true)
	target:AddNewModifier(caster, self, "modifier_tp_bless", {duration = self.duration})
	-- body
end