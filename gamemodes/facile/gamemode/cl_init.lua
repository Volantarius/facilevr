include( "shared.lua" )

include( "cl_fahud.lua" )
include( "cl_voting.lua" )
include( "cl_deathnotice.lua" )
include( "cl_interactions.lua" )
include( "cl_pickteam.lua" )
include( "cl_targetid.lua" )

-- Remove loads of fluff
hook.Remove( "HUDPaint", "PlayerOptionDraw" )
hook.Remove( "PlayerBindPress", "PlayerOptionInput" )
hook.Remove( "DrawOverlay", "DragNDropPaint" )
hook.Remove( "Think", "DragNDropThink" )

CreateClientConVar( "cl_spec_mode", "5", true, true, nil, 3, 6 )

CreateClientConVar( "cl_bhopauto", "0", true, true, nil, 0, 1 )
CreateClientConVar( "cl_bhoptraining", "0", true, true, nil, 0, 1 )
CreateClientConVar( "cl_bhopvr", "0", true, true, nil, 0, 1 )

CreateClientConVar( "cl_vrlaser", "0", true, true, nil, 0, 1 )

convar_autostart_vr = CreateClientConVar( "cl_favr_autostart", "0", true, true, nil, 0, 1 )
--convar_autostart_vr = CreateConVar( "cl_favr_autostart", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, nil, 0, 1 )

surface.CreateFont( "DermaVRDefault", {
	font		= "Roboto",
	size		= 26,
	weight		= 800
} )

surface.CreateFont( "DermaVRMedium", {
	font		= "Roboto",
	size		= 16,
	weight		= 800
} )

surface.CreateFont( "DermaVRLarge", {
	font		= "Roboto",
	size		= 64,
	weight		= 800
} )

-- ########################
-- LocalPlayer is infact valid from this point
-- ########################
function GM:InitPostEntity()
	local vr_autostart = convar_autostart_vr:GetBool()
	
	-- Request the server to start VR
	if ( vr_autostart && !VR_MODE ) then
		timer.Simple( 1, function()
			net.Start("facile_requeststate")
				net.WriteUInt( 100, 32 )
			net.SendToServer()
		end )
		
		return
	end
	
	if ( !vr_autostart ) then
		timer.Simple( 2, function() GAMEMODE:ShowTeam() end )
	end
end

local FaFlashlight = ProjectedTexture()
local FaFlashlight_enabled = false

local function UpdateFacileFlashlight()
	FaFlashlight = ProjectedTexture()
	
	FaFlashlight:SetTexture( "effects/flashlight001" )
	FaFlashlight:SetFarZ( 1300 )
	FaFlashlight:SetQuadraticAttenuation( 100 )
	FaFlashlight:SetLinearAttenuation( 0 )
	FaFlashlight:SetConstantAttenuation( 0 )
	FaFlashlight:SetFOV( 60 )
	FaFlashlight:SetBrightness( 0 )-- SET TO 100 when in use
	FaFlashlight:SetColor( Color(255, 255, 255, 255) )
	FaFlashlight:Update()
end

-- This is updated whenever the player's alive state has changed
function GM:RecievePlayerState( value )

	--GAMEMODE:HUDNeedsUpdate( value )
	hook.Call( "HUDNeedsUpdate", GAMEMODE, value )

	-- Checks if player has VR
	GAMEMODE:PlayerUpdateVR( value )
	
	-- Custom flashlights!
	if ( IsValid( FaFlashlight ) ) then
		FaFlashlight:Remove()
		UpdateFacileFlashlight()
	else
		UpdateFacileFlashlight()
	end
	
	if ( value == 2 ) then
		FaFlashlight:SetBrightness( 0 )
		FaFlashlight:Update()
		
		FaFlashlight_enabled = false
	end
	
	if ( value == 3 ) then
		FaFlashlight:SetBrightness( 100 )
		
		FaFlashlight_enabled = true
	end
	
	-- Show Teams
	if ( value == 50 ) then
		GAMEMODE:ShowTeam()
	end
	
end

-- Keep this local and then call the gamemode
local function RecievePlayerStateLocal( len )
	local value = net.ReadUInt(32)

	GAMEMODE:RecievePlayerState( value )
end

net.Receive( "facile_playerstate", RecievePlayerStateLocal )

