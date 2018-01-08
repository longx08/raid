--LinkLuaModifier("modifier_tp_revive", "abilities/dk/modifier_tp_revive.lua", LUA_MODIFIER_MOTION_NONE)

tp_revive = class({})

function tp_revive:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function tp_revive:OnSpellStart()
	self.caster = self:GetCaster()
	self.heal = self:GetSpecialValueFor("heal")
	DoHeal(self.caster,self.caster,self.heal*self.caster:GetMaxHealth()/100)
	self.caster:GiveMana(self.heal*self.caster:GetMaxMana()/100)
	self.caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
	
	if GameRules.HERO_TABLE == nil then
		return
	end
	local DEAD_HEROS = {}
	local hero = nil
	for _,v in pairs(GameRules.HERO_TABLE) do
		if v and v:IsAlive() == false then
			table.insert(DEAD_HEROS, v)
			if v:HasModifier("modifier_tank") then
				hero = v
			end
		end
	end
	if #DEAD_HEROS > 0 then
		if hero == nil then
			hero = PickRandomData(DEAD_HEROS)
		end
		if hero then
			hero:RespawnHero(false, false)
			hero:SetAbsOrigin(self.caster:GetAbsOrigin() + RandomVector(100))
		end
	end
	-- body
end

