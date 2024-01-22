SWEP.Base = "weapon_vdm_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel 	= "models/weapons/cstrike/c_eq_smokegrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_smokegrenade.mdl"

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= 1
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "Grenade"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

if CLIENT then
	SWEP.PrintName 	= "Turtles"
	
	SWEP.ViewModelFOV = 54
	
	SWEP.Slot = 4
	SWEP.SlotPos = 3
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/explosive" )
	SWEP.WepSelectIconSquare = true
end

-- Hopefully this can be used for other things like Crossbows, and chargable things
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "PulledBack")
	self:NetworkVar("Bool", 1, "Releasing")
	
	self:NetworkVar("Bool", 3, "Rebound")
	
	self:NetworkVar("Float", 0, "PulledTime")
	self:NetworkVar("Float", 1, "ReleasedTime")
end

function SWEP:Initialize()
	self:SetHoldType("grenade")
end

function SWEP:Think()
	if ( self:GetRebound() and CurTime() > (self:GetReleasedTime() + 0.65) ) then
		self:SetRebound( false )
		
		-- Grenade only thing
		if ( self:Ammo1() > 0 ) then
			self:SendWeaponAnim( ACT_VM_DRAW )
		end
	end
	
	if ( self:GetReleasing() and not self:GetPulledBack() and CurTime() > (self:GetReleasedTime() + 0.00) ) then
		self:Release( CurTime() - self:GetPulledTime() )
		
		self:SetReleasing( false )
		
		self:SetRebound( true )
	end
	
	if ( self:GetPulledBack() ) then
		if ( not self.Owner:KeyDown(IN_ATTACK) and CurTime() > self:GetPulledTime() ) then
			self:SetReleasedTime( CurTime() )
			
			self:SetPulledBack( false )
			
			self:SetReleasing( true )
		end
	end
end

function SWEP:Deploy()
	if SERVER then
		self:SetPulledBack( false )
		self:SetReleasing( false )
		self:SetPulledTime( 0 )
		self:SetReleasedTime( 0 )
		self:SetRebound( false )
	end
	
	return true
end

--[[///////////////////////////////////////////////////////////]]

-- New pull and release mechanics
function SWEP:Release( heldtime )
	self:EmitSound( "WeaponFrag.Throw" )
	
	self:SendWeaponAnim( ACT_VM_THROW )
	
	self:ShootPrimaryEffects()
	
	self:SetNextPrimaryFire( CurTime() + 1.25 )
	
	self:ShootObject( 16, 0.9 )
	
	self:TakePrimaryAmmo( 1 )
end

function SWEP:PullBack()
	self:SendWeaponAnim( ACT_VM_PULLPIN )
	
	self:SetPulledBack( true )
	self:SetPulledTime( CurTime() + 1.2 )
	self:SetNextPrimaryFire( CurTime() + 2.5 )
end

function SWEP:ShootPrimaryEffects()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanPrimaryAttack()
	if ( self:Ammo1() <= 0 ) then
		--self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.4 )
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:SetNextPrimaryFire( CurTime() + 1.0 )
	
	self:PullBack()
end

function SWEP:ShootObject( damage, aimcone )
	if CLIENT then return end
	SuppressHostEvents( NULL )
	
	local ent = ents.Create( "sent_vdm_turtlegrenade" )
	if ( !IsValid(ent) ) then return end
	
	local forward = self.Owner:GetAimVector()
	
	ent:SetPos( self.Owner:GetShootPos() + (forward * 16) )
	ent:SetAngles( self.Owner:EyeAngles() )
	ent:SetOwner( self.Owner )
	
	ent:Spawn()
	ent:Activate()
	
	-- Always get phys object after creation
	local phys = ent:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:ApplyForceCenter(forward * 1500)--2000
	else
		ent:Remove()
	end
end