function GM:OnSpawnMenuOpen()
	-- Need to make this toggable, or just leave this in the contextmenu idk
	--[[local faDsk = list.Get( "FacileDesktopWindows" )

	local newv = faDsk["FacileLoadoutMenu"]

	if (newv) then
		local buymenu = vgui.Create( "DFrame" )

		buymenu:SetBackgroundBlur( true )

		buymenu:SetSize( newv.width, newv.height )
		buymenu:SetTitle( newv.title )
		buymenu:Center()

		newv.init( nil, buymenu )

		buymenu:MakePopup()
	end]]
end

local cock_trace = {
	mins = Vector(1,1,1) * -16,
	maxs = Vector(1,1,1) * 16,
	mask = bit.bor( MASK_SHOT ),
	collision_group = COLLISION_GROUP_DEBRIS
}

function GM:CalcView( pl, origin, angles, fov, znear, zfar )
	local Vehicle	= pl:GetVehicle()
	local Weapon	= pl:GetActiveWeapon()
	
	local view = {
		["origin"] = origin,
		["angles"] = angles,
		["fov"] = fov,
		["znear"] = znear,
		["zfar"] = zfar,
		["drawviewer"] = false,
	}
	
	if ( IsValid( Vehicle ) ) then return hook.Run( "CalcVehicleView", Vehicle, pl, view ) end

	if ( drive.CalcView( pl, view ) ) then return view end
	
	player_manager.RunClass( pl, "CalcView", view )
	
	-- Give the active weapon a go at changing the view
	if ( IsValid( Weapon ) ) then
		
		local func = Weapon.CalcView
		if ( func ) then
			local origin, angles, fov = func( Weapon, pl, Vector( view.origin ), Angle( view.angles ), view.fov ) -- Note: Constructor to copy the object so the child function can't edit it.
			view.origin, view.angles, view.fov = origin or view.origin, angles or view.angles, fov or view.fov
		end
		
	end
	
	local alive = pl:Alive()
	
	if ( alive && IsValid( FaFlashlight ) && FaFlashlight_enabled ) then
		--local eyepos = p:EyePos()
		--local eyeang = p:EyeAngles()
		
		local right = angles:Right()
		local up = angles:Up()
		local forward = angles:Forward()
		
		local new_origin = (right * 5) + (forward * -2) + (up * 10)
		
		local end_pos = new_origin + origin + (forward * 300)
		
		cock_trace.start = new_origin + origin
		cock_trace.endpos = end_pos
		cock_trace.filter = pl
		
		local tr = util.TraceHull( cock_trace )
		
		local dlight = DynamicLight( pl:EntIndex() )
		
		local hitpos = end_pos + (forward * -16)
		
		if ( tr.Hit ) then
			cock_trace.start = tr.HitPos + (forward * -16)
			cock_trace.endpos = tr.HitPos
			
			hitpos = tr.HitPos + (forward * -16)
		end
		
		dlight.pos = hitpos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 0
		dlight.decay = 100
		dlight.size = 256
		dlight.dietime = CurTime() + 0.01
		
		FaFlashlight:SetPos( new_origin + origin + (forward * 12) )
		FaFlashlight:SetAngles( angles + Angle(5,2,0) )
		FaFlashlight:Update()
	end
	
	return view
end

function GM:HUDPaint()

	--hook.Run( "HUDDrawTargetID" )-- Fuck this for now until I figure out a good vgui solution
	hook.Run( "HUDDrawPickupHistory" )

end

-- This is to send the server to run a command
function GM:PlayerBindPress( pl, bind, down )

	-- Redirect binds to the spectate system

	if ( pl:Alive() ) then return false end

	local mode = pl:GetObserverMode()

	if ( mode > OBS_MODE_NONE && down ) then

		if ( bind == "+jump" ) then RunConsoleCommand( "spec_mode" ) end
		if ( bind == "+attack" ) then RunConsoleCommand( "spec_next" ) end
		if ( bind == "+attack2" ) then RunConsoleCommand( "spec_prev" ) end

	end

	return false

end

-- A way to make the server force weapon switch correctly
local function FASwitchWeapon( len )
	local class = net.ReadString()

	local ply = LocalPlayer()

	if ( !IsValid(ply) || !ply:Alive() ) then return end

	local wep = ply:GetWeapon( class )

	if ( wep && IsValid( wep ) ) then
		input.SelectWeapon( wep )
	end
