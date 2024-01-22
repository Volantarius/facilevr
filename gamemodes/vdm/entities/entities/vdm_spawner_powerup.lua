AddCSLuaFile()
DEFINE_BASECLASS( "vdm_base_spawner" )

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = false
ENT.RenderGroup = RENDERGROUP_BOTH

local PickupSound = Sound( "VdmPickupTS.Grab" )
local RegenSound = Sound( "VdmPickupTS.Spawn" )

if (SERVER) then
	function ENT:OnPickUp( ply )
		self:EmitSound( PickupSound )
	end
	
	function ENT:PostPickUp()
		self:SetColor( Color(0, 225, 128) )
		self:SetAngOffset( Angle(90, 0, 0) )
		self:SetModel( Model("models/weapons/armor/armor.mdl") )
	end
	
	function ENT:OnRespawn()
		self:EmitSound( RegenSound )
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	--[[
		MAKE SURE TO NOT OVERRIDE THESE
		( "Bool", 0, "Taken" )
		( "Bool", 1, "PostTaken" )
		
		( "Float", 0, "PickupTime" )
		( "Float", 1, "RespawnedTime" )
		
		( "Angle", 0, "AngOffset" )
	]]
	
	--[[self:NetworkVar( "Bool", 0, "Taken" ) -- Is the pickup taken?
	
	if ( SERVER ) then
		self:SetTaken( false )
		
	end]]
end

function ENT:Initialize()
	BaseClass.Initialize( self )
	
	-- Make sure we grab a weapon from the pickup_manager!
	if (SERVER) then
		self:PostPickUp()
	end
end
