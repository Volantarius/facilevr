local MatTracer = Material( "effects/spark" )

local Gravity = Vector(0,0,-514.78)
local BulletAcc = 400 * 16

local tracerTimeLength = 1/60

function EFFECT:Init( data )
	local startpos = data:GetStart()
	local endpos = data:GetOrigin()

	self.StartPos = startpos
	
	self.EndPos = endpos
	
	local dir = endpos - startpos
	
	self.Dir = dir:GetNormalized()
	
	self.BulletPos5 = startpos
	self.BulletPos4 = startpos
	self.BulletPos3 = startpos
	self.BulletPos2 = startpos
	self.BulletPos1 = startpos
	
	self:SetRenderBoundsWS( startpos, endpos )
	
	local time = UnPredictedCurTime()

	self.LastTime = time
	
	self.CreateTime = time
	self.Length = 0

	self.DieTime = time + (dir:Length() / BulletAcc)
end

function EFFECT:Think()
	local NowTime = UnPredictedCurTime()
	
	local tLen = (NowTime - self.LastTime) + self.Length
	local flightTime = NowTime - self.CreateTime

	if (tLen >= tracerTimeLength) then
		local p1, p2, p3, p4 = self.BulletPos1, self.BulletPos2, self.BulletPos3, self.BulletPos4

		self.BulletPos5 = p4
		self.BulletPos4 = p3
		self.BulletPos3 = p2
		self.BulletPos2 = p1
		self.BulletPos1 = p1 + (self.Dir * BulletAcc * tLen) + (Gravity * tLen * (flightTime*flightTime))

		self.Length = 0
	else
		self.Length = tLen
	end

	self.LastTime = NowTime

	return (NowTime < self.DieTime)
end

local renderSetMaterial, renderStartBeam, renderAddBeam, renderEndBeam = render.SetMaterial, render.StartBeam, render.AddBeam, render.EndBeam

local colHot, colOut = Color(255, 255, 255, 255), Color(255, 0, 0, 255)

function EFFECT:Render()
	renderSetMaterial( MatTracer )
	
	local p1, p2, p3, p4, p5 = self.BulletPos1, self.BulletPos2, self.BulletPos3, self.BulletPos4, self.BulletPos5

	renderStartBeam(5)
	renderAddBeam( p1, 6, 1.00, colHot )
	renderAddBeam( p2, 6, 0.75, colHot )
	renderAddBeam( p3, 6, 0.50, colHot )
	renderAddBeam( p4, 6, 0.25, colHot )
	renderAddBeam( p5, 6, 0.00, colHot )
	renderEndBeam()
	
	renderStartBeam(5)
	renderAddBeam( p1, 16, 1.00, colOut )
	renderAddBeam( p2, 16, 0.75, colOut )
	renderAddBeam( p3, 16, 0.50, colOut )
	renderAddBeam( p4, 16, 0.25, colOut )
	renderAddBeam( p5, 16, 0.00, colOut )
	renderEndBeam()
end
