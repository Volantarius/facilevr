include( "shared.lua" )
include( "cl_viewscreen.lua" )

SWEP.Author = "Volantarius"
SWEP.Category = "Volantarius"

SWEP.Slot = 2
SWEP.SlotPos = 7

SWEP.UseHands = true

SWEP.DrawCrosshair = true

killicon.Add( "weapon_vdm_tool_base", "killicons/csgo_aug", Color(255, 255, 255, 255) )

SWEP.WepSelectIcon = surface.GetTextureID( "vgui/gmod_tool" )

function SWEP:FireAnimationEvent( pos, ang, event, options )
end

function SWEP:PrintWeaponInfo( x, y, alpha )
end

local gradient = surface.GetTextureID( "gui/gradient" )
local infoicon = surface.GetTextureID( "gui/info" )

surface.CreateFont( "GModToolName", {
	font = "Roboto Bk",
	size = 80,
	weight = 1000
} )

surface.CreateFont( "GModToolSubtitle", {
	font = "Roboto Bk",
	size = 24,
	weight = 1000
} )

surface.CreateFont( "GModToolHelp", {
	font = "Roboto Bk",
	size = 17,
	weight = 1000
} )

local ToolNameHeight = 0
local InfoBoxHeight = 0

function SWEP:DrawHUD()
	local x, y = 50, 40
	local w, h = 0, 0

	local TextTable = {}
	local QuadTable = {}

	QuadTable.texture = gradient
	QuadTable.color = Color( 10, 10, 10, 180 )

	QuadTable.x = 0
	QuadTable.y = y - 8
	QuadTable.w = 600
	QuadTable.h = ToolNameHeight - ( y - 8 )
	draw.TexturedQuad( QuadTable )

	TextTable.font = "GModToolName"
	TextTable.color = Color( 240, 240, 240, 255 )
	TextTable.pos = { x, y }
	TextTable.text = self.ToolName
	w, h = draw.TextShadow( TextTable, 2 )
	y = y + h

	TextTable.font = "GModToolSubtitle"
	TextTable.pos = { x, y }
	TextTable.text = self.Description
	w, h = draw.TextShadow( TextTable, 1 )
	y = y + h + 8

	ToolNameHeight = y

	QuadTable.y = y
	QuadTable.h = InfoBoxHeight
	QuadTable.color = Color( 0, 0, 0, 230 )
	draw.TexturedQuad( QuadTable )

	y = y + 4

	TextTable.font = "GModToolHelp"

	local h2 = 0

	for i = 1, 4, 1 do
		local mode_info = ""
		local icon = "gui/info"
		
		if (i == 1) then
			mode_info = self.info
			icon = "gui/info"
		elseif (i == 2) then
			mode_info = self.info_left
			icon = "gui/lmb.png"
		elseif (i == 3) then
			mode_info = self.info_right
			icon = "gui/rmb.png"
		elseif (i == 4) then
			mode_info = self.info_reload
			icon = "gui/r.png"
		end
		
		if ( !mode_info ) then continue end
		
		TextTable.text = mode_info
		TextTable.pos = { x + 21, y + h2 }
		
		w, h = draw.TextShadow( TextTable, 1 )

		self.Icons = self.Icons or {}
		if ( icon && !self.Icons[ icon ] ) then self.Icons[ icon ] = Material( icon ) end
		
		if ( icon && self.Icons[ icon ] && !self.Icons[ icon ]:IsError() ) then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( self.Icons[ icon ] )
			surface.DrawTexturedRect( x, y + h2, 16, 16 )
		end

		h2 = h2 + h

	end

	InfoBoxHeight = h2 + 8
end