SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 15
SWEP.Primary.DefaultClip 	= 15
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "AR2"
SWEP.Primary.FireDelay 		= 0.15

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "Lazer Dance"
	
	SWEP.ViewModelFOV = 54
	SWEP.ViewModelFlip = false
	
	SWEP.UseHands = true
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	
	killicon.Add( "weapon_vdm_lazer", "killicons/famas", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/famas" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 0, 255, 0, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 30
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide, wide * 0.5, 1, 0, 0, 1 )
	end
	
	--[[function SWEP:FireAnimationEvent( pos, ang, event, options )
		if ( event == 5001 or event == 5011 or event == 5021 or event == 5031 ) then
			local data = EffectData()
			data:SetFlags( 0 )
			data:SetEntity( self.Owner:GetViewModel() )
			data:SetAttachment( math.floor( ( event - 4991 ) / 10 ) )
			data:SetScale( 0.6 ) -- Works for CS flashs, need to do for custom CSS guns
			util.Effect( "StriderMuzzleFlash", data )
			
			return true
		end
	end]]
end

function SWEP:Initialize()
	self:SetHoldType( "ar2" )
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
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
	return false
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:EmitSound( "NPC_Sniper.FireBullet" )
	
	self:ShootBullet( 32, 1, 0.0, self.Primary.Ammo, 25.0 )
	
	self:ShootEffects()
	
	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	
	-- Causes issues lol
	if ( IsValid(self.Owner) ) then
		--self.Owner:VRecoil( -1.00, -0.22 )
		
		self.Owner:SetVelocity( self.Owner:GetAimVector() * -400 )
	end
end

function SWEP:BulletBack(attacker, tr, dmginfo, bullet)
	if ( SERVER && IsValid(tr.Entity) ) then
		dmginfo:SetDamageType( bit.bor(dmginfo:GetDamageType(), DMG_REMOVENORAGDOLL) )
		
		dmginfo:SetDamageCustom( 256 )--Derezzed killeffects
	end
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = tracer || 1
	bullet.Force = force || 1
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	
	bullet.TracerName = "tracer_vol_lazer_green"
	
	bullet.Callback = function (attacker, tr, dmginfo)
		self:BulletBack(attacker, tr, dmginfo, bullet)
	end
	
	self.Owner:FireBullets( bullet )
end

--[[function SWEP:DoImpactEffect( tr, nDamageType )
	if ( tr.HitSky ) then return false end
	
	local ed = EffectData()
	ed:SetOrigin( tr.HitPos )
	ed:SetNormal( tr.HitNormal )
	util.Effect( "impact_vdm_pixels", ed )
end]]