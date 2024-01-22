EFFECT.Mat = Material( "sprites/disp_portal" )

function EFFECT:Init( data )
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	
	self.Alpha = 255
	self.Life = 0
end

function EFFECT:Think()
	self.Life = self.Life + (FrameTime() * 0.5)
	self.Alpha = 255 * (1 - self.Life)
	
	return (self.Life < 1)
end

function EFFECT:Render()
	if (self.Alpha < 1) then return end
	
	local delta = 1 - self.Life
	local col = Color( 255, 255, 255, 255 * delta )
	
	local fart = math.Clamp(self.Life, 0, 0.25) * 4
	fart = fart * fart
	
	render.SetMaterial( self.Mat )
	
	render.DrawSprite( self.Position + (self.Normal * 32), 75 * fart, 75 * fart, col )
end
