AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Runner"

PLAYER.Info					= [[Used in Deathrun.]]

PLAYER.DropWeaponOnDie		= false
PLAYER.TeammateNoCollide	= true
PLAYER.AvoidPlayers			= false

function PLAYER:Loadout()
	local ply = self.Player
	ply:RemoveAllAmmo()
	
	ply:Give( "weapon_knife" )
	
	ply:SwitchToDefaultWeapon()
end

player_manager.RegisterClass( "player_vdm_runner", PLAYER, "player_vdm_cs" )