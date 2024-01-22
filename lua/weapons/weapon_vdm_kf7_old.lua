SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "Volantarius"

SWEP.ViewModel = "models/weapons/kf7/v_kf7.mdl"
SWEP.WorldModel = "models/weapons/kf7/w_kf7.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 30
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "SMG1"
SWEP.Primary.FireDelay 		= 3/20

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "KF7 classic"
	
	SWEP.ViewModelFOV = 54
	SWEP.ViewModelFlip = false
	
	SWEP.UseHands = false
	
	SWEP.Slot = 2
	SWEP.SlotPos = 5
	
	SWEP.DrawCrosshair = false
	
	killicon.Add( "weapon_vdm_kf7", "killicons/swep_default", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/swep_default" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 60 + 16
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide * 0.5, wide * 0.5, 1, 0, 0, 1 )
	end
	
	--[[ SECONDARY AIM ]]
	
	local Zoom = 1.0
	local LastTime = UnPredictedCurTime()
	
	function SWEP:TranslateFOV( current_fov )
		local NowTime = UnPredictedCurTime()
		local delta = NowTime - LastTime
		LastTime = NowTime
		
		if (self.Owner:KeyDown( IN_ATTACK2 )) then
			Zoom = math.Approach(Zoom, 0.55, 1.66 * delta)
		else
			Zoom = math.Approach(Zoom, 1.00, 1.66 * delta)
		end
		
		return current_fov * Zoom
	end
	
	function SWEP:AdjustMouseSensitivity()
		return Zoom
	end
	
	local crosshair = Material( "vdm/gecross" )
	local cr_size = 32
	local cr_scale = 3
	
	local midPointX = ScrW()*0.5
	local midPointY = ScrH()*0.5
	
	function SWEP:DrawHUDBackground()
		if (Zoom >= 1.0) then return end
		
		surface.SetDrawColor( 255, 255, 255, 128 )
		surface.SetMaterial( crosshair )
		
		local crosshair_size = cr_size * cr_scale
		
		surface.DrawTexturedRect( midPointX - (crosshair_size/2), midPointY - (crosshair_size/2), crosshair_size, crosshair_size )
	end
end

function SWEP:Initialize()
	self:SetHoldType("ar2")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "BurstCount")
	self:NetworkVar("Bool", 0, "AutoReload")
	self:NetworkVar("Float", 0, "FiredTime")
end

function SWEP:Reload()
	if ( self.Owner:KeyDown(IN_ATTACK) ) then return false end
	
	if ( self:Clip1() >= self.Primary.ClipSize || self:Ammo1() <= 0 ) then return false end
	
	local burstCount = self:GetBurstCount() + 2
	
	if ( CurTime() <= (self:GetNextPrimaryFire() + (burstCount * self.Primary.FireDelay)) ) then return false end
	
	if ( SERVER ) then
		self:SetBurstCount( 0 )
		self:SetAutoReload( false )
		self:SetFiredTime( 0 )
	end
	
	self:EmitSound( "Vol_GoldenEye.Reload" )
	self:DefaultReload( ACT_VM_RELOAD )
end

SWEP.BurstAmount = 3

function SWEP:Think()
	local burstCount = self:GetBurstCount()
	
	-- and not self.Owner:KeyDown(IN_ATTACK)
	if ( burstCount < self.BurstAmount and burstCount > 0 and CurTime() > self:GetNextPrimaryFire() ) then
		
		if ( CurTime() > (self:GetNextPrimaryFire() + ((burstCount-1) * self.Primary.FireDelay)) ) then
			
			if ( self:Clip1() > 0 ) then
				self:CalledAttack()
			end
			
			self:SetBurstCount( burstCount + 1 )
		end
		
		if ( self:GetBurstCount() >= self.BurstAmount ) then
			self:SetBurstCount( 0 )
		end
	end
	
	local fireTime = self:GetFiredTime()
	burstCount = self:GetBurstCount()
	
	if ( CurTime() >= (fireTime + (self.Primary.FireDelay * 0.5)) and fireTime > 0 and not self.Owner:KeyDown( IN_ATTACK2 ) and burstCount < self.BurstAmount and burstCount > 0 ) then
		self:EmitSound( "Vol_GE_KF7.Single" )
		self:SetFiredTime( 0 )
	end
	
	if ( self:GetAutoReload() and self:Clip1() <= 0 and self:Ammo1() > 0 and not self.Owner:KeyDown(IN_ATTACK) and CurTime() > (self:GetNextPrimaryFire() + self.Primary.FireDelay) ) then
		self:Reload()
	end
end

function SWEP:Deploy()
	self:EmitSound( Sound("Vol_GoldenEye_Weapon.Switch") )
	
	if ( SERVER ) then
		self:SetBurstCount( 0 )
		self:SetAutoReload( false )
		self:SetFiredTime( 0 )
	end
	
	return true
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanPrimaryAttack()
	if ( self:Clip1() <= 0 ) then
		self:EmitSound( Sound("Vol_GE_Empty.Single") )
		
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
		
		self:SetAutoReload( true )
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

-- Will have to make sure this has lag compensation
function SWEP:CalledAttack()
	if ( CLIENT and game.SinglePlayer() ) then return end-- This fixs singleplayer repeating shit
	
	self:EmitSound( "Vol_GE_KF7.Single" )
	
	if ( IsValid(self.Owner) ) then
		self.Owner:LagCompensation( true )--DO IT
		
		local spread = 0.025
		if (self.Owner:KeyDown( IN_ATTACK2 )) then spread = 0.008 end
		
		self:ShootBullet( 19, 1, spread )
		
		self.Owner:LagCompensation( false )--DONE IT
		
		--self.Owner:VRecoil( -0.35, -0.0 )
	end
	
	self:TakePrimaryAmmo( 1 )
	
	self:ShootEffects()
	
	self:SetFiredTime( CurTime() )
	
	if ( self:Clip1() <= 0 ) then
		self:SetAutoReload( true )
	end
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	if ( self:GetBurstCount() > 1 ) then
		return
	end
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	
	self:CalledAttack()
	
	if ( not self.Owner:KeyDown( IN_ATTACK2 ) ) then
		self:SetBurstCount( 1 )--Starts burst when non zero!
	end
end

function SWEP:SecondaryAttack()
	--asd
end

function SWEP:BulletBack(attacker, tr, dmginfo, bullet)
	if ( tr.HitSky  ) then return end
	
	if ( tr.MatType == MAT_SLOSH or tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH ) then return end
	
	if ( SERVER and IsFirstTimePredicted() ) then
		sound.Play( Sound("Vol_GE_Ricochet.Single"), tr.HitPos )
	end
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = tracer || 1
	bullet.Force = force || 4
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	--Can make the ammotype one thing, so bullets can still appear and shit
	
	bullet.TracerName = "tracer_vol_goldeneye"
	
	bullet.Callback = function (attacker, tr, dmginfo)
		self:BulletBack(attacker, tr, dmginfo, bullet)
	end
	
	self.Owner:FireBullets( bullet )
end

function SWEP:DoImpactEffect( tr, nDamageType )
	--[[if ( tr.HitSky ) then return false end
	
	local ed = EffectData()
	ed:SetOrigin( tr.HitPos )
	ed:SetNormal( tr.HitNormal )
	ed:SetScale( 1.3 )
	ed:SetMagnitude( 1.3 )
	ed:SetRadius( 1.0 )
	util.Effect( "ElectricSpark", ed )]]
	
	return false
end