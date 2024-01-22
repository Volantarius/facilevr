local MatLaser  = Material( "effects/fadelaser_1" )
local MatTracer = Material( "effects/laser_tracer" )

local BulletAcc = 2400 * 16
local beamColor = Color(255, 255, 255, 255)

local tracerTimeLength = 2/60

--[[
	This is to be an example of localising variables and ease the constant index calls for each variable for self!
]]

function EFFECT:Init( data )
	-- First locally create variables that will be reused, and only ever assign self variables

	self.Life = 0

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
	self.Life = self.Life + FrameTime() * 0.78
	
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

	return (self.Life < 1)
end

local renderSetMaterial, renderDrawBeam = render.SetMaterial, render.DrawBeam

function EFFECT:Render()
	local life = self.Life

	if (life > 1) then return end

	local bulletEnded = UnPredictedCurTime() > self.DieTime

	local p1 = self.BulletPos1
	
	renderSetMaterial( MatLaser )
	
	renderDrawBeam( self.StartPos, bulletEnded and self.EndPos or p1, 6, 0, 0.5, Color( 255, 255, 255, 32 * ( 1 - life ) ) )
	
	if ( bulletEnded ) then return end
	
	renderSetMaterial( MatTracer )
	
	renderDrawBeam( p1, self.BulletPos2, 3, 0.0, 1.0, beamColor )
end
