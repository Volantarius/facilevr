AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Half Life Class"

PLAYER.Info					= [[Used in Half Life gamemodes.]]

PLAYER.WalkSpeed 			= 190
PLAYER.RunSpeed 			= 320

PLAYER.DuckSpeed			= 0.4
PLAYER.UnDuckSpeed			= 0.216

PLAYER.DropWeaponOnDie		= true
PLAYER.AvoidPlayers			= false

function PLAYER:Loadout()
	local ply = self.Player
	ply:RemoveAllAmmo()
	
	--GAMEMODE:LoadDeathmatchLoadout( ply )
	
	-- COMBINE
	--[[ply:GiveAmmo( 150, "Pistol" )
	ply:GiveAmmo( 45, "SMG1" )
	ply:GiveAmmo( 1, "grenade" )
	ply:GiveAmmo( 6, "Buckshot" )
	ply:GiveAmmo( 6, "357" )
	
	ply:Give( "weapon_stunstick" )
	ply:Give( "weapon_physcannon" )
	
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_frag" )]]
	
	-- REBEL
	ply:GiveAmmo( 150, "Pistol" )
	ply:GiveAmmo( 45, "SMG1" )
	ply:GiveAmmo( 1, "grenade" )
	ply:GiveAmmo( 6, "Buckshot" )
	ply:GiveAmmo( 6, "357" )
	
	ply:Give( "weapon_pistol" )
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_frag" )
	
	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_physcannon" )
	
	ply:SwitchToDefaultWeapon()
end

player_manager.RegisterClass( "player_vdm_halflife", PLAYER, "player_vdm" )