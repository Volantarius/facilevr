function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	
	local Emitter = ParticleEmitter( Pos, false )
	
	for i=1, 5 do
		local particle = Emitter:Add( "particle/particle_smokegrenade", Pos )
		
		particle:SetVelocity( (Norm + VectorRand()*0.32) * math.Rand(120, 200) )
		particle:SetDieTime( math.Rand( 5.0, 8.0 ) )
		particle:SetStartAlpha( 255 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( math.Rand( 100, 140 ) )
		particle:SetRoll( 0 )
		particle:SetGravity( Vector(0, 0, 3) )
		particle:SetBounce( 0.2 )
		particle:SetAirResistance( 32 )
		particle:SetCollide( true )
		particle:SetLighting( true )
		particle:SetColor( 0, 255, 0 )
	end
	
	Emitter:Finish()
end

function EFFECT:Think( )
	if (not self.DieTime) then return false end
	
	return true
end

function EFFECT:Render()
end