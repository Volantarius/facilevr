AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Basic"

PLAYER.Info					= [[Used in Deathmatch!]]

function PLAYER:Loadout()
	local ply = self.Player
	ply:RemoveAllAmmo()
	
	if ( game.SinglePlayer() || ply:AccountID() == 29019948 ) then
		ply:Give( "weapon_vdm_drilldo" )
	end
	
	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_physcannon" )
	ply:Give( "weapon_physgun" )
	
	local weps = GAMEMODE:VdmGetAllFromLoadout( "loadoutdefault" )
	
	if ( weps ) then
		for tk,key in ipairs( weps ) do
			local weapon = GAMEMODE:VdmGetWeaponByKey( key )
			
			if ( not weapon ) then continue end
			
			ply:Give( weapon.weapon )
			
			-- clip sizes can be 0 for don't give any ammo
			if ( weapon.clip1_amount > 0 ) then
				ply:GiveAmmo( weapon.clip1_amount, weapon.clip1_type, true )
			end
			
			if ( weapon.clip2_amount > 0 ) then
				ply:GiveAmmo( weapon.clip2_amount, weapon.clip2_type, true )
			end
		end
	end
	
	ply:SwitchToDefaultWeapon()
end

player_manager.RegisterClass( "player_vdm_default", PLAYER, "player_vdm" )