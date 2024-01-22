EFFECT.MatLaser  = Material( "effects/fadelaser_1" )
EFFECT.MatTracer = Material( "effects/spark" )

function EFFECT:Init( data )
	self.Position = data:GetStart()
	
	local ent = data:GetEntity()
	local att = data:GetAttachment()
	
	self.StartPos = self:GetTracerShootPos(self.Position, ent, att)
	self.EndPos = data:GetOrigin()
	
	self.Dir = self.EndPos - self.StartPos
	
	self.FireDistance = self.Dir:Length()
	
	self.Dir:Normalize()
	
	self.BulletAcc = 900 * 16
	
	self.LastPosition = self.StartPos
	--self.LastPosition2 = self.StartPos
	self.BulletPosition = self.StartPos
	
	self.Alpha = 255
	self.Life = 0
	
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.LastTime = UnPredictedCurTime()
	
	self.DieTime = UnPredictedCurTime() + (self.FireDistance / self.BulletAcc)
end

function EFFECT:Think()
	self.Life = self.Life + FrameTime() * 0.78
	self.Alpha = 255 * (1 - self.Life)
	
	return (self.Life < 1)
end

function EFFECT:Render()
	if (self.Alpha < 1) then return end
	
	local NowTime = UnPredictedCurTime()
	
	local tDelta = NowTime - self.LastTime
	self.LastTime = NowTime
	
	--self.LastPosition2 = self.LastPosition
	self.LastPosition = self.BulletPosition
	self.BulletPosition = self.BulletPosition + (self.Dir * self.BulletAcc * tDelta)
	
	local bulletEnded = UnPredictedCurTime() > self.DieTime
	
	render.SetMaterial( self.MatLaser )
	
	local beamEndPos = self.EndPos
	
	if (not bulletEnded) then beamEndPos = self.BulletPosition end
	
	if ( bulletEnded ) then return end
	
	render.SetMaterial( self.MatTracer )
	
	render.StartBeam(2)
	render.AddBeam( self.BulletPosition, 5, 1.0, Color(255, 255, 255, 255) )
	render.AddBeam( self.LastPosition, 5, 0.0, Color(255, 255, 255, 255) )
	render.EndBeam()
end
