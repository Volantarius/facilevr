EFFECT.Mat = Material( "effects/fadelaser_1" )

function EFFECT:Init( data )
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	
	--local ent = data:GetEntity()
	--local att = data:GetAttachment()
	
	--self.StartPos = self:GetTracerShootPos(self.Position, ent, att)
	
	--self.Dir = self.EndPos - self.StartPos
	
	self.Alpha = 255
	self.Life = 0
	
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
end

function EFFECT:Think()
	self.Life = self.Life + FrameTime() * 0.125
	self.Alpha = 255 * (1 - self.Life)
	
	return (self.Life < 1)
end

function EFFECT:Render()
	
	if (self.Alpha < 1) then return end
	
	render.SetMaterial( self.Mat )
	
	render.DrawBeam( 	self.StartPos,		-- Start Position
						self.EndPos,		-- End Position
						5,					-- Width
						0.925,				-- START texture coordinate
						0.5,					-- END texture coordinate
						Color( 10, 192, 255, 255 * ( 1 - self.Life ) ) )
	
end
