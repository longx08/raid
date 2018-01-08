LinkLuaModifier("modifier_lina_ghost", "abilities/lina/modifier_lina_ghost.lua", LUA_MODIFIER_MOTION_NONE)

lina_ghost = class({})

function lina_ghost:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end



function lina_ghost:OnSpellStart()
	local caster = self:GetCaster()
	if caster == nil then
		return
	end
	caster:EmitSound("Hero_Pugna.Decrepify")
	self.duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_lina_ghost", {duration = self.duration})
	-- body
end