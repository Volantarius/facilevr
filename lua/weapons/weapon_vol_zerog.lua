AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.PrintName = "Zero Gravity"
SWEP.Author = "Volantarius"
SWEP.Category = "Volantarius"

SWEP.Instructions = [[<color=230,230,150,255>Primary:</color> Possess an object.

<color=230,230,150,255>Reload:</color> Return to last object you possessed.

<color=230,230,150,255>USE:</color> Stop possessing.]]

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel = "models/weapons/c_physcannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.ViewModelFOV = 54
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 0
	SWEP.SlotPos = 3
	
	function SWEP:PrintWeaponInfo( x, y, alpha )
		if ( self.InfoMarkup == nil ) then
			local str
			
			str = "<font=HudSelectionText>"
			str = str .. self.Instructions
			str = str .. "</font>"
			
			self.InfoMarkup = markup.Parse( str, 250 )
		end
		
		surface.SetDrawColor( 60, 60, 60, alpha )
		surface.SetTexture( self.SpeechBubbleLid )
		
		surface.DrawTexturedRect( x, y-64-5, 128, 64 )
		draw.RoundedBox( 8, x-5, y-6, 260, self.InfoMarkup:GetHeight() + 18, Color( 60, 60, 60, alpha ) )
		
		self.InfoMarkup:Draw( x+5, y+5, nil, nil, alpha )
	end
	
	--function SWEP:DrawWorldModel() end
	--function SWEP:DrawWorldModelTranslucent() end
end

SWEP.SndSelectDeny = Sound( "HL2Player.UseDeny" )
SWEP.SndSelectOk = Sound( "weapons/physgun_off.wav" )

function SWEP:SetupDataTables()
end

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

local blah_velocity = Vector()
local blah_vector = Vector()
local blah_gravity = Vector(0, 0, 8.933002) * 0.5
local blah_speed = 0
local selected_entity = nil
local selected_distance = 1024
local relative_velocity = Vector()

function SWEP:Think()
	
	local p = self.Owner
	
	if ( IsValid( p ) ) then
		
		if ( p:KeyDown( IN_ATTACK ) ) then
			local speed = 1
			
			if ( p:KeyDown( IN_SPEED ) ) then
				speed = 6
			end
			
			blah_speed = blah_speed + speed
			
			blah_speed = math.Clamp( blah_speed, 0, 400 )
			
			blah_vector = p:GetAimVector()
			
			blah_velocity = blah_vector * blah_speed
			
			local tr = p:GetEyeTrace()
			local e = tr.Entity
			
			if ( IsValid( e ) ) then
				relative_velocity = e:GetVelocity()
			end
		end
		
		if ( p:KeyPressed( IN_RELOAD ) ) then
			relative_velocity = relative_velocity * 0
			
			if ( SERVER ) then
				local tr = p:GetEyeTrace()
				local e = tr.Entity
				
				if ( IsValid( e ) ) then
					local phys = e:GetPhysicsObject()
					
					if ( IsValid(phys) ) then
						phys:SetVelocity( e:GetVelocity() + (p:GetAimVector() * 500) + blah_velocity )
					end
					
				end
			end
		end
		
		if ( p:KeyDown( IN_ATTACK2 ) ) then
			local speed = 1
			
			if ( p:KeyDown( IN_SPEED ) ) then
				speed = 6
			end
			
			blah_speed = blah_speed - speed
			
			blah_speed = math.Clamp( blah_speed, 0, 400 )
			
			blah_velocity = blah_vector * blah_speed
			
			local tr = p:GetEyeTrace()
			local e = tr.Entity
			
			if ( IsValid( e ) ) then
				relative_velocity = e:GetVelocity()
			end
		end
		
		--p:SetVelocity( ( p:GetVelocity() * -1 ) + blah_velocity + blah_gravity + relative_velocity )
		p:SetVelocity( ( p:GetVelocity() * -1 ) + blah_velocity + relative_velocity )
	end
	
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.1 )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	local p = self.Owner
	
	if ( !IsValid( p ) ) then return end
	
	p:SetAnimation( PLAYER_ATTACK1 )
	
	p:SetVelocity( p:GetAimVector() * 25 )
	
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.25 )
	
	self.Owner:EmitSound(self.SndSelectDeny)
	
	return false
end

function SWEP:Reload()
	-- Make this function semi-automatic
	if ( !self.Owner:KeyPressed( IN_RELOAD ) ) then return end
	
	self.Owner:EmitSound(self.SndSelectDeny)
	
	return false
end