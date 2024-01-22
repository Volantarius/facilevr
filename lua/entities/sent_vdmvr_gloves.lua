AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Poor mans vr gloves"
ENT.Author = "Volantarius"
ENT.Category = "Fun + Games"

ENT.Editable = false
ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	
end

local modellol = Model( "models/weapons/w_eq_fraggrenade_thrown.mdl" )

function ENT:Initialize()
	self:SetModel( modellol )
	
	if ( SERVER ) then
		self:PhysicsInitSphere( 1.8, "flesh" )
		
		local phys = self:GetPhysicsObject()
		
		if ( IsValid( phys ) ) then
			phys:SetMass( 400 )
			
			phys:SetDragCoefficient( 0.5 )
			
			local held_old_lin_damping, held_old_ang_damping = phys:GetDamping(), 1
			
			phys:SetDamping( held_old_lin_damping, 10 )
			
			phys:EnableDrag( false )
			
			--self:SetSolidFlags( FSOLID_NOT_SOLID )
			--self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )
			
			--rphys:AddGameFlag( FVPHYSICS_PLAYER_HELD )
			phys:SetContents( CONTENTS_GRATE )
		end
	end
	
end

function ENT:Think()
	
end

function ENT:PhysicsSimulate()
	
end