local MatTracer = Material( "effects/spark" )

local BulletAcc = 1200 * 16
local beamColor = Color(255, 255, 255, 255)

local tracerTimeLength = 1/30

function EFFECT:Init( data )
	local startpos = self:GetTracerShootPos(data:GetStart(), data:GetEntity(), data:GetAttachment())
	self.StartPos = startpos

	local endpos = data:GetOrigin()
	self.EndPos = endpos
	
	local dir = endpos - startpos
	
	local FireDistance = dir:Length()
	
	self.Dir = dir:GetNormalized()
	
	self.BulletPos2 = startpos
	self.BulletPos1 = startpos
	
	self:SetRenderBoundsWS( startpos, endpos )
	
	local time = UnPredictedCurTime()

	self.LastTime = time
	self.Length = 0
	
	self.DieTime = time + (FireDistance / BulletAcc)
end

function EFFECT:Think()
	local NowTime = UnPredictedCurTime()

	local tDelta = NowTime - self.LastTime
	self.LastTime = NowTime

	local newLength = self.Length + tDelta
	
	local dist = (self.Dir * BulletAcc * tDelta)
	
	self.BulletPos1 = self.BulletPos1 + dist
	
	if ( newLength > tracerTimeLength ) then
		self.BulletPos2 = self.BulletPos2 + dist
	else
		self.Length = newLength
	end

	return (NowTime < self.DieTime)
end

local renderSetMaterial, renderDrawBeam = render.SetMaterial, render.DrawBeam

function EFFECT:Render()
	renderSetMaterial( MatTracer )
	
	renderDrawBeam( self.BulletPos1, self.BulletPos2, 10, 1.0, 0.0, beamColor )
end