end

net.Receive( "facile_switchweapon", FASwitchWeapon )

--
-- Also! We don't need the fire vector, we already have this from setting the view angles in StartCommand
local favr_fire_pos = CreateConVar( "favr_fire_pos", "0.0 0.0 0.0", { FCVAR_USERINFO, FCVAR_DONTRECORD } )
local favr_fire_ang = CreateConVar( "favr_fire_ang", "0.0 0.0 0.0", { FCVAR_USERINFO, FCVAR_DONTRECORD } )
local favr_fire_vec = CreateConVar( "favr_fire_vec", "0.0 0.0 0.0", { FCVAR_USERINFO, FCVAR_DONTRECORD } )
local favr_off_pos = CreateConVar( "favr_off_pos", "0.0 0.0 0.0", { FCVAR_USERINFO, FCVAR_DONTRECORD } )
local favr_off_ang = CreateConVar( "favr_off_ang", "0.0 0.0 0.0", { FCVAR_USERINFO, FCVAR_DONTRECORD } )
local favr_off_vec = CreateConVar( "favr_off_vec", "0.0 0.0 0.0", { FCVAR_USERINFO, FCVAR_DONTRECORD } )
local favr_hmd_pos = CreateConVar( "favr_hmd_pos", "0.0 0.0 0.0", { FCVAR_USERINFO, FCVAR_DONTRECORD } )
local favr_hmd_ang = CreateConVar( "favr_hmd_ang", "0.0 0.0 0.0", { FCVAR_USERINFO, FCVAR_DONTRECORD } )
local favr_hmd_vec = CreateConVar( "favr_hmd_vec", "0.0 0.0 0.0", { FCVAR_USERINFO, FCVAR_DONTRECORD } )

local function has_vr_modules()
	local has_module = file.Exists( "lua/bin/gmcl_vrmod_win32.dll", "GAME" )

	if ( not has_module ) then
		ErrorNoHalt( "[VR]", "Could not locate VR modules!" )

		VR_MODE = nil

		return false
	end

	return true
end

local function attempt_vr()
	local has_module = has_vr_modules()
	
	print( "[VR]", "Attempting to enable vr..." )
	
	if ( VR_MODE ) then
		ErrorNoHalt( "[VR]", "Already enabled!" )
		return
	end
	
	GAMEMODE:DisableDeathNotices()
	
	-- TODO: Add commands that will change which mode to run
	
	if ( game.SinglePlayer() ) then
		--include( "vr/vr_enable_opticalillusions.lua" )
		include( "vr/vr_enable.lua" )
	else
		include( "vr/vr_enable.lua" )
	end
end

local function enable_vr()
	if ( !VR_MODE ) then
		net.Start("facile_requeststate")
			net.WriteUInt( 100, 32 )
		net.SendToServer()
	end
end

concommand.Add( "vr_enable", enable_vr )

local function enable_vr_test()
	if ( VR_MODE_TEST ) then
		ErrorNoHalt( "Already testing!" )
		return
	end

	GAMEMODE:DisableDeathNotices()

	include( "vr/vr_testing.lua" )
end

concommand.Add( "vr_enable_test", enable_vr_test )

local function shutdown_vr()

	local has_module = has_vr_modules()

end

-- Blah
function GM:PlayerAttemptVR()
	if ( !VR_MODE ) then
		attempt_vr()
	end
end

function GM:VR_SetupPanel()
	-- Placeholder
end

function GM:PlayerUpdateVR( player_state )
	-- player_state :
	-- 0 == the player has entered death state
	-- 1 == the player has just spawned alive
	
	-- Auto start VR
	-- Only allow starting of VR once the server has started its backend
	if ( player_state == 256 ) then
		GAMEMODE:PlayerAttemptVR()
	end
end

--local color_client = Color(255, 241, 122, 200)
--local color_server = Color(156, 241, 255, 200)

function GM:UpdateVRNetwork( p )
	-- Placeholder
end

function GM:FacileTick()
	local p = LocalPlayer()
	
	if ( IsValid( p ) ) then
		--UpdateUseEntity( p )
		
		GAMEMODE:UpdateVRNetwork( p )
	end
end

-- base for controller haptic setup or vr
function GM:TriggerHaptic( mode, delay, duration, frequency, amplitude )
	
end

function GM:VRShowMapMenu( value )
	
end