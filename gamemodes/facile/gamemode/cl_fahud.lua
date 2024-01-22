surface.CreateFont( "FacileHUD", {
	font	= "Roboto",
	size	= 17,
	weight	= 800
} )

surface.CreateFont( "FacileHUDLarge", {
	font	= "Roboto Cn",
	size	= 54,
	weight	= 100,
	additive = true
} )

local convar_record = CreateClientConVar( "cl_bhop_speedrecord", "0", true, true, nil, nil, nil )
local convar_show = CreateClientConVar( "cl_bhop_showups", "0", true, true, nil, 0, 1 )

local g_alive = false

-- Shit breaks on reload
local timerLbl
local bottomLbl

local function CreateExampleCountdown( parent )
	parent:SetAlignment( 8 )
	
	local baselbl = parent:Add( "DLabel" )
	baselbl:SetText( "" )
	baselbl:SetSize( 256, 54+20 )
	
	timerLbl = baselbl:Add( "DLabel" )
	timerLbl:Dock( TOP )
	timerLbl:SetTall( 54 )
	timerLbl:SetFont( "FacileHUDLarge" )
	timerLbl:SetText( "00:00" )
	timerLbl:SetTextColor( Color(255, 236, 12) )
	timerLbl:SetContentAlignment( 5 )
	timerLbl.timerFuture = GetGlobalFloat( "FacileTimer", false )
	
	bottomLbl = baselbl:Add( "DLabel" )
	bottomLbl:Dock( BOTTOM )
	bottomLbl:SetTall( 20 )
	bottomLbl:SetFont( "FacileHUD" )
	bottomLbl:SetText( GetGlobalString( "FacileTimerMsg", "" ) )
	bottomLbl:SetTextColor( color_white )
	bottomLbl:SetContentAlignment( 5 )
	
	parent:InvalidateLayout( true )
	
	-- I think is is absolutely destroying the cpu....
	-- HAVE GOT TO FUCKING LIMIT THIS SHIT
	timerLbl.Think = function( self )
		if ( self.timerFuture == false ) then return end
		
		local diff = self.timerFuture - CurTime()
		local minutes = math.floor(diff / 60)
		
		if (minutes < 0) then
			minutes = 0
		end
		
		local seconds = math.floor(diff - (60 * minutes))
		
		if (seconds < 0) then
			seconds = 0
		end
		
		if (seconds < 10) then seconds = "0"..seconds end
		
		if (minutes < 10) then minutes = "0"..minutes end
		
		self:SetText( minutes..":"..seconds )
	end
end

local function faUpdateTimer( value, msg )
	
	if (not IsValid(timerLbl)) then return end
	
	if ( msg ) then
		bottomLbl:SetText( msg )
	end
	
	if ( value == -1 ) then
		timerLbl:SetText( "--:--" )
		timerLbl.timerFuture = false
		return
	end
	
	if ( value ~= -2 ) then
		timerLbl.timerFuture = value
	end
end

local function CreateSpeedCounter( parent )
	parent:SetAlignment( 2 )
	
	local baselbl = parent:Add( "DLabel" )
	baselbl:SetText( "" )
	baselbl:SetSize( 256, 54+20 )
	
	local speedLbl = baselbl:Add( "DLabel" )
	speedLbl:Dock( TOP )
	speedLbl:SetTall( 54 )
	speedLbl:SetFont( "FacileHUDLarge" )
	speedLbl:SetText( "0" )
	speedLbl:SetTextColor( Color(255, 236, 12) )
	speedLbl:SetContentAlignment( 5 )
	
	local bottomLbl = baselbl:Add( "DLabel" )
	bottomLbl:Dock( BOTTOM )
	bottomLbl:SetTall( 20 )
	bottomLbl:SetFont( "FacileHUD" )
	bottomLbl:SetText( "0" )
	bottomLbl:SetTextColor( color_white )
	bottomLbl:SetContentAlignment( 5 )
	
	parent:InvalidateLayout( true )
	
	-- I think is is absolutely destroying the cpu....
	-- HAVE GOT TO FUCKING LIMIT THIS SHIT
	speedLbl.Think = function( self )
		local p = LocalPlayer()
		local v = p:GetVelocity()
		
		local speed = math.Round(v:Length() * 10) * 0.1
		
		local current_record = math.Round(convar_record:GetFloat() * 10) * 0.1
		
		local speed_str = Format( "%06.1f", speed )
		
		self:SetText( speed_str )
		
		if ( g_alive && speed > current_record ) then
			convar_record:SetFloat( speed )
		end
		
		bottomLbl:SetText( current_record )
	end
end

-- @NOTE: JESUS FUCKING CHRIST THIS DESTROYS FRAME RATE................ WHAT IN THE FUCK

local exampleTimerPnl
local speedPnl

local function CreateHUD()
	exampleTimerPnl = vgui.Create( "FaHUDPanel" )
	
	CreateExampleCountdown( exampleTimerPnl )
	
	-- Reload doesn't work so just scrap this for normal gameplay
	--[[exampleTimerPnl.AllowAutoRefresh = true
	
	exampleTimerPnl.PreAutoRefresh = function() exampleTimerPnl:Clear() end
	
	exampleTimerPnl.PostAutoRefresh = function()
		exampleTimerPnl:Init()
		CreateExampleCountdown( exampleTimerPnl )
	end]]
end

net.Receive( "facile_updatetimer", function(len)
	faUpdateTimer( net.ReadFloat(), net.ReadString() )
end )

function GM:HUDNeedsUpdate( value )
	local pl = LocalPlayer()
	
	if ( not IsValid(pl) ) then return end
	
	if ( value == 1 || value == 0 ) then
		g_alive = value == 1
	end
	
	local spechud_valid = IsValid( g_SpecHud )
	
	if ( spechud_valid ) then
		if ( g_alive ) then
			g_SpecHud:Hide()
		else
			g_SpecHud:Show()
		end
	end
	
	local timer_valid = IsValid( exampleTimerPnl )
	
	if ( !timer_valid && !VR_MODE ) then CreateHUD() end
	
	if ( convar_show:GetBool() && !VR_MODE ) then
		if ( !IsValid( speedPnl ) ) then
			speedPnl = vgui.Create( "FaHUDPanel" )
			
			CreateSpeedCounter( speedPnl )
		end
	else
		if ( IsValid( speedPnl ) ) then
			speedPnl:Remove()
		end
	end
	
	-- 256 is VR starting
	-- Also remove EVERYTHING FOR VR LOL
	if ( value == 256 ) then
		if ( timer_valid ) then exampleTimerPnl:Remove() end
		if ( spechud_valid ) then g_SpecHud:Remove() end
		if ( IsValid( speedPnl ) ) then speedPnl:Remove() end
	end
end