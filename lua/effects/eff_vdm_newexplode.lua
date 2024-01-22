function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	
	self:CreateParticles()
	
	sound.Play( "Vol_MineTest.Explode", self.Pos )
end

function EFFECT:CreateParticles()
	local Emitter = ParticleEmitter( self.Pos + (self.Normal * 4), false )
	
	for k=0,32 do
		local particle = Emitter:Add( "effects/fire_cloud2", self.Pos )
		
		particle:SetDieTime( 4.0 )
		
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 24 )
		
		particle:SetStartSize( 24 )
		particle:SetEndSize( 0 )
		
		particle:SetStartLength( 200 )
		particle:SetEndLength( 10 )
		
		particle:SetAirResistance( 1.0 )
		
		local velocity = (self.Normal * 2) + VectorRand(-1.5, 1.5)
		
		particle:SetVelocity( velocity * 1400 )--2800
		particle:SetGravity( Vector(0,0,-600.0) )
		
		particle:SetCollideCallback(function(pa, hitpos, hitnormal)
			pa:SetDieTime( 0 )
		end)
		
		particle:SetCollide( true )
		particle:SetLighting( false )
		particle:SetColor( 255, 255, 255 )
	end
	
	--[[for k=0,12 do
		local particle = Emitter:Add( "particle/particle_smokegrenade", (self.Normal * 100) + self.Pos + VectorRand(-100, 100) )
		
		particle:SetDieTime( 5.0 )
		
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		
		particle:SetStartSize( 80 )
		particle:SetEndSize( 80 )
		
		particle:SetRoll( math.Rand(0,1) )
		particle:SetRollDelta( math.Rand(0.2, 2) )
		
		particle:SetAirResistance( 0.7 )
		particle:SetGravity( Vector(0,0,10) )
		
		particle:SetCollide( false )
		particle:SetLighting( false )
		particle:SetColor( 0, 0, 0 )
	end]]
	
	for k=0,12 do
		local smokePos = ( (self.Normal * 1.8) + VectorRand(-1.0, 1.0) ) * 32
		
		local particle = Emitter:Add( "effects/fire_cloud2", self.Pos + smokePos )
		
		particle:SetDieTime( 0.3 )
		
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		
		particle:SetStartSize( math.Rand(50,100) )
		particle:SetEndSize( 50 )
		
		particle:SetRoll( math.Rand(0,1) )
		particle:SetRollDelta( math.Rand(0, 2) )
		particle:SetBounce( 0 )
		
		local velocity = self.Normal + VectorRand()
		particle:SetVelocity( velocity * 200 )
		
		particle:SetCollide( false )
		particle:SetLighting( false )
		particle:SetColor( 255, 255, 255 )
	end
	
	for k=0,12 do
		local smokePos = ( (self.Normal * 1.8) + VectorRand(-1.0, 1.0) ) * 32
		
		local particle = Emitter:Add( "effects/fuckember", self.Pos + smokePos )
		
		particle:SetDieTime( 0.5 )
		
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		
		particle:SetStartSize( 24 )
		particle:SetEndSize( 200 )
		
		particle:SetRoll( math.Rand(0,1) )
		particle:SetRollDelta( math.Rand(0.5, 3) )
		
		local velocity = self.Normal + VectorRand()
		particle:SetVelocity( velocity * 200 )
		
		particle:SetAirResistance( 1.0 )
		
		particle:SetCollideCallback(function(pa, hitpos, hitnormal)
			pa:SetDieTime( 0 )
		end)
		
		particle:SetCollide( true )
		particle:SetLighting( false )
		particle:SetColor( 255, 255, 255 )
	end
	
	Emitter:Finish()
end

function EFFECT:Think()
	if (not self.DieTime) then return false end
	
	return true
end

function EFFECT:Render()
end