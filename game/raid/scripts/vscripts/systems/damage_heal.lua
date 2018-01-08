
function DoDamage( attacker,victim,damage,damage_type,damage_flags,ablity )
	if attacker == nil or victim == nil then
		return
	end
	local crit = Equip:GetSpellCrit(attacker)
	local cdamage = Equip:GetSpellCritDamage(attacker)
	if crit and cdamage and math.random(0,100) < crit then
		damage = damage * cdamage/100
		PopupCriticalDamage(victim, math.floor(damage))
	end
	--print("damage:"..damage)
	local damageTable = {
		victim = victim,
		attacker = attacker,
		damage = damage,
		damage_type = damage_type,
		damage_flags = damage_flags,
		ablity = ablity
	}
	ApplyDamage(damageTable)
	-- body
end

function DoHeal( caster,target,amount )
	if caster == nil or target == nil then
		return
	end
	local crit = Equip:GetSpellCrit(caster)
	local cdamage = Equip:GetSpellCritDamage(caster)
	if crit and cdamage and math.random(0,100) < crit then
		amount = amount * cdamage/100
		PopupCriticalHealing(target,math.floor(amount))
	else
		PopupHealing(target,math.floor(amount) )
	end
	target:Heal(amount, caster)
	
	-- body
end