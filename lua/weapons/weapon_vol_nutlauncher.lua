SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "Volantarius"

--[[SWEP.ViewModel 	= "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"]]
SWEP.ViewModel 	= "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 6
SWEP.Primary.DefaultClip 	= 6
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "Grenade"
SWEP.Primary.FireDelay 		= 0.24

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "NUT Launcher"
	
	SWEP.ViewModelFOV = 54
	
	SWEP.UseHands = true
	
	SWEP.Slot = 4
	SWEP.SlotPos = 3
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/swep_default" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 236, 12, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 60 + 16
		wide = wide - 60
		
		--[[y = y + 30
		x = x + 30
		wide = wide - 60]]
		
		surface.DrawTexturedRectUV( x, y, wide * 0.5, wide * 0.5, 1, 0, 0, 1 )
	end
end

function SWEP:SetupDataTables()
end

function SWEP:Initialize()
	self:SetHoldType("shotgun")
end

function SWEP:Think()
	--
end

function SWEP:Deploy()
	return true
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootPrimaryEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	--self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanPrimaryAttack()
	if ( self:Clip1() <= 0 ) then
		self:EmitSound( "Vol_TS_Dry.Single" )
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack()
	if ( self:Clip2() <= 0 ) then
		self:EmitSound( "Vol_TS_Dry.Single" )
		self:SetNextSecondaryFire( CurTime() + self.Primary.FireDelay )
		
		return false
	end
	
	return true
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:EmitSound( "Weapon_SMG1.Double" )
	
	self:ShootObject( 16, 0.9 )
	
	--self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	
	if ( IsValid(self.Owner) ) then
		self.Owner:VRecoil( -1.84, -0.1 )
	end
	
	self:ShootPrimaryEffects()
end

local colorslol = {
	Color(255, 32, 0),
	Color(255,200,0),
	Color(64,64,255),
	Color(32,255,32)
}

function SWEP:ShootObject( damage, aimcone )
	if CLIENT then return end
	SuppressHostEvents( NULL )
	
	local ent = ents.Create( "sent_vdm_bouncyball" )
	if ( !IsValid(ent) ) then return end
	
	local finalAngles = self.Owner:GetAimVector():Angle() + self.Owner:GetViewPunchAngles()
	finalAngles = finalAngles + Angle( math.Rand(-1 * aimcone, aimcone), math.Rand(-1 * aimcone, aimcone), 0 )
	
	local forward = finalAngles:Forward()
	
	ent:SetPos( self.Owner:GetShootPos() + (forward * 32) + (finalAngles:Right() * 4) )
	ent:SetAngles( finalAngles )
	ent:SetOwner( self.Owner )
	
	ent:SetColor( colorslol[ math.random(#colorslol) ] )
	
	ent:Spawn()
	ent:Activate()
	
	-- Always get phys object after creation
	local phys = ent:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:ApplyForceCenter(forward * 30000)--3000,1500
	else
		ent:Remove()
	end
end