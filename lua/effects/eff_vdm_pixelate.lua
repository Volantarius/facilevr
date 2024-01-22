function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Ent = data:GetEntity()
	
	--self.DieTime = UnPredictedCurTime() + 0.3
	self:CreateParticles()
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
	"ValveBiped.Bip01_R_Toe0",
	"ValveBiped.Bip01_L_Thigh",
	"ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_L_Foot",
	"ValveBiped.Bip01_L_Toe0"
}

function EFFECT:CreateParticles()
	local Emitter = ParticleEmitter( self.Pos, false )
	
	for k,bonename in pairs(bones) do
		local boneid = self.Ent:LookupBone(bonename)
		
		if ( boneid ) then
			local bonepos, boneang = self.Ent:GetBonePosition(boneid)
			
			if ( bonepos == Vector(0,0,0) || bonepos == nil ) then continue end
			
			local particle = Emitter:Add( "particle/vdm_pixels", bonepos )
			
			particle:SetDieTime( 6.0 )
			
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 255 )
			
			particle:SetStartSize( math.Rand(3, 6) )
			particle:SetEndSize( particle:GetStartSize() )
			
			particle:SetNextThink( CurTime() + 3.0 )
			
			particle:SetThinkFunction(function(pa)
				pa:SetGravity( Vector(0,0,-100.0) )
				pa:SetNextThink( CurTime() + 10.0 )
			end)
			
			particle:SetCollide( true )
			particle:SetLighting( false )
			particle:SetColor( 0, 255, 0 )
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