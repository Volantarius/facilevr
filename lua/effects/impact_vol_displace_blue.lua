EFFECT.Mat = Material( "effects/rollerglow" )
EFFECT.Mat2 = Material( "effects/yellowflare" )

function EFFECT:Init( data )
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	
	self.Alpha = 255
	self.Life = 0
end

function EFFECT:Think()
	self.Life = self.Life + (FrameTime() * 2.0)
	self.Alpha = 255 * (1 - self.Life)
	
	return (self.Life < 1)
end

function EFFECT:Render()
	if (self.Alpha < 1) then return end
	
	local delta = 1 - self.Life
	local col = Color( 0, 170, 255, 255 * delta )
	
	local deltaQ = delta * delta
	local deltaQQ = delta * delta * delta
	
	render.SetMaterial( self.Mat )
	
	render.DrawQuadEasy( self.Position + (self.Normal * 0.1), self.Normal, 32 * deltaQ, 32 * deltaQ, col, 360 * delta )
	
	render.SetMaterial( self.Mat2 )
	
	render.DrawQuadEasy( self.Position + (self.Normal * 0.3), self.Normal, 64 * deltaQQ, 64 * deltaQQ, Color( 255, 255, 200, 255 ), 0 )
end
