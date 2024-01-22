function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	--self.Ent = data:GetEntity()
	
	self.RandVec = VectorRand(-1.5, 1.5)
	
	self.DieTime = UnPredictedCurTime() + math.Rand(0.06, 0.22)
	
	self.Emitter = ParticleEmitter( self.Pos, false )
	
	self.Seed = math.Rand(0, 1)
	
	self.NextDrip = UnPredictedCurTime()
end

function EFFECT:CreateParticles()
	local particle = self.Emitter:Add( "effects/cum_core", self.Pos )
	
	particle:SetDieTime( 4.0 )
	
	particle:SetStartAlpha( 200 )
	particle:SetEndAlpha( 0 )
	
	particle:SetStartSize( 4 )
	particle:SetEndSize( 0 )
	
	particle:SetRoll( math.Rand(0,1) )
	particle:SetBounce( 0 )
	
	particle:SetStartLength( 12 )
	particle:SetEndLength( 12 )
	
	particle:SetCollide( true )
	particle:SetLighting( false )
	particle:SetColor( 255, 255, 255 )
	
	particle:SetCollideCallback(function(pa, hitpos, hitnormal)
	--	pa:SetDieTime( 0.1 )
	--	util.Decal( "BirdPoop", hitpos, hitpos - hitnormal )
		particle:SetStartLength( 0 )
		particle:SetEndLength( 0 )
	end)
	
	particle:SetAirResistance( 0.7 )
	
	local spurt = math.sin(UnPredictedCurTime() * (8+self.Seed)) + 1
	spurt = (spurt * 90) + 110
	
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