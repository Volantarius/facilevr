AddCSLuaFile()
DEFINE_BASECLASS( "vdm_base_spawner" )

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = false
ENT.RenderGroup = RENDERGROUP_BOTH

local PickupSound = Sound( "VdmPickup.Grab" )
local RegenSound = Sound( "VdmPickup.Spawn" )

if (SERVER) then
	ENT.WeaponName = "weapon_vol_pistol"
	ENT.Ammo1Amount = 25
	ENT.Ammo2Amount = 0
	ENT.Ammo1Type = "Pistol"
	ENT.Ammo2Type = "none"
	
	function ENT:OnPickUp( ply )
		self:EmitSound( PickupSound )
		
		ply:Give( self.WeaponName )
		
		-- clip sizes can be 0 for don't give any ammo
		if ( self.Ammo1Amount > 0 ) then
			ply:GiveAmmo( self.Ammo1Amount, self.Ammo1Type )
		end
		
		if ( self.Ammo2Amount > 0 ) then
			ply:GiveAmmo( self.Ammo2Amount, self.Ammo2Type )
		end
	end
	
	function ENT:PostPickUp()
		local newWep = GAMEMODE:VdmGetRandomWeaponCurrentLoadout()
		
		self.WeaponName = newWep.weapon
		self.Ammo1Amount = newWep.clip1_amount
		self.Ammo2Amount = newWep.clip2_amount
		self.Ammo1Type = newWep.clip1_type
		self.Ammo2Type = newWep.clip2_type
		
		self:SetColor( newWep.color )
		
		self:SetAngOffset( newWep.rotateoffset )
		
		self:SetModel( newWep.worldmodel )
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
