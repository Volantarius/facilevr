local MatTracer  = Material( "effects/spark" )
local MatTracer2 = Material( "effects/getracer" )

local BulletAcc = 2400 * 16

local tracerTimeLength = 1/60

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

local colHot, colOut = Color(255, 255, 255, 255), Color(255, 0, 0, 255)

function EFFECT:Render()
	local p1, p2 = self.BulletPos1, self.BulletPos2
	
	renderSetMaterial( MatTracer2 )
	
	renderDrawBeam( p1, p2, 16, 0.0, 1.0, colHot )

	renderSetMaterial( MatTracer )

	renderDrawBeam( p1, p2, 32, 1.0, 0.0, colOut )
end
