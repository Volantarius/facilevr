SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = "models/hlof/v_displacer.mdl"
SWEP.WorldModel = "models/hlof/w_displacer.mdl"

--[[
	ACT_VM_IDLE
	ACT_GAUSS_SPINUP
	ACT_GAUSS_SPINCYCLE
	ACT_VM_PRIMARYATTACK
	ACT_VM_DRAW
	ACT_VM_HOLSTER
]]

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= 50
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "AR2"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.PullMaxTime = 1.5

if CLIENT then
	SWEP.PrintName 	= "Displacer"
	
	SWEP.ViewModelFOV = 85
	
	SWEP.UseHands = false
	
	SWEP.Slot = 2
	SWEP.SlotPos = 9
	
	killicon.Add( "weapon_vdm_displacer", "killicons/csgo_charge", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/gravitygun" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 236, 12, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 30
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide, wide * 0.5, 1, 0, 0, 1 )
	end
	
	local MATglow  = Material( "sprites/disp_glow01" )
	local MATglow2 = Material( "sprites/disp_glow02" )
	local MATglow4 = Material( "sprites/disp_ring01" )
	
	function SWEP:PostDrawViewModel( vm, wep, ply )
		cam.Start3D(EyePos(), EyeAngles(), 85, 0, 0, ScrW(), ScrH(), nil, nil)
			local tracerPos = EyePos()
			local wepAng = vm:GetAngles()
			
			local fw = wepAng:Forward()
			local rh = wepAng:Right()
			local up = wepAng:Up()
			
			local pos = tracerPos + (fw * 4) + (rh * 0.78) + (up * -1.1)
			
			render.SetMaterial( MATglow )
			
			local size = (math.cos(UnPredictedCurTime() * 6.17) * 4) + 1
			
			render.DrawSprite( pos, size, size, Color( 0, 255, 0, 128 ) )
			
			render.SetMaterial( MATglow2 )
			
			local size2 = (math.sin(UnPredictedCurTime() * 7.9) * 2) + 3
			
			render.DrawSprite( pos, size2, size2, Color( 0, 255, 0, 255 ) )
			
			-- ////////////////////////
			
			if ( not self:GetPulledBack() ) then cam.End3D() return end
			
			local heldtime = CurTime() - (self:GetPulledTime() - 0.9)
			
			if (heldtime < 0) then cam.End3D() return end
			
			local ChargeTime = math.min( heldtime, self.PullMaxTime ) / self.PullMaxTime
			
			render.SetMaterial( MATglow4 )
			
			local size4 = (2 * ChargeTime) + 1
			
			render.DrawSprite( pos, size4, size4, Color( 255, 255, 255, 200 ) )
		cam.End3D()
		
		return false
	end
end

-- Hopefully this can be used for other things like Crossbows, and chargable things
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "PulledBack")
	self:NetworkVar("Bool", 1, "Releasing")
	
	self:NetworkVar("Bool", 2, "PulledLoop")
	
	self:NetworkVar("Float", 0, "PulledTime")
	self:NetworkVar("Float", 1, "ReleasedTime")
end

function SWEP:Initialize()
	self:SetHoldType("physgun")
end

function SWEP:Think()
	if ( self:GetReleasing() and not self:GetPulledBack() and CurTime() > (self:GetReleasedTime() + 0.0) ) then
		self:Release( CurTime() - self:GetPulledTime() )
		
		self:SetReleasing( false )
		self:SetPulledLoop( false )
	end
	
	if ( self:GetPulledBack() ) then
		if ( not self.Owner:KeyDown(IN_ATTACK) and CurTime() > self:GetPulledTime() ) then
			self:SetReleasedTime( CurTime() )
			
			self:SetPulledBack( false )
			
			self:SetReleasing( true )
		end
	end
	
	if ( not self:GetPulledLoop() and self:GetPulledBack() and CurTime() > self:GetPulledTime() ) then
		self:SendWeaponAnim( ACT_GAUSS_SPINCYCLE )
		
		self:SetPulledLoop( true )
	end
end

function SWEP:Deploy()
	if SERVER then
		self:SetPulledBack( false )
		self:SetReleasing( false )
		self:SetPulledTime( 0 )
		self:SetReleasedTime( 0 )
		
		self:SetPulledLoop( false )
	end
	
	return true
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:OnDrop()
	self:StopSound( "OF_Displacer.Loop" )-- LOOOOOP
end

function SWEP:Holster()
	self:StopSound( "OF_Displacer.Loop" )-- LOOOOOP
	return true
