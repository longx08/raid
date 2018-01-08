LinkLuaModifier("modifier_lina_light_thinker", "abilities/lina/modifier_lina_light_thinker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lina_light", "abilities/lina/modifier_lina_light.lua", LUA_MODIFIER_MOTION_NONE)

lina_light = class({})

function lina_light:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function lina_light:GetAOERadius(  )
	return self:GetSpecialValueFor("radius")
	-- body
end

function lina_light:OnSpellStart()
	CreateModifierThinker(self:GetCaster(), self, "modifier_lina_light_thinker", {sp = Equip:GetSpellPower(self:GetCaster())}, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
	-- body
end