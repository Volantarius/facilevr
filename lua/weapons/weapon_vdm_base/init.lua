AddCSLuaFile( "cl_init.lua" )

AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

SWEP.Weight = 20

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

-- @Volantarius: Grab CS:S map's trick of getting ammo set on map weapons!
function SWEP:KeyValue( key, value )
	if ( key == "ammo" ) then
		self.ammo = value
	end
end

-- @Volantarius: CS:S doesn't allow salvaging weapons, but this is probably how it should work
-- @Note: Can't get this to apply for HL2 weapons.. unless I redo them
function SWEP:EquipAmmo( pl )
	if ( IsValid( pl ) && self.ammo ~= nil ) then
		pl:GiveAmmo( self.ammo, self.Primary.Ammo )
		
		self.ammo = 0
	end
end

function SWEP:Equip( pl )
end

function SWEP:OnDrop()
end

function SWEP:ShouldDropOnDie()
	return true
end