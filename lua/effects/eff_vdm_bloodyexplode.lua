function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Ent = data:GetEntity()
	self.Normal = data:GetNormal()
	self.Ang = (data:GetAngles()):Forward()
	
	self:CreateParticles()
	
	sound.Play( "Vdm_Gore.Explode", self.Pos )
end

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

function EFFECT:CreateParticles()
	local Emitter = ParticleEmitter( self.Pos, false )
	
	for k,bonename in pairs(bones) do
		local boneid = self.Ent:LookupBone(bonename)
		
		if ( boneid ) then
			local bonepos, boneang = self.Ent:GetBonePosition(boneid)
			
			if ( bonepos == Vector(0,0,0) || bonepos == nil ) then continue end
			
			for i=1, 4 do
				local ed = EffectData()
				ed:SetOrigin( bonepos )
				ed:SetNormal( self.Normal )
				util.Effect( "BloodImpact", ed )
				
				local particle = Emitter:Add( "effects/blood_core", bonepos )
				
				particle:SetDieTime( 6.0 )
				
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 255 )
				
				particle:SetStartSize( math.Rand(24, 48) )-- math.Rand(10, 23)
				particle:SetEndSize( 10 )
				
				particle:SetRoll( math.Rand(0,1) )
				particle:SetBounce( 0 )
				
				particle:SetStartLength( 100 )
				particle:SetEndLength( 100 )
				
				local velocity = self.Normal
				
				if ( i % 3 == 0 ) then
					velocity = self.Ang
				end
				
				velocity = velocity + VectorRand(-0.5, 0.5) + Vector(0,0,0.3)
				
				particle:SetAirResistance( 0.4 )--0.7
				particle:SetVelocity( velocity * math.Rand(600, 2000) )
				particle:SetGravity( Vector(0,0,-700.0) )
				
				particle:SetCollideCallback(function(pa, hitpos, hitnormal)
					util.Decal( "Blood", hitpos, hitpos - hitnormal )
					sound.Play( "Vdm_Gore.Splat", hitpos + hitnormal )
					pa:SetDieTime( 1.5 )
					
					if ( hitnormal.z < -0.75 ) then
						local ed = EffectData()
						ed:SetOrigin(hitpos)
						ed:SetNormal(hitnormal)
						util.Effect( "eff_vdm_blooddripper", ed )
					end
				end)
				
				particle:SetCollide( true )
				particle:SetLighting( true )
				particle:SetColor( 128, 0, 0 )
			end
		end
	end
	
	Emitter:Finish()
end

function EFFECT:Think()
	if (not self.DieTime) then return false end
	
	return true
end

function EFFECT:Render()
end