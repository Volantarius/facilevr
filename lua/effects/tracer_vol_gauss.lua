local matLaser = Material( "effects/tracer_middle" )
local matZap	 = Material( "effects/gaussZap" )
local matSpr   = Material( "sprites/physg_glow1" )

function EFFECT:Init( data )
	self.Position = data:GetStart()
	self.EndPos = data:GetOrigin()
	
	local ent = data:GetEntity()
	local att = data:GetAttachment()
	
	self.StartPos = self:GetTracerShootPos(self.Position, ent, att)
	
	self.Dir = self.StartPos - self.EndPos
	
	self.Length = self.Dir:LengthSqr() / (1024 * 1024)
	
	self.Dir:Normalize()
	
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.DieTime = CurTime() + math.Rand( 2, 3 )
	
	self.Size = 8
end

function EFFECT:Think( )
	if CurTime() > self.DieTime then
		return false
	end
	
	self.Size = self.Size - ( 16 * FrameTime( ) )
	return true
end

local zapTime = 0

function EFFECT:Render( )
	render.SetMaterial( matLaser )
	render.DrawBeam( self.StartPos, self.EndPos, self.Size, 0.93, 0, Color( 255, 24, 0, 128 ) )
	
	if (self.Size <= 0) then return end
	local zapSize = (7 * math.sin( CurTime() * 58 )) * self.Size
	
	local randcoord = math.Rand( 0, 1 )
	
	render.SetMaterial( matZap )
	render.DrawBeam( self.StartPos, self.EndPos, zapSize, randcoord, randcoord + self.Length, Color( 255, 255, 200, 255 ) )
	
	local sprSize = (self.Size * 1.5) ^ 2
	
	render.SetMaterial( matSpr )
	render.DrawSprite( self.EndPos + (self.Dir * 4), sprSize, sprSize, Color( 255, 200, 100, 255 ) )
end
