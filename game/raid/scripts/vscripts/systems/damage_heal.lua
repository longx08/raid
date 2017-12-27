
function DoDamage( attacker,victim,damage,damage_type,damage_flags,ablity )
	local crit = Equip:GetSpellCrit( attacker )  --法术暴击
	local cdamage = Equip:GetSpellCritDamage(attacker) --暴击伤害
	if crit and cdamage and math.random(0,100) < crit then
		damage = damage * cdamage/100
	end
	print("damage:"..damage)
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
	target:Heal(amount, caster)
	-- body
end