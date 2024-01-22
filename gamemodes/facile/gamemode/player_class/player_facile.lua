AddCSLuaFile()

if ( CLIENT ) then

	CreateConVar( "cl_facile_playermodel", "alyx.mdl",  { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "Set your player model in Facile")

	CreateConVar( "cl_facile_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
	CreateConVar( "cl_facile_weaponcolor", "0.30 1.80 2.10", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
	CreateConVar( "cl_facile_playerskin", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The skin to use, if the model has any" )
	CreateConVar( "cl_facile_playerbodygroups", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The bodygroups to use, if the model has any" )

	CreateConVar( "cl_facile_trail", "trails/smoke", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_trail_enabled", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_trail_add", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_trail_color", "1.00 1.00 1.00", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_trail_start", "24", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_trail_end", "24", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	
	CreateConVar( "cl_facile_loadout_weapon0", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_loadout_weapon1", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_loadout_weapon2", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_loadout_weapon3", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_loadout_weapon4", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_loadout_weapon5", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_loadout_weapon6", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_loadout_weapon7", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_loadout_weapon8", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	CreateConVar( "cl_facile_loadout_weapon9", "", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD } )
	
end

local PLAYER = {}

PLAYER.DisplayName			= "Facile Base"

PLAYER.Info					= [[Facile base player class. Use this for gamemodes deriving from Facile.]]

PLAYER.WalkSpeed			= 300
PLAYER.RunSpeed				= 400
PLAYER.CrouchedWalkSpeed	= 0.3

PLAYER.DuckSpeed			= 0.3
PLAYER.UnDuckSpeed			= 0.3

PLAYER.JumpPower			= 200

PLAYER.CanUseFlashlight		= true

PLAYER.MaxHealth			= 100
PLAYER.StartHealth			= 100
PLAYER.StartArmor			= 0

PLAYER.DropWeaponOnDie		= true
PLAYER.TeammateNoCollide	= true
PLAYER.AvoidPlayers			= true
PLAYER.UseVMHands			= true

function PLAYER:Loadout()
	
	local p = self.Player
	
	p:RemoveAllAmmo()
	
	p:GiveAmmo( 255,	"Pistol", 		true )
	p:GiveAmmo( 255,	"SMG1", 		true )
	p:GiveAmmo( 5,	"grenade", 		true )
	p:GiveAmmo( 255,	"Buckshot", 	true )
	p:GiveAmmo( 255,	"357", 			true )
	p:GiveAmmo( 64,	"XBowBolt", 	true )
	p:GiveAmmo( 255,	"AR2AltFire", 	true )
	p:GiveAmmo( 255,	"AR2", 			true )
	p:GiveAmmo( 5,	"SMG1_Grenade", true )
	p:GiveAmmo( 255,	"AR2AltFire", 	true )
	p:GiveAmmo( 5,	"RPG_Round", 	true )
	p:GiveAmmo( 2,	"slam", 		true )
	
	p:GiveAmmo( 255,	"vdm_556mm", 	true )
	p:GiveAmmo( 255,	"vdm_556box", 	true )
	p:GiveAmmo( 255,	"vdm_762mm", 	true )
	p:GiveAmmo( 255,	"vdm_338mag", 	true )
	p:GiveAmmo( 255,	"vdm_50ae", 	true )
	p:GiveAmmo( 255,	"vdm_9mm", 		true )
	p:GiveAmmo( 255,	"vdm_57mm", 	true )
	p:GiveAmmo( 255,	"vdm_45acp", 	true )
	
	p:Give( "weapon_crowbar" )
	p:Give( "weapon_stunstick" )
	p:Give( "weapon_pistol" )
	p:Give( "weapon_smg1" )
	p:Give( "weapon_frag" )
	p:Give( "weapon_physcannon" )
	p:Give( "weapon_crossbow" )
	p:Give( "weapon_shotgun" )
	p:Give( "weapon_357" )
	p:Give( "weapon_rpg" )
	p:Give( "weapon_ar2" )
	p:Give( "weapon_physgun" )
	p:Give( "weapon_slam" )
	p:Give( "weapon_bugbait" )
	p:Give( "weapon_fists" )
	p:Give( "weapon_medkit" )
	
	p:Give( "weapon_vcss_ak47" )
	p:Give( "weapon_vcss_usp" )
	p:Give( "weapon_vcss_glock" )
	p:Give( "weapon_vcss_galil" )
	p:Give( "weapon_vcss_mp5" )
	p:Give( "weapon_vcss_xm1014" )
	p:Give( "weapon_vcss_m4a1" )
	p:Give( "weapon_vcss_famas" )
	p:Give( "weapon_vcss_scout" )
	p:Give( "weapon_vcss_p90" )
	p:Give( "weapon_vdm_kf7" )
	
	p:Give( "weapon_vcod_p90" )
	p:Give( "weapon_vcod_ak47" )
	
end

local player_models = player_manager.AllValidModels()

local player_model_count = 0

for k,v in pairs( player_models ) do
	player_model_count = player_model_count + 1
end

function PLAYER:SetModel()

	local p = self.Player

	local cl_playermodel = p:GetInfo( "cl_facile_playermodel" )
	local modelname = "models/player/alyx.mdl"
	
	if ( p:IsBot() ) then
		modelname = "models/player/zombie_classic.mdl"
	else
		modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	end
	
	util.PrecacheModel( modelname )
	p:SetModel( modelname )

	local skin = p:GetInfoNum( "cl_facile_playerskin", 0 )
	p:SetSkin( skin )

	local groups = p:GetInfo( "cl_facile_playerbodygroups" )
	
	if ( groups == nil ) then groups = "" end
	
	local groups = string.Explode( " ", groups )
	
	for k = 0, p:GetNumBodyGroups() - 1 do
		p:SetBodygroup( k, tonumber( groups[ k + 1 ] ) or 0 )
	end

end

function PLAYER:Spawn()

	local p = self.Player

	local col = Vector( p:GetInfo( "cl_facile_playercolor" ) )
	
	if col:Length() == 0 then
		col = Vector( 0.8, 0.001, 0.8 )
	end
	
	p:SetPlayerColor( col )

	col = Vector( p:GetInfo( "cl_facile_weaponcolor" ) )
	
	if col:Length() == 0 then
		col = Vector( 0.8, 0.001, 0.8 )
	end
	
	p:SetWeaponColor( col )

end

function PLAYER:GetHandsModel()
	
	local p = self.Player
	
	local cl_playermodel = p:GetInfo( "cl_facile_playermodel" )
	return player_manager.TranslatePlayerHands( cl_playermodel )
	
end

player_manager.RegisterClass( "player_facile", PLAYER, "player_default" )