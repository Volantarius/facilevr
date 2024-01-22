AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Death"

PLAYER.Info					= [[Used in Deathrun!]]

PLAYER.WalkSpeed 			= 250
PLAYER.RunSpeed 			= 250

PLAYER.DuckSpeed			= 0.45
PLAYER.UnDuckSpeed			= 0.216

PLAYER.DropWeaponOnDie		= false
PLAYER.TeammateNoCollide	= true
PLAYER.AvoidPlayers			= false

local lolmodel = Model( "models/player/death.mdl"  )

function PLAYER:SetModel()
	self.Player:SetModel( lolmodel )
end

function PLAYER:Loadout()
	local ply = self.Player
	ply:RemoveAllAmmo()
	
	ply:Give( "weapon_vdm_sythe" )
	
	ply:SetBloodColor( DONT_BLEED )
end

player_manager.RegisterClass( "player_vdm_death", PLAYER, "player_vdm" )