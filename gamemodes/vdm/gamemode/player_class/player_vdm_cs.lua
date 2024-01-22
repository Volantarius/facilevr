AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "CS Class"

PLAYER.Info					= [[Used in CSS styled gamemodes.]]

PLAYER.WalkSpeed 			= 250
PLAYER.RunSpeed 			= 250

PLAYER.DuckSpeed			= 0.45
PLAYER.UnDuckSpeed			= 0.216

PLAYER.DropWeaponOnDie		= true

function PLAYER:Loadout()
	local ply = self.Player
	ply:RemoveAllAmmo()
	
	ply:Give( "weapon_knife" )
	
	GAMEMODE:LoadDeathmatchLoadout( ply )
	
	ply:SwitchToDefaultWeapon()
end

player_manager.RegisterClass( "player_vdm_cs", PLAYER, "player_vdm" )