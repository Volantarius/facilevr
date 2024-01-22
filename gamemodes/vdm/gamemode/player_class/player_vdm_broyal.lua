AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Battler"

PLAYER.Info					= [[One random weapon. Used in Battle Royal!]]

function PLAYER:Loadout()
	local ply = self.Player
	ply:RemoveAllAmmo()
	
	local wepTbl = GAMEMODE:VdmGetRandomWeaponCurrentLoadout()
	
	ply:Give( wepTbl.weapon )
	
	if ( wepTbl.clip1_amount > 0 ) then
		ply:GiveAmmo( wepTbl.clip1_amount, wepTbl.clip1_type, true )
	end
	
	if ( wepTbl.clip2_amount > 0 ) then
		ply:GiveAmmo( wepTbl.clip2_amount, wepTbl.clip2_type, true )
	end
	
	ply:SelectWeapon( wepTbl.weapon )
end

player_manager.RegisterClass( "player_vdm_broyal", PLAYER, "player_vdm" )