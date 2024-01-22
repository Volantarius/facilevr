AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Hidden"

PLAYER.Info					= [[Used in The Hidden.]]

PLAYER.WalkSpeed			= 350
PLAYER.RunSpeed				= 350
PLAYER.CrouchedWalkSpeed	= 0.5

PLAYER.JumpPower			= 300

PLAYER.DropWeaponOnDie		= false
PLAYER.TeammateNoCollide	= true
PLAYER.AvoidPlayers			= false

PLAYER.CanUseFlashlight 	= false

PLAYER.MaxHealth			= 150
PLAYER.StartHealth			= 150

local playermodel = "models/player/soldier_stripped.mdl"

function PLAYER:SetModel()
	util.PrecacheModel( playermodel )
	self.Player:SetModel( playermodel )
end

function PLAYER:Loadout()
	local ply = self.Player
	ply:RemoveAllAmmo()
	
	ply:Give( "ph_driver" )
	
	ply:Give( "weapon_knife" )
	
	ply:SwitchToDefaultWeapon()
end

player_manager.RegisterClass( "player_vdm_hidden", PLAYER, "player_vdm" )