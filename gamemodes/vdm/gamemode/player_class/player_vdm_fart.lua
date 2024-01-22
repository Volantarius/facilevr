AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Fart"

PLAYER.Info					= [[Load up on the beans and drop it like its hot.]]

PLAYER.WalkSpeed 			= 250
PLAYER.RunSpeed 			= 250

PLAYER.DuckSpeed			= 0.45
PLAYER.UnDuckSpeed			= 0.216

PLAYER.DropWeaponOnDie		= true

function PLAYER:Loadout()
	local ply = self.Player
	ply:RemoveAllAmmo()
	
	ply:Give( "weapon_vdm_fartgun" )
	
	ply:GiveAmmo( 170, "Pistol", true )
	
	ply:SwitchToDefaultWeapon()
end

player_manager.RegisterClass( "player_vdm_fart", PLAYER, "player_vdm" )