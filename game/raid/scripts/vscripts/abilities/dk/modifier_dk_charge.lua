modifier_dk_charge = class({})

function modifier_dk_charge:IsStunDebuff()
	return true
	-- body
end

function modifier_dk_charge:IsHidden()
	return false
	-- body
end

function modifier_dk_charge:IsPurgable(  )
	return false
	-- body
end

function modifier_dk_charge:OnCreated( kv )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
			self:Destroy()
			return
		end
		self.target = self:GetAbility():GetCursorTarget()
		self.speed = self:GetAbility():GetSpecialValueFor("speed")
		self.multiple = self:GetAbility():GetSpecialValueFor("multiple")
	end
	-- body
end

function modifier_dk_charge:OnDestroy(  )
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController(self)
		self:GetParent():RemoveVerticalMotionController(self)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetOrigin(), true)
	end
	-- body
end

function modifier_dk_charge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
	-- body
end

function modifier_dk_charge:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
	-- body
end

function modifier_dk_charge:GetOverrideAnimation()
	return ACT_DOTA_ATTACK
	-- body
end

function modifier_dk_charge:UpdateHorizontalMotion(me,dt)
	if IsServer() then
		if self.target == nil or self.target:IsNull() or self.target:IsAlive() == false then
			self:Destroy()
			return
		end
		local oldPosition = me:GetOrigin()
		local direction = (self.target:GetOrigin() - oldPosition):Normalized()
		local distance = (self.target:GetOrigin() - oldPosition):Length2D()
		local newPosition = oldPosition + direction*self.speed*dt
		newPosition.z = 0
		me:SetOrigin(newPosition)
		if distance <= 150 then
			--print("end")
			if self.target:GetTeam() ~= self:GetParent():GetTeam() then
				self.target:AddNewModifier(self:GetParent(), self:GetAbility(),"modifier_dk_charge_effect", {duration = 2})
				DoDamage(self:GetParent(),self.target,Equip:GetAttackPower(self:GetParent())*self.multiple,DAMAGE_TYPE_PURE,0,self:GetAbility())
			end
			self:GetParent():RemoveHorizontalMotionController(self)
			self:GetParent():RemoveVerticalMotionController(self)
			self:SetDuration(0.15,true)
		end
	end
	-- body
end

function modifier_dk_charge:UpdateVerticalMotion(me,dt)
	if IsServer() then
		if self.target == nil or self.target:IsNull() or self.target:IsAlive() == false then
			self:Destroy()
			return
		end
		local oldPosition = me:GetOrigin()
		local targetPosition = self.target:GetOrigin()
		local move = targetPosition - oldPosition
		local up = move.z/(move:Length()) *self.speed
		oldPosition.z = oldPosition.z + up
		local flGroundHeight = GetGroundHeight(oldPosition, self:GetParent())
		if oldPosition.z <flGroundHeight then
			oldPosition.z = flGroundHeight
		end
		me:SetOrigin(oldPosition)
	end
	-- body
end