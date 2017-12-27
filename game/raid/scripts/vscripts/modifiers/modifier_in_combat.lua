if modifier_in_combat == nil then
	modifier_in_combat = class({})
end

function modifier_in_combat:IsHidden()
	return true
	-- body
end

function modifier_in_combat:RemoveOnDeath(  )
	return false
	-- body
end

function modifier_in_combat:IsPurgable( )
	return false
	-- body
end

function modifier_in_combat:OnCreated(event)
	self.parent = self:GetParent()
	self.playerID = self.parent:GetPlayerOwnerID()
	-- body
end

function modifier_in_combat:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_HEAL_RECEIVED
	}
	return funcs
	-- body
end

function modifier_in_combat:OnTakeDamage(event)
	if event.attacker == nil or event.attacker:IsNull() or event.attacker:IsAlive()==false then
		return
	end
	if event.attacker:GetTeam() == event.unit:GetTeam() then --队友伤害
		return
	end
	Combat:DealDamage(event.attacker,event.unit,event.damage,self.parent==event.attacker)
	-- body
end

function modifier_in_combat:OnHealReceived(event)
	if bINCOMBAT and event.inflictor and event.inflictor:GetTeam() == self.parent:GetTeam() then
		Combat:DealHeal(event.inflictor:GetPlayerOwnerID(),event.gain)
	end
	-- body
end