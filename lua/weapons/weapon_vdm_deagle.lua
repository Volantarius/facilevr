SWEP.Base = "weapon_vdm_base"

SWEP.PrintName 	= "Super Eagle"
SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"

SWEP.Spawnable = true

SWEP.Primary.ClipSize 		= 9
SWEP.Primary.DefaultClip 	= 9
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "357"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

if CLIENT then
	SWEP.ViewModelFOV = 54
	SWEP.UseHands = true
	
	killicon.Add( "weapon_vdm_deagle", "killicons/deagle", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/deagle" )
	SWEP.WepSelectIconSquare = true
	
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.068 )
	
	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end
	
	self:EmitSound( "Vol_MaxPayne_Deagle.Single" )
	
	self:ShootBullet( 32, 1, 0.012, self.Primary.Ammo, 99 )
	
	self:TakePrimaryAmmo( 1 )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self:ShootEffects()
	
	self.Owner:VRecoil( -2.70, -0.05 )
end

function SWEP:BulletBack(attacker, tr, dmginfo, bullet, num)
	if ( CLIENT ) then return end
	if ( num >= 10 ) then return end
	if ( not tr.Hit or tr.HitSky or tr.StartSolid ) then return end
	
	local dot = tr.Normal:Dot(tr.HitNormal)
	
	local reflection = (-2 * dot * tr.HitNormal) + tr.Normal
	
	local bullet2 = bullet
	
	bullet2.Callback = function (attacker2, tr2, dmginfo2)
		util.ParticleTracer(bullet2.TracerName, tr.HitPos, tr2.HitPos, true)
		
		self:BulletBack(attacker, tr2, dmginfo, bullet2, num + 1)
	end
	
	bullet2.Src = tr.HitPos
	bullet2.Dir = reflection
	bullet2.Tracer = 0
	bullet2.Spread = Vector( 0.01, 0.01, 0 )
	
	-- Really dumb to do this way
	timer.Simple( (tr.Fraction * 4096) / 900, function()
		--self.Owner:FireBullets( bullet2, false )
		self:FireBullets( bullet2, false )
		
		sound.Play( Sound("Vol_New_Ricochet.Single"), tr.HitPos + tr.HitNormal )
		
	end )
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	--bullet.Dir = (self.Owner:GetAimVector():Angle() + self.Owner:GetViewPunchAngles()):Forward()
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = tracer || 1
	bullet.Force = force || 1
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	
	--bullet.TracerName = "tracer_vol_timesplit"
	--bullet.TracerName = "tracer_vol_incin"
	--bullet.TracerName = "tracer_vol_lazer_green"
	bullet.TracerName = "tracer_vol_goldeneye"
	
	bullet.Callback = function (attacker, tr, dmginfo)
		self:BulletBack(attacker, tr, dmginfo, bullet, 0)
	end
	
	self.Owner:FireBullets( bullet )
end