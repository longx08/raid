LinkLuaModifier("modifier_dk_taunt", "abilities/dk/modifier_dk_taunt.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dk_taunt_debuff", "abilities/dk/modifier_dk_taunt_debuff.lua", LUA_MODIFIER_MOTION_NONE)

dk_taunt = class({})

function dk_taunt:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function dk_taunt:GetIntrinsicModifierName()
	return "modifier_dk_taunt"
	-- body
end

function dk_taunt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster == nil or target == nil then
		return
	end
	self.duration = self:GetSpecialValueFor("duration")
	caster:EmitSound("Hero_Axe.BerserkersCall.Item.Shoutmask")
	target:SetAggroTarget(caster)
	target:AddNewModifier(caster, self, "modifier_dk_taunt_debuff", {duration = self.duration})
	if target.aggro_table then
		local entIndex,maxAggro = TableMaxValue( target.aggro_table )
		if caster:GetEntityIndex() ~= entIndex and maxAggro ~= nil then
			target.aggro_table[caster:GetEntityIndex()] = maxAggro * 1.3
		end
	end
	-- body
end