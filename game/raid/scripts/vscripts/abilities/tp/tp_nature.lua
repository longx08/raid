--LinkLuaModifier("modifier_tp_nature", "abilities/dk/modifier_tp_nature.lua", LUA_MODIFIER_MOTION_NONE)

tp_nature = class({})

function tp_nature:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost(self,iLevel) * (1+self:GetCaster():GetMaxMana()/2000)
	-- body
end

function tp_nature:OnSpellStart()
	self.Time = 0
	self.caster = self:GetCaster()
	self.radius = self:GetSpecialValueFor("radius")
	self.amount = self:GetSpecialValueFor("multiple") * Equip:GetSpellPower(self.caster)
	self.caster:EmitSound("Hero_Oracle.FatesEdict")
	-- body
end

function tp_nature:OnChannelThink(flInterval)
	if IsServer() then
		self.Time = self.Time + flInterval
		if self.Time >= 1.0 then
			local ally = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
			if #ally then
				for _,v in pairs(ally) do
					if v and v:IsAlive() then
						DoHeal(self.caster,v,self.amount)
					end
				end
			end
			self.Time = self.Time - 1
		end
	end
	-- body
end