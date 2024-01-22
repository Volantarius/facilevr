surface.CreateFont( "VdmNotify", {
	font	= "Saira ExtraCondensed SemiBold",
	size	= 128,
	weight	= 400
} )

surface.CreateFont( "VdmNotifySmall", {
	font	= "Saira ExtraCondensed SemiBold",
	size	= 48,
	weight	= 400,
} )

local vdmGameTypeCV = GetConVar( "sv_vdm_gametype" )

local defColor = Color( 255, 70, 70 )

local notifyHeight = ScrH() * 0.0926-- ~= 100 px on 1080
local roundNotifyOff = ScrH() * 0.3333

local function VdmRoundNotify( text, text2 )
	text = text || "DEATHMATCH"
	text2 = text2 || "SOME PICKUP SET"
	
	local NotifyPanel = vgui.Create( "DNotify" )
	NotifyPanel:SetPos( 0, 0 )
	NotifyPanel:SetSize( ScrW(), ScrH() )
	NotifyPanel:SetLife( 4 )--12 seoconds for game over stuffs
	
	local bg = vgui.Create( "DPanel", NotifyPanel )
	bg:Dock( FILL )
	bg:SetBackgroundColor(Color(0,0,0,0))
	
	local bg_middle = vgui.Create( "DPanel", bg )
	bg_middle:SetPos( 0, roundNotifyOff - (notifyHeight * 1.5) )
	bg_middle:SetSize( ScrW(), notifyHeight * 3 )
	bg_middle:SetBackgroundColor(Color(0,0,0,250))
	
	local lbl = vgui.Create( "DLabel", bg )
	lbl:SetPos( 0, roundNotifyOff - notifyHeight )
	lbl:SetSize( ScrW(), notifyHeight * 2 )
	lbl:SetText( string.upper(text) )
	lbl:SetTextColor( defColor )
	lbl:SetFont( "VdmNotify" )
	lbl:SetContentAlignment( 5 )
	
	local lbl2 = vgui.Create( "DLabel", bg )
	lbl2:SetPos( 0, roundNotifyOff + (notifyHeight * 0.5) )
	lbl2:SetSize( ScrW(), notifyHeight )
	lbl2:SetText( string.upper(text2) )
	lbl2:SetTextColor( defColor )
	lbl2:SetFont( "VdmNotifySmall" )
	lbl2:SetContentAlignment( 5 )
	
	NotifyPanel:AddItem(bg)
end
net.Receive( "vdmn_notifygame", function(len) VdmRoundNotify( net.ReadString(), net.ReadString() ) end )

local function Bloop()
	surface.PlaySound( "volantarius/chat_display_text.wav" )
end

local function PrintLoadoutChange( name, changeNow )
	if ( changeNow ) then
		
		chat.AddText( defColor, "(VDM)", color_white, " Changed loadout to ", defColor, name )
		
	else
		
		chat.AddText( defColor, "(VDM)", color_white, " Changing loadout to ", defColor, name, color_white, " next round!" )
		
	end
	Bloop()
end
net.Receive( "vdmn_loadoutchange", function(len) PrintLoadoutChange( net.ReadString(), net.ReadBool() ) end )

local function PrintGameTypeChange( name )
	local shGameInfo = table.Copy( g_VdmGameTypes[ name ] )
	
	chat.AddText( defColor, "(VDM)", color_white, " Changed game type to ", defColor, shGameInfo.PrintName, color_white, " next round!" )
	Bloop()
end
net.Receive( "vdmn_gametypechange", function(len) PrintGameTypeChange( net.ReadString() ) end )

local function GenericNotify( msg )
	chat.AddText( defColor, "(VDM) ", color_white, msg )
	Bloop()
end
net.Receive( "vdmn_genericnotify", function(len) GenericNotify( net.ReadString() ) end )