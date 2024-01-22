SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel 	= "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/mines/w_proximitymine.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= 1
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "slam"
SWEP.Primary.FireDelay 		= 0.50

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "Prox. Mines"
	
	SWEP.ViewModelFOV = 54
	
	SWEP.UseHands = true
	
	SWEP.Slot = 5
	SWEP.SlotPos = 3
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/proximitymine" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 236, 12, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 60 + 16
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide * 0.5, wide * 0.5, 1, 0, 0, 1 )
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "FiredLast")
	self:NetworkVar("Bool", 0, "Fired")
end

function SWEP:Initialize()
	self:SetHoldType("slam")
end

function SWEP:Think()
	if ( CurTime() > (self:GetFiredLast() + 0.2) and self:GetFired() ) then
		self:SetFired( false )
		
		if ( self:Ammo1() > 0 ) then
			self:SendWeaponAnim( ACT_SLAM_TRIPMINE_DRAW )
		end
	end
end

function SWEP:Deploy()
	if SERVER then
		self:SetFiredLast( 0 )
		self:SetFired( false )
	end
	
	self:EmitSound( Sound("Vol_GoldenEye_Mine.Switch") )
	
	self:SendWeaponAnim( ACT_SLAM_TRIPMINE_DRAW )
	
	return true
end

function SWEP:Reload()
	return false
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootEffects()
	self:SendWeaponAnim( ACT_SLAM_TRIPMINE_ATTACH2 )
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanPrimaryAttack()
	if ( self:Ammo1() <= 0 ) then
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack()
	if ( self:Clip2() <= 0 ) then
		self:SetNextSecondaryFire( CurTime() + self.Primary.FireDelay )
		
		return false
	end
	
	return true
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	local fired = self:ShootObject()
	
	if (fired) then
		self:TakePrimaryAmmo( 1 )
		
		self:SetFiredLast( CurTime() + 0.3 )
		
		self:SetFired( true )
	end
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
end

function SWEP:SecondaryAttack()
	if ( !self:CanSecondaryAttack() ) then return end
	
	--self:ShootObject()
	
	--self:TakeSecondaryAmmo( 1 )
	
	self:SetNextSecondaryFire( CurTime() + self.Primary.FireDelay )
end

local trace_place = {
	mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
}

function SWEP:ShootObject()
	if CLIENT then return end
	SuppressHostEvents( NULL )
	
	local ent = ents.Create( "sent_vdm_proxmine" )
	if ( !IsValid(ent) ) then return end
	
	local p = self.Owner
	local pos_start = p:GetShootPos()
	
	trace_place.start = pos_start
	trace_place.endpos = pos_start + (p:GetAimVector() * 512)
	trace_place.filter = p
	
	local trace = util.TraceLine( trace_place )
	
	if ( !trace.Hit or trace.HitSky or trace.HitNonWorld or trace.StartPos:DistToSqr(trace.HitPos) >= 5200 ) then
		p:EmitSound( "HL2Player.UseDeny" )
		return false
	end
	
	self:ShootEffects()
	--self:EmitSound( "Metal.SawbladeStick" )
	--self:EmitSound( "Vol_Mine.Attach" )
	self:EmitSound( "Vol_GE_Mine.Attach" )
	
	ent:SetPos( trace.HitPos )
	ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0) )
	ent:SetOwner( p )
	ent:SetWallNormal( trace.HitNormal )
	
	ent:Spawn()
	ent:Activate()
	
	return true
end