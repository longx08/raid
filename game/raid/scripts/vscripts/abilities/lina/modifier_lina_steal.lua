
modifier_lina_steal = class({})



function modifier_lina_steal:IsDebuff()
	return true
	-- body
end

function modifier_lina_steal:GetEffectName()
	return "particles/econ/items/bounty_hunter/bounty_hunter_hunters_hoard/bounty_hunter_hoard_track_trail.vpcf"
	-- body
end

function modifier_lina_steal:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
	-- body
end

function modifier_lina_steal:OnCreated(kv)
	self.mana = kv.mana
	-- body
end

function modifier_lina_steal:DeclareFunctions(  )
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED
	}
	return funcs
	-- body
end


function modifier_lina_steal:OnAttacked(params)
	if IsServer() then		
		if params.target == self:GetParent() and params.attacker then
			local mana = self.mana
			if params.attacker == self:GetCaster() then
				mana = mana * 2
			end	
			if mana > self:GetParent():GetMana() then
				mana = 	self:GetParent():GetMana()
			end
			if mana > 0 then
				self:GetParent():ReduceMana(mana)
				params.attacker:GiveMana(mana)
			end
		end
	end
	-- body
end