function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Ent = data:GetEntity()
	self.Duration = data:GetScale()
	
	self.DieTime = UnPredictedCurTime() + self.Duration
end

function EFFECT:Think()
	if (not self.DieTime) then return false end
	
	if ( UnPredictedCurTime() > self.DieTime ) then
		return false
	end
	
	return true
end

--local MAT_RING = Material( "effects/pickup_ring" )
local MAT_RING = Material( "effects/protect_ring" )

local upward = Vector(0, 0, 32)

function EFFECT:Render()
	
	render.SetMaterial( MAT_RING )
	
	render.DrawSprite( self.Ent:GetPos() + upward, 100, 100, Color( 200, 210, 255, 190 ) )
	
end