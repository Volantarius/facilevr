AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.PrintName = "Kinesis"
SWEP.Author = "Volantarius"
SWEP.Category = "Volantarius"

SWEP.Instructions = [[<color=230,230,150,255>Primary:</color> Possess an object.

<color=230,230,150,255>Reload:</color> Return to last object you possessed.

<color=230,230,150,255>USE:</color> Stop possessing.]]

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = nil

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
	SWEP.Slot = 5
	SWEP.SlotPos = 0
	
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
	
	function SWEP:DrawWorldModel() end
	function SWEP:DrawWorldModelTranslucent() end
end

SWEP.SndSelectDeny = Sound( "HL2Player.UseDeny" )
SWEP.SndSelectOk = Sound( "weapons/physgun_off.wav" )

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity", 0, "DrivenEnt" )
end

function SWEP:Initialize()
	self:SetHoldType( "normal" )--"magic" )
	
	self:SetDrivenEnt( nil )
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.25 )
	
	local trace = self.Owner:GetEyeTrace()
	if ( !trace.Hit ) then return end
	
	local ent = trace.Entity
	
	local class = ent:GetClass()
	
	if ( !string.find( class, "prop_physics*" ) && !string.find( class, "sent_vdm*" ) ) then return end
	--if ( !string.find( class, "prop_physics*" ) ) then return end
	if ( ent:HasSpawnFlags( SF_PHYSPROP_MOTIONDISABLED ) || ent:HasSpawnFlags( SF_PHYSPROP_PREVENT_PICKUP ) ) then return end
	
	--self.Owner:EmitSound(self.SndSelectOk)
	
	-- TODO, use our new drive or something...
	drive.PlayerStartDriving( self.Owner, ent, "drive_physical_two" )-- drive_physical_two
	
	--[[if ( engine.ActiveGamemode() == "stalker_vretta" ) then
		self.Owner:SetColor(Color(255,255,255,0))
	end]]
	
	self:SetDrivenEnt( ent )
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.25 )
	
	self.Owner:EmitSound(self.SndSelectDeny)
end

function SWEP:Reload()
	-- Make this function semi-automatic
	if ( !self.Owner:KeyPressed( IN_RELOAD ) ) then return end
	
	local ent = self:GetDrivenEnt()
	
	if ( not IsValid(ent) ) then
		self.Owner:EmitSound(self.SndSelectDeny)--MAKE LOCAL
		return
	end
	
	if ( not IsValid( ent:GetPhysicsObject() ) ) then
		if (SERVER) then
			self:SetDrivenEnt( nil )
		end
	end
	
	-- Carefully written so that the server will only override if there's no phys object
	-- If this breaks for you cause you changed it, revert the changes lol
	
	ent = self:GetDrivenEnt()
	
	if ( IsValid(ent) and not self.Owner:IsDrivingEntity() ) then
		drive.PlayerStartDriving( self.Owner, ent, "drive_physical" )
	end
end

function SWEP:Think()
	
end