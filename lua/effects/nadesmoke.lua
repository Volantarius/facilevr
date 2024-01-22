local velocity_dummy = Vector(0,0,0.1)-- any smaller breaks lighting..

function EFFECT:Init( data )
	
	local Pos = data:GetOrigin()
	
	local emitter = ParticleEmitter( Pos, false )
	
	--local particle = emitter:Add( "particle/particle_smokegrenade", Pos )
	local particle = emitter:Add( "particle/vdm_particle_smokegrenade", Pos )
	--local particle = emitter:Add( "particle/sparkles", Pos )
	
	particle:SetVelocity( velocity_dummy )-- BUG! Particle needs velocity to be lit?????
	
	particle:SetDieTime( 2 )--2.0 )
	
	particle:SetStartAlpha( 250 )
	particle:SetStartSize( 12 )
	
	particle:SetEndAlpha( 0 )
	particle:SetEndSize( 95 )
	
	particle:SetRoll( math.Rand(-45, 45) )
	
	particle:SetCollide( false )
	particle:SetLighting( true )
	
	--particle:SetColor( 128, 128, 128 )
	--particle:SetColor( 192, 192, 192 )
	particle:SetColor( 255, 255, 255 )
	
	emitter:Finish()
end

function EFFECT:Think( )
	if (not self.DieTime) then return false end
	
	return true
end


function EFFECT:Render()
end



