AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Monkey Ball"
ENT.Author = "Volantarius"
ENT.Category = "Fun + Games"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	
end

local modellol = Model( "models/volantarius/ball_future.mdl" )--monkeyball

function ENT:Initialize()
	self:SetModel( modellol )
	
	if ( SERVER ) then
		self:PhysicsInitSphere( 46, "Plastic_Box" )-- 46 or 45...
		
		local phys = self:GetPhysicsObject()
		
		if ( IsValid( phys ) ) then
			phys:SetMass( 100 )
			
			--phys:SetDragCoefficient( 0.5 )
		end
	end
	
	--asd
end

function ENT:Think()
	
end

function ENT:PhysicsSimulate()
	
end

--[[if CLIENT then
	function ENT:Draw()
		--self:DrawModel()
	end
	
	local matBall = Material( "sprites/sent_ball" )
	
	function ENT:DrawTranslucent()
		render.SetMaterial( matBall )
		
		render.DrawSprite( self:GetPos(), 5, 5, self.gColor )
	end
end]]