end

function SWEP:OnRemove()
	self:StopSound( "OF_Displacer.Loop" )-- LOOOOOP
end

function SWEP:OwnerChanged()
	self:StopSound( "OF_Displacer.Loop" )-- LOOOOOP
end

-- New pull and release mechanics
function SWEP:Release( heldtime )
	if ( CLIENT and game.SinglePlayer() ) then return end
	
	local ChargeTime = math.min( heldtime, self.PullMaxTime ) / self.PullMaxTime
	
	if (ChargeTime == 1) then
		self:EmitSound( "OF_Displacer.TeleSelf" )
	else
		self:EmitSound( "OF_Displacer.Fire" )
	end
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self:StopSound( "OF_Displacer.Loop" )-- LOOOOOP
	
	self:SetNextPrimaryFire( CurTime() + 0.20 )
	
	self:ShootPrimaryEffects()
	
	self:ShootBullet( (ChargeTime*90)+16, 1, 0.0, self.Primary.Ammo, (ChargeTime*50.0) + 10.0, ChargeTime )
	
	self:TakePrimaryAmmo( math.floor(ChargeTime*49)+1 )
	
	if ( IsValid(self.Owner) ) then
		self.Owner:ViewPunch( Angle(0, 0, 4) )
		self.Owner:VRecoil( -3 + (ChargeTime*-5.0), -3 + (ChargeTime*-2.0) )
	end
end

function SWEP:PullBack()
	self:SendWeaponAnim( ACT_GAUSS_SPINUP )
	
	self:EmitSound( "OF_Displacer.Loop" )--LOOOOP
	
	self:EmitSound( "OF_Displacer.Spin2" )--"OF_Displacer.Spin"
	
	self:SetPulledBack( true )
	
	self:SetPulledTime( CurTime() + 0.9 )
	self:SetNextPrimaryFire( CurTime() + 0.9 )
end

function SWEP:ShootPrimaryEffects()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:MuzzleFlash()
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

function SWEP:Reload()
	return false
end

-- Not sure if this does show on other computers
function SWEP:ButtBack(attacker, tr, dmginfo, bullet, chargeTime)
	sound.Play("OF_Displacer.Impact", tr.HitPos + tr.HitNormal)
	
	if (IsFirstTimePredicted() && chargeTime == 1) then
		local ed = EffectData()
		ed:SetOrigin( tr.HitPos )
		ed:SetNormal( tr.HitNormal )
		util.Effect( "impact_vol_displace_explode", ed )
		
		if ( not tr.HitSky ) then
			local bullet2 = bullet
			
			bullet2.Damage = 2
			bullet2.Src = tr.HitPos + (tr.HitNormal * 32)
			bullet2.Dir = tr.HitNormal
			bullet2.Tracer = 0
			bullet2.Spread = Vector( 0.5, 0.5, 0 )
			bullet2.Num = 19
			
			bullet2.Callback = function (attacker2, tr2, dmginfo2)
				util.ParticleTracer(bullet2.TracerName, bullet2.Src, tr2.HitPos, true)
			end
			
			self.Owner:FireBullets( bullet2 )
		end
		
		if ( IsValid(tr.Entity) && tr.Entity:IsPlayer() ) then
			dmginfo:SetDamageType( bit.bor(dmginfo:GetDamageType(), DMG_DISSOLVE) )
		else
			util.BlastDamage( self, self.Owner, tr.HitPos - tr.Normal, 128, 70 )
		end
	end
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, chargeTime )
	local bullet = {}
	bullet.Num = num_bullets
	
	bullet.Dir = self.Owner:GetAimVector()
	
	local aim = self.Owner:EyeAngles()
	
	local pos = self.Owner:GetShootPos() + (aim:Forward() * 4) + (aim:Right() * 0.78) + (aim:Up() * -1.1)
	
	bullet.Src = pos
	
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = 1
	bullet.Force = force || 1
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	
	bullet.TracerName = "tracer_vol_displace"
	
	-- Only for largely charged shots
	bullet.Callback = function (attacker, tr, dmginfo)
		self:ButtBack(attacker, tr, dmginfo, bullet, chargeTime)
	end
	
	self.Owner:FireBullets( bullet )
end

function SWEP:DoImpactEffect( tr, nDamageType )
	if ( tr.HitSky ) then return false end
	
	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos )
	effectdata:SetNormal( tr.HitNormal )
	util.Effect( "impact_vol_displace", effectdata )
	
	return true
end