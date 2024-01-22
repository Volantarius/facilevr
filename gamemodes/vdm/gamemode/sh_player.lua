AddCSLuaFile()

-- Used to calculate the current source engine armor scale, and new ones
local function CalcArmorRatio( damage, armor, ratio, bonus )
	ratio = ratio || 0.2
	bonus = bonus || 1.0
	
	local newDamage = damage
	local armorDamage = 0
	
	if ( armor > 0 ) then
		newDamage = damage * ratio
		
		local newArmor = (damage - newDamage) * bonus
		
		if ( newArmor < 1.0 ) then
			newArmor = 1.0
		end
		
		if ( newArmor > armor ) then
			newArmor = armor * (1 / bonus)
			newDamage = damage - newArmor
			
			armorDamage = armor
		else
			armorDamage = newArmor
		end
		
		return newDamage, armorDamage
	else
		return damage, armorDamage
	end
end

-- MAKE SURE THIS DOES TAKE AND SEND FLOATS!!!!!!!!!!!!!
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	-- (2021) Really should only scale bullet damage
	local bulletDmg = dmginfo:IsBulletDamage()
	
	-- TODO: May have to adjust for armor.... crap really need a buildt in thing for that
	
	-- VCSS weapons should send the ArmorRatio through this
	local bonus = dmginfo:GetDamageBonus()
	
	if ( bonus <= 0 ) then
		bonus = 1.7
	end
	
	-- Halved in CS:S I think lol
	local ArmorRatio = bonus / 2.02
	
	local armorValue = ply:Armor()
	local damage = dmginfo:GetDamage()
	local armorTaken = 0
	
	local allowArmor = armorValue > 0 and hitgroup ~= HITGROUP_LEFTLEG and hitgroup ~= HITGROUP_RIGHTLEG
	
	-- Only calc armor ratios if theres armor lol
	-- Legs do not have armor!
	if ( bulletDmg and allowArmor ) then
		local nDam, arTaken = CalcArmorRatio( damage, armorValue, ArmorRatio, 1.06 )
		
		armorTaken = arTaken / 2 -- CS:S halves the return armor value
		damage = nDam
	end
	
	-- Damage is scaled after armor calculation
	-- Armor taken has to be scaled too!
	if (bulletDmg) then
		local scaleD = 1
		local scaleA = 1
		
		-- Need to make helmet check too lol
		if ( hitgroup == HITGROUP_HEAD ) then
			scaleD = 4
			scaleA = 4
		end
		
		if ( hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG ) then
			scaleD = 0.75
			scaleA = 0.00
		end
		
		if ( hitgroup == HITGROUP_STOMACH ) then
			scaleD = 1.25
			scaleA = 1.25
		end
		
		-- Scale it!
		armorTaken = armorTaken * scaleA
		damage = damage * scaleD
	end
	
	-- Because we know the armor ratio, we can reverse what is internally used in the engine
	-- So we scale all the damage to get what we what on the other end. Basically an exploit
	local fuckDamage = damage
	
	-- (2021) changed from allowArmor, because I think any part can be scaled with armor, we don't want any scaling if we dont want it
	if ( armorValue > 0 ) then
		local wishedDamage = damage
		fuckDamage = wishedDamage * 5 -- 5 so we can multiply by 0.2 to get the same number
		
		-- If greater than armor, the engine will fuck with it, lets lower the damage even more
		if ( (fuckDamage - wishedDamage) > armorValue ) then
			fuckDamage = fuckDamage - (fuckDamage - wishedDamage - armorValue)
		end
	end
	
	dmginfo:SetDamage( fuckDamage )
	
	ply.vvArmorValue = armorValue - armorTaken-- Hack to throw at PostEntityTakeDamage, in init.lua
end