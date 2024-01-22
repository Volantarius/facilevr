function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	
	self.DieTime = UnPredictedCurTime() + 10.0
	
	self.Emitter = ParticleEmitter( self.Pos, false )
	
	self.NextDrip = UnPredictedCurTime()
end

function EFFECT:CreateParticles()
	local horizontal = VectorRand(-14, 14)
	horizontal.z = 0
	
	local particle = self.Emitter:Add( "effects/blooddrop", self.Pos + horizontal )
	
	particle:SetDieTime( 2.0 )
	
	particle:SetStartAlpha( 255 )
	particle:SetEndAlpha( 0 )
	
	particle:SetStartSize( 2.5 )
	particle:SetEndSize( 2.5 )
	
	particle:SetCollide( true )
	particle:SetLighting( true )
	particle:SetColor( 192, 0, 0 )
	
	particle:SetCollideCallback(function(pa, hitpos, hitnormal)
		pa:SetDieTime( 0.1 )
		util.Decal( "Impact.Flesh", hitpos, hitpos - hitnormal )
	end)
	
	particle:SetGravity( Vector(0,0,-600.0) )
end

function EFFECT:Think()
	if (not self.DieTime) then return false end
	
	if (UnPredictedCurTime() > self.DieTime) then
		self.Emitter:Finish()
		return false
	else
		if ( UnPredictedCurTime() > self.NextDrip ) then
			self:CreateParticles()
			
			self.NextDrip = UnPredictedCurTime() + math.Rand(0.7, 6.7)
		end
	end
	
	return true
end

function EFFECT:Render()
end