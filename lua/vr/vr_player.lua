local GM = gmod.GetGamemode()

if ( !GM ) then
	ErrorNoHalt( "[VR]", "Could not redefine gamemode!" )
	return
end

local LocalPlayer, LocalToWorld, WorldToLocal = LocalPlayer, LocalToWorld, WorldToLocal

local p = LocalPlayer()

--[[
	Inverse Kinematics
	
	We want the player to lean forwards for the headset being lower than intended.
	We need to also allow scaling of the player.
]]

function GM:VR_UpdatePlayer( data )
end

function GM:VR_DrawPlayer( data )
end

function GM:VR_StateChangedPlayer( data )
	-- modelname, state
end

function GM:VR_BoneCallBack( e, bone_count )
	
end