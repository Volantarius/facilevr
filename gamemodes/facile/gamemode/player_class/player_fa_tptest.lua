AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "ThirdPerson Test"

PLAYER.Info = "For the future of really cool stuff!"

PLAYER.WalkSpeed			= 250
PLAYER.RunSpeed				= 300

PLAYER.JumpPower			= 200

PLAYER.StartArmor			= 100

-- Yay so this helps out a lot for fixing up VR's view entity system
function PLAYER:Spawn()
	local p = self.Player
	local player_pos = p:GetPos()
	
	local tp_view = p.tp_view_entity
	
	if ( !IsValid( tp_view ) ) then
		tp_view = ents.Create( "fa_thirdpersoncamera" )
		
		tp_view:SetPos( player_pos + Vector(32, 0, 0) )
		tp_view:SetAngles( Angle(0,0,0) )
		
		tp_view:Spawn()
		
		p.tp_view_entity = tp_view
		p.tp_view_entity:SetOwner( p )
	end
	
	p:SetViewEntity( tp_view )
	
	--p:SetViewEntity( p )
end

function PLAYER:Loadout()
	local p = self.Player
	
	p:RemoveAllAmmo()
	
	p:GiveAmmo( 800, "Pistol", true )
	p:GiveAmmo( 800, "SMG1", true )
	p:GiveAmmo( 5,   "grenade", true )
	p:GiveAmmo( 800, "Buckshot", true )
	p:GiveAmmo( 800, "357", true )
	p:GiveAmmo( 64,  "XBowBolt", true )
	p:GiveAmmo( 800, "AR2AltFire", true )
	p:GiveAmmo( 800, "AR2", true )
	p:GiveAmmo( 5,   "SMG1_Grenade", true )
	p:GiveAmmo( 800, "AR2AltFire", true )
	p:GiveAmmo( 5,   "RPG_Round", true )
	p:GiveAmmo( 2,   "slam", true )
	
	p:Give( "weapon_crowbar" )
	--p:Give( "weapon_stunstick" )
	p:Give( "weapon_pistol" )
	p:Give( "weapon_smg1" )
	--p:Give( "weapon_frag" )
	p:Give( "weapon_physcannon" )
	p:Give( "weapon_crossbow" )
	--p:Give( "weapon_shotgun" )
	--p:Give( "weapon_357" )
	--p:Give( "weapon_rpg" )
	p:Give( "weapon_ar2" )
	p:Give( "weapon_physgun" )
	--p:Give( "weapon_slam" )
	--p:Give( "weapon_bugbait" )
	
end

player_manager.RegisterClass( "player_fa_tptest", PLAYER, "player_facile" )