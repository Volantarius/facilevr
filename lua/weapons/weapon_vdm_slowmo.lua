SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 6
SWEP.Primary.DefaultClip 	= 6
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "357"
SWEP.Primary.FireDelay 		= 1.5

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "Matrix Gun"
	
	SWEP.ViewModelFOV = 54
	SWEP.ViewModelFlip = false
	
	SWEP.UseHands = true
	
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	
	killicon.Add( "weapon_vdm_slowmo", "killicons/357", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/357" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 236, 12, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 30
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide, wide * 0.5, 1, 0, 0, 1 )
	end
end

function SWEP:Initialize()
	self:SetHoldType("revolver")
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootPrimaryEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	if ( self.Owner ~= nil ) then
		local vm = self.Owner:GetViewModel()
		
		vm:SetPlaybackRate( 0.25 )
	end
	
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanPrimaryAttack()
	if ( self:Clip1() <= 0 ) then
		--self:EmitSound( "Vol_TS_Dry.Single" )
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:EmitSound( "Vol_Bullettime.Start" )
	self:EmitSound( "Vol_MaxPayne_Deagle.Single" )
	
	--self:ShootBullet( 10, 1, 0.004 )
	
	self:ShootObject( 16, 0.9 )
	
	--self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	
	self.Owner:VRecoil( -6.00, -0.10 )
	
	self:ShootPrimaryEffects()
end

function SWEP:ShootObject( damage, aimcone )
	if CLIENT then return end
	SuppressHostEvents( NULL )
	
	local ent = ents.Create( "sent_vdm_slowbullet" )
	if ( !IsValid(ent) ) then return end
	
	local finalAngles = self.Owner:GetAimVector():Angle() + self.Owner:GetViewPunchAngles()
	finalAngles = finalAngles + Angle( math.Rand(-1 * aimcone, aimcone), math.Rand(-1 * aimcone, aimcone), 0 )
	
	local forward = finalAngles:Forward()
	
	--ent:SetPos( self.Owner:GetShootPos() + (forward * 32) + (finalAngles:Right() * 4) )
	ent:SetPos( self.Owner:GetShootPos() )
	ent:SetAngles( finalAngles )
	ent:SetOwner( self.Owner )
	
	ent:Spawn()
	ent:Activate()
	
	-- Always get phys object after creation
	local phys = ent:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:ApplyForceCenter(forward * 500)--3000,1500
	else
		ent:Remove()
	end
end