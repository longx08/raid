LinkLuaModifier("modifier_dk_block", "abilities/dk/modifier_dk_block.lua", LUA_MODIFIER_MOTION_NONE)

dk_block = class({})

function dk_block:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function dk_block:OnSpellStart()
	local caster = self:GetCaster()
	if caster == nil then
		return
	end
	self.duration = self:GetSpecialValueFor("duration")
	self.block = self:GetSpecialValueFor("multiple")*Equip:GetAttackPower( caster )
	caster:EmitSound("Hero_Medusa.ManaShield.On")
	caster:AddNewModifier(caster, self, "modifier_dk_block", {duration = self.duration,block=self.block})
	-- body
end