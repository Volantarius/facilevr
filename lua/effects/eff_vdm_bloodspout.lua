function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Ent = data:GetEntity()
	
	--if ( IsValid(self.Ent) ) then
	--	self.Velo = self.Ent:GetVelocity()
	--end
	
	self.RandVec = VectorRand(-1.5, 1.5)
	
	self.DieTime = UnPredictedCurTime() + math.Rand(0.06, 0.22)
	
	self.Emitter = ParticleEmitter( self.Pos, false )
	
	self.NextDrip = UnPredictedCurTime()
end

function EFFECT:CreateParticles()
	local particle = self.Emitter:Add( "effects/blood_core", self.Pos )
	
	particle:SetDieTime( 6.0 )
	
	particle:SetStartAlpha( 255 )
	particle:SetEndAlpha( 255 )
	
	particle:SetStartSize( 3 )
	particle:SetEndSize( 3 )
	
	particle:SetRoll( math.Rand(0,1) )
	particle:SetBounce( 0 )
	
	particle:SetStartLength( 6 )
	particle:SetEndLength( 6 )
	
	particle:SetCollide( true )
	particle:SetLighting( true )
	particle:SetColor( 192, 0, 0 )
	
	particle:SetCollideCallback(function(pa, hitpos, hitnormal)
		pa:SetDieTime( 0.1 )
		util.Decal( "Impact.Flesh", hitpos, hitpos - hitnormal )
	end)
	
	particle:SetAirResistance( 0.7 )
	
	local spurt = math.sin(UnPredictedCurTime() * 8) + 1
	spurt = (spurt * 60) + 110
	
	local velocityOff = (UnPredictedCurTime() - self.DieTime) * self.RandVec
	
	particle:SetVelocity( (self.Normal + Vector(0,0,0.8) + velocityOff) * spurt )
	
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
			
			self.NextDrip = UnPredictedCurTime() + (RealFrameTime() * 4)
		end
	end
	
	return true
end

function EFFECT:Render()
end