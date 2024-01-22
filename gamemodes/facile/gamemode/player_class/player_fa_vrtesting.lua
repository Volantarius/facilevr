AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Virtual Insanity"

PLAYER.Info = "For testing vr!"

PLAYER.WalkSpeed			= 250
PLAYER.RunSpeed				= 400

PLAYER.JumpPower			= 200

PLAYER.StartArmor			= 100

function PLAYER:Loadout()
	local p = self.Player
	
	p:RemoveAllAmmo()
	
	p:GiveAmmo( 800,	"Pistol", 		true )
	p:GiveAmmo( 800,	"SMG1", 		true )
	p:GiveAmmo( 5,		"grenade", 		true )
	p:GiveAmmo( 800,	"Buckshot", 	true )
	p:GiveAmmo( 800,	"357", 			true )
	p:GiveAmmo( 64,		"XBowBolt", 	true )
	p:GiveAmmo( 800,	"AR2AltFire", 	true )
	p:GiveAmmo( 800,	"AR2", 			true )
	p:GiveAmmo( 5,		"SMG1_Grenade", true )
	p:GiveAmmo( 800,	"AR2AltFire", 	true )
	p:GiveAmmo( 5,		"RPG_Round", 	true )
	p:GiveAmmo( 2,		"slam", 		true )
	
	p:GiveAmmo( 800,	"vdm_556mm", 	true )
	p:GiveAmmo( 800,	"vdm_556box", 	true )
	p:GiveAmmo( 800,	"vdm_762mm", 	true )
	p:GiveAmmo( 800,	"vdm_338mag", 	true )
	p:GiveAmmo( 800,	"vdm_50ae", 	true )
	p:GiveAmmo( 800,	"vdm_57mm", 	true )
	
	p:Give( "weapon_crowbar" )
	p:Give( "weapon_physcannon" )
	p:Give( "weapon_crossbow" )
	p:Give( "weapon_physgun" )
	p:Give( "weapon_vdm_fartgun" )
	p:Give( "weapon_vdmvr_pistol" )
	p:Give( "weapon_vcss_glock" )
	p:Give( "weapon_vcss_galil" )
	p:Give( "weapon_vcss_mp5" )
	
	p:Give( "weapon_vdm_lazer" )
	p:Give( "weapon_vdm_tool_destroy" )
	p:Give( "weapon_vdm_goldengun" )
	p:Give( "weapon_vdm_garand" )
	p:Give( "weapon_vcod_beretta" )
	p:Give( "weapon_vol_zerog" )
	
end

player_manager.RegisterClass( "player_fa_vr", PLAYER, "player_facile" )