local function volantariusExplode( ply )
	local bones = {
		"ValveBiped.Bip01_Spine",
		"ValveBiped.Bip01_Spine1",
		"ValveBiped.Bip01_Spine2",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_R_UpperArm",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Hand",
		"ValveBiped.Bip01_L_UpperArm",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Hand",
		"ValveBiped.Bip01_R_Thigh",
		"ValveBiped.Bip01_R_Calf",
		"ValveBiped.Bip01_R_Foot",
		"ValveBiped.Bip01_L_Thigh",
		"ValveBiped.Bip01_L_Calf",
		"ValveBiped.Bip01_L_Foot"
	}
	
	sound.Play( "Vdm_Gore.Explode", ply:GetPos() )
	
	for k,bonename in ipairs(bones) do
		local boneid = ply:LookupBone(bonename)
		
		if ( boneid ) then
			local bonepos, boneang = ply:GetBonePosition(boneid)
			
			if ( bonepos == Vector(0,0,0) || bonepos == nil ) then continue end
			
			local dildo = ents.Create("vdm_gib_dildo")
			
			dildo:SetPos(bonepos)
			dildo:SetAngles(boneang)
			
			dildo:Spawn()
		end
	end
end

local volanteDeathSound = Sound( "VdmCharacter_Taki.Death" )

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	ply:AddDeaths( 1 )
	
	ply:StopParticles()
	
	--[[local inf_test = dmginfo:GetInflictor()
	
	print( ply, attacker, dmginfo:GetDamageType() )
	
	if ( inf_test ) then
		local c_min, c_max = inf_test:GetCollisionBounds()
		debugoverlay.Box( inf_test:GetPos(), c_min, c_max, 6, Color(255, 0, 0, 128) )
	end]]
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
		if ( attacker == ply ) then
			if ( GAMEMODE.TakeFragOnSuicide ) then
				attacker:AddFrags( -1 )
			end
		else
			attacker:AddFrags( 1 )
		end
	end
	
	--if ( GAMEMODE.EnableFreezeCam && IsValid( attacker ) && attacker:IsPlayer() && attacker != ply ) then
	--	ply:SpectateEntity( attacker )
	--	ply:Spectate( OBS_MODE_FREEZECAM )
	--end
	
	--
	-- Now we handle ragdolling and stuff
	--
	
	local dudeRemove = false
	
	--:P
	--[[if ( ply:AccountID() == 29019948 ) then
		volantariusExplode(ply)
		dudeRemove = true
	end]]
	
	local pPos = ply:GetPos()
	
	if ( dmginfo:IsFallDamage() and dmginfo:GetDamage() > 150 ) then
		local effectdata = EffectData()
		effectdata:SetOrigin( pPos )
		effectdata:SetEntity( ply )
		effectdata:SetNormal( Vector(0,0,1) )
		effectdata:SetAngles( Angle(90,0,0) )
		util.Effect( "eff_vdm_bloodyexplode", effectdata, true, true )
		return
	end
	
	local dCustom = dmginfo:GetDamageCustom()
	local direction = dmginfo:GetDamageForce()
	
	local allowCrush = dmginfo:IsDamageType(DMG_CRUSH) && ( direction:LengthSqr() > 576000000 )
	
	-- InstaGIB
	if ( bit.band(dCustom, 4) ~= 0 || allowCrush ) then
		direction:Normalize()
		
		local effectdata = EffectData()
		effectdata:SetOrigin( pPos )
		effectdata:SetEntity( ply )
		effectdata:SetNormal( direction )
		effectdata:SetAngles( (ply:GetVelocity()):Angle() )
		util.Effect( "eff_vdm_bloodyexplode", effectdata, true, true )
		return
	end
	
	-- Pixelate!
	if ( bit.band(dCustom, 256) ~= 0 ) then
		local ed = EffectData()
		ed:SetOrigin( pPos )
		ed:SetEntity( ply )
		util.Effect("eff_vdm_pixelate", ed, true, true)
		return
	end
	
	-- We need a way of handling classes, or different specific player's sounds
	--if ( game.SinglePlayer() or ply:AccountID() == 29019948 ) then
		--ply:EmitSound( volanteDeathSound )
		
	--	sound.Play( volanteDeathSound, pPos )
	--else
		-- Screw the original death sounds, let's stuff this with a bunch of stuff to determine how bad the death sound should be and stuff
		GAMEMODE:VdmPlayerDeathSound( ply, dmginfo )
	--end
	
	if ( not dmginfo:IsDamageType(DMG_REMOVENORAGDOLL) && not dudeRemove ) then
		--Make sure ragdolls aren't being made with this damage type!!
		ply:CreateRagdoll()
	end
end