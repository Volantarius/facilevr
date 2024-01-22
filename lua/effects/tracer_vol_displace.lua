EFFECT.Mat = Material( "particle/bendibeam" )

function EFFECT:Init( data )
	self.Position = data:GetStart()
	self.EndPos = data:GetOrigin()
	
	local ent = data:GetEntity()
	local att = data:GetAttachment()
	
	self.StartPos = self:GetTracerShootPos(self.Position, ent, att)
	
	self.Dir = self.EndPos - self.StartPos
	self.Dir:Normalize()
	
	self.Dist = self.EndPos:Distance(self.StartPos)
	
	self.MidPoint = self.EndPos - (self.Dist * 0.5 * self.Dir)
	
	self.Coord = self.Dist / 128
	
	self.FuckPoint = self.MidPoint
	
	self.Alpha = 255
	self.Life = 0
	
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
end

function EFFECT:Think()
	self.Life = self.Life + (FrameTime() * 2.0)
	self.Alpha = 255 * (1 - self.Life)
	
	self.FuckPoint = self.MidPoint + VectorRand(-6, 6)
	
	return (self.Life < 1)
end

function EFFECT:Render()
	if (self.Alpha < 1) then return end
	
	local fart = UnPredictedCurTime() * 10
	fart = math.ceil(fart) - fart
	
	local col = Color( 0, 255, 0, 255 * ( 1 - self.Life ) )
	
	render.SetMaterial( self.Mat )
	
	render.StartBeam(3)
	render.AddBeam( self.EndPos, 3, 	self.Coord + fart, col )
	render.AddBeam( self.FuckPoint, 3, 	(self.Coord * 0.5) + fart, col )
	--col.a = 0
	render.AddBeam( self.StartPos, 3, 	0.0 + fart, col )
	render.EndBeam()
